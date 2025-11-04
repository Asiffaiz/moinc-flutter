import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/reports/domain/models/reports_model.dart';
import 'package:moinc/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:moinc/features/reports/presentation/screens/report_webview_screen.dart';
import 'package:moinc/widgets/custom_error_dialog.dart';
import 'package:moinc/widgets/dashboard_shimmer.dart';

// Dummy data for reports
final List<ReportsModel> dummyReports = [
  ReportsModel(
    id: 1,
    title: 'Monthly Performance Report',
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    publishedAt: DateTime.now().subtract(const Duration(days: 3)),
    status: 'processed',
    reportStatus: 1,
    url: 'https://moinc.ai/reports/monthly-performance',
  ),
  ReportsModel(
    id: 2,
    title: 'User Engagement Analytics',
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    publishedAt: DateTime.now().subtract(const Duration(days: 8)),
    status: 'processed',
    reportStatus: 1,
    url: 'https://moinc.ai/reports/user-engagement',
  ),
  ReportsModel(
    id: 3,
    title: 'AI Usage Statistics',
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    publishedAt: DateTime.now().subtract(const Duration(days: 12)),
    status: 'processing',
    reportStatus: 0,
    url: 'https://moinc.ai/reports/ai-usage',
  ),
  ReportsModel(
    id: 4,
    title: 'Quarterly Financial Summary',
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    publishedAt: DateTime.now().subtract(const Duration(days: 25)),
    status: 'processed',
    reportStatus: 1,
    url: 'https://moinc.ai/reports/quarterly-financial',
  ),
  ReportsModel(
    id: 5,
    title: 'User Feedback Analysis',
    createdAt: DateTime.now().subtract(const Duration(days: 20)),
    publishedAt: DateTime.now().subtract(const Duration(days: 18)),
    status: 'processed',
    reportStatus: 0,
    url: 'https://moinc.ai/reports/user-feedback',
  ),
];

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Load from API in production
    // context.read<ReportsBloc>().add(LoadReportsData());
    _showDummyData();

    // For development, we can use the dummy data directly
    // Uncomment the line below to use dummy data instead of API
    // _showDummyData();
  }

  // Method to show dummy data for development
  void _showDummyData() {
    Future.delayed(Duration.zero, () {
      if (mounted) {
        context.read<ReportsBloc>().emit(
          ReportsLoaded(reportsData: dummyReports),
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // appBar: AppBar(
      //   centerTitle: true,
      //   title: const Text('Reports'),
      //   backgroundColor: AppTheme.secondaryColor,
      //   foregroundColor: AppTheme.primaryColor,
      //   // leading: CustomBackButton(
      //   //   onTap: () {
      //   //     Navigator.pop(context); // Go back
      //   //   },
      //   // ),
      // ),
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          if (state is ReportsError) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CustomErrorDialog.show(
                context: context,
                onRetry: () {
                  // Your retry logic here
                  Navigator.pop(context);
                  context.read<ReportsBloc>().add(LoadReportsData());
                },
              );
            });
          }

          if (state is ReportUrlLoaded) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        ReportWebViewScreen(url: state.url, title: state.title),
              ),
            );
          }

          if (state is ReportUrlError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.errorMessage),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          // Show loading indicator
          if (state is ReportsLoading) {
            return const DashboardShimmer();
          }

          // Show URL loading indicator but keep the list visible in background
          if (state is ReportUrlLoading) {
            if (state.reportsData.isNotEmpty) {
              return Stack(
                children: [
                  _buildUnsignedAgreementsList(state.reportsData),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            // return const DashboardShimmer();
          }

          // Show error message
          if (state is ReportsError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Something went wrong Please try again',
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            );
          }

          // Display reports data from any state that has it
          if (state.reportsData.isNotEmpty) {
            return _buildUnsignedAgreementsList(state.reportsData);
          }

          // Fallback if no reports are available
          // Show dummy data if there are no reports from API
          return _buildUnsignedAgreementsList(dummyReports);
          // If you want to show a "no reports" message instead, uncomment below
          // return Center(child: Text('No reports found', style: TextStyle(color: Colors.white, fontSize: 16)));
        },
      ),
    );
  }

  Widget _buildUnsignedAgreementsList(List<ReportsModel> reports) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: reports.length,
      itemBuilder: (context, index) {
        final report = reports[index];
        return _buildAgreementCard(report, index);
      },
    );
  }

  Widget _buildAgreementCard(ReportsModel report, int index) {
    String createdAt = DateFormat('MMMM d yyyy').format(report.createdAt);

    String publishedAt = DateFormat('MMMM d yyyy').format(report.publishedAt);
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppTheme.primaryColor),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 2,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/icons/ic_report.png',
                      width: 20,
                      height: 20,
                      color: AppTheme.primaryColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        //  agreement.title,
                        report.title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 8),
                _buildInfoRow(
                  'Created Date:',
                  createdAt,
                  AppTheme.primaryColor,
                ),
                const SizedBox(height: 8),
                _buildInfoRow(
                  'Published Date:',
                  publishedAt,
                  AppTheme.primaryColor,
                ),
                // const SizedBox(height: 8),
                // _buildDescription(agreement.description),
              ],
            ),
          ),
          Divider(height: 1, color: AppTheme.primaryColor.withOpacity(0.5)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildActionButton(
                      icon: null,
                      labelColor: Colors.white,
                      label: capitalize(report.status),
                      fillColor: const Color.fromARGB(255, 43, 68, 78),
                      color:
                          report.status == 'processed'
                              ? Colors.green
                              : Colors.orange,
                      onPressed: () {},
                    ),

                    _buildActionButton(
                      icon: null,
                      labelColor: Colors.white,
                      fillColor: Colors.green,
                      label:
                          report.reportStatus == 1
                              ? 'Published'
                              : 'Unpublished',
                      color:
                          report.reportStatus == 1
                              ? Colors.green
                              : Colors.orange,
                      onPressed: () {},
                    ),

                    _buildActionButton(
                      icon: Icons.visibility,
                      labelColor: Colors.black,
                      fillColor: Colors.transparent,
                      label: 'View',
                      color: AppTheme.primaryColor,
                      onPressed:
                          report.status == 'processed' &&
                                  report.reportStatus == 1
                              ? () {
                                context.read<ReportsBloc>().add(
                                  GetReportUrl(reportId: report.id),
                                );
                              }
                              : null,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String capitalize(String value) {
    if (value.isEmpty) {
      return value; // Return the empty string if it's empty
    }
    return "${value[0].toUpperCase()}${value.substring(1)}";
  }

  Widget _buildInfoRow(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.white70,
          ),
        ),
        const SizedBox(width: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(String description) {
    return Text(
      description,
      maxLines: 3,
      overflow: TextOverflow.ellipsis,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildStatusColumn({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required IconData? icon,
    required String label,
    required Color color,
    required Color labelColor,
    required Color fillColor,
    required VoidCallback? onPressed,
  }) {
    // Use theme colors for View button
    if (label == 'View') {
      return InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(4),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.primaryColor,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Row(
            children: [
              icon != null
                  ? Icon(icon, size: 16, color: Colors.black)
                  : const SizedBox(),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.black,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // For other status buttons
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(4),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: fillColor,
          border: Border.all(color: color),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Row(
          children: [
            icon != null
                ? Icon(icon, size: 16, color: AppTheme.primaryColor)
                : const SizedBox(),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: labelColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case 'processed':
        return Icons.check_circle_outline;
      case 'processing':
        return Icons.hourglass_empty;
      case 'approved':
        return Icons.verified;
      case 'rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.check_circle_outline;
    }
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'processed':
        return Colors.blue;
      case 'processing':
        return Colors.orange;
      case 'approved':
        return Colors.blue;
      case 'rejected':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}
