import 'package:facial_attendance/presentation/screens/Auth/login/login_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'dart:async';
import '../../data/database/general_db/db_helper.dart';
import 'package:provider/provider.dart';
import 'register_student_controller.dart';
import 'manage_students_controller.dart';

class HomeController extends ChangeNotifier {
  final storage = const FlutterSecureStorage();
  bool isRefreshing = false;
  String userFullName = "User";
  String greeting = "";
  Map<String, Future<int>> studentStats = {};

  HomeController() {
    _initialize();
  }

  void _initialize() {
    _loadUserInfo();
    _fetchStats();
  }

  Future<void> _loadUserInfo() async {
    String? fullName = await storage.read(key: 'fullName');
    userFullName = fullName ?? "User";
    greeting = _getGreeting();
    notifyListeners();
  }

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }

  Future<void> _fetchStats() async {
    studentStats = {
      'Total Students': _getTotalStudents(),
      'Total 100 Level': _getTotal100L(),
      'Total 200 Level': _getTotal200L(),
      'Total 300 Level': _getTotal300L(),
      'Total 400 Level': _getTotal400L(),
    };
    notifyListeners();
  }

  Future<int> _getTotalStudents() async {
    final db = await DBHelper().database;
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM students');
    return result.first['count'] as int;
  }

  Future<int> _getTotal100L() async => _countStudentsByClass("100 Level");
  Future<int> _getTotal200L() async => _countStudentsByClass("200 Level");
  Future<int> _getTotal300L() async => _countStudentsByClass("300 Level");
  Future<int> _getTotal400L() async => _countStudentsByClass("400 Level");

  Future<int> _countStudentsByClass(String className) async {
    final db = await DBHelper().database;
    final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM students WHERE presentLevel = ?',
        [className]);
    return result.first['count'] as int;
  }

  Future<void> refreshData() async {
    isRefreshing = true;
    notifyListeners();

    await _fetchStats();

    isRefreshing = false;
    notifyListeners();
  }

  Future<void> logout(BuildContext context) async {
    // Clear secure storage
    await storage.deleteAll();

    // Clear any cached data
    isRefreshing = false;
    userFullName = "User";
    greeting = "";
    studentStats = {};

    // Navigate to login page with a fresh instance
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => LoginPage(
          key: UniqueKey(),
        ),
      ),
      (route) => false, // Remove all previous routes
    );

    notifyListeners();
    print("Logout completed");
  }
}
