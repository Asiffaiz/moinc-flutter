import 'package:flutter/material.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Privacy Policy',
              style: AppTheme.headingMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: November 1, 2025',
              style: AppTheme.bodySmall.copyWith(color: AppTheme.lightTextColor),
            ),
            const SizedBox(height: 24),
            Text(
              'Introduction',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This Privacy Policy explains how Moinc AI ("we", "us", or "our") collects, uses, and discloses your information when you use our mobile application (the "App").',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Information We Collect',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We may collect several types of information from and about users of our App, including:\n\n'
              '• Personal information: Name, email address, and other contact information\n'
              '• Usage data: Information about how you use the App\n'
              '• Device information: Information about your mobile device and internet connection',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'How We Use Your Information',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We use information that we collect about you or that you provide to us:\n\n'
              '• To provide and improve our App\n'
              '• To personalize your experience\n'
              '• To communicate with you\n'
              '• To analyze usage patterns',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Disclosure of Your Information',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We may disclose personal information that we collect or you provide:\n\n'
              '• To contractors, service providers, and other third parties we use to support our business\n'
              '• To comply with any court order, law, or legal process\n'
              '• To enforce our rights arising from any contracts entered into between you and us\n'
              '• To protect the rights, property, or safety of our company, our users, or others',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Data Security',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We have implemented measures designed to secure your personal information from accidental loss and from unauthorized access, use, alteration, and disclosure. However, the transmission of information via the internet is not completely secure. We cannot guarantee the security of your personal information transmitted through our App.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Changes to Our Privacy Policy',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We may update our Privacy Policy from time to time. If we make material changes to how we treat our users\' personal information, we will post the new Privacy Policy on this page and notify you through the App.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Contact Information',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'To ask questions or comment about this Privacy Policy and our privacy practices, contact us at:\n\nprivacy@moinc.ai',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
