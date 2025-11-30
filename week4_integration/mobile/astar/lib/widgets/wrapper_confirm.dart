import 'package:flutter/material.dart';
import '../widgets/button_cancel.dart';
import '../widgets/button_done.dart';

class WrapperConfirm extends StatefulWidget {
  const WrapperConfirm({super.key});

  @override
  State<WrapperConfirm> createState() => _WrapperConfirmState();
}

class _WrapperConfirmState extends State<WrapperConfirm> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsetsGeometry.directional(
        start: 40,
        end: 40,
        top: 40,
        bottom: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          CancelButton(route: '/manage'),
          DoneButton(route: '/manage')
        ],
      ),
    );
  }
}