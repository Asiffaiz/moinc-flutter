import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/ai%20agent/app.dart';
import 'package:provider/provider.dart';

class AIAgentPopup extends StatelessWidget {
  const AIAgentPopup({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          // Semi-transparent overlay for the background
          GestureDetector(
            onTap: () {}, // Prevent taps from passing through
            child: Container(color: Colors.black.withOpacity(0.1)),
          ),

          // Animated container with padding to show it's floating above dashboard
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 60, 16, 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  // gradient: LinearGradient(
                  //   begin: Alignment.topCenter,
                  //   end: Alignment.bottomCenter,
                  //   colors: [
                  //     AppTheme.secondaryColor.withOpacity(0.9),
                  //     AppTheme.secondaryColor,
                  //   ],
                  // ),
                  // boxShadow: [
                  //   BoxShadow(
                  //     color: Colors.black.withOpacity(0.3),
                  //     blurRadius: 15,
                  //     spreadRadius: 5,
                  //   ),
                  // ],
                ),
                child: const VoiceAssistantApp(),
              ),
            ),
          ),

          // Close button
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: CloseButton(
                onPressed: () => Navigator.of(context).pop(),
                color: AppTheme.primaryColor,
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all(
                    Colors.white.withOpacity(0.2),
                  ),
                  shape: WidgetStateProperty.all(const CircleBorder()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to show the AI agent popup
void showAIAgentPopup(BuildContext context) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false,
    barrierLabel: 'AI Agent',
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation1, animation2) {
      return const AIAgentPopup();
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 1),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(parent: animation, curve: Curves.easeOutQuad),
        ),
        child: child,
      );
    },
  );
}
