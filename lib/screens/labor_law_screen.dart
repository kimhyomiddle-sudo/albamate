import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LaborLawScreen extends StatelessWidget {
  const LaborLawScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('노동법 정보')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInfoCard(
              icon: Icons.attach_money,
              title: '2026년 최저시급',
              color: AppColors.primary,
              items: [
                _InfoItem('최저시급', '10,320원'),
                _InfoItem('하루 8시간 기준', '82,560원'),
                _InfoItem('월 환산 (209시간)', '2,156,880원'),
                _InfoItem('위반 시', '3년 이하 징역 또는 2천만원 이하 벌금'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.calendar_today,
              title: '주휴수당',
              color: AppColors.secondary,
              items: [
                _InfoItem('지급 조건', '주 15시간 이상 근무'),
                _InfoItem('계산법', '1주 총 근무시간 ÷ 5 × 시급'),
                _InfoItem('예시 (주 40시간)', '40 ÷ 5 × 10,160 = 81,280원'),
                _InfoItem('주의', '결근 시 해당 주 주휴수당 미지급 가능'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.coffee_rounded,
              title: '휴게시간 보장',
              color: AppColors.accent,
              items: [
                _InfoItem('4시간 근무', '30분 이상 휴게'),
                _InfoItem('8시간 근무', '1시간 이상 휴게'),
                _InfoItem('휴게시간', '근무시간에 미포함 (무급)'),
                _InfoItem('위반 시', '2년 이하 징역 또는 2천만원 이하 벌금'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.nightlight_round,
              title: '야간근무 수당',
              color: AppColors.primary,
              items: [
                _InfoItem('야간 시간대', '오후 10시 ~ 오전 6시'),
                _InfoItem('추가 수당', '통상임금의 50% 가산'),
                _InfoItem('예시', '시급 10,160원 → 야간 15,240원'),
                _InfoItem('적용 대상', '5인 이상 사업장'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.child_care_rounded,
              title: '청소년 근로규정',
              color: AppColors.danger,
              items: [
                _InfoItem('근로 가능 나이', '만 15세 이상'),
                _InfoItem('하루 최대', '7시간 (성인 8시간)'),
                _InfoItem('주 최대', '35시간 (성인 40시간)'),
                _InfoItem('야간·휴일 근무', '원칙적으로 금지 (본인 동의 시 가능)'),
                _InfoItem('필요 서류', '친권자 동의서 + 나이 증명 서류'),
              ],
            ),
            const SizedBox(height: 16),
            _buildInfoCard(
              icon: Icons.phone_rounded,
              title: '도움이 필요할 때',
              color: AppColors.dark,
              items: [
                _InfoItem('고용노동부 상담', '1350 (무료)'),
                _InfoItem('청소년 근로권익센터', '1644-3119'),
                _InfoItem('노동청 진정 접수', 'minwon.moel.go.kr'),
                _InfoItem('운영시간', '평일 09:00 ~ 18:00'),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required Color color,
    required List<_InfoItem> items,
  }) {
    return Container(
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
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: color),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: items
                  .map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 6),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 120,
                            child: Text(
                              item.label,
                              style: const TextStyle(
                                color: AppColors.grey,
                                fontSize: 13,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              item.value,
                              style: const TextStyle(
                                color: AppColors.dark,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoItem {
  final String label;
  final String value;
  const _InfoItem(this.label, this.value);
}
