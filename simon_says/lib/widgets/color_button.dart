import 'package:flutter/material.dart';

class ColorButton extends StatelessWidget {
  final Color color;
  final bool isLit;
  final VoidCallback onPressed;

  const ColorButton({
    super.key,
    required this.color,
    required this.isLit,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      decoration: BoxDecoration(
        color: isLit
            ? (color == Colors.white ? Colors.grey : Colors.white)
            : color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          if (isLit)
            BoxShadow(
              color: color == Colors.white ? Colors.grey : color,
              blurRadius: 20,
              spreadRadius: 5,
            ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const SizedBox.expand(),
      ),
    );
  }
}
