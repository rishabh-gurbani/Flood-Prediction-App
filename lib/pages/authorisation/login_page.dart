import '/utils/input_field.dart';
import '/utils/submit_button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'forgot_password.dart';
import '/constants/text_styles.dart';
import '/utils/error_message.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({Key? key, required this.showRegisterPage}) : super(key: key);

  final VoidCallback showRegisterPage;

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String _invalid = "test";
  bool _wrong = false;

  late final TextEditingController _emailController;
  late final TextEditingController _passController;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passController = TextEditingController();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passController.dispose();
    super.dispose();
  }

  Future signIn() async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passController.text.trim());
      setState(() {
        _wrong = false;
      });
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setState(() {
          _wrong = true;
          _invalid = 'No user found for that email.';
        });
      } else if (e.code == 'wrong-password') {
        setState(() {
          _wrong = true;
          _invalid = 'No user found for that email.';
        });
      } else {
        setState(() {
          _wrong = true;
          _invalid = 'Invalid User ID or Password';
        });
      }
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
                  Icons.waves_sharp,
                  size: 40,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Flood Prediction",
                  style: primary,
                ),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  "Welcome back",
                  style: secondary,
                ),
                const SizedBox(
                  height: 30,
                ),
                InputField(
                    prompt: "Email ID",
                    isPassword: false,
                    controller: _emailController,
                    onChanged: (string) {}),
                InputField(
                    prompt: "Password",
                    isPassword: true,
                    controller: _passController,
                    onChanged: (string) {}),
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30.0, vertical: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(context,
                              MaterialPageRoute(builder: (context) {
                            return const ForgotPassword();
                          }));
                        },
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              color: Colors.blue, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ],
                  ),
                ),
                ErrorMessage(showErrorMessage: _wrong, errorMessage: _invalid),
                SubmitButton(
                  string: "Submit",
                  action: signIn,
                ),
                const SizedBox(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("New here?",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            color: Colors.black87,
                            fontSize: 14)),
                    const SizedBox(
                      width: 4,
                    ),
                    GestureDetector(
                        onTap: widget.showRegisterPage,
                        child: const Text("Signup",
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
