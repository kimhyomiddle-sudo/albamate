import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';
import '../utils/constants.dart';
import 'home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _userIdController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _ageController = TextEditingController();

  String _selectedGender = '';
  bool _isLoading = false;
  bool _obscurePassword = true;
  int _currentStep = 0;

  @override
  void dispose() {
    _nameController.dispose();
    _userIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameController.text.isEmpty) {
      _showSnackBar('이름을 입력해주세요');
      return;
    }
    if (_userIdController.text.isEmpty) {
      _showSnackBar('아이디를 입력해주세요');
      return;
    }
    if (_emailController.text.isEmpty) {
      _showSnackBar('이메일을 입력해주세요');
      return;
    }
    if (_passwordController.text.length < 6) {
      _showSnackBar('비밀번호는 6자리 이상이어야 합니다');
      return;
    }
    if (_passwordController.text != _confirmPasswordController.text) {
      _showSnackBar('비밀번호가 일치하지 않습니다');
      return;
    }

    setState(() => _isLoading = true);
    final authService = Provider.of<AuthService>(context, listen: false);
    final success = await authService.register(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      name: _nameController.text.trim(),
      userId: _userIdController.text.trim(),
      gender: _selectedGender,
      age: int.tryParse(_ageController.text) ?? 0,
    );
    setState(() => _isLoading = false);

    if (success && mounted) {
      // 직업 추가 다이얼로그 표시
      _showAddJobDialog();
    } else if (mounted) {
      _showSnackBar('회원가입에 실패했습니다. 다시 시도해주세요');
    }
  }

  void _showAddJobDialog() {
    final jobNameController = TextEditingController();
    final hourlyWageController = TextEditingController();
    String selectedRole = 'employee';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text('직업 추가', style: AppTextStyles.heading3),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '알바 정보를 입력해주세요\n(나중에 마이페이지에서 추가할 수 있어요)',
                  style: TextStyle(color: AppColors.grey, fontSize: 13),
                ),
                const SizedBox(height: 16),
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
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () =>
                            setDialogState(() => selectedRole = 'employee'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedRole == 'employee'
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedRole == 'employee'
                                  ? AppColors.primary
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: selectedRole == 'employee'
                                    ? Colors.white
                                    : AppColors.grey,
                              ),
                              const SizedBox(height: 4),
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
                        onTap: () =>
                            setDialogState(() => selectedRole = 'boss'),
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            color: selectedRole == 'boss'
                                ? AppColors.accent
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: selectedRole == 'boss'
                                  ? AppColors.accent
                                  : Colors.grey.shade300,
                            ),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.star_outline,
                                color: selectedRole == 'boss'
                                    ? Colors.white
                                    : AppColors.grey,
                              ),
                              const SizedBox(height: 4),
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
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const HomeScreen()),
                );
              },
              child: const Text('나중에', style: TextStyle(color: AppColors.grey)),
            ),
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
                }
                if (mounted) {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const HomeScreen()),
                  );
                }
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(80, 44)),
              child: const Text('추가'),
            ),
          ],
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('회원가입', style: AppTextStyles.heading1),
                const Text(
                  '알바메이트와 함께 시작해요',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                ),
                const SizedBox(height: 32),
                _buildTextField(
                  controller: _nameController,
                  label: '실명',
                  hint: '예: 홍길동',
                  icon: Icons.person_outlined,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _userIdController,
                  label: '아이디 (친구 추가 시 사용)',
                  hint: '예: alba_mate123',
                  icon: Icons.alternate_email,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _emailController,
                  label: '이메일',
                  hint: '예: example@email.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _passwordController,
                  label: '비밀번호 (6자리 이상)',
                  hint: '비밀번호 입력',
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off
                          : Icons.visibility,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _confirmPasswordController,
                  label: '비밀번호 확인',
                  hint: '비밀번호 재입력',
                  icon: Icons.lock_outlined,
                  obscureText: _obscurePassword,
                ),
                const SizedBox(height: 16),
                _buildTextField(
                  controller: _ageController,
                  label: '나이 (선택)',
                  hint: '예: 22',
                  icon: Icons.cake_outlined,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),
                const Text(
                  '성별 (선택)',
                  style: TextStyle(fontSize: 14, color: AppColors.grey),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildGenderButton('남성', Icons.male),
                    const SizedBox(width: 12),
                    _buildGenderButton('여성', Icons.female),
                    const SizedBox(width: 12),
                    _buildGenderButton('기타', Icons.person),
                  ],
                ),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _isLoading ? null : _register,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          '회원가입',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenderButton(String label, IconData icon) {
    final isSelected = _selectedGender == label;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedGender = label),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : Colors.grey.shade100,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isSelected ? AppColors.primary : Colors.grey.shade300,
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: isSelected ? Colors.white : AppColors.grey,
                size: 20,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.white : AppColors.grey,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: Icon(icon, color: AppColors.primary),
        suffixIcon: suffixIcon,
      ),
    );
  }
}
