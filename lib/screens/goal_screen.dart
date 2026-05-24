import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../utils/constants.dart';

class GoalScreen extends StatefulWidget {
  const GoalScreen({super.key});

  @override
  State<GoalScreen> createState() => _GoalScreenState();
}

class _GoalScreenState extends State<GoalScreen> {
  final _itemNameController = TextEditingController();
  final _itemPriceController = TextEditingController();
  final _savedAmountController = TextEditingController();
  final _hourlyWageController = TextEditingController();
  final _formatter = NumberFormat('#,###');
  final List<Map<String, dynamic>> _goals = [];

  @override
  void dispose() {
    _itemNameController.dispose();
    _itemPriceController.dispose();
    _savedAmountController.dispose();
    _hourlyWageController.dispose();
    super.dispose();
  }

  void _showAddGoalSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('새 목표 추가', style: AppTextStyles.heading3),
            const SizedBox(height: 20),
            TextField(
              controller: _itemNameController,
              decoration: const InputDecoration(
                labelText: '사고 싶은 것',
                hintText: '예: 에어팟 프로',
                prefixIcon: Icon(Icons.shopping_bag_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _itemPriceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '가격 (원)',
                hintText: '예: 350000',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _savedAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '현재 모은 금액 (원)',
                hintText: '예: 100000',
                prefixIcon: Icon(Icons.savings_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _hourlyWageController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '시급 (원)',
                hintText: '예: 10160',
                prefixIcon: Icon(Icons.access_time),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                _addGoal();
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.secondary,
              ),
              child: const Text('목표 추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  void _addGoal() {
    final name = _itemNameController.text.trim();
    final price =
        double.tryParse(_itemPriceController.text.replaceAll(',', '')) ?? 0;
    final saved =
        double.tryParse(_savedAmountController.text.replaceAll(',', '')) ?? 0;
    final wage =
        double.tryParse(_hourlyWageController.text.replaceAll(',', '')) ?? 0;

    if (name.isEmpty || price == 0 || wage == 0) return;

    final remaining = price - saved;
    final hoursNeeded = remaining > 0 ? remaining / wage : 0;

    setState(() {
      _goals.add({
        'name': name,
        'price': price,
        'saved': saved,
        'wage': wage,
        'hoursNeeded': hoursNeeded,
        'progress': (saved / price).clamp(0.0, 1.0),
      });
      _itemNameController.clear();
      _itemPriceController.clear();
      _savedAmountController.clear();
      _hourlyWageController.clear();
    });
  }

  String _getEncouragement(double progress) {
    if (progress >= 1.0) return '🎉 목표 달성! 정말 대단해요!';
    if (progress >= 0.8) return '💪 거의 다 왔어요! 조금만 더!';
    if (progress >= 0.5) return '🔥 절반 넘었어요! 잘 하고 있어요!';
    if (progress >= 0.3) return '😊 좋아요! 계속 화이팅!';
    return '🌱 시작이 반이에요! 할 수 있어요!';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('목표 저축')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddGoalSheet,
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: _goals.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.savings_rounded,
                    size: 64,
                    color: Colors.grey.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '아직 목표가 없어요\n+ 버튼으로 목표를 추가해보세요!',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 16),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _goals.length,
              itemBuilder: (context, index) {
                final goal = _goals[index];
                final progress = goal['progress'] as double;
                final hoursNeeded = goal['hoursNeeded'] as double;
                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(goal['name'], style: AppTextStyles.heading3),
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: AppColors.grey,
                            ),
                            onPressed: () =>
                                setState(() => _goals.removeAt(index)),
                          ),
                        ],
                      ),
                      Text(
                        '목표 ${_formatter.format(goal['price'].round())}원 · 저축 ${_formatter.format(goal['saved'].round())}원',
                        style: const TextStyle(
                          color: AppColors.grey,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          minHeight: 10,
                          backgroundColor: Colors.grey.shade200,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            AppColors.secondary,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${(progress * 100).toStringAsFixed(1)}% 달성',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.secondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.secondary.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.access_time,
                              color: AppColors.secondary,
                              size: 18,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                hoursNeeded <= 0
                                    ? '목표를 달성했어요! 🎉'
                                    : '앞으로 ${hoursNeeded.toStringAsFixed(1)}시간 더 일하면 돼요!',
                                style: const TextStyle(
                                  color: Color(0xFF2D8C4E),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getEncouragement(progress),
                        style: const TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}
