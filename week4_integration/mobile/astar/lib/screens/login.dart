import 'package:flutter/material.dart';
import '../widgets/input_pass.dart';
import '../widgets/button_signin.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({super.key});
  
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              InputPass(controller: passwordController),
              const SizedBox(height: 15),
              SignInButton()
            ],
          ),
        ),
      ),
    );
  }
}