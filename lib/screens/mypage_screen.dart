import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'login_screen.dart';

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('마이페이지')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 프로필 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    child: Text(
                      user?.name.isNotEmpty == true
                          ? user!.name[0].toUpperCase()
                          : '?',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user?.name ?? '',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        '@${user?.userId ?? ''}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                      Text(
                        user?.email ?? '',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.white60,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 개인정보 수정
            _buildSectionTitle('개인정보'),
            _buildCard(
              child: Column(
                children: [
                  _buildInfoRow('이름', user?.name ?? ''),
                  _buildInfoRow('아이디', '@${user?.userId ?? ''}'),
                  _buildInfoRow('이메일', user?.email ?? ''),
                  _buildInfoRow('나이', user?.age != 0 ? '${user?.age}세' : '미입력'),
                  _buildInfoRow(
                    '성별',
                    user?.gender.isNotEmpty == true ? user!.gender : '미입력',
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () => _showEditProfileDialog(context, user),
                      icon: const Icon(Icons.edit_outlined),
                      label: const Text('개인정보 수정'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primary,
                        side: const BorderSide(color: AppColors.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 채팅 수신 설정
            _buildSectionTitle('채팅 설정'),
            _buildCard(
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '채팅 수신 허용',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: AppColors.dark,
                          ),
                        ),
                        Text(
                          '끄면 새로운 채팅을 받지 않아요',
                          style: TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: user?.allowChat ?? true,
                    onChanged: (v) async {
                      if (user != null) {
                        await authService.updateUser(
                          user.copyWith(allowChat: v),
                        );
                      }
                    },
                    activeColor: AppColors.primary,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 직업 목록
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('내 알바 목록', style: AppTextStyles.heading3),
                TextButton.icon(
                  onPressed: () => _showAddJobDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('추가'),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.primary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (user?.jobs.isEmpty == true)
              _buildCard(
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 8),
                      Icon(
                        Icons.work_off_outlined,
                        size: 40,
                        color: Colors.grey.shade300,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '등록된 알바가 없어요',
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              )
            else
              ...user!.jobs.map(
                (job) => _buildJobCard(context, job, authService),
              ),
            const SizedBox(height: 24),

            // 로그아웃
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authService.logout();
                  if (context.mounted) {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                    );
                  }
                },
                icon: const Icon(Icons.logout_rounded),
                label: const Text('로그아웃'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.danger,
                  side: const BorderSide(color: AppColors.danger),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(title, style: AppTextStyles.heading3),
    );
  }

  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
      child: child,
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.grey, fontSize: 13),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.dark,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildJobCard(
    BuildContext context,
    JobModel job,
    AuthService authService,
  ) {
    final isBoss = job.role == 'boss';
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: (isBoss ? AppColors.accent : AppColors.primary).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              isBoss ? Icons.star_rounded : Icons.person_rounded,
              color: isBoss ? AppColors.accent : AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  job.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                Text(
                  '${isBoss ? '사장님' : '직원'} · 시급 ${job.hourlyWage.toInt()}원',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AppColors.grey),
            onPressed: () async {
              await authService.removeJob(job.id);
            },
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, UserModel? user) {
    final nameController = TextEditingController(text: user?.name ?? '');
    final ageController = TextEditingController(
      text: user?.age != 0 ? '${user?.age}' : '',
    );
    String selectedGender = user?.gender ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomState) => Padding(
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
              const Text('개인정보 수정', style: AppTextStyles.heading3),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: const InputDecoration(
                  labelText: '이름',
                  prefixIcon: Icon(Icons.person_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: ageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '나이',
                  prefixIcon: Icon(Icons.cake_outlined),
                ),
              ),
              const SizedBox(height: 12),
              const Text('성별', style: TextStyle(color: AppColors.grey)),
              const SizedBox(height: 8),
              Row(
                children: ['남성', '여성', '기타'].map((g) {
                  final isSelected = selectedGender == g;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setBottomState(() => selectedGender = g),
                      child: Container(
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          g,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : AppColors.grey,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  final authService = Provider.of<AuthService>(
                    context,
                    listen: false,
                  );
                  await authService.updateUser(
                    user!.copyWith(
                      name: nameController.text.trim(),
                      age: int.tryParse(ageController.text) ?? 0,
                      gender: selectedGender,
                    ),
                  );
                  if (context.mounted) Navigator.pop(context);
                },
                child: const Text('저장하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddJobDialog(BuildContext context) {
    final jobNameController = TextEditingController();
    final hourlyWageController = TextEditingController();
    String selectedRole = 'employee';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => StatefulBuilder(
        builder: (context, setBottomState) => Padding(
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
              const Text('알바 추가', style: AppTextStyles.heading3),
              const SizedBox(height: 20),
              TextField(
                controller: jobNameController,
                decoration: const InputDecoration(
                  labelText: '알바 이름',
                  hintText: '예: 스타벅스 강남점',
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: hourlyWageController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '시급 (원)',
                  hintText: '예: 10160',
                  prefixIcon: Icon(Icons.attach_money),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '역할 선택',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () =>
                          setBottomState(() => selectedRole = 'employee'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedRole == 'employee'
                              ? AppColors.primary
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.person_outline,
                              color: selectedRole == 'employee'
                                  ? Colors.white
                                  : AppColors.grey,
                            ),
                            Text(
                              '직원',
                              style: TextStyle(
                                color: selectedRole == 'employee'
                                    ? Colors.white
                                    : AppColors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setBottomState(() => selectedRole = 'boss'),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: selectedRole == 'boss'
                              ? AppColors.accent
                              : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            Icon(
                              Icons.star_outline,
                              color: selectedRole == 'boss'
                                  ? Colors.white
                                  : AppColors.grey,
                            ),
                            Text(
                              '사장님',
                              style: TextStyle(
                                color: selectedRole == 'boss'
                                    ? Colors.white
                                    : AppColors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (jobNameController.text.isNotEmpty) {
                    final authService = Provider.of<AuthService>(
                      context,
                      listen: false,
                    );
                    await authService.addJob(
                      JobModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: jobNameController.text.trim(),
                        role: selectedRole,
                        hourlyWage:
                            double.tryParse(hourlyWageController.text) ?? 0,
                      ),
                    );
                    if (context.mounted) Navigator.pop(context);
                  }
                },
                child: const Text('추가하기'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
