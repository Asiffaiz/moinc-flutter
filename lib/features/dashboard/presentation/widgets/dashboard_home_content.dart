import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:intl/intl.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/ai%20agent/app.dart';
import 'package:moinc/features/dashboard/domain/models/dashboard_data_model.dart';
import 'package:moinc/features/dashboard/presentation/bloc/bloc/dashboard_bloc.dart';
import 'package:moinc/widgets/custom_error_dialog.dart';
import 'package:moinc/widgets/dashboard_shimmer.dart';

// Dummy forms data for development
final List<AssignedFormModel> dummyForms = [
  AssignedFormModel(
    formTitle: 'Personal Information Form',
    formDesc:
        'Please complete your personal information details to help us serve you better.',
    formLink: 'form_token_123',
    formAccountno: 'ACC001',
    btnText: 'Fill Form',
    allowMultiple: 1,
    isFilled: 'No',
    filledDate: '',
    linkForm: 0,
    externalLink: '',
    agentEnable: true, // Enable AI agent for this form
  ),
  AssignedFormModel(
    formTitle: 'AI Usage Preferences',
    formDesc:
        'Tell us how you prefer to interact with our AI assistant and customize your experience.',
    formLink: 'form_token_456',
    formAccountno: 'ACC002',
    btnText: 'Update Preferences',
    allowMultiple: 0,
    isFilled: 'No',
    filledDate: '',
    linkForm: 0,
    externalLink: '',
    agentEnable: false, // Disable AI agent for this form
  ),
  AssignedFormModel(
    formTitle: 'Feedback Survey',
    formDesc:
        'We value your opinion! Please take a moment to share your thoughts about our services.',
    formLink: 'form_token_789',
    formAccountno: 'ACC003',
    btnText: 'Submit Feedback',
    allowMultiple: 1,
    isFilled: 'No',
    filledDate: '',
    linkForm: 0,
    externalLink: '',
    agentEnable: true, // Enable AI agent for this form
  ),
  AssignedFormModel(
    formTitle: 'Communication Preferences',
    formDesc:
        'Update your communication preferences to receive notifications that matter to you.',
    formLink: 'form_token_101',
    formAccountno: 'ACC004',
    btnText: 'Set Preferences',
    allowMultiple: 0,
    isFilled: 'Yes',
    filledDate: '2025-10-30',
    linkForm: 0,
    externalLink: '',
    agentEnable: false, // Disable AI agent for this form
  ),
];

class DashboardHomeContent extends StatefulWidget {
  final Function(String menuId, String? url)? onMenuItemSelected;

  const DashboardHomeContent({super.key, this.onMenuItemSelected});

  @override
  State<DashboardHomeContent> createState() => _DashboardHomeContentState();
}

class _DashboardHomeContentState extends State<DashboardHomeContent> {
  @override
  void initState() {
    super.initState();
    // Only load data if it's not already loaded
    final currentState = context.read<DashboardBloc>().state;
    if (currentState is! DashboardLoaded) {
      // For API data (production)
      // context.read<DashboardBloc>().add(LoadDashboardData());

      // For dummy data (development)
      _showDummyData();
    }
  }

