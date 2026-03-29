import 'package:flutter/material.dart';

class OptionCard extends StatelessWidget {
  final String text;
  final bool isSelected;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;

  const OptionCard({
    super.key,
    required this.text,
    required this.isSelected,
    this.isCorrect = false,
    this.isWrong = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color borderColor = Colors.grey.shade300;
    Color bgColor = Colors.white;
    Color textColor = Colors.black87;

    if (isCorrect) {
      borderColor = const Color(0xFF58CC02);
      bgColor = const Color(0xFFD7FFB8);
      textColor = const Color(0xFF58CC02);
    } else if (isWrong) {
      borderColor = const Color(0xFFFF4B4B);
      bgColor = const Color(0xFFFFE0E0);
      textColor = const Color(0xFFFF4B4B);
    } else if (isSelected) {
      borderColor = Colors.blueAccent;
      bgColor = Colors.blue.withAlpha(26);
      textColor = Colors.blueAccent;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 2),
          // Duolingo style subtle bottom border shadow
          boxShadow: [
            BoxShadow(
              color: isCorrect
                  ? const Color(0xFF4BA602)
                  : (isWrong
                      ? const Color(0xFFCC3B3B)
                      : (isSelected ? Colors.blue : Colors.grey.shade300)),
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: textColor,
          ),
        ),
      ),
    );
  }
}
