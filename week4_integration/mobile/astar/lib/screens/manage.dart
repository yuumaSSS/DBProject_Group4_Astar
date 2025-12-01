import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../widgets/header.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header(title: 'Manage'),

        Expanded(
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _MenuButton(
                  label: 'ADD',
                  color: const Color(0xFF008000),
                  onTap: () => context.go('/manage/add'),
                ),
                
                const SizedBox(height: 20),
                
                _MenuButton(
                  label: 'UPDATE',
                  color: const Color(0xFF5B6EE1),
                  onTap: () => context.go('/manage/update'),
                ),

                const SizedBox(height: 20),

                _MenuButton(
                  label: 'DELETE',
                  color: const Color(0xFFFF0004),
                  onTap: () => context.go('/manage/delete'),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _MenuButton({
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: color,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        splashColor: const Color.fromARGB(255, 216, 216, 216),
        borderRadius: BorderRadius.circular(20),
        enableFeedback: false,
        child: Container(
          width: 200,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
          alignment: Alignment.center,
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontFamily: 'Monocraft',
              fontSize: 30
            ),
          ),
        ),
      ),
    );
  }
}