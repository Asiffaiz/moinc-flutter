import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/reports/domain/models/reports_model.dart';
import 'package:moinc/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:moinc/features/reports/presentation/screens/report_webview_screen.dart';
import 'package:moinc/utils/custom_toast.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    // Load reports from API
    context.read<ReportsBloc>().add(LoadReportsData());
  }

  // Refresh reports from API
  Future<void> _refreshReports() async {
    context.read<ReportsBloc>().add(LoadReportsData());
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
            CustomToast.showCustomeToast(
              state.errorMessage,
              AppTheme.errorColor,
            );
          }
        },
        builder: (context, state) {
          // Show loading indicator
          if (state is ReportsLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          // Show URL loading indicator but keep the list visible in background
          if (state is ReportUrlLoading) {
            if (state.reportsData.isNotEmpty) {
              return Stack(
                children: [
                  RefreshIndicator(
                    onRefresh: _refreshReports,
                    color: AppTheme.primaryColor,
                    child: _buildUnsignedAgreementsList(state.reportsData),
                  ),
                  const Center(child: CircularProgressIndicator()),
                ],
              );
            }
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            );
          }

          // Show "no reports" message (user-friendly)
          if (state is ReportsNoData) {
            return RefreshIndicator(
              onRefresh: _refreshReports,
              color: AppTheme.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.description_outlined,
                            size: 60,
                            color: AppTheme.primaryColor.withOpacity(0.5),
                          ),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: Text(
                              state.message,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: _refreshReports,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Refresh'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Show error message with retry button
          if (state is ReportsError) {
            return RefreshIndicator(
              onRefresh: _refreshReports,
              color: AppTheme.primaryColor,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.6,
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: Colors.red,
                            size: 60,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Something went wrong. Please try again',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          if (state.errorMessage.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                              ),
                              child: Text(
                                state.errorMessage,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          const SizedBox(height: 24),
                          ElevatedButton(
                            onPressed: () {
                              context.read<ReportsBloc>().add(
                                LoadReportsData(),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.black,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 24,
                                vertical: 12,
                              ),
                            ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          // Display reports data from any state that has it
          if (state.reportsData.isNotEmpty) {
            return RefreshIndicator(
              onRefresh: _refreshReports,
              color: AppTheme.primaryColor,
              child: _buildUnsignedAgreementsList(state.reportsData),
            );
          }

          // Show empty state if no reports are available
          return RefreshIndicator(
            onRefresh: _refreshReports,
            color: AppTheme.primaryColor,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.6,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'No reports found',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _refreshReports,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                          ),
                          child: const Text('Refresh'),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildUnsignedAgreementsList(List<ReportsModel> reports) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
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
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                  alignment: Alignment.topRight,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 0,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(255, 43, 68, 78),
                      border: Border.all(
                        color:
                            report.status == 'processed'
                                ? Colors.green
                                : Colors.orange,
                      ),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      capitalize(report.status),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),

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
                _buildActionButton(
                  icon: Icons.visibility,
                  labelColor: Colors.black,
                  fillColor: Colors.transparent,
                  label: 'View',
                  color: AppTheme.primaryColor,
                  onPressed:
                      report.status == 'processed' && report.reportStatus == 1
                          ? () {
                            context.read<ReportsBloc>().add(
                              GetReportUrl(reportId: report.id),
                            );
                          }
                          : null,
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
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon != null
                  ? Icon(icon, size: 16, color: Colors.black)
                  : const SizedBox(),
              const SizedBox(width: 4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 16,
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
}
