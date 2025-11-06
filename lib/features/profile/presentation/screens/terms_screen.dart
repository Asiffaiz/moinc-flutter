import 'package:flutter/material.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Terms & Conditions'),
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
              'Terms & Conditions',
              style: AppTheme.headingMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Text(
              'Last updated: November 1, 2025',
              style: AppTheme.bodySmall.copyWith(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            Text(
              'Acceptance of Terms',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'By accessing or using the Moinc AI mobile application (the "App"), you agree to be bound by these Terms and Conditions. If you do not agree to these Terms, you may not use the App.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Use of the App',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You may use the App only for lawful purposes and in accordance with these Terms. You agree not to use the App:\n\n'
              '• In any way that violates any applicable law or regulation\n'
              '• To transmit any material that is harmful, threatening, or otherwise objectionable\n'
              '• To attempt to interfere with the proper functioning of the App',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Intellectual Property',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The App and its entire contents, features, and functionality are owned by Moinc AI and are protected by international copyright, trademark, and other intellectual property laws.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'User Contributions',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'The App may contain features that allow users to post, upload, or contribute content. By providing any content to the App, you grant us a non-exclusive, royalty-free, worldwide, perpetual license to use, reproduce, modify, adapt, publish, translate, distribute, and display such content.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Disclaimer of Warranties',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'THE APP IS PROVIDED "AS IS" AND "AS AVAILABLE" WITHOUT ANY WARRANTIES OF ANY KIND, EITHER EXPRESS OR IMPLIED. WE DISCLAIM ALL WARRANTIES, INCLUDING IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Limitation of Liability',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TO THE FULLEST EXTENT PERMITTED BY LAW, IN NO EVENT WILL MOINC AI BE LIABLE FOR ANY INDIRECT, SPECIAL, INCIDENTAL, CONSEQUENTIAL, OR PUNITIVE DAMAGES ARISING OUT OF OR RELATING TO YOUR USE OF THE APP.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Changes to Terms',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'We may revise and update these Terms from time to time at our sole discretion. All changes are effective immediately when we post them. Your continued use of the App following the posting of revised Terms means that you accept and agree to the changes.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Text(
              'Governing Law',
              style: AppTheme.headingSmall.copyWith(
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'These Terms and your use of the App shall be governed by and construed in accordance with the laws of the United States, without giving effect to any choice or conflict of law provision or rule.',
              style: AppTheme.bodyMedium.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
