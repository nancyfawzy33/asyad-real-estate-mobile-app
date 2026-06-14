import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import 'verify_code.dart';

class Createaccount extends StatefulWidget {
  const Createaccount({super.key});

  @override
  State<Createaccount> createState() => _CreateaccountState();
}

class _CreateaccountState extends State<Createaccount> {
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _handleSignUp() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text.trim();

    if (name.isEmpty || email.isEmpty || phone.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);

      final response = await apiService.register({
        'username': name,
        'email': email,
        'phoneNumber': phone,
        'password': password,
        'role': 'user',
      });

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => VerifyCode(email: email)),
        );
      }
    } catch (e) {
      final apiService = Provider.of<ApiService>(context, listen: false);
      String errorMessage = apiService.extractErrorMessage(e);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMessage), backgroundColor: Colors.redAccent),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                _buildLogo(),
                const SizedBox(height: 20),
                _buildSignUpForm(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return SizedBox(
      height: 80, width: 80,
      child: Image.asset(
        "assets/images/logo.png",
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) =>
        const Icon(Icons.business, size: 50, color: Color(0xFF0095FF)),
      ),
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("Create Account 🚀", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          const Text("Fill in your details to get started.", style: TextStyle(fontSize: 15, color: Colors.grey)),
          const SizedBox(height: 30),
          _fieldLabel("Full Name"),
          TextField(controller: _nameController, decoration: _inputDecoration("Enter your full name", Icons.person_outline)),
          const SizedBox(height: 20),
          _fieldLabel("Email Address"),
          TextField(controller: _emailController, keyboardType: TextInputType.emailAddress, decoration: _inputDecoration("example@email.com", Icons.email_outlined)),
          const SizedBox(height: 20),
          _fieldLabel("Phone Number"),
          TextField(controller: _phoneController, keyboardType: TextInputType.phone, decoration: _inputDecoration("Phone number", Icons.phone, prefixText: "+20 ", isPhone: true)),
          const SizedBox(height: 20),
          _fieldLabel("Password"),
          TextField(controller: _passwordController, obscureText: !_isPasswordVisible, decoration: _passwordDecoration()),
          const SizedBox(height: 30),
          _buildSignUpButton(),
          const SizedBox(height: 30),
          _buildDivider(),
          const SizedBox(height: 25),
          _buildSocialRow(), // هنا التعديل
          const SizedBox(height: 35),
          _buildLoginRedirect(),
        ],
      ),
    );
  }

  Widget _fieldLabel(String label) => Padding(padding: const EdgeInsets.only(bottom: 10), child: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)));

  InputDecoration _inputDecoration(String hint, IconData icon, {String prefixText = "", bool isPhone = false}) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: isPhone ? _buildPhonePrefix(prefixText) : Icon(icon, color: Colors.grey, size: 22),
      filled: true, fillColor: const Color(0xFFFBFBFB),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFF0F0F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF0095FF))),
    );
  }

  Widget _buildPhonePrefix(String prefix) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 12),
        Image.network('https://flagcdn.com/w40/eg.png', width: 25, errorBuilder: (c, e, s) => const Icon(Icons.flag, size: 20)),
        const SizedBox(width: 8),
        Text(prefix, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
        const SizedBox(width: 5),
      ],
    );
  }

  InputDecoration _passwordDecoration() {
    return InputDecoration(
      hintText: "Enter your password",
      prefixIcon: const Icon(Icons.lock_outline, color: Colors.grey, size: 22),
      suffixIcon: GestureDetector(
        onTap: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        child: Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15), child: Text(_isPasswordVisible ? "Hide" : "Show", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold))),
      ),
      filled: true, fillColor: const Color(0xFFFBFBFB),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFFF0F0F0))),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: const BorderSide(color: Color(0xFF0095FF))),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity, height: 55,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleSignUp,
        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0095FF), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)), elevation: 0),
        child: _isLoading ? const CircularProgressIndicator(color: Colors.white) : const Text("Sign Up", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
      ),
    );
  }

  Widget _buildDivider() {
    return Row(
      children: const [
        Expanded(child: Divider(thickness: 1, color: Color(0xFFE5E5E5))),
        Padding(padding: EdgeInsets.symmetric(horizontal: 10), child: Text("or sign up with", style: TextStyle(color: Colors.grey))),
        Expanded(child: Divider(thickness: 1, color: Color(0xFFE5E5E5))),
      ],
    );
  }

  // --- التعديل النهائي لأيقونة جوجل ---
  Widget _buildSocialRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _socialIcon(
          url: 'https://upload.wikimedia.org/wikipedia/commons/thumb/c/c1/Google_%22G%22_logo.svg/1200px-Google_%22G%22_logo.svg.png',
          isNetwork: true,
        ),
        const SizedBox(width: 20),
        _socialIcon(icon: Icons.apple, isNetwork: false),
        const SizedBox(width: 20),
        _socialIcon(icon: Icons.facebook, color: const Color(0xFF1877F2), isNetwork: false),
      ],
    );
  }

  Widget _socialIcon({String? url, IconData? icon, Color? color, required bool isNetwork}) {
    return Container(
      width: 70, height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFFFBFBFB),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Center(
        child: isNetwork && url != null
            ? Image.network(url, width: 28, errorBuilder: (c, e, s) => const Icon(Icons.g_mobiledata, size: 35, color: Colors.red))
            : Icon(icon, size: 30, color: color ?? Colors.black),
      ),
    );
  }

  Widget _buildLoginRedirect() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account? ", style: TextStyle(color: Colors.grey)),
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: const Text("Log In", style: TextStyle(color: Color(0xFF0095FF), fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }
}