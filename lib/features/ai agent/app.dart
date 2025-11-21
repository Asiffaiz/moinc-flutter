import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'controllers/app_ctrl.dart';
import 'screens/audio_call_screen.dart';
import 'screens/no_agent_screen.dart';

final appCtrl = AppCtrl();

class VoiceAssistantApp extends StatelessWidget {
  const VoiceAssistantApp({super.key});

  @override
  Widget build(BuildContext ctx) => Builder(
    builder:
        (ctx) => Selector<AppCtrl, bool>(
          selector: (ctx, appCtx) => appCtx.publicAgentModel != null,
          builder: (ctx, hasAgent, _) {
            // Show NoAgentScreen if no agent is assigned
            if (!hasAgent) {
              return const NoAgentScreen();
            }

            // Show AudioCallScreen if agent is assigned
            return const AudioCallScreen();

            // Original code for reference (currently not used)
            // if (screen == AppScreenState.audioCall) {
            //   return const AudioCallScreen();
            // }
            // return AppLayoutSwitcher(
            //   frontBuilder: (ctx) => const WelcomeScreen(),
            //   backBuilder: (ctx) => const AgentScreen(),
            //   isFront: screen == AppScreenState.welcome,
            // );
          },
        ),
  );
}
