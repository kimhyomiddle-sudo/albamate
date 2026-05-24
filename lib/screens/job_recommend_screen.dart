import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/auth_service.dart';
import '../utils/constants.dart';

class JobRecommendScreen extends StatefulWidget {
  const JobRecommendScreen({super.key});

  @override
  State<JobRecommendScreen> createState() => _JobRecommendScreenState();
}

class _JobRecommendScreenState extends State<JobRecommendScreen> {
  final _majorController = TextEditingController();
  final _interestController = TextEditingController();
  String _selectedCareer = '';
  bool _hasSearched = false;

  final List<String> _careerOptions = [
    'IT/개발',
    '디자인',
    '마케팅',
    '경영/회계',
    '교육',
    '의료/보건',
    '법률',
    '공학',
    '예술/문화',
    '기타',
  ];

  final Map<String, List<Map<String, dynamic>>> _recommendations = {
    'IT/개발': [
      {
        'title': '웹/앱 개발 외주',
        'description': '프리랜서 개발 프로젝트. 포트폴리오 쌓기 좋아요.',
        'site': 'kmong.com',
        'icon': Icons.code_rounded,
        'color': Color(0xFF6C63FF),
      },
      {
        'title': 'IT 회사 인턴',
        'description': '스타트업, IT기업 인턴십. 실무 경험을 쌓을 수 있어요.',
        'site': 'wanted.co.kr',
        'icon': Icons.computer_rounded,
        'color': Color(0xFF5352ED),
      },
      {
        'title': '코딩 강사',
        'description': '초중고 코딩 교육 강사. 시급이 높은 편이에요.',
        'site': 'albamon.com',
        'icon': Icons.school_rounded,
        'color': Color(0xFF2ED573),
      },
    ],
    '디자인': [
      {
        'title': '디자인 외주',
        'description': '로고, 포스터, SNS 콘텐츠 디자인 프리랜서.',
        'site': 'kmong.com',
        'icon': Icons.palette_rounded,
        'color': Color(0xFFFA8231),
      },
      {
        'title': '사진/영상 촬영',
        'description': '행사, 제품 촬영 등 프리랜서 활동.',
        'site': 'kmong.com',
        'icon': Icons.camera_alt_rounded,
        'color': Color(0xFFFF4757),
      },
    ],
    '교육': [
      {
        'title': '과외/튜터링',
        'description': '초중고 과외, 대학생 과외. 시급이 높아요.',
        'site': 'tutorings.co.kr',
        'icon': Icons.menu_book_rounded,
        'color': Color(0xFF5352ED),
      },
      {
        'title': '학원 보조강사',
        'description': '영어, 수학 등 학원 보조강사.',
        'site': 'albamon.com',
        'icon': Icons.cast_for_education_rounded,
        'color': Color(0xFF43E97B),
      },
    ],
    '마케팅': [
      {
        'title': 'SNS 마케터',
        'description': '인스타그램, 유튜브 등 SNS 콘텐츠 관리.',
        'site': 'kmong.com',
        'icon': Icons.campaign_rounded,
        'color': Color(0xFFFA8231),
      },
      {
        'title': '브랜드 홍보 알바',
        'description': '행사장, 팝업스토어 홍보 도우미.',
        'site': 'albamon.com',
        'icon': Icons.record_voice_over_rounded,
        'color': Color(0xFF6C63FF),
      },
    ],
  };

  List<Map<String, dynamic>> get _getRecommendations {
    if (_selectedCareer.isEmpty) return [];
    return _recommendations[_selectedCareer] ??
        [
          {
            'title': '국가근로장학금',
            'description': '전공 무관하게 지원 가능한 근로장학금.',
            'site': 'kosaf.go.kr',
            'icon': Icons.school_rounded,
            'color': AppColors.primary,
          },
          {
            'title': '교내 근로 알바',
            'description': '학교 내 다양한 부서에서 근무 가능.',
            'site': '',
            'icon': Icons.business_rounded,
            'color': AppColors.accent,
          },
        ];
  }

  @override
  void dispose() {
    _majorController.dispose();
    _interestController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('알바 추천')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 안내 카드
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF2ED573), Color(0xFF43E97B)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '내 커리어에 맞는 알바 찾기 🎯',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${user?.name ?? ''}님의 전공과 관심 분야에 맞는\n알바를 추천해드려요!',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // 입력 폼
              const Text('내 정보 입력', style: AppTextStyles.heading3),
              const SizedBox(height: 16),
              TextField(
                controller: _majorController,
                decoration: const InputDecoration(
                  labelText: '전공',
                  hintText: '예: 컴퓨터공학, 경영학, 간호학',
                  prefixIcon: Icon(Icons.school_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _interestController,
                decoration: const InputDecoration(
                  labelText: '관심사 / 특기',
                  hintText: '예: 그림 그리기, 영어 잘함, 운전가능',
                  prefixIcon: Icon(Icons.star_outline_rounded),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                '희망 커리어 방향',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.dark,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _careerOptions.map((career) {
                  final isSelected = _selectedCareer == career;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedCareer = career),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? const Color(0xFF2ED573)
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected
                              ? const Color(0xFF2ED573)
                              : Colors.grey.shade300,
                        ),
                      ),
                      child: Text(
                        career,
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
                }).toList(),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: () {
                  if (_selectedCareer.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('커리어 방향을 선택해주세요')),
                    );
                    return;
                  }
                  setState(() => _hasSearched = true);
                },
                icon: const Icon(Icons.search_rounded),
                label: const Text('알바 추천받기'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2ED573),
                ),
              ),

              // 추천 결과
              if (_hasSearched && _getRecommendations.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  '$_selectedCareer 관련 추천 알바',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                ..._getRecommendations.map(
                  (job) => Container(
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
                            color: (job['color'] as Color).withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            job['icon'] as IconData,
                            color: job['color'] as Color,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                job['title'],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.dark,
                                ),
                              ),
                              Text(
                                job['description'],
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.grey,
                                ),
                              ),
                              if (job['site'].toString().isNotEmpty)
                                Text(
                                  '🔗 ${job['site']}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: job['color'] as Color,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
