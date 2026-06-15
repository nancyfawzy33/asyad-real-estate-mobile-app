import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:project_app_is4/core/api_service.dart';
import 'package:project_app_is4/core/employee_api_service.dart';
import 'package:project_app_is4/splash_screen/splashscreen.dart';

void main() {
  // التأكد من تهيئة كل خدمات فلاتر قبل تشغيل التطبيق
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // تعريف الـ ApiService ليكون متاحاً في كل شاشات التطبيق
        Provider<ApiService>(
          create: (_) => ApiService(),
        ),
        // إضافة EmployeeApiService للتعامل مع مهام الموظفين
        Provider<EmployeeApiService>(
          create: (_) => EmployeeApiService(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Real Estate App',
      theme: ThemeData(
        // استخدام اللون الأزرق الأساسي المتناسق مع تصميمك
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF0095FF)),
        useMaterial3: true,
        fontFamily: 'Cairo',
      ),
      // نقطة الانطلاق هي الـ Splash Screen
      home: const SplashScreen(),
    );
  }
}