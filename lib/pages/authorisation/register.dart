import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../utils/error_message.dart';
import '/utils/input_field.dart';
import '/utils/submit_button.dart';
import '/constants/text_styles.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({Key? key, required this.showLoginPage}) : super(key: key);

  final VoidCallback showLoginPage;

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  late final TextEditingController _emailController;
  late final TextEditingController _passController;
  late final TextEditingController _repPassController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passController = TextEditingController();
    _repPassController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    _repPassController.dispose();
    super.dispose();
  }

  bool passwordMatch = true;

  bool checkPasswordsMatch(_) {
    setState(() {
      passwordMatch =
          (_passController.text.trim() == _repPassController.text.trim());
    });
    return passwordMatch;
  }

  Future signUp() async {
    if (checkPasswordsMatch("")) {
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[300],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.waving_hand_sharp,
                  size: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Get Started",
                  style: primary,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Register here",
                  style: secondary,
                ),
                const SizedBox(
                  height: 30,
                ),
                InputField(
                  prompt: "Enter Email ID",
                  isPassword: false,
                  controller: _emailController,
                  onChanged: (string) {},
                ),
                InputField(
                    prompt: "Enter Password",
                    isPassword: true,
                    controller: _passController,
                    onChanged: (string) {}),
                InputField(
                    prompt: "Enter Password Again",
                    isPassword: true,
                    controller: _repPassController,
                    onChanged: checkPasswordsMatch),
                ErrorMessage(
                    showErrorMessage: !passwordMatch,
                    errorMessage: "Passwords don't match"),
                SubmitButton(string: "Sign Up", action: signUp),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Already Registered?",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontSize: 14)),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                        onTap: widget.showLoginPage,
                        child: const Text("Login",
                            style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Colors.blueAccent,
                                fontSize: 14)))
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
