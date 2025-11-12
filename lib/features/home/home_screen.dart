import 'package:flutter/material.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/dashboard/presentation/widgets/dashboard_home_content.dart';
import 'package:moinc/features/documents/presentation/screens/documents_screen.dart';
import 'package:moinc/features/profile/presentation/screens/profile_screen.dart';
import 'package:moinc/features/reports/presentation/screens/reports_screen.dart';
import 'package:provider/provider.dart';
import '../ai%20agent/controllers/app_ctrl.dart' as app_ctrl;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final connectionState = context.watch<app_ctrl.AppCtrl>().connectionState;
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar:
          connectionState == app_ctrl.ConnectionState.disconnected
              ? AppBar(
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
              )
              : null,
      body: SafeArea(
        child: IndexedStack(
          index: _currentIndex,
          children: [
            // Dashboard Tab
            _buildDashboardTab(),

            // Documents Tab
            const DocumentsScreen(),

            // Reports Tab
            _buildReportsTab(),

            // Profile Tab
            _buildProfileTab(),
          ],
        ),
      ),
      bottomNavigationBar:
          connectionState == app_ctrl.ConnectionState.disconnected
              ? BottomNavigationBar(
                currentIndex: _currentIndex,
                onTap: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Image.asset(
                      'assets/icons/ic_home.png',
                      height: 24,
                      width: 24,
                      color: Colors.white,
                    ),
                    activeIcon: Image.asset(
                      'assets/icons/ic_home.png',
                      height: 24,
                      width: 24,
                      color: AppTheme.primaryColor,
                    ),
                    label: 'Home',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.folder_outlined),
                    activeIcon: Icon(Icons.folder),
                    label: 'Documents',
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.analytics_outlined),
                    activeIcon: Icon(Icons.analytics),
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
              )
              : null,
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
    //
    //         // AI Agent section
    //         _isAgentEnabled ? const AiAgentWidget() : const AiAgentForm(),
    //
    //         const SizedBox(height: 24),
    //
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
    return const ProfileScreen();
  }
}
