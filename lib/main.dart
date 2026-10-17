import 'package:flutter/material.dart';
import 'package:pertemuan_3/bmi_screen.dart';

void main() {
  runApp(const bmiapp());
}

class bmiapp extends StatelessWidget {
  const bmiapp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: BMIScreen(),
    );
  }
}