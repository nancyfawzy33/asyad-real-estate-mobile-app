import 'package:flutter/material.dart';
// تأكدي من أن اسم الملف هنا يطابق اسم الملف الذي يحتوي على كلاس ChangePassAdmin
import 'change_pass_admin.dart';

class EditProfileAdmin extends StatefulWidget {
  const EditProfileAdmin({super.key});

  @override
  State<EditProfileAdmin> createState() => _EditProfileAdminState();
}

class _EditProfileAdminState extends State<EditProfileAdmin> {
  final TextEditingController _nameController = TextEditingController(text: "Nancy Fawzy");
  final TextEditingController _emailController = TextEditingController(text: "example@gmail.com");
  final TextEditingController _phoneController = TextEditingController(text: "+20 10 12345678");

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25.0),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    children: [
                      const SizedBox(height: 10),
                      const Text(
                        "Edit Profile",
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B)
                        ),
                      ),

                      const Spacer(flex: 1),

                      _buildLabel("Full Name"),
                      _buildTextField(_nameController),

                      const SizedBox(height: 20),

                      _buildLabel("Email Address"),
                      _buildTextField(_emailController),

                      const SizedBox(height: 20),

                      _buildLabel("Phone Number"),
                      _buildTextField(_phoneController),

                      const SizedBox(height: 20),

                      _buildLabel("Password"),
                      _buildPasswordField(context),

                      const Spacer(flex: 2),

                      SizedBox(
                        width: double.infinity,
                        height: 55,
                        child: ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF007BFF),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)
                            ),
                            elevation: 0,
                          ),
                          child: const Text(
                            "Save Changes",
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        label,
        style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Color(0xFF64748B)
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        controller: controller,
        cursorColor: const Color(0xFF007BFF),
        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
        decoration: const InputDecoration(
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildPasswordField(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
      ),
      child: TextField(
        obscureText: true,
        readOnly: true,
        onTap: () {
          // تم تحديث الربط هنا
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const ChangePassAdmin()),
          );
        },
        decoration: InputDecoration(
          hintText: "••••••••",
          suffixIcon: TextButton(
            onPressed: () {
              // تم تحديث الربط هنا أيضاً
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ChangePassAdmin()),
              );
            },
            child: const Text(
                "Change",
                style: TextStyle(
                    color: Color(0xFF007BFF),
                    fontWeight: FontWeight.bold
                )
            ),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }
}