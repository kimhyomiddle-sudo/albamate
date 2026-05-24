import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';
import 'login_screen.dart';
import 'chat_screen.dart';
import 'mypage_screen.dart';
import 'salary_screen.dart';
import 'goal_screen.dart';
import 'checklist_screen.dart';
import 'labor_law_screen.dart';
import 'job_info_screen.dart';
import 'job_recommend_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  final List<Widget> _tabs = [
    const HomeTab(),
    const ChatScreen(),
    const MyPageScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tabs[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey,
        selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: '홈'),
          BottomNavigationBarItem(icon: Icon(Icons.chat_rounded), label: '채팅'),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: '마이페이지',
          ),
        ],
      ),
    );
  }
}

// 기능 목록 데이터
class FeatureItem {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  final Widget screen;
  final bool bossOnly;

  const FeatureItem({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    required this.screen,
    this.bossOnly = false,
  });
}

final List<FeatureItem> allFeatures = [
  FeatureItem(
    id: 'salary',
    title: '급여 계산기',
    description: '달력으로 근무 일정을 기록하고\n월급을 자동 계산해드려요',
    icon: Icons.calculate_rounded,
    color: AppColors.primary,
    screen: const SalaryScreen(),
  ),
  FeatureItem(
    id: 'goal',
    title: '목표 저축',
    description: '사고 싶은 것을 등록하고\n몇 시간 더 일하면 되는지 알려드려요',
    icon: Icons.savings_rounded,
    color: AppColors.secondary,
    screen: const GoalScreen(),
  ),
  FeatureItem(
    id: 'checklist',
    title: '체크리스트',
    description: '업무 체크리스트를 만들고\n동료들과 공유해요',
    icon: Icons.checklist_rounded,
    color: AppColors.accent,
    screen: const ChecklistScreen(),
  ),
  FeatureItem(
    id: 'laborlaw',
    title: '노동법 정보',
    description: '최저시급, 주휴수당, 청소년 근로규정 등\n내 권리를 알아보세요',
    icon: Icons.gavel_rounded,
    color: AppColors.danger,
    screen: const LaborLawScreen(),
  ),
  FeatureItem(
    id: 'jobinfo',
    title: '알바 종류 정리',
    description: '국가근로장학금, 근로재단, 음식점 등\n다양한 알바 정보를 모아봤어요',
    icon: Icons.work_rounded,
    color: Color(0xFF5352ED),
    screen: const JobInfoScreen(),
  ),
  FeatureItem(
    id: 'jobrecommend',
    title: '알바 추천',
    description: '전공과 커리어에 맞는\n알바를 추천해드려요',
    icon: Icons.recommend_rounded,
    color: Color(0xFF2ED573),
    screen: const JobRecommendScreen(),
  ),
];

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final activeWidgets = user?.activeWidgets ?? [];
    final isBoss = user?.jobs.any((j) => j.role == 'boss') ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu_rounded),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: const Text('알바메이트'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () async {
              await authService.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
      drawer: _buildDrawer(context, authService, isBoss),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 인사말 카드
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '안녕하세요, ${user?.name ?? ''}님! 👋',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isBoss ? '사장님, 오늘도 화이팅이에요!' : '오늘도 열심히 일하셨나요?',
                    style: const TextStyle(fontSize: 14, color: Colors.white70),
                  ),
                  if (user?.jobs.isNotEmpty == true) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      children: user!.jobs.map((job) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${job.role == 'boss' ? '👑 ' : ''}${job.name}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 최저시급 안내
            Container(
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
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.info_outline,
                      color: AppColors.primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '2026년 최저시급',
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                      Text(
                        '10,320원',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.dark,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 활성 위젯들
            if (activeWidgets.isNotEmpty) ...[
              const Text('내 바로가기', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.3,
                children: activeWidgets.map((widgetId) {
                  final feature = allFeatures.firstWhere(
                    (f) => f.id == widgetId,
                    orElse: () => allFeatures[0],
                  );
                  return _buildWidgetCard(context, feature);
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],

            // 기능 추가 안내
            if (activeWidgets.isEmpty)
              Center(
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    Icon(
                      Icons.widgets_outlined,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      '왼쪽 위 ☰ 메뉴에서\n기능을 홈에 추가해보세요!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetCard(BuildContext context, FeatureItem feature) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => feature.screen),
      ),
      child: Container(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: feature.color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(feature.icon, color: feature.color, size: 24),
            ),
            const Spacer(),
            Text(
              feature.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.dark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawer(
    BuildContext context,
    AuthService authService,
    bool isBoss,
  ) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              color: AppColors.primary,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.work_rounded, color: Colors.white, size: 32),
                  const SizedBox(height: 8),
                  Text(
                    authService.currentUser?.name ?? '',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '@${authService.currentUser?.userId ?? ''}',
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                '기능 목록',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  ...allFeatures.map(
                    (feature) =>
                        _buildDrawerItem(context, feature, authService),
                  ),
                  if (isBoss) ...[
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: Text(
                        '사장님 전용',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.accent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    _buildBossDrawerItem(
                      context,
                      icon: Icons.calendar_month_rounded,
                      title: '직원 근무 스케줄',
                      color: AppColors.accent,
                    ),
                    _buildBossDrawerItem(
                      context,
                      icon: Icons.assignment_rounded,
                      title: '직원 계약일 관리',
                      color: AppColors.accent,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
    BuildContext context,
    FeatureItem feature,
    AuthService authService,
  ) {
    final isAdded =
        authService.currentUser?.activeWidgets.contains(feature.id) ?? false;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: feature.color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(feature.icon, color: feature.color, size: 20),
      ),
      title: Text(
        feature.title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        _showFeatureDetail(context, feature, authService, isAdded);
      },
    );
  }

  Widget _buildBossDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required Color color,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(
        title,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
      ),
      onTap: () {
        Navigator.pop(context);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('준비 중인 기능이에요!')));
      },
    );
  }

  void _showFeatureDetail(
    BuildContext context,
    FeatureItem feature,
    AuthService authService,
    bool isAdded,
  ) {
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: feature.color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(feature.icon, color: feature.color, size: 28),
                ),
                const SizedBox(width: 16),
                Text(feature.title, style: AppTextStyles.heading3),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              feature.description,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.grey,
                height: 1.6,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      Navigator.pop(context);
                      if (isAdded) {
                        await authService.removeWidget(feature.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${feature.title} 위젯을 삭제했어요'),
                            ),
                          );
                        }
                      } else {
                        await authService.addWidget(feature.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('${feature.title} 위젯을 추가했어요'),
                            ),
                          );
                        }
                      }
                    },
                    icon: Icon(
                      isAdded
                          ? Icons.remove_circle_outline
                          : Icons.add_circle_outline,
                    ),
                    label: Text(isAdded ? '위젯 삭제' : '위젯 추가'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: feature.color,
                      side: BorderSide(color: feature.color),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => feature.screen),
                      );
                    },
                    icon: const Icon(Icons.open_in_new_rounded),
                    label: const Text('페이지 열기'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: feature.color,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      minimumSize: Size.zero,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
