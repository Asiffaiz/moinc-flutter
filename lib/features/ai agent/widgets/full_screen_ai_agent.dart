import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/ai%20agent/app.dart';

class FullScreenAIAgent extends StatefulWidget {
  final VoidCallback onClose;

  const FullScreenAIAgent({Key? key, required this.onClose}) : super(key: key);

  @override
  State<FullScreenAIAgent> createState() => _FullScreenAIAgentState();
}

class _FullScreenAIAgentState extends State<FullScreenAIAgent> {
  @override
  void initState() {
    super.initState();
    // Hide status bar and bottom navigation when in full screen
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  @override
  void dispose() {
    // Restore system UI when widget is disposed
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppTheme.secondaryColor,
      child: Stack(
        children: [
          // Main content
          const SafeArea(child: VoiceAssistantApp()),

          // Close button
          Positioned(
            top: 40,
            right: 16,
            child: SafeArea(
              child: CloseButton(
                onPressed: widget.onClose,
                color: AppTheme.primaryColor,
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all(
                    Colors.white.withOpacity(0.2),
                  ),
                  shape: MaterialStateProperty.all(const CircleBorder()),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
