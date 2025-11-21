import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';

/// Screen displayed when no AI agent is assigned to the client
class NoAgentScreen extends StatelessWidget {
  const NoAgentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: AppTheme.secondaryColor),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Icon with animated glow effect
                  _buildIconWithGlow(),

                  const SizedBox(height: 40),

                  // Main heading
                  Text(
                    'No Agent Assigned',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 16),

                  // Description
                  Text(
                    'Your AI assistant is currently not assigned to your account.',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 40),

                  // Information card
                  // _buildInfoCard(),
                  const SizedBox(height: 32),

                  // Contact support message
                  _buildContactSupport(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconWithGlow() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Container(
          width: 160,
          height: 160,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: [
                AppTheme.primaryColor.withValues(alpha: 0.3 * value),
                AppTheme.primaryColor.withValues(alpha: 0.1 * value),
                Colors.transparent,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          child: Center(
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.2),
                border: Border.all(color: AppTheme.primaryColor, width: 2),
              ),
              child: Icon(
                Icons.support_agent_outlined,
                size: 60,
                color: AppTheme.primaryColor,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.primaryColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            Icons.schedule,
            'Setup in Progress',
            'Your AI agent is being configured',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.notifications_active_outlined,
            'We\'ll Notify You',
            'You\'ll be notified once your agent is ready',
          ),
          const SizedBox(height: 16),
          _buildInfoRow(
            Icons.access_time,
            'Usually Takes',
            'Agent setup typically completes within 24 hours',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.primaryColor, size: 24),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white.withValues(alpha: 0.7),
                  height: 1.4,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactSupport() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.help_outline, color: AppTheme.primaryColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Need help? Contact our support team',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
