import 'package:flutter/material.dart';
import '../widgets/header.dart';

class StockScreen extends StatelessWidget {
  const StockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.vertical,
      child: Column(
        children: [
          Header(title: 'Products'),
          
        ],
      ),
    );
  }
}