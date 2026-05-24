import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utils/constants.dart';

class JobInfoScreen extends StatefulWidget {
  const JobInfoScreen({super.key});

  @override
  State<JobInfoScreen> createState() => _JobInfoScreenState();
}

class _JobInfoScreenState extends State<JobInfoScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = '전체';

  final List<String> _categories = ['전체', '국가지원', '교내', '외식', '유통', '교육', '기타'];

  final List<Map<String, dynamic>> _jobs = [
    {
      'title': '국가근로장학금',
      'category': '국가지원',
      'description': '한국장학재단에서 지원하는 근로장학금. 교내외 근로 활동을 통해 장학금을 받을 수 있어요.',
      'hourlyWage': '최저시급 이상',
      'link': 'https://www.kosaf.go.kr',
      'tags': ['대학생', '장학금', '교내외'],
      'icon': Icons.school_rounded,
      'color': Color(0xFF6C63FF),
    },
    {
      'title': '근로복지재단 알바',
      'category': '국가지원',
      'description': '근로복지공단에서 운영하는 다양한 근로 프로그램. 복지 관련 기관에서 일할 수 있어요.',
      'hourlyWage': '협의',
      'link': 'https://www.kcomwel.or.kr',
      'tags': ['복지', '공공기관'],
      'icon': Icons.account_balance_rounded,
      'color': Color(0xFF43E97B),
    },
    {
      'title': '학교 사무실 알바',
      'category': '교내',
      'description': '학교 행정실, 도서관, 연구실 등에서 근무하는 교내 알바. 학업과 병행하기 좋아요.',
      'hourlyWage': '최저시급',
      'link': '',
      'tags': ['교내', '대학생', '유연근무'],
      'icon': Icons.business_rounded,
      'color': Color(0xFFFA8231),
    },
    {
      'title': '카페/음료',
      'category': '외식',
      'description': '카페, 커피숍 등에서 음료 제조 및 서빙. 바리스타 자격증 취득 기회도 있어요.',
      'hourlyWage': '최저시급~12,000원',
      'link': 'https://www.albamon.com',
      'tags': ['바리스타', '서비스', '주말가능'],
      'icon': Icons.coffee_rounded,
      'color': Color(0xFF795548),
    },
    {
      'title': '음식점/식당',
      'category': '외식',
      'description': '홀 서빙, 주방 보조 등 다양한 포지션. 식사 제공되는 경우가 많아요.',
      'hourlyWage': '최저시급~13,000원',
      'link': 'https://www.albamon.com',
      'tags': ['서빙', '주방', '식사제공'],
      'icon': Icons.restaurant_rounded,
      'color': Color(0xFFFF4757),
    },
    {
      'title': '편의점',
      'category': '유통',
      'description': '24시간 운영 편의점. 야간 근무 시 야간수당 지급. 혼자 근무하는 경우가 많아요.',
      'hourlyWage': '최저시급~야간할증',
      'link': 'https://www.albamon.com',
      'tags': ['야간가능', '유통', '혼자근무'],
      'icon': Icons.store_rounded,
      'color': Color(0xFF2ED573),
    },
    {
      'title': '학원 강사/튜터',
      'category': '교육',
      'description': '과외, 학원 보조강사, 공부방 교사 등. 전공 지식을 활용할 수 있어요.',
      'hourlyWage': '15,000원~30,000원',
      'link': 'https://www.albamon.com',
      'tags': ['교육', '전공활용', '고시급'],
      'icon': Icons.menu_book_rounded,
      'color': Color(0xFF5352ED),
    },
    {
      'title': '배달 알바',
      'category': '기타',
      'description': '음식 배달, 택배 등. 자유로운 시간 운용 가능. 오토바이 또는 자전거 필요.',
      'hourlyWage': '건당 수수료',
      'link': 'https://www.baemin.com',
      'tags': ['자유시간', '배달', '라이더'],
      'icon': Icons.delivery_dining_rounded,
      'color': Color(0xFF1E90FF),
    },
  ];

  List<Map<String, dynamic>> get _filteredJobs {
    return _jobs.where((job) {
      final matchesCategory =
          _selectedCategory == '전체' || job['category'] == _selectedCategory;
      final matchesSearch =
          _searchQuery.isEmpty ||
          job['title'].toString().contains(_searchQuery) ||
          job['description'].toString().contains(_searchQuery) ||
          (job['tags'] as List).any(
            (tag) => tag.toString().contains(_searchQuery),
          );
      return matchesCategory && matchesSearch;
    }).toList();
  }

  Future<void> _launchUrl(String url) async {
    if (url.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('학교 홈페이지에서 확인해주세요')));
      return;
    }
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('알바 종류 정리')),
      body: Column(
        children: [
          // 검색창
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '알바 종류 검색...',
                prefixIcon: const Icon(
                  Icons.search_rounded,
                  color: AppColors.grey,
                ),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear_rounded),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchQuery = '');
                        },
                      )
                    : null,
              ),
              onChanged: (v) => setState(() => _searchQuery = v),
            ),
          ),

          // 카테고리 필터
          SizedBox(
            height: 40,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? const Color(0xFF5352ED)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isSelected
                            ? const Color(0xFF5352ED)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Text(
                      cat,
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

          // 알바 목록
          Expanded(
            child: _filteredJobs.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off_rounded,
                          size: 64,
                          color: Colors.grey.shade300,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          '검색 결과가 없어요',
                          style: TextStyle(color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: _filteredJobs.length,
                    itemBuilder: (context, index) {
                      final job = _filteredJobs[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 12),
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
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
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
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          job['title'],
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.dark,
                                          ),
                                        ),
                                        Text(
                                          '시급: ${job['hourlyWage']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: (job['color'] as Color).withValues(
                                        alpha: 0.1,
                                      ),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Text(
                                      job['category'],
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: job['color'] as Color,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                job['description'],
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.grey,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Wrap(
                                spacing: 6,
                                children: (job['tags'] as List)
                                    .map(
                                      (tag) => Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 3,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.grey.shade100,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          '#$tag',
                                          style: const TextStyle(
                                            fontSize: 11,
                                            color: AppColors.grey,
                                          ),
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                              const SizedBox(height: 12),
                              SizedBox(
                                width: double.infinity,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      _launchUrl(job['link'] as String),
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('자세히 보기'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: job['color'] as Color,
                                    side: BorderSide(
                                      color: job['color'] as Color,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                    ),
                                    minimumSize: Size.zero,
                                  ),
                                ),
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
