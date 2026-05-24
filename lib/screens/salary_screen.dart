import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../services/auth_service.dart';
import '../models/schedule_model.dart';
import '../utils/constants.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  final List<ScheduleModel> _schedules = [];
  final _actualSalaryController = TextEditingController();
  final _formatter = NumberFormat('#,###');

  @override
  void dispose() {
    _actualSalaryController.dispose();
    super.dispose();
  }

  List<ScheduleModel> _getSchedulesForDay(DateTime day) {
    return _schedules
        .where(
          (s) =>
              s.date.year == day.year &&
              s.date.month == day.month &&
              s.date.day == day.day,
        )
        .toList();
  }

  List<ScheduleModel> _getSchedulesForMonth(DateTime month) {
    return _schedules
        .where((s) => s.date.year == month.year && s.date.month == month.month)
        .toList();
  }

  double _calculateMonthlySalary() {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null || user.jobs.isEmpty) return 0;

    double total = 0;
    final monthSchedules = _getSchedulesForMonth(_focusedDay);

    for (final schedule in monthSchedules) {
      final job = user.jobs.firstWhere(
        (j) => j.id == schedule.jobId,
        orElse: () => user.jobs.first,
      );
      double wage = job.hourlyWage * schedule.workedHours;
      if (schedule.isNightShift) wage *= 1.5;
      if (schedule.isHoliday) wage *= 2.0;
      total += wage;
    }

    // 주휴수당 계산
    Map<int, double> weeklyHours = {};
    for (final schedule in monthSchedules) {
      final weekNum = _getWeekNumber(schedule.date);
      weeklyHours[weekNum] = (weeklyHours[weekNum] ?? 0) + schedule.workedHours;
    }
    for (final hours in weeklyHours.values) {
      if (hours >= 15) {
        final job = user.jobs.first;
        total += job.hourlyWage * (hours / 5);
      }
    }
    return total;
  }

  int _getWeekNumber(DateTime date) {
    return ((date.day - 1) / 7).floor();
  }

  void _showAddScheduleDialog(DateTime day) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final user = authService.currentUser;
    if (user == null || user.jobs.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('마이페이지에서 알바를 먼저 추가해주세요')));
      return;
    }

    TimeOfDay startTime = const TimeOfDay(hour: 9, minute: 0);
    TimeOfDay endTime = const TimeOfDay(hour: 18, minute: 0);
    bool isNightShift = false;
    bool isHoliday = false;
    RepeatType repeatType = RepeatType.none;
    String selectedJobId = user.jobs.first.id;

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
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${day.month}월 ${day.day}일 근무 추가',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 20),

                // 알바 선택
                if (user.jobs.length > 1) ...[
                  const Text(
                    '알바 선택',
                    style: TextStyle(color: AppColors.grey, fontSize: 13),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: user.jobs.map((job) {
                      final isSelected = selectedJobId == job.id;
                      return GestureDetector(
                        onTap: () =>
                            setBottomState(() => selectedJobId = job.id),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? AppColors.primary
                                : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            job.name,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.grey,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // 시간 선택
                Row(
                  children: [
                    Expanded(
                      child: _buildTimeButton(
                        label: '시작 시간',
                        time: startTime,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: startTime,
                          );
                          if (picked != null) {
                            setBottomState(() => startTime = picked);
                          }
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildTimeButton(
                        label: '종료 시간',
                        time: endTime,
                        onTap: () async {
                          final picked = await showTimePicker(
                            context: context,
                            initialTime: endTime,
                          );
                          if (picked != null) {
                            setBottomState(() => endTime = picked);
                          }
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // 야간/공휴일 스위치
                _buildSwitchRow(
                  title: '야간 근무',
                  subtitle: '밤 10시~새벽 6시 (+50%)',
                  value: isNightShift,
                  onChanged: (v) => setBottomState(() => isNightShift = v),
                ),
                _buildSwitchRow(
                  title: '공휴일 근무',
                  subtitle: '빨간날 근무 (+100%)',
                  value: isHoliday,
                  onChanged: (v) => setBottomState(() => isHoliday = v),
                ),
                const SizedBox(height: 16),

                // 반복 설정
                const Text(
                  '반복 설정',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.dark,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildRepeatChip(
                      label: '반복 없음',
                      selected: repeatType == RepeatType.none,
                      onTap: () =>
                          setBottomState(() => repeatType = RepeatType.none),
                    ),
                    const SizedBox(width: 8),
                    _buildRepeatChip(
                      label: '매주 반복',
                      selected: repeatType == RepeatType.weekly,
                      onTap: () =>
                          setBottomState(() => repeatType = RepeatType.weekly),
                    ),
                    const SizedBox(width: 8),
                    _buildRepeatChip(
                      label: '매월 반복',
                      selected: repeatType == RepeatType.monthly,
                      onTap: () =>
                          setBottomState(() => repeatType = RepeatType.monthly),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    _addSchedule(
                      day: day,
                      startTime: startTime,
                      endTime: endTime,
                      isNightShift: isNightShift,
                      isHoliday: isHoliday,
                      repeatType: repeatType,
                      jobId: selectedJobId,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text('근무 추가'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _addSchedule({
    required DateTime day,
    required TimeOfDay startTime,
    required TimeOfDay endTime,
    required bool isNightShift,
    required bool isHoliday,
    required RepeatType repeatType,
    required String jobId,
  }) {
    final start = DateTime(
      day.year,
      day.month,
      day.day,
      startTime.hour,
      startTime.minute,
    );
    final end = DateTime(
      day.year,
      day.month,
      day.day,
      endTime.hour,
      endTime.minute,
    );

    List<DateTime> dates = [day];

    if (repeatType == RepeatType.weekly) {
      for (int i = 1; i <= 3; i++) {
        dates.add(day.add(Duration(days: 7 * i)));
      }
    } else if (repeatType == RepeatType.monthly) {
      for (int i = 1; i <= 2; i++) {
        final nextMonth = DateTime(day.year, day.month + i, day.day);
        dates.add(nextMonth);
      }
    }

    setState(() {
      for (final date in dates) {
        final s = DateTime(
          date.year,
          date.month,
          date.day,
          startTime.hour,
          startTime.minute,
        );
        final e = DateTime(
          date.year,
          date.month,
          date.day,
          endTime.hour,
          endTime.minute,
        );
        _schedules.add(
          ScheduleModel(
            id:
                DateTime.now().millisecondsSinceEpoch.toString() +
                date.toString(),
            jobId: jobId,
            date: date,
            startTime: s,
            endTime: e,
            isNightShift: isNightShift,
            isHoliday: isHoliday,
            repeatType: repeatType,
          ),
        );
      }
    });
  }

  Widget _buildTimeButton({
    required String label,
    required TimeOfDay time,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppColors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwitchRow({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 12, color: AppColors.grey),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.primary,
        ),
      ],
    );
  }

  Widget _buildRepeatChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.grey,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.currentUser;
    final selectedSchedules = _selectedDay != null
        ? _getSchedulesForDay(_selectedDay!)
        : [];
    final monthlySalary = _calculateMonthlySalary();
    final actualSalary =
        double.tryParse(_actualSalaryController.text.replaceAll(',', '')) ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('급여 계산기')),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // 달력
              Container(
                color: Colors.white,
                child: TableCalendar(
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: _focusedDay,
                  selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                  onDaySelected: (selectedDay, focusedDay) {
                    setState(() {
                      _selectedDay = selectedDay;
                      _focusedDay = focusedDay;
                    });
                    _showAddScheduleDialog(selectedDay);
                  },
                  onPageChanged: (focusedDay) {
                    setState(() => _focusedDay = focusedDay);
                  },
                  eventLoader: (day) => _getSchedulesForDay(day),
                  calendarStyle: CalendarStyle(
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                    markerDecoration: const BoxDecoration(
                      color: AppColors.accent,
                      shape: BoxShape.circle,
                    ),
                    weekendTextStyle: const TextStyle(color: AppColors.danger),
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 월 급여 요약
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [AppColors.primary, AppColors.primaryLight],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_focusedDay.month}월 예상 급여',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${_formatter.format(monthlySalary.round())}원',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '근무일수 ${_getSchedulesForMonth(_focusedDay).length}일 · 총 ${_getSchedulesForMonth(_focusedDay).fold(0.0, (sum, s) => sum + s.workedHours).toStringAsFixed(1)}시간',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 실수령액 비교
                    Container(
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
                          const Text('실수령액 비교', style: AppTextStyles.heading3),
                          const SizedBox(height: 12),
                          TextField(
                            controller: _actualSalaryController,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(
                              labelText: '실제 받은 급여 (원)',
                              hintText: '예: 1200000',
                              prefixIcon: Icon(Icons.account_balance_wallet),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          if (actualSalary > 0) ...[
                            const SizedBox(height: 12),
                            _buildDifferenceRow(monthlySalary, actualSalary),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // 선택한 날 근무 목록
                    if (selectedSchedules.isNotEmpty) ...[
                      Text(
                        '${_selectedDay?.month}월 ${_selectedDay?.day}일 근무',
                        style: AppTextStyles.heading3,
                      ),
                      const SizedBox(height: 12),
                      ...selectedSchedules.map(
                        (s) => _buildScheduleCard(s, user),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDifferenceRow(double calculated, double actual) {
    final diff = actual - calculated;
    final isUnder = diff < 0;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: (isUnder ? AppColors.danger : AppColors.secondary).withValues(
          alpha: 0.1,
        ),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('예상 급여'),
              Text('${_formatter.format(calculated.round())}원'),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('실수령액'),
              Text('${_formatter.format(actual.round())}원'),
            ],
          ),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '차액',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnder ? AppColors.danger : AppColors.secondary,
                ),
              ),
              Text(
                '${diff >= 0 ? '+' : ''}${_formatter.format(diff.round())}원',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isUnder ? AppColors.danger : AppColors.secondary,
                ),
              ),
            ],
          ),
          if (isUnder)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text(
                '⚠️ 급여가 적게 지급됐어요!\n고용노동부(1350)에 문의해보세요.',
                style: TextStyle(color: AppColors.danger, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildScheduleCard(ScheduleModel schedule, user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 8),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.access_time,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${schedule.startTime.hour.toString().padLeft(2, '0')}:${schedule.startTime.minute.toString().padLeft(2, '0')} ~ ${schedule.endTime.hour.toString().padLeft(2, '0')}:${schedule.endTime.minute.toString().padLeft(2, '0')}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  '${schedule.workedHours.toStringAsFixed(1)}시간'
                  '${schedule.isNightShift ? ' · 야간' : ''}'
                  '${schedule.isHoliday ? ' · 공휴일' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.grey),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.delete_outline,
              color: AppColors.grey,
              size: 20,
            ),
            onPressed: () {
              setState(
                () => _schedules.removeWhere((s) => s.id == schedule.id),
              );
            },
          ),
        ],
      ),
    );
  }
}
