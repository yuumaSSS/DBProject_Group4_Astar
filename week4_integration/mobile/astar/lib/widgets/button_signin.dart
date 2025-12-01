import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class SignInButton extends StatelessWidget {
  const SignInButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFF5B6EE1),
      borderRadius: BorderRadius.all(Radius.zero),
      child: InkWell(
        onTap: () {
          context.go('/loading');
        },
        splashColor: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.all(Radius.zero),
        enableFeedback: false,
        child: Padding(
          padding: EdgeInsetsGeometry.directional(
            start: 5,
            end: 5,
            top: 1,
            bottom: 1,
          ),
          child: Text(
            'Sign In',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Monocraft',
              fontSize: 20,
            ),
          ),
        ),
      ),
    );
  }
}
