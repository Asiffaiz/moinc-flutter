import 'package:flutter/material.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/dashboard/presentation/widgets/dashboard_home_content.dart';
import 'package:moinc/features/reports/presentation/screens/reports_screen.dart';
import 'package:moinc/widgets/ai_agent_form.dart';
import 'package:moinc/widgets/ai_agent_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  bool _isAgentEnabled = false; // This would come from settings in real app

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('${AppConstants.appName} AI'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Handle notifications
            },
          ),
          // IconButton(
          //   icon: const Icon(Icons.settings_outlined),
          //   onPressed: () {
          //     _showSettingsBottomSheet(context);
          //   },
          // ),
        ],
      ),
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Dashboard Tab
            _buildDashboardTab(),

            // Reports Tab
            _buildReportsTab(),

            // Profile Tab
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_outlined),
            activeIcon: Icon(Icons.analytics_outlined),
            label: 'Reports',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        backgroundColor: AppTheme.secondaryColor,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.white70,
      ),
    );
  }

  Widget _buildReportsTab() {
    return const ReportsScreen();
  }

  Widget _buildDashboardTab() {
    return DashboardHomeContent();

    // SingleChildScrollView(
    //   child: Padding(
    //     padding: const EdgeInsets.all(AppConstants.defaultPadding),
    //     child: Column(
    //       crossAxisAlignment: CrossAxisAlignment.start,
    //       children: [
    //         // Welcome section
    //         Text(
    //           'Welcome to Moinc AI',
    //           style: TextStyle(
    //             fontSize: 32,
    //             fontWeight: FontWeight.bold,
    //             color: Colors.white,
    //           ),
    //         ),
    //         const SizedBox(height: 8),
    //         Text(
    //           'Your personal AI assistant',
    //           style: TextStyle(fontSize: 18, color: Colors.white70),
    //         ),
    //         const SizedBox(height: 24),

    //         // AI Agent section
    //         _isAgentEnabled ? const AiAgentWidget() : const AiAgentForm(),

    //         const SizedBox(height: 24),

    //         // Recent activity section
    //         Text(
    //           'Recent Activity',
    //           style: TextStyle(
    //             fontSize: 28,
    //             fontWeight: FontWeight.bold,
    //             color: Colors.white,
    //           ),
    //         ),
    //         const SizedBox(height: 16),
    //         _buildRecentActivityItem(
    //           title: 'Generated content',
    //           description: 'AI generated a blog post about machine learning',
    //           time: '2 hours ago',
    //           icon: Icons.article_outlined,
    //         ),
    //         const SizedBox(height: 12),
    //         _buildRecentActivityItem(
    //           title: 'Answered question',
    //           description: 'AI provided information about Flutter development',
    //           time: '5 hours ago',
    //           icon: Icons.question_answer_outlined,
    //         ),
    //         const SizedBox(height: 12),
    //         _buildRecentActivityItem(
    //           title: 'Completed task',
    //           description: 'AI helped analyze data from your spreadsheet',
    //           time: '1 day ago',
    //           icon: Icons.task_outlined,
    //         ),
    //       ],
    //     ),
    //   ),
    // );
  }

  Widget _buildProfileTab() {
    // This will be implemented in the profile screen
    return const Center(
      child: Text('Profile Tab - Will be implemented separately'),
    );
  }

  Widget _buildRecentActivityItem({
    required String title,
    required String description,
    required String time,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor),
      ),
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
                  style: AppTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: AppTheme.bodySmall.copyWith(color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(time, style: AppTheme.bodySmall.copyWith(color: Colors.white60)),
        ],
      ),
    );
  }

  void _showSettingsBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Settings', style: AppTheme.headingSmall),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    title: const Text('Enable AI Agent Widget'),
                    subtitle: const Text(
                      'Show AI agent widget instead of form on dashboard',
                    ),
                    trailing: Switch(
                      value: _isAgentEnabled,
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        setState(() {
                          _isAgentEnabled = value;
                        });
                        // Update parent state
                        this.setState(() {});
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Dark Mode'),
                    subtitle: const Text('Switch between light and dark theme'),
                    trailing: Switch(
                      value: false, // Would be connected to theme provider
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        // Would toggle theme
                      },
                    ),
                  ),
                  const Divider(),
                  ListTile(
                    title: const Text('Enable Registration'),
                    subtitle: const Text('Allow new users to register'),
                    trailing: Switch(
                      value: true, // Would be connected to settings
                      activeColor: AppTheme.primaryColor,
                      onChanged: (value) {
                        // Would toggle registration
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        );
      },
    );
  }
}
