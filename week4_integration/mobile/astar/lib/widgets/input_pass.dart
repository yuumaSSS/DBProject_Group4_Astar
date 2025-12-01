import 'package:flutter/material.dart';

class InputPass extends StatefulWidget {
  final TextEditingController controller;

  const InputPass({
    super.key,
    required this.controller,
  });

  @override
  State<InputPass> createState() => _InputPassState();
}

class _InputPassState extends State<InputPass> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            fontSize: 16,
            fontFamily: 'Monocraft'
          ),
        ),
        
        TextFormField(
          controller: widget.controller,
          obscureText: _obscureText,
          style: TextStyle(
            color: Colors.black,
            fontFamily: 'Monocraft'
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Color(0xFFD6E1EC),
            border: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.all(Radius.zero)
            ),
            hintText: '*******',
            hintStyle: const TextStyle(
              color: Color(0xFF9D9D9D),
              fontFamily: 'Monocraft',
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: () {
                setState(() {
                  _obscureText = !_obscureText;
                });
              },
            ),
          ),
        )
      ],
    );
  }
}