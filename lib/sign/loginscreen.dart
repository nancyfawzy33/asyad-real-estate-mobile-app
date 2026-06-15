import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart'; // 🎯 إضافة المكتبة لفحص التوكن
import '../core/api_service.dart';
import '../dashboard_screen/employee_dashboard.dart';
import '../home/home_screen.dart';
import 'createaccount.dart';
import 'reset_pass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _isLoading = false;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _storage = const FlutterSecureStorage();

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter your email and password")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. تنظيف أي توكن قديم معلق في الجهاز لتفادي مشاكل الكاش
      await _storage.delete(key: 'token');

      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.login(email, password);

      debugPrint("====== LOGIN RESPONSE DATA ======");
      debugPrint(response.data.toString());
      debugPrint("=================================");

      if (response.statusCode == 200) {
        // 2. استخراج التوكن وحفظه في الـ Secure Storage
        final token = (response.data['token'] ?? response.data['accessToken'] ?? response.data['data']?['token'])?.toString();

        if (token != null && token.isNotEmpty) {
          await _storage.write(key: 'token', value: token);
          debugPrint("💾 New Token saved successfully!");

          String role = 'user';
          var responseData = response.data;

          // 3. محاولة قراءة الـ role من الـ Response أولاً
          if (responseData is Map) {
            if (responseData.containsKey('role') && responseData['role'] != null) {
              role = responseData['role'].toString().toLowerCase().trim();
            }
            else if (responseData['data'] is Map && responseData['data'].containsKey('role') && responseData['data']['role'] != null) {
              role = responseData['data']['role'].toString().toLowerCase().trim();
            }
            else if (responseData['data'] is Map && responseData['data']['user'] is Map && responseData['data']['user'].containsKey('role')) {
              role = responseData['data']['user']['role'].toString().toLowerCase().trim();
            }
          }

          // 🎯 4. خطوة أمان إضافية: لو الـ role مجاتش من الـ Response، نفك التوكن ونقراها منه
          if (role == 'user' || role.isEmpty) {
            try {
              final decodedToken = JwtDecoder.decode(token);
              if (decodedToken.containsKey('role') && decodedToken['role'] != null) {
                role = decodedToken['role'].toString().toLowerCase().trim();
                debugPrint("👤 Role extracted safely from JWT: $role");
              }
            } catch (jwtError) {
              debugPrint("JWT Decoding Error: $jwtError");
            }
          }

          debugPrint("🎯 Final Detected Role: $role");

          if (!mounted) return;

          // 5. التوجيه بناءً على الـ Role المشتقة
          if (role == 'employee' || role == 'admin') {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const EmployeeDashboard())
            );
          } else {
            Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen())
            );
          }
        } else {
          throw Exception("Token not found in server response");
        }
      }
    } catch (e) {
      final errorMsg = Provider.of<ApiService>(context, listen: false).extractErrorMessage(e);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMsg)));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 25.0),
          child: Column(
            children: [
              const SizedBox(height: 50),
              Center(
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(15),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0095FF).withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.maps_home_work_rounded, size: 50, color: Color(0xFF0095FF)),
                    ),
                    const SizedBox(height: 10),
                    const Text("ASYAD", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF0095FF))),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(35),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 20, offset: const Offset(0, 10)),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Center(child: Text("Welcome back 👋", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold))),
                    const SizedBox(height: 8),
                    const Center(child: Text("Sign in to continue", style: TextStyle(color: Colors.grey, fontSize: 14))),
                    const SizedBox(height: 35),

                    _fieldLabel("Email"),
                    _buildTextField(_emailController, "example@email.com", false),

                    const SizedBox(height: 20),
                    _fieldLabel("Password"),
                    _buildTextField(_passwordController, "••••••••", true),

                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const ResetPass())),
                        child: const Text("Forgot password?", style: TextStyle(color: Color(0xFF0095FF), fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity, height: 55,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0095FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                          elevation: 0,
                        ),
                        child: _isLoading
                            ? const CircularProgressIndicator(color: Colors.white)
                            : const Text("Sign in", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      ),
                    ),

                    const SizedBox(height: 30),
                    _buildDivider(),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.center, // 🎯 تم تصليح السطر ده هنا
                      children: [
                        _socialIcon('https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png'),
                        const SizedBox(width: 20),
                        _socialIcon(null, icon: Icons.apple, color: Colors.black),
                        const SizedBox(width: 20),
                        _socialIcon(null, icon: Icons.facebook, color: const Color(0xFF1877F2)),
                      ],
                    ),

                    const SizedBox(height: 30),
                    _buildSignUpRedirect(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)));

  Widget _buildTextField(TextEditingController controller, String hint, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      style: const TextStyle(fontSize: 15, color: Color(0xFF1A1E25)),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
        filled: true, fillColor: const Color(0xFFFBFBFB),
        suffixIcon: isPassword ? GestureDetector(onTap: () => setState(() => _obscurePassword = !_obscurePassword), child: Padding(padding: const EdgeInsets.all(14), child: Text(_obscurePassword ? "Show" : "Hide", style: const TextStyle(color: Color(0xFF0095FF), fontWeight: FontWeight.bold, fontSize: 12)))) : null,
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFF0F0F0))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF0095FF))),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFEEEEEE))),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 10), child: Text("or continue with", style: TextStyle(color: Colors.grey.shade500, fontSize: 12))),
        const Expanded(child: Divider(thickness: 1, color: Color(0xFFEEEEEE))),
      ],
    );
  }

  Widget _socialIcon(String? url, {IconData? icon, Color? color}) {
    return Container(
      width: 70, height: 60,
      decoration: BoxDecoration(color: const Color(0xFFFBFBFB), borderRadius: BorderRadius.circular(15), border: Border.all(color: const Color(0xFFF0F0F0))),
      child: Center(
        child: url != null
            ? Image.network(url, width: 25, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 30))
            : Icon(icon, size: 30, color: color),
      ),
    );
  }

  Widget _buildSignUpRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Don't have an account? ", style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Createaccount())),
          child: const Text("Sign Up", style: TextStyle(color: Color(0xFF0095FF), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}