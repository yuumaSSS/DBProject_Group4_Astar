import 'package:flutter/material.dart';

class InputEmail extends StatefulWidget {
  final TextEditingController controller;
  final bool dark;

  const InputEmail({super.key, required this.controller, required this.dark});

  @override
  State<InputEmail> createState() => _InputEmailState();
}

class _InputEmailState extends State<InputEmail> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = widget.dark ? Colors.white : Colors.black;
    final Color currentIconColor = _isFocused ? Color(0xFF5B6EE1) : Color(0xFF9D9D9D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Email',
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'Monocraft',
            fontWeight: FontWeight.w600,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            color: _isFocused ? Colors.white : const Color(0xFFEEF2F6),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _isFocused ? const Color(0xFF5B6EE1) : Colors.transparent,
              width: 1.5,
            ),
            boxShadow: _isFocused
                ? [
                    BoxShadow(
                      color: const Color(0xFF5B6EE1).withAlpha(40),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: TextFormField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: const TextStyle(
              color: Colors.black,
              fontFamily: 'Monocraft',
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: 'admin@astar.com',
              hintStyle: TextStyle(
                color: Color(0xFF9D9D9D),
                fontFamily: 'Monocraft',
                fontSize: 12,
              ),
              prefixIcon: Icon(Icons.email_outlined, size: 20, color: currentIconColor,),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
