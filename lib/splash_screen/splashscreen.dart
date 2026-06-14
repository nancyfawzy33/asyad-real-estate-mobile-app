import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:provider/provider.dart';
import 'package:project_app_is4/core/api_service.dart';
import 'package:project_app_is4/onboarding/onboarding_screen1.dart';
import 'package:project_app_is4/home/home_screen.dart';
import 'package:project_app_is4/dashboard_screen/employee_dashboard.dart';
import 'package:project_app_is4/sign/loginscreen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;

    try {
      final token = await _storage.read(key: 'token');

      if (token == null || token.isEmpty) {
        _goToNextStep();
        return;
      }

      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getMe();

      if (response.statusCode == 200) {
        // --- الإصلاح هنا: استخراج الـ Role بشكل دقيق ---
        final userData = response.data['data'];

        // بنفحص الـ Role في كل الأماكن المحتملة في الـ JSON ونحوله لـ lowercase
        String role = 'user';
        if (userData != null) {
          final rawRole = userData['roleId'] is Map
              ? userData['roleId']['name']
              : (userData['role'] ?? 'user');
          role = rawRole.toString().toLowerCase();
        }

        if (!mounted) return;

        // التوجيه الصحيح بناءً على الـ Role
        if (role == 'employee' || role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const EmployeeDashboard()),
          );
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          );
        }
      } else {
        _goToNextStep();
      }
    } catch (e) {
      debugPrint("Splash Auth Error: $e");
      _goToNextStep();
    }
  }

  void _goToNextStep() {
    if (!mounted) return;
    // هنا القرار: هل يروح Onboarding ولا Login علطول؟
    // لو عايزة تروحي للوجن اللي في الصورة علطول غيريها لـ LoginScreen()
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const OnboardingScreen1()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0289FB), Color(0xFF0062B3)],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                'assets/images/logoin.png',
                height: 180,
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.business, size: 100, color: Colors.white),
              ),
              const SizedBox(height: 20),
              const Text(
                'اسم يبني مستقبل',
                style: TextStyle(fontSize: 22, color: Colors.white, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 30),
              const CircularProgressIndicator(color: Colors.white70),
            ],
          ),
        ),
      ),
    );
  }
}