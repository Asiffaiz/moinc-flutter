import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/ai%20agent/app.dart';
import 'package:moinc/features/ai%20agent/controllers/app_ctrl.dart';
import 'package:provider/provider.dart';

class StandaloneAIAgent extends StatefulWidget {
  const StandaloneAIAgent({Key? key}) : super(key: key);

  @override
  State<StandaloneAIAgent> createState() => _StandaloneAIAgentState();
}

class _StandaloneAIAgentState extends State<StandaloneAIAgent>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;
  bool _isFullScreen = false;

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
    // Restore system UI when widget is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  void _enterFullScreen() {
    setState(() {
      _isFullScreen = true;
    });
    // Hide status bar and navigation bar
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  void _exitFullScreen() {
    setState(() {
      _isFullScreen = false;
    });
    // Restore system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }

  @override
  Widget build(BuildContext context) {
    // Return the VoiceAssistantApp which has its own providers
    if (_isFullScreen) {
      return Material(
        color: AppTheme.secondaryColor,
        child: const SafeArea(child: VoiceAssistantApp()),
      );
    } else {
      return _buildCompactUI();
    }
  }

  Widget _buildCompactUI() {
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
            style: TextStyle(color: Colors.white70, fontSize: 14),
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
      onTap: () {
        // Connect to the AI agent
        _enterFullScreen();
        // Use the VoiceAssistantApp's appCtrl
        appCtrl.connect();
      },
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
