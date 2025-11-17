import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Notification icon with animation
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.primaryColor.withOpacity(0.1),
                ),
                child: Icon(
                  Icons.notifications_outlined,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              const SizedBox(height: 32),
              // Coming soon text
              Text(
                'Coming Soon!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),
              // const SizedBox(height: 16),
              // Description text
              // Text(
              //   'We\'re working hard to bring you an amazing notifications experience. Stay tuned!',
              //   style: TextStyle(
              //     fontSize: 16,
              //     color: Colors.white.withOpacity(0.7),
              //     height: 1.5,
              //   ),
              //   textAlign: TextAlign.center,
              // ),
              const SizedBox(height: 48),
              // Decorative icon
              Icon(
                Icons.construction_outlined,
                size: 40,
                color: AppTheme.primaryColor.withOpacity(0.5),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
