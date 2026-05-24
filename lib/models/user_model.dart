class UserModel {
  final String uid;
  final String name;
  final String email;
  final String userId; // 친구 추가용 아이디
  final String gender;
  final int age;
  final List<JobModel> jobs;
  final bool allowChat; // 채팅 수신 허용
  final List<String> friends; // 친구 목록 uid
  final List<String> blockedUsers; // 차단 목록 uid
  final List<String> activeWidgets; // 홈에 추가된 위젯 목록

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    required this.userId,
    this.gender = '',
    this.age = 0,
    this.jobs = const [],
    this.allowChat = true,
    this.friends = const [],
    this.blockedUsers = const [],
    this.activeWidgets = const [],
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      userId: map['userId'] ?? '',
      gender: map['gender'] ?? '',
      age: map['age'] ?? 0,
      jobs:
          (map['jobs'] as List<dynamic>?)
              ?.map((j) => JobModel.fromMap(j))
              .toList() ??
          [],
      allowChat: map['allowChat'] ?? true,
      friends: List<String>.from(map['friends'] ?? []),
      blockedUsers: List<String>.from(map['blockedUsers'] ?? []),
      activeWidgets: List<String>.from(map['activeWidgets'] ?? []),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'userId': userId,
      'gender': gender,
      'age': age,
      'jobs': jobs.map((j) => j.toMap()).toList(),
      'allowChat': allowChat,
      'friends': friends,
      'blockedUsers': blockedUsers,
      'activeWidgets': activeWidgets,
    };
  }

  UserModel copyWith({
    String? name,
    String? gender,
    int? age,
    List<JobModel>? jobs,
    bool? allowChat,
    List<String>? friends,
    List<String>? blockedUsers,
    List<String>? activeWidgets,
  }) {
    return UserModel(
      uid: uid,
      name: name ?? this.name,
      email: email,
      userId: userId,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      jobs: jobs ?? this.jobs,
      allowChat: allowChat ?? this.allowChat,
      friends: friends ?? this.friends,
      blockedUsers: blockedUsers ?? this.blockedUsers,
      activeWidgets: activeWidgets ?? this.activeWidgets,
    );
  }
}

class JobModel {
  final String id;
  final String name; // 알바 이름
  final String role; // 'boss' or 'employee'
  final double hourlyWage;
  final String chatroomCode; // 사장님용 채팅방 코드

  JobModel({
    required this.id,
    required this.name,
    required this.role,
    this.hourlyWage = 0,
    this.chatroomCode = '',
  });

  factory JobModel.fromMap(Map<String, dynamic> map) {
    return JobModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'employee',
      hourlyWage: (map['hourlyWage'] ?? 0).toDouble(),
      chatroomCode: map['chatroomCode'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'role': role,
      'hourlyWage': hourlyWage,
      'chatroomCode': chatroomCode,
    };
  }
}
