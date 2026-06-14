import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import 'pass_change.dart';

class NewPass extends StatefulWidget {
  final String email;
  const NewPass({super.key, required this.email});

  @override
  State<NewPass> createState() => _NewPassState();
}

class _NewPassState extends State<NewPass> {
  bool _obscureText = true;
  int _focusedFieldIndex = 0; // 0: Reset Code, 1: New Password, 2: Confirm Password
  bool _isLoading = false;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  void _onKeyTap(String value) {
    TextEditingController activeController;
    if (_focusedFieldIndex == 0) {
      activeController = _codeController;
      if (activeController.text.length >= 6) return;
    } else if (_focusedFieldIndex == 1) {
      activeController = _passController;
    } else {
      activeController = _confirmPassController;
    }

    setState(() {
      activeController.text += value;
    });
  }

  void _onBackspace() {
    TextEditingController activeController = _focusedFieldIndex == 0
        ? _codeController
        : (_focusedFieldIndex == 1 ? _passController : _confirmPassController);

    if (activeController.text.isNotEmpty) {
      setState(() {
        activeController.text =
            activeController.text.substring(0, activeController.text.length - 1);
      });
    }
  }

  Future<void> _handleResetPassword() async {
    final code = _codeController.text.trim();
    final password = _passController.text.trim();
    final confirmPassword = _confirmPassController.text.trim();

    if (code.length < 6 || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill in all fields correctly")),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Passwords do not match")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.resetPassword(widget.email, code, password);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const PassChange()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to reset password. Check the code and try again.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FB),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildBackButton(context),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 35, horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          )
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Center(
                            child: Text(
                              "New Password 🔐",
                              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              "Enter the 6-digit code sent to ${widget.email} and your new password",
                              style: const TextStyle(fontSize: 13, color: Colors.grey),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 35),
                          const Text("Reset Code",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _buildTextField(
                              controller: _codeController,
                              index: 0,
                              hint: "6-digit code",
                              obscure: false),
                          const SizedBox(height: 20),
                          const Text("New Password",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _buildTextField(
                              controller: _passController,
                              index: 1,
                              hint: "••••••••",
                              obscure: _obscureText,
                              isPasswordField: true),
                          const SizedBox(height: 20),
                          const Text("Confirm Password",
                              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          const SizedBox(height: 8),
                          _buildTextField(
                              controller: _confirmPassController,
                              index: 2,
                              hint: "••••••••",
                              obscure: _obscureText),
                          const SizedBox(height: 35),
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleResetPassword,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0095FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                      "Reset Password",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildCustomKeyboard(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required int index,
    required String hint,
    required bool obscure,
    bool isPasswordField = false,
  }) {
    bool isFocused = _focusedFieldIndex == index;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isFocused ? const Color(0xFF0095FF) : const Color(0xFFE0E0E0),
          width: isFocused ? 1.5 : 1.0,
        ),
      ),
      child: TextField(
        controller: controller,
        readOnly: true,
        obscureText: obscure,
        obscuringCharacter: '●',
        style: const TextStyle(fontSize: 16),
        onTap: () {
          setState(() {
            _focusedFieldIndex = index;
          });
        },
        decoration: InputDecoration(
          hintText: hint,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          suffixIcon: isPasswordField
              ? GestureDetector(
                  onTap: () {
                    setState(() {
                      _obscureText = !_obscureText;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14.0),
                    child: Text(
                      _obscureText ? "Show" : "Hide",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Color(0xFF0095FF),
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildBackButton(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
      ),
    );
  }

  Widget _buildCustomKeyboard() {
    return Container(
      color: const Color(0xFFF2F2F2),
      padding: const EdgeInsets.fromLTRB(6, 10, 6, 20),
      child: Column(
        children: [
          _buildKeyboardRow(["1", "2", "3"], ["", "ABC", "DEF"]),
          const SizedBox(height: 8),
          _buildKeyboardRow(["4", "5", "6"], ["GHI", "JKL", "MNO"]),
          const SizedBox(height: 8),
          _buildKeyboardRow(["7", "8", "9"], ["PQRS", "TUV", "WXYZ"]),
          const SizedBox(height: 8),
          Row(
            children: [
              const Expanded(child: SizedBox()),
              Expanded(child: _keyboardButton("0", "")),
              Expanded(
                child: InkWell(
                  onTap: _onBackspace,
                  child: const Icon(Icons.backspace_outlined, size: 26, color: Colors.black54),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKeyboardRow(List<String> nums, List<String> letters) {
    return Row(
      children: List.generate(
        3,
        (i) => Expanded(child: _keyboardButton(nums[i], letters[i])),
      ),
    );
  }

  Widget _keyboardButton(String num, String sub) {
    return InkWell(
      onTap: () => _onKeyTap(num),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        height: 46,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 1)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(num, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
            if (sub.isNotEmpty)
              Text(sub, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
