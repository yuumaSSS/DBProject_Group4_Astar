import 'package:flutter/material.dart';
import '../widgets/button_signin.dart';
import '../widgets/input_email.dart';
import '../widgets/input_pass.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late final TextEditingController emailController;
  late final TextEditingController passController;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: isDarkMode ? Colors.black : Colors.white,
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  height: 160,
                  child: Image.asset(
                    isDarkMode
                        ? 'assets/images/icons/icon_d.png'
                        : 'assets/images/icons/icon.png',
                    fit: BoxFit.contain,
                  ),
                ),
                const SizedBox(height: 20),

                InputEmail(controller: emailController, dark: isDarkMode),
                const SizedBox(height: 20),

                InputPass(controller: passController, dark: isDarkMode),

                const SizedBox(height: 35),

                SignInButton(email: emailController, pass: passController, dark: isDarkMode,),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
