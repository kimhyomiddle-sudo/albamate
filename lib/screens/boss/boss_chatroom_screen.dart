import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class BossChatroomScreen extends StatelessWidget {
  const BossChatroomScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('채팅방 관리')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_rounded, size: 64, color: Colors.grey.shade300),
            const SizedBox(height: 16),
            Text(
              '채팅방을 여기서 관리할 수 있어요',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
