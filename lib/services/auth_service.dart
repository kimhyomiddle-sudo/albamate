import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoggedIn = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoggedIn => _isLoggedIn;

  // 앱 시작 시 로그인 상태 확인
  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    final uid = prefs.getString('uid');
    if (uid != null) {
      final name = prefs.getString('name') ?? '';
      final email = prefs.getString('email') ?? '';
      final userId = prefs.getString('userId') ?? '';
      final gender = prefs.getString('gender') ?? '';
      final age = prefs.getInt('age') ?? 0;
      final allowChat = prefs.getBool('allowChat') ?? true;
      final activeWidgets =
          prefs.getStringList('activeWidgets') ?? [];

      _currentUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        userId: userId,
        gender: gender,
        age: age,
        allowChat: allowChat,
        activeWidgets: activeWidgets,
      );
      _isLoggedIn = true;
      notifyListeners();
    }
  }

  Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6) {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('email') ?? '';
      final savedPassword = prefs.getString('password') ?? '';

      if (savedEmail == email && savedPassword == password) {
        await checkLoginStatus();
        return true;
      }
    }
    return false;
  }

  Future<bool> register({
    required String email,
    required String password,
    required String name,
    required String userId,
    String gender = '',
    int age = 0,
  }) async {
    await Future.delayed(const Duration(seconds: 1));
    if (email.isNotEmpty && password.length >= 6 && name.isNotEmpty) {
      final prefs = await SharedPreferences.getInstance();
      final uid = DateTime.now().millisecondsSinceEpoch.toString();

      await prefs.setString('uid', uid);
      await prefs.setString('email', email);
      await prefs.setString('password', password);
      await prefs.setString('name', name);
      await prefs.setString('userId', userId);
      await prefs.setString('gender', gender);
      await prefs.setInt('age', age);
      await prefs.setBool('allowChat', true);
      await prefs.setStringList('activeWidgets', []);

      _currentUser = UserModel(
        uid: uid,
        name: name,
        email: email,
        userId: userId,
        gender: gender,
        age: age,
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<void> updateUser(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('name', user.name);
    await prefs.setString('gender', user.gender);
    await prefs.setInt('age', user.age);
    await prefs.setBool('allowChat', user.allowChat);
    await prefs.setStringList('activeWidgets', user.activeWidgets);

    _currentUser = user;
    notifyListeners();
  }

  Future<void> addWidget(String widgetId) async {
    if (_currentUser == null) return;
    final widgets = List<String>.from(_currentUser!.activeWidgets);
    if (!widgets.contains(widgetId)) {
      widgets.add(widgetId);
      await updateUser(_currentUser!.copyWith(activeWidgets: widgets));
    }
  }

  Future<void> removeWidget(String widgetId) async {
    if (_currentUser == null) return;
    final widgets = List<String>.from(_currentUser!.activeWidgets);
    widgets.remove(widgetId);
    await updateUser(_currentUser!.copyWith(activeWidgets: widgets));
  }

  Future<void> addJob(JobModel job) async {
    if (_currentUser == null) return;
    final jobs = List<JobModel>.from(_currentUser!.jobs);
    jobs.add(job);
    await updateUser(_currentUser!.copyWith(jobs: jobs));
  }

  Future<void> removeJob(String jobId) async {
    if (_currentUser == null) return;
    final jobs = _currentUser!.jobs.where((j) => j.id != jobId).toList();
    await updateUser(_currentUser!.copyWith(jobs: jobs));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('uid');
    _currentUser = null;
    _isLoggedIn = false;
    notifyListeners();
  }
}