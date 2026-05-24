class ScheduleModel {
  final String id;
  final String jobId;
  final DateTime date;
  final DateTime startTime;
  final DateTime endTime;
  final bool isNightShift;
  final bool isHoliday;
  final RepeatType repeatType;

  ScheduleModel({
    required this.id,
    required this.jobId,
    required this.date,
    required this.startTime,
    required this.endTime,
    this.isNightShift = false,
    this.isHoliday = false,
    this.repeatType = RepeatType.none,
  });

  double get workedHours {
    double hours = endTime.difference(startTime).inMinutes / 60;
    // 휴게시간 자동 제외
    if (hours >= 8) {
      hours -= 1.0; // 1시간 제외
    } else if (hours >= 4) {
      hours -= 0.5; // 30분 제외
    }
    return hours;
  }

  double get earnedWage {
    return 0; // jobId로 시급 계산은 서비스에서 처리
  }

  factory ScheduleModel.fromMap(Map<String, dynamic> map) {
    return ScheduleModel(
      id: map['id'] ?? '',
      jobId: map['jobId'] ?? '',
      date: DateTime.parse(map['date']),
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      isNightShift: map['isNightShift'] ?? false,
      isHoliday: map['isHoliday'] ?? false,
      repeatType: RepeatType.values.firstWhere(
        (e) => e.name == (map['repeatType'] ?? 'none'),
        orElse: () => RepeatType.none,
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jobId': jobId,
      'date': date.toIso8601String(),
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isNightShift': isNightShift,
      'isHoliday': isHoliday,
      'repeatType': repeatType.name,
    };
  }
}

enum RepeatType {
  none, // 반복 없음
  weekly, // 매주 반복
  monthly, // 매월 반복
}
