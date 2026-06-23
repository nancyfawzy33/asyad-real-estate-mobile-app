import 'package:flutter/material.dart';
import 'package:project_app_is4/profile/payment_screen.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/api_service.dart';
import '../sign/loginscreen.dart';
import 'appointment_screen.dart';
import 'edit_profile_screen.dart';
import 'help_support_screen.dart';
import 'notifications_screen.dart';
// استيراد الشاشات الجديدة



class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _userData;
  final _storage = const FlutterSecureStorage();

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.getMe();
      if (response.statusCode == 200) {
        setState(() {
          _userData = response.data['data'];
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to load profile data")),
      );
    }
  }

  Future<void> _handleLogout() async {
    await _storage.delete(key: 'token');
    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Stack(
            clipBehavior: Clip.none,
            alignment: Alignment.topCenter,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("Log Out?", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 10),
                    const Text("Are you sure you want to log out?", textAlign: TextAlign.center, style: TextStyle(color: Colors.grey)),
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(child: TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel"))),
                        const SizedBox(width: 15),
                        Expanded(child: ElevatedButton(onPressed: () { Navigator.pop(context); _handleLogout(); }, style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text("Logout", style: TextStyle(color: Colors.white)))),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(top: -30, child: Container(padding: const EdgeInsets.all(12), decoration: const BoxDecoration(color: Color(0xFFFFF1F1), shape: BoxShape.circle), child: const Icon(Icons.priority_high_rounded, color: Colors.red, size: 30))),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final userName = _userData?['userName'] ?? _userData?['fullName'] ?? "User";
    final email = _userData?['email'] ?? "No email";

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Text(userName, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              Text(email, style: const TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),

              _buildProfileCard(Icons.edit_note_rounded, "Edit Profile", onTap: () async {
                await Navigator.push(context, MaterialPageRoute(builder: (context) => const EditProfileScreen()));
                _fetchUserData();
              }),
              _buildProfileCard(Icons.notifications_none_rounded, "Notifications", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const NotificationsScreen()))),

              // ✅ هنا تم ربط الشاشتين الجديدتين
              _buildProfileCard(Icons.calendar_today_outlined, "My Appointments", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyAppointmentsScreen()))),
              _buildProfileCard(Icons.payment_outlined, "My Payments", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPaymentsScreen()))),

              _buildProfileCard(Icons.help_outline_rounded, "Help & Support", onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const HelpSupportScreen()))),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton.icon(
                  onPressed: () => _showLogoutDialog(context),
                  icon: const Icon(Icons.logout_rounded),
                  label: const Text("Log Out"),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFEBEE), foregroundColor: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileCard(IconData icon, String title, {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFE2E8F0))),
        child: Row(
          children: [
            Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: const Color(0xFFF1F5F9), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: const Color(0xFF007BFF))),
            const SizedBox(width: 15),
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            const Spacer(),
            const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}