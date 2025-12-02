import 'package:flutter/material.dart';
import '../widgets/input_email.dart';
import '../widgets/input_pass.dart';
import '../widgets/button_signin.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(50.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(
                    height: 180,
                    child: Image.asset(
                      'assets/images/icons/logo_login.png',
                      fit: BoxFit.contain,
                    ),
                  ),
                  const SizedBox(height: 40),

                  InputEmail(controller: emailController),
                  const SizedBox(height: 15),
                  InputPass(controller: passController),
                  const SizedBox(height: 15),

                  SignInButton(email: emailController, pass: passController),
                ],
              ),
            ),
          ),
      ),
    );
  }
}
