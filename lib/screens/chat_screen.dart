import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../services/chat_service.dart';
import '../utils/constants.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('채팅'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.grey,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '친구 채팅'),
            Tab(text: '단체 채팅방'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [_DirectChatTab(), _GroupChatTab()],
      ),
    );
  }
}

class _DirectChatTab extends StatefulWidget {
  const _DirectChatTab();

  @override
  State<_DirectChatTab> createState() => _DirectChatTabState();
}

class _DirectChatTabState extends State<_DirectChatTab> {
  void _showAddFriendDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('친구 추가', style: AppTextStyles.heading3),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '아이디 입력',
            hintText: '상대방 아이디를 입력하세요',
            prefixIcon: Icon(Icons.alternate_email),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                final chatService = Provider.of<ChatService>(
                  context,
                  listen: false,
                );
                final myUser = authService.currentUser!;
                chatService.createDirectChat(
                  myId: myUser.uid,
                  myName: myUser.name,
                  friendId: controller.text,
                  friendName: controller.text,
                );
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('${controller.text}님과 채팅방이 생성됐어요!'),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
            child: const Text('추가'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final authService = Provider.of<AuthService>(context);
    final myId = authService.currentUser?.uid ?? '';
    final directRooms = chatService.chatRooms
        .where((r) => !r.isGroupChat && r.memberIds.contains(myId))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddFriendDialog,
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.person_add_rounded, color: Colors.white),
      ),
      body: directRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 채팅방이 없어요\n+ 버튼으로 친구를 추가해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: directRooms.length,
              itemBuilder: (context, index) {
                final room = directRooms[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                    child: Text(
                      room.name.isNotEmpty ? room.name[0].toUpperCase() : '?',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  title: Text(
                    room.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    room.lastMessage?.content ?? '메시지를 보내보세요',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          roomId: room.id,
                          roomName: room.name,
                          isGroupChat: false,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class _GroupChatTab extends StatefulWidget {
  const _GroupChatTab();

  @override
  State<_GroupChatTab> createState() => _GroupChatTabState();
}

class _GroupChatTabState extends State<_GroupChatTab> {
  void _showJoinOrCreateDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('단체 채팅방', style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.add_rounded, color: AppColors.accent),
              ),
              title: const Text('채팅방 만들기 (사장님)'),
              subtitle: const Text('새 채팅방을 만들고 코드를 공유하세요'),
              onTap: () {
                Navigator.pop(context);
                _showCreateRoomDialog();
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.login_rounded,
                  color: AppColors.primary,
                ),
              ),
              title: const Text('채팅방 참여하기 (직원)'),
              subtitle: const Text('사장님께 받은 코드로 입장하세요'),
              onTap: () {
                Navigator.pop(context);
                _showJoinRoomDialog();
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreateRoomDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('채팅방 만들기', style: AppTextStyles.heading3),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '채팅방 이름',
            hintText: '예: 스타벅스 강남점',
            prefixIcon: Icon(Icons.chat_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                final authService = Provider.of<AuthService>(
                  context,
                  listen: false,
                );
                final chatService = Provider.of<ChatService>(
                  context,
                  listen: false,
                );
                final room = chatService.createGroupChat(
                  bossId: authService.currentUser!.uid,
                  roomName: controller.text.trim(),
                );
                Navigator.pop(context);
                _showRoomCode(room.code ?? '');
              }
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
            child: const Text('만들기'),
          ),
        ],
      ),
    );
  }

  void _showRoomCode(String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('채팅방 코드', style: AppTextStyles.heading3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '직원들에게 아래 코드를 공유해주세요',
              style: TextStyle(color: AppColors.grey),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                code,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                  letterSpacing: 4,
                ),
              ),
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  void _showJoinRoomDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('채팅방 참여', style: AppTextStyles.heading3),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: '채팅방 코드',
            hintText: '6자리 코드 입력',
            prefixIcon: Icon(Icons.key_rounded),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('취소', style: TextStyle(color: AppColors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              final authService = Provider.of<AuthService>(
                context,
                listen: false,
              );
              final chatService = Provider.of<ChatService>(
                context,
                listen: false,
              );
              final success = chatService.joinChatRoom(
                code: controller.text.trim().toUpperCase(),
                userId: authService.currentUser!.uid,
              );
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(success ? '채팅방에 참여했어요!' : '올바르지 않은 코드예요'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
            child: const Text('참여'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final authService = Provider.of<AuthService>(context);
    final myId = authService.currentUser?.uid ?? '';
    final groupRooms = chatService.chatRooms
        .where((r) => r.isGroupChat && r.memberIds.contains(myId))
        .toList();

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: _showJoinOrCreateDialog,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
      body: groupRooms.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '단체 채팅방이 없어요\n사장님이라면 방을 만들고\n직원이라면 코드로 참여하세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              itemCount: groupRooms.length,
              itemBuilder: (context, index) {
                final room = groupRooms[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.accent.withValues(alpha: 0.1),
                    child: const Icon(
                      Icons.group_rounded,
                      color: AppColors.accent,
                    ),
                  ),
                  title: Text(
                    room.name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    '참여자 ${room.memberIds.length}명',
                    style: const TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  trailing: room.code != null
                      ? Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            room.code!,
                            style: const TextStyle(
                              color: AppColors.accent,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )
                      : null,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ChatRoomScreen(
                          roomId: room.id,
                          roomName: room.name,
                          isGroupChat: true,
                        ),
                      ),
                    );
                  },
                );
              },
            ),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  final String roomId;
  final String roomName;
  final bool isGroupChat;

  const ChatRoomScreen({
    super.key,
    required this.roomId,
    required this.roomName,
    required this.isGroupChat,
  });

  @override
  State<ChatRoomScreen> createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  bool _isAnonymous = false;

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    final authService = Provider.of<AuthService>(context, listen: false);
    final chatService = Provider.of<ChatService>(context, listen: false);
    final user = authService.currentUser!;

    chatService.sendMessage(
      roomId: widget.roomId,
      senderId: user.uid,
      senderName: user.name,
      content: _messageController.text.trim(),
      isAnonymous: _isAnonymous,
    );
    _messageController.clear();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final chatService = Provider.of<ChatService>(context);
    final authService = Provider.of<AuthService>(context);
    final messages = chatService.getMessages(widget.roomId);
    final myId = authService.currentUser?.uid ?? '';

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.roomName),
            if (widget.isGroupChat)
              const Text(
                '단체 채팅방',
                style: TextStyle(fontSize: 12, color: AppColors.grey),
              ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: messages.isEmpty
                ? const Center(
                    child: Text(
                      '첫 메시지를 보내보세요!',
                      style: TextStyle(color: AppColors.grey),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final msg = messages[index];
                      final isMe = msg.senderId == myId;
                      return _buildMessageBubble(msg, isMe);
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              children: [
                if (widget.isGroupChat)
                  Row(
                    children: [
                      Switch(
                        value: _isAnonymous,
                        onChanged: (v) => setState(() => _isAnonymous = v),
                        activeColor: AppColors.primary,
                      ),
                      const Text(
                        '익명으로 보내기',
                        style: TextStyle(fontSize: 13, color: AppColors.grey),
                      ),
                    ],
                  ),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _messageController,
                        decoration: InputDecoration(
                          hintText: _isAnonymous
                              ? '익명으로 메시지 보내기...'
                              : '메시지를 입력하세요...',
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: const BorderSide(
                              color: AppColors.primary,
                              width: 2,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(24),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: _sendMessage,
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage msg, bool isMe) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: isMe
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary.withValues(alpha: 0.1),
              child: Text(
                msg.isAnonymous ? '?' : msg.senderName[0].toUpperCase(),
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          Column(
            crossAxisAlignment: isMe
                ? CrossAxisAlignment.end
                : CrossAxisAlignment.start,
            children: [
              if (!isMe)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(
                    msg.isAnonymous ? '익명' : msg.senderName,
                    style: const TextStyle(fontSize: 12, color: AppColors.grey),
                  ),
                ),
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.65,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isMe ? AppColors.primary : Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: const Radius.circular(16),
                    topRight: const Radius.circular(16),
                    bottomLeft: Radius.circular(isMe ? 16 : 4),
                    bottomRight: Radius.circular(isMe ? 4 : 16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: Text(
                  msg.content,
                  style: TextStyle(
                    color: isMe ? Colors.white : AppColors.dark,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
