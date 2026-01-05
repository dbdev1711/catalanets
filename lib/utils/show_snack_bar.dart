import 'package:flutter/material.dart';

void showSnackBar(BuildContext context, String text, {Color color = Colors.redAccent}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(text, style: TextStyle(fontSize: 18)),
      backgroundColor: color,
      duration: const Duration(seconds: 4),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
    ),
  );
}