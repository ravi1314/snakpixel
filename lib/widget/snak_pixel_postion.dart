import 'package:flutter/material.dart';

class MySnakePixel extends StatelessWidget {
  const MySnakePixel({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Container(
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(4)),
      ),
    );
  }
}
