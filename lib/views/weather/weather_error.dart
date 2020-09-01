import 'package:flutter/material.dart';

class ErrorView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 240),
      child: Text(
        "Error fetching weather details".toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Colors.red[400],
          fontSize: 32,
        ),
      ),
    );
  }
}
