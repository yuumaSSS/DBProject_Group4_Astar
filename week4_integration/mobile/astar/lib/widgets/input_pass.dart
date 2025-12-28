import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class InputPass extends StatefulWidget {
  final TextEditingController controller;
  final bool dark;

  const InputPass({super.key, required this.controller, required this.dark});

  @override
  State<InputPass> createState() => _InputPassState();
}

class _InputPassState extends State<InputPass> {
  bool _obscureText = true;
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(
      () => setState(() => _isFocused = _focusNode.hasFocus),
    );
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color titleColor = widget.dark ? Colors.white : Colors.black;
    final Color fieldColor = _isFocused
        ? (widget.dark ? const Color(0xFF2C2C2C) : Colors.white)
        : (widget.dark ? const Color(0xFF1E1E1E) : const Color(0xFFEEF2F6));
    final Color iconColor = _isFocused
        ? const Color(0xFF5B6EE1)
        : (widget.dark ? Colors.white.withAlpha(100) : const Color(0xFF9D9D9D));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Password',
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
            color: fieldColor,
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
            cursorColor: const Color(0xFF5B6EE1),
            controller: widget.controller,
            focusNode: _focusNode,
            obscureText: _obscureText,
            style: TextStyle(
              color: widget.dark ? Colors.white : Colors.black,
              fontFamily: 'Monocraft',
              fontSize: 13,
            ),
            decoration: InputDecoration(
              hintText: '*******',
              hintStyle: TextStyle(
                color: widget.dark
                    ? Colors.white.withAlpha(60)
                    : const Color(0xFF9D9D9D),
                fontFamily: 'Monocraft',
                fontSize: 12,
              ),
              prefixIcon: Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: iconColor,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscureText
                      ? Icons.visibility_off_rounded
                      : Icons.visibility_rounded,
                  color: iconColor,
                  size: 20,
                ),
                onPressed: () {
                  HapticFeedback.selectionClick();
                  setState(() => _obscureText = !_obscureText);
                },
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
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
