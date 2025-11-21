import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';

class CompactAIAgent extends StatefulWidget {
  final VoidCallback onActivate;

  const CompactAIAgent({Key? key, required this.onActivate}) : super(key: key);

  @override
  State<CompactAIAgent> createState() => _CompactAIAgentState();
}

class _CompactAIAgentState extends State<CompactAIAgent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(Icons.mic, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              const Text(
                'AI Assistant',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            'Ask me anything or get help with your tasks',
            style: TextStyle(color: AppTheme.lightTextColor, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          _buildTalkButton(),
        ],
      ),
    );
  }

  Widget _buildTalkButton() {
    return GestureDetector(
      onTap: widget.onActivate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.primaryColor,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primaryColor.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _animationController,
              builder: (context, child) {
                return Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.black.withOpacity(0.8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.white.withOpacity(_animation.value * 0.3),
                        blurRadius: 8,
                        spreadRadius: _animation.value * 2,
                      ),
                    ],
                  ),
                  child: const Icon(Icons.mic, color: Colors.white, size: 16),
                );
              },
            ),
            const SizedBox(width: 8),
            const Text(
              'Talk Now',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