  // Method to show dummy data for development
  void _showDummyData() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        final dummyData = DashboardDataModel(
          welcomeContent:
              '<h2 style="color: #D4AF37;">Welcome David!</h2><p>Your personal AI assistant is ready to help you. Explore the forms below to get started.</p>',
          assignedForms: dummyForms,
          agreementSummary: AgreementsSummaryModel(
            totalAgreements: 5,
            totalSigned: 3,
            totalNotSigned: 2,
          ),
        );
        context.read<DashboardBloc>().emit(
          DashboardLoaded(dashboardData: dummyData),
        );
      }
    });
  }

  _handleRetry() {
    context.read<DashboardBloc>().add(LoadDashboardData());
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<DashboardBloc, DashboardState>(
      listener: (context, state) {
        if (state is DashboardError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            CustomErrorDialog.show(
              context: context,
              onRetry: () {
                // Your retry logic here
                Navigator.pop(context);
                _handleRetry();
              },
            );
          });
        }
      },
      builder: (context, state) {
        if (state is DashboardLoading) {
          return const DashboardShimmer();
        }

        if (state is DashboardLoaded) {
          final dashboardData = state.dashboardData;
          return RefreshIndicator(
            onRefresh: () async {
              context.read<DashboardBloc>().add(LoadDashboardData());
            },
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Padding(
                  //   padding: const EdgeInsets.symmetric(
                  //     horizontal: 16,
                  //     vertical: 8,
                  //   ),
                  //   child: _buildStatisticsCards(dashboardData),
                  // ),
                  _buildAssignedFormsList(dashboardData),

                  // _buildCleanNumberRequestCard(),
                  // _buildLetterOfAuthorizationCard(),
                ],
              ),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  _buildAssignedFormsList(DashboardDataModel dashboardData) {
    return Column(
      children: [
        // Always show welcome content at the top
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.secondaryColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.primaryColor.withOpacity(0.5)),
            ),
            child: Html(
              data: dashboardData.welcomeContent,
              style: {
                "h2": Style(color: AppTheme.primaryColor),
                "p": Style(color: Colors.white),
                "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              },
            ),
          ),
        ),

        // Show forms if available
        dashboardData.assignedForms.isEmpty
            ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  'No forms assigned yet',
                  style: TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ),
            )
            : ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: dashboardData.assignedForms.length,
              itemBuilder: (context, index) {
                final form = dashboardData.assignedForms[index];
                return _buildFormsCard(form);
              },
            ),
      ],
    );
  }

  // Keeping this method for potential future use
  // Widget _buildAgreementsCard() {
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
  //     child: Card(
  //       elevation: 0,
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(12),
  //         side: BorderSide(color: Colors.grey.shade300),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(16),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Icon(
  //                   Icons.description_outlined,
  //                   color: AppColors.primaryColor,
  //                 ),
  //                 const SizedBox(width: 8),
  //                 const Text(
  //                   'Agreements',
  //                   style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 16),
  //             Container(
  //               decoration: BoxDecoration(
  //                 border: Border.all(color: Colors.grey.shade300),
  //                 borderRadius: BorderRadius.circular(8),
  //               ),
  //               child: Row(
  //                 children: [
  //                   Expanded(
  //                     child: _buildAgreementTab(
  //                       label: 'Signed',
  //                       count: '12',
  //                       isActive: true,
  //                     ),
  //                   ),
  //                   Expanded(
  //                     child: _buildAgreementTab(
  //                       label: 'Unsigned',
  //                       count: '12',
  //                       isActive: false,
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  IconData _getIconForTitle(String title) {
    switch (title) {
      case 'Agreements':
        return Icons.description_outlined;
      case 'Orders':
        return Icons.shopping_cart_outlined;
      case 'Commissions':
        return Icons.attach_money;
      case 'Sales':
        return Icons.trending_up;
      default:
        return Icons.info_outline;
    }
  }

  String removeHtmlTags(String htmlString) {
    final RegExp exp = RegExp(
      r'<[^>]*>',
      multiLine: true,
      caseSensitive: false,
    );
    return htmlString.replaceAll(exp, '').trim();
  }

  Widget _buildFormsCard(AssignedFormModel form) {
    return _buildInfoCard(
      title: form.formTitle,
      icon: Icons.person_search_outlined,
      description: Bidi.stripHtmlIfNeeded(form.formDesc),
      buttonText: form.btnText,
      formAccountNo: form.formAccountno,
      form: form,
      onTap: _navigateToForm(form),
    );
  }

  dynamic _navigateToForm(AssignedFormModel form) {
    if (form.allowMultiple == 0 && form.isFilled == 'Yes') {
      return null;
    } else {
      if (form.formAccountno != '' &&
          form.formLink != '' &&
          form.linkForm == 0) {
        return () {
          // Navigator.push(
          //   context,
          //   MaterialPageRoute(
          //     builder:
          //         (context) => FormMainScreen(
          //           formAccountNo: form.formAccountno,
          //           formToken: form.formLink,
          //           isFrom: 'dashboard',
          //           refreshForms: null,
          //         ),
          //   ),
          // );
        };
      }
    }
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color:
              onPressed != null
                  ? AppTheme.primaryColor.withOpacity(0.2)
                  : const Color.fromARGB(255, 43, 68, 78),
          border: Border.all(color: AppTheme.primaryColor),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: onPressed != null ? Colors.white : Colors.white70,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required String description,
    required String buttonText,
    required VoidCallback? onTap,
    required String formAccountNo,
    required AssignedFormModel form,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SizedBox(
        // width: double.infinity,
        // height: MediaQuery.of(context).size.height * 0.2,
        child: Card(
          elevation: 0,
          color: AppTheme.secondaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: AppTheme.primaryColor),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (form.agentEnable) // Only show agent button if enabled
                      InkWell(
                        onTap: () {
                          // Handle agent call button tap
                          // ScaffoldMessenger.of(context).showSnackBar(
                          //   SnackBar(
                          //     content: Text('AI Agent for $title activated'),
                          //     backgroundColor: AppTheme.primaryColor,
                          //     behavior: SnackBarBehavior.floating,
                          //   ),
                          // );

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => VoiceAssistantApp(),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.primaryColor,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.call, color: Colors.black, size: 16),
                              SizedBox(width: 4),
                              Text(
                                'Agent',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: RichText(
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        text: TextSpan(
                          style: TextStyle(fontSize: 14, color: Colors.white70),
                          children: [
                            TextSpan(text: description),

                            // TextSpan(
                            //   text: '  More',
                            //   style: TextStyle(
                            //     color: AppColors.primaryColor,
                            //     fontWeight: FontWeight.normal,
                            //   ),
                            // ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      icon: Icons.visibility,
                      label: 'Submissions',
                      color: AppTheme.primaryColor,
                      onPressed: _handleSubmissionsNavigation(
                        formAccountNo,
                        title,
                        form,
                        context,
                      ),
                    ),
                    const SizedBox(width: 30),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        width: MediaQuery.of(context).size.width * 0.7,
                        child: ElevatedButton(
                          onPressed: onTap,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 0,
                            ),
                          ),
                          child: Text(
                            buttonText,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

dynamic _handleSubmissionsNavigation(
  String formAccountNo,
  String formTitle,
  AssignedFormModel form,
  BuildContext context,
) {
  if (form.allowMultiple == 1 && form.isFilled == 'NO') {
    return null;
  } else {
    if (formAccountNo != '' && formTitle != '') {
      return () {
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder:
        //         (context) => FormSubmissionsScreen(
        //           formAccountNo: formAccountNo,
        //           formTitle: formTitle,
        //         ),
        //   ),
        // );
      };
    }
  }
}

class StatItem {
  final String label;
  final String value;

  StatItem(this.label, this.value);
}
