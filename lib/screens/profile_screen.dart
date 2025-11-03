import 'package:flutter/material.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: () {
              // Open edit profile
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Profile'),
            Tab(text: 'Privacy Policy'),
            Tab(text: 'Terms'),
          ],
          labelColor: AppTheme.primaryColor,
          unselectedLabelColor: Colors.white70,
          indicatorColor: AppTheme.primaryColor,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Profile Tab
          _buildProfileTab(),

          // Privacy Policy Tab
          _buildPrivacyPolicyTab(),

          // Terms & Conditions Tab
          _buildTermsTab(),
        ],
      ),
    );
  }

  Widget _buildProfileTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 20),

          // Profile Picture
          Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                child: const Icon(
                  Icons.person,
                  size: 60,
                  color: AppTheme.primaryColor,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Name
          Text(
            'John Doe',
            style: AppTheme.headingMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            'john.doe@example.com',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 32),

          // Profile Details
          _buildProfileDetailCard(
            title: 'Account Information',
            items: [
              _buildProfileDetailItem(
                title: 'Full Name',
                value: 'John Doe',
                icon: Icons.person_outline,
              ),
              _buildProfileDetailItem(
                title: 'Email',
                value: 'john.doe@example.com',
                icon: Icons.email_outlined,
              ),
              _buildProfileDetailItem(
                title: 'Phone',
                value: '+1 (555) 123-4567',
                icon: Icons.phone_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Preferences
          _buildProfileDetailCard(
            title: 'Preferences',
            items: [
              _buildProfileDetailItem(
                title: 'Language',
                value: 'English',
                icon: Icons.language_outlined,
              ),
              _buildProfileDetailItem(
                title: 'Notifications',
                value: 'Enabled',
                icon: Icons.notifications_outlined,
              ),
              _buildProfileDetailItem(
                title: 'Theme',
                value: 'Light',
                icon: Icons.brightness_6_outlined,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Logout Button
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                _showLogoutDialog(context);
              },
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorColor,
                side: const BorderSide(color: AppTheme.errorColor),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildPrivacyPolicyTab() {
    return SingleChildScrollView(
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
            style: AppTheme.bodySmall.copyWith(color: Colors.white70),
          ),
          const SizedBox(height: 24),
          Text(
            'Introduction',
            style: AppTheme.headingSmall
                .copyWith(color: AppTheme.primaryColor)
                .copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'This Privacy Policy explains how Moinc AI ("we", "us", or "our") collects, uses, and discloses your information when you use our mobile application (the "App").',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            'Information We Collect',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryColor),
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
            style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryColor),
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
          // Add more sections as needed
        ],
      ),
    );
  }

  Widget _buildTermsTab() {
    return SingleChildScrollView(
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
            style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'By accessing or using the Moinc AI mobile application (the "App"), you agree to be bound by these Terms and Conditions. If you do not agree to these Terms, you may not use the App.',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          Text(
            'Use of the App',
            style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryColor),
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
            style: AppTheme.headingSmall.copyWith(color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            'The App and its entire contents, features, and functionality are owned by Moinc AI and are protected by international copyright, trademark, and other intellectual property laws.',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 24),
          // Add more sections as needed
        ],
      ),
    );
  }

  Widget _buildProfileDetailCard({
    required String title,
    required List<Widget> items,
  }) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: AppTheme.headingSmall
                  .copyWith(color: AppTheme.primaryColor)
                  .copyWith(fontSize: 18, color: AppTheme.primaryColor),
            ),
          ),
          Divider(height: 1, color: AppTheme.primaryColor.withOpacity(0.5)),
          ...items,
        ],
      ),
    );
  }

  Widget _buildProfileDetailItem({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTheme.bodySmall.copyWith(color: Colors.white60),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, size: 16, color: AppTheme.primaryColor),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: AppTheme.secondaryColor,
            title: Text('Logout', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to logout?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: Text(
                  'Cancel',
                  style: TextStyle(color: AppTheme.primaryColor),
                ),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Navigate to login screen
                  Navigator.pushReplacementNamed(
                    context,
                    AppConstants.loginRoute,
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.errorColor,
                ),
                child: Text('Logout', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }
}
