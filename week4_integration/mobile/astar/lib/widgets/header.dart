import 'package:flutter/material.dart';

class Header extends StatelessWidget {
  final String title;
  const Header({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.directional(
        start: 40,
        end: 40,
        top: 5,
        bottom: 40,
      ),
      child: Center(
        child: Text(
          title,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Monocraft',
            fontWeight: FontWeight.w600,
            fontSize: 40,
            shadows: [Shadow(
              color: Color.fromARGB(64, 0, 0, 0),
              offset: Offset(0, 4),
            )]
          ),
        ),
      )
    );
  }
}
