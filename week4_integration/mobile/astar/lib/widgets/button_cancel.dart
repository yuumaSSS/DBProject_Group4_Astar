import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CancelButton extends StatelessWidget {
  final String route;
  const CancelButton({
    super.key,
    required this.route
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Color(0xFFFF0004),
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () => context.go(route),
        splashColor: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.circular(20),
        enableFeedback: false,
        child: Container(
          width: 150,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          alignment: Alignment.center,
          child: Text(
            'Cancel',
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Monocraft',
              fontSize: 30
            ),
          ),
        )
      ),
    );
  }
}
