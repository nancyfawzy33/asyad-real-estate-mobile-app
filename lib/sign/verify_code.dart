import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/api_service.dart';
import 'Accountcreatescreen.dart';

class VerifyCode extends StatefulWidget {
  final String email;
  const VerifyCode({super.key, required this.email});

  @override
  State<VerifyCode> createState() => _VerifyCodeState();
}

class _VerifyCodeState extends State<VerifyCode> {
  final List<TextEditingController> controllers =
      List.generate(6, (_) => TextEditingController());

  Timer? _timer;
  int _secondsRemaining = 45;
  bool _isTimerFinished = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _isTimerFinished = false;
      _secondsRemaining = 45;
    });
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        setState(() {
          _isTimerFinished = true;
          _timer?.cancel();
        });
      }
    });
  }

  String get timerText {
    int mins = _secondsRemaining ~/ 60;
    int secs = _secondsRemaining % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in controllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _onNumberPressed(String number) {
    for (var controller in controllers) {
      if (controller.text.isEmpty) {
        setState(() => controller.text = number);
        break;
      }
    }
  }

  void _onDeletePressed() {
    for (int i = controllers.length - 1; i >= 0; i--) {
      if (controllers[i].text.isNotEmpty) {
        setState(() => controllers[i].text = '');
        break;
      }
    }
  }

  Future<void> _handleVerify() async {
    String code = controllers.map((e) => e.text).join();
    if (code.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full 6-digit code")),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final apiService = Provider.of<ApiService>(context, listen: false);
      final response = await apiService.verifyCode(widget.email, code);

      if (response.statusCode == 200) {
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AccountCreated()),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Verification failed. Please check the code.")),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                        ),
                        child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
                      ),
                    ),
                    const SizedBox(height: 30),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 15),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 20)
                        ],
                      ),
                      child: Column(
                        children: [
                          const Text("Verify Code 📩",
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 10),
                          Text("We sent a 6-digit code to ${widget.email}",
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 14, color: Colors.grey)),
                          const SizedBox(height: 40),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(6, (index) {
                              bool isFilled = controllers[index].text.isNotEmpty;
                              return Container(
                                width: 45,
                                height: 55,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: isFilled
                                        ? const Color(0xFF0095FF)
                                        : const Color(0xFFE0E0E0),
                                    width: 2,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    controllers[index].text,
                                    style:
                                        const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            }),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isTimerFinished ? "Didn't receive code? " : "Resend code in ",
                                  style: const TextStyle(color: Colors.grey)),
                              GestureDetector(
                                onTap: _isTimerFinished ? _startTimer : null,
                                child: Text(_isTimerFinished ? "Resend Now" : timerText,
                                    style: const TextStyle(
                                        color: Color(0xFF0095FF), fontWeight: FontWeight.bold)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 40),
                          SizedBox(
                            width: double.infinity,
                            height: 55,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleVerify,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF0095FF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                elevation: 0,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text("Verify",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold)),
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
                  onTap: _onDeletePressed,
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
      children: List.generate(3, (i) => Expanded(child: _keyboardButton(nums[i], letters[i]))),
    );
  }

  Widget _keyboardButton(String num, String sub) {
    return InkWell(
      onTap: () => _onNumberPressed(num),
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
            if (sub.isNotEmpty) Text(sub, style: const TextStyle(fontSize: 8, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
