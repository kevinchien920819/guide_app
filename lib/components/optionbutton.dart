
import 'package:flutter/material.dart';

class OptionButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const OptionButton({super.key, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 8),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
        ),
        child: Text(label),
      ),
    );
  }
}
