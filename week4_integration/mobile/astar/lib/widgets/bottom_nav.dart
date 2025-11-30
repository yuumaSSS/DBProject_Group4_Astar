import 'package:flutter/material.dart';

class BottomNav extends StatelessWidget {
  final String imgPath;
  final String activeImgPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const BottomNav({
    super.key,
    required this.imgPath,
    required this.activeImgPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.all(Radius.zero),
      enableFeedback: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            height: 50,
            child: Image.asset(
              isSelected ? activeImgPath : imgPath,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 1),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Monocraft',
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}