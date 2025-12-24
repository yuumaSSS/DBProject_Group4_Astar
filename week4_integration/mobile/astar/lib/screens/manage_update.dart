import 'package:flutter/material.dart';
import '../widgets/header.dart';
import '../widgets/wrapper_confirm.dart';

class ManageUpdateScreen extends StatefulWidget {
  const ManageUpdateScreen({super.key});

  @override
  State<ManageUpdateScreen> createState() => _ManageAddScreenState();
}

class _ManageAddScreenState extends State<ManageUpdateScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isVisible = true;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Header(title: 'Update'),
        Expanded( 
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            reverseDuration: Duration.zero,
            switchInCurve: Curves.easeOutBack,
            transitionBuilder: (Widget child, Animation<double> animation) {
              return SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0.0, 0.1),
                  end: Offset.zero,
                ).animate(animation),
                child: FadeTransition(
                  opacity: animation,
                  child: child,
                ),
              );
            },
            child: _isVisible
                ? const SingleChildScrollView(
                    key: ValueKey<String>('content'),
                    scrollDirection: Axis.vertical,
                    child: Column(
                      children: [
                        WrapperConfirm()
                      ],
                    ),
                  )
                : const SizedBox.shrink(key: ValueKey<String>('empty')),
          ),
        )
      ],
    );
  }
}