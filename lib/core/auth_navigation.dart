import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../home/home_screen.dart';
import '../sign/loginscreen.dart';
import '../dashboard_screen/employee_dashboard.dart';

/// Shared sign-out and root navigation so filter/search screens are never a dead-end.
class AuthNavigation {
  AuthNavigation._();

  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  static Future<void> logoutAndGoLogin(BuildContext context) async {
    await _storage.delete(key: 'token');
    if (!context.mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (_) => false,
    );
  }

  /// Clears stack and shows the normal user home (property feed).
  static void goToUserHome(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
          (_) => false,
    );
  }

  static void goToEmployeeDashboard(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const EmployeeDashboard()),
          (_) => false,
    );
  }
}