import 'package:flutter/material.dart';

class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  final bool isAnonymous;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isAnonymous = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'senderId': senderId,
      'senderName': senderName,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  factory ChatMessage.fromMap(Map<String, dynamic> map) {
    return ChatMessage(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      senderName: map['senderName'] ?? '',
      content: map['content'] ?? '',
      timestamp: DateTime.parse(map['timestamp']),
      isAnonymous: map['isAnonymous'] ?? false,
    );
  }
}

class ChatRoom {
  final String id;
  final String name;
  final List<String> memberIds;
  final ChatMessage? lastMessage;
  final bool isGroupChat;
  final String? code; // 사장님 채팅방 코드

  ChatRoom({
    required this.id,
    required this.name,
    required this.memberIds,
    this.lastMessage,
    this.isGroupChat = false,
    this.code,
  });
}

class ChatService extends ChangeNotifier {
  final List<ChatRoom> _chatRooms = [];
  final Map<String, List<ChatMessage>> _messages = {};

  List<ChatRoom> get chatRooms => _chatRooms;

  List<ChatMessage> getMessages(String roomId) {
    return _messages[roomId] ?? [];
  }

  // 1:1 채팅방 생성
  ChatRoom createDirectChat({
    required String myId,
    required String myName,
    required String friendId,
    required String friendName,
  }) {
    final existingRoom = _chatRooms.firstWhere(
      (r) =>
          !r.isGroupChat &&
          r.memberIds.contains(myId) &&
          r.memberIds.contains(friendId),
      orElse: () => ChatRoom(id: '', name: '', memberIds: []),
    );

    if (existingRoom.id.isNotEmpty) return existingRoom;

    final room = ChatRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: friendName,
      memberIds: [myId, friendId],
      isGroupChat: false,
    );
    _chatRooms.add(room);
    notifyListeners();
    return room;
  }

  // 사장님 채팅방 생성
  ChatRoom createGroupChat({required String bossId, required String roomName}) {
    final code = _generateCode();
    final room = ChatRoom(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: roomName,
      memberIds: [bossId],
      isGroupChat: true,
      code: code,
    );
    _chatRooms.add(room);
    notifyListeners();
    return room;
  }

  // 코드로 채팅방 참여
  bool joinChatRoom({required String code, required String userId}) {
    final index = _chatRooms.indexWhere((r) => r.code == code);
    if (index == -1) return false;

    final room = _chatRooms[index];
    if (!room.memberIds.contains(userId)) {
      final updatedRoom = ChatRoom(
        id: room.id,
        name: room.name,
        memberIds: [...room.memberIds, userId],
        isGroupChat: room.isGroupChat,
        code: room.code,
      );
      _chatRooms[index] = updatedRoom;
      notifyListeners();
    }
    return true;
  }

  // 메시지 전송
  void sendMessage({
    required String roomId,
    required String senderId,
    required String senderName,
    required String content,
    bool isAnonymous = false,
  }) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: senderId,
      senderName: isAnonymous ? '익명' : senderName,
      content: content,
      timestamp: DateTime.now(),
      isAnonymous: isAnonymous,
    );

    if (_messages[roomId] == null) {
      _messages[roomId] = [];
    }
    _messages[roomId]!.add(message);
    notifyListeners();
  }

  String _generateCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(6, (i) {
      return chars[(DateTime.now().microsecondsSinceEpoch + i * 7) %
          chars.length];
    }).join();
  }
}
