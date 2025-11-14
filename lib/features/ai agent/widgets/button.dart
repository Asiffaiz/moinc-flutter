import 'package:flutter/material.dart';

/// Button shown when disconnected to start a new conversation
class Button extends StatelessWidget {
  final VoidCallback onPressed;
  final bool isProgressing;
  final bool isDisabled;
  final Color color;
  final String text;

  const Button({
    super.key,
    required this.text,
    required this.onPressed,
    this.isProgressing = false,
    this.isDisabled = false,
    this.color = Colors.indigo,
  });

  @override
  Widget build(BuildContext ctx) => TextButton(
    onPressed: isProgressing || isDisabled ? null : onPressed,
    style: TextButton.styleFrom(
      backgroundColor: color,
      foregroundColor: Colors.black,
      disabledForegroundColor: Colors.black54,
      elevation: 2,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
        side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
      ),
    ),
    child: Row(
      spacing: 15,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (isProgressing)
          const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation(Colors.black),
            ),
          ),
        Text(
          text.toUpperCase(),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}
