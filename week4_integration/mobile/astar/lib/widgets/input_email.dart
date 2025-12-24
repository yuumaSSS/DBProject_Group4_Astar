import 'package:flutter/material.dart';

class InputEmail extends StatefulWidget {
  final TextEditingController controller;

  const InputEmail({
    super.key,
    required this.controller
  });

  @override
  State<InputEmail> createState() => _InputEmailState();
}

class _InputEmailState extends State<InputEmail> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Email',
          style: TextStyle(fontSize: 16, fontFamily: 'Monocraft'),
        ),

        TextFormField(
          controller: widget.controller,
          style: TextStyle(color: Colors.black, fontFamily: 'Monocraft'),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFD6E1EC),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.zero),
            ),
            hintText: 'admin@gmail.com',
            hintStyle: const TextStyle(
              color: Color(0xFF9D9D9D),
              fontFamily: 'Monocraft',
            ),
          ),
        ),
      ],
    );
  }
}
