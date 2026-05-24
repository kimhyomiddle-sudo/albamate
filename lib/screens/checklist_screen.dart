import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ChecklistScreen extends StatefulWidget {
  const ChecklistScreen({super.key});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final _taskController = TextEditingController();
  final _categoryController = TextEditingController();

  final List<Map<String, dynamic>> _tasks = [
    {'title': '오픈 청소 완료', 'category': '청소', 'done': false, 'important': true},
    {'title': '재고 확인하기', 'category': '재고', 'done': false, 'important': false},
    {'title': '마감 정산', 'category': '정산', 'done': true, 'important': true},
  ];

  String _selectedCategory = '전체';
  final List<String> _categories = ['전체', '청소', '재고', '정산', '기타'];

  @override
  void dispose() {
    _taskController.dispose();
    _categoryController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredTasks {
    if (_selectedCategory == '전체') return _tasks;
    return _tasks.where((t) => t['category'] == _selectedCategory).toList();
  }

  void _showAddTaskSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('할 일 추가', style: AppTextStyles.heading3),
            const SizedBox(height: 16),
            TextField(
              controller: _taskController,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: '할 일',
                hintText: '예: 오픈 청소하기',
                prefixIcon: Icon(Icons.check_circle_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _categoryController,
              decoration: const InputDecoration(
                labelText: '카테고리 (선택)',
                hintText: '예: 청소, 재고, 정산',
                prefixIcon: Icon(Icons.label_outline),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (_taskController.text.trim().isNotEmpty) {
                  setState(() {
                    _tasks.add({
                      'title': _taskController.text.trim(),
                      'category': _categoryController.text.trim().isEmpty
                          ? '기타'
                          : _categoryController.text.trim(),
                      'done': false,
                      'important': false,
                    });
                    _taskController.clear();
                    _categoryController.clear();
                  });
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
              ),
              child: const Text('추가하기'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doneTasks = _tasks.where((t) => t['done'] == true).length;
    final totalTasks = _tasks.length;

    return Scaffold(
      appBar: AppBar(title: const Text('체크리스트')),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddTaskSheet,
        backgroundColor: AppColors.accent,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      body: Column(
        children: [
          // 진행률 카드
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.accent, Color(0xFFFFB347)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$doneTasks / $totalTasks 완료',
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: totalTasks > 0 ? doneTasks / totalTasks : 0,
                          minHeight: 8,
                          backgroundColor: Colors.white30,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  totalTasks > 0
                      ? '${(doneTasks / totalTasks * 100).toStringAsFixed(0)}%'
                      : '0%',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          // 카테고리 필터
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = category),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.accent : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.accent
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      category,
                      style: TextStyle(
                        color: isSelected ? Colors.white : AppColors.grey,
                        fontWeight: isSelected
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 13,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 12),

          // 할 일 목록
          Expanded(
            child: _filteredTasks.isEmpty
                ? Center(
                    child: Text(
                      '할 일이 없어요!',
                      style: TextStyle(color: Colors.grey.shade400),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      final task = _filteredTasks[index];
                      final realIndex = _tasks.indexOf(task);
                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: ListTile(
                          leading: GestureDetector(
                            onTap: () => setState(
                              () => _tasks[realIndex]['done'] =
                                  !_tasks[realIndex]['done'],
                            ),
                            child: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: task['done']
                                    ? AppColors.accent
                                    : Colors.transparent,
                                border: Border.all(
                                  color: task['done']
                                      ? AppColors.accent
                                      : Colors.grey.shade400,
                                  width: 2,
                                ),
                              ),
                              child: task['done']
                                  ? const Icon(
                                      Icons.check,
                                      size: 14,
                                      color: Colors.white,
                                    )
                                  : null,
                            ),
                          ),
                          title: Text(
                            task['title'],
                            style: TextStyle(
                              decoration: task['done']
                                  ? TextDecoration.lineThrough
                                  : null,
                              color: task['done']
                                  ? AppColors.grey
                                  : AppColors.dark,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          subtitle: Text(
                            task['category'],
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.grey,
                            ),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: Icon(
                                  task['important']
                                      ? Icons.star_rounded
                                      : Icons.star_border_rounded,
                                  color: task['important']
                                      ? AppColors.accent
                                      : AppColors.grey,
                                ),
                                onPressed: () => setState(
                                  () => _tasks[realIndex]['important'] =
                                      !_tasks[realIndex]['important'],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete_outline,
                                  color: AppColors.grey,
                                ),
                                onPressed: () =>
                                    setState(() => _tasks.removeAt(realIndex)),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
