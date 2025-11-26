import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/reports/domain/models/reports_model.dart';
import 'package:moinc/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:moinc/features/reports/presentation/screens/report_webview_screen.dart';
import 'package:moinc/utils/custom_toast.dart';
import 'package:shimmer/shimmer.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key, this.autoLoad = false});

  final bool autoLoad;

  @override
  State<ReportsScreen> createState() => ReportsScreenState();
}

class ReportsScreenState extends State<ReportsScreen> {
  bool _hasLoaded = false;
  bool _hasShownDashboardReport =
      false; // Track if dashboard report has been shown
  bool _showDashboardWebView = false; // Track if we should show webview inline
  bool _isLoadingDashboardUrl = false; // Track if we're loading dashboard URL
  String? _dashboardReportUrl;
  WebViewController? _dashboardWebViewController;
  bool _isWebViewLoading = false;
  Timer? _sessionTimer;
  int _remainingSeconds = 10 * 60; // 10 minutes
  bool _isDialogShown = false;
  OverlayEntry? _overlayEntry;

  @override
  void initState() {
    super.initState();
    // Only load reports if autoLoad is true
    if (widget.autoLoad) {
      _loadReports();
    }
  }

  @override
  void dispose() {
    _sessionTimer?.cancel();
    _overlayEntry?.remove();
    super.dispose();
  }

  // Load reports from API
  void _loadReports() {
    if (!_hasLoaded) {
      _hasLoaded = true;
      context.read<ReportsBloc>().add(LoadReportsData());
    }
  }

  // Refresh reports from API
  Future<void> _refreshReports() async {
    context.read<ReportsBloc>().add(LoadReportsData());
  }

  // Public method to load reports (called when tab becomes visible)
  void loadReportsIfNeeded() {
    if (!_hasLoaded) {
      _loadReports();
    }
  }

  // Initialize dashboard webview
  void _initDashboardWebView() {
    if (_dashboardReportUrl == null) return;

    _dashboardWebViewController =
        WebViewController()
          ..setJavaScriptMode(JavaScriptMode.unrestricted)
          ..setNavigationDelegate(
            NavigationDelegate(
              onPageStarted: (String url) {
                setState(() {
                  _isWebViewLoading = true;
                });
              },
              onPageFinished: (String url) {
                setState(() {
                  _isWebViewLoading = false;
                });
              },
              onWebResourceError: (WebResourceError error) {
                debugPrint('WebView error: ${error.description}');
              },
            ),
          )
          ..loadRequest(Uri.parse(_dashboardReportUrl!));

    _startSessionTimer();
  }

  // Start session timer for dashboard webview
  void _startSessionTimer() {
    if (_sessionTimer != null && _sessionTimer!.isActive) {
      _sessionTimer!.cancel();
    }

    _remainingSeconds = 10 * 60; // 10 minutes
    _isDialogShown = false;
    _overlayEntry?.remove();
    _overlayEntry = null;

    _sessionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted && _showDashboardWebView) {
        setState(() {
          _remainingSeconds--;
        });

        // Show warning when 30 seconds left
        if (_remainingSeconds == 30 && !_isDialogShown) {
          _showExpiryWarningOverlay();
        }

        // Auto-refresh when time is up
        if (_remainingSeconds <= 0 && !_isDialogShown) {
          timer.cancel();
          _refreshDashboardWebView();
        }
      } else {
        timer.cancel();
      }
    });
  }

  // Refresh dashboard webview
  void _refreshDashboardWebView() {
    _sessionTimer?.cancel();
    _remainingSeconds = 10 * 60;
    _isDialogShown = false;
    _dashboardWebViewController?.reload();
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted && _showDashboardWebView) {
        _startSessionTimer();
      }
    });
  }

  // Show expiry warning overlay
  void _showExpiryWarningOverlay() {
    _isDialogShown = true;
    OverlayState? overlayState = Overlay.of(context);

    _overlayEntry = OverlayEntry(
      builder: (context) => _buildSessionExpiryOverlay(),
    );

    overlayState.insert(_overlayEntry!);
  }

  // Build session expiry overlay
  Widget _buildSessionExpiryOverlay() {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    final formattedTime = "$minutes:$seconds";
    final screenSize = MediaQuery.of(context).size;

    return Material(
      type: MaterialType.transparency,
      child: Container(
        width: screenSize.width,
        height: screenSize.height,
        color: Colors.black.withOpacity(0.5),
        child: Center(
          child: Container(
            width: screenSize.width * 0.9,
            constraints: const BoxConstraints(maxWidth: 400),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.timer, color: Colors.grey, size: 24),
                      SizedBox(width: 10),
                      Text(
                        'Session Expiring Soon',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Icon(Icons.access_time, size: 50, color: Colors.blueGrey),
                const SizedBox(height: 16),
                const Text(
                  'Your session will expire in:',
                  style: TextStyle(fontSize: 16),
                ),
                const SizedBox(height: 10),
                Text(
                  formattedTime,
                  style: const TextStyle(
                    fontSize: 48,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 16),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    'Do you want to stay signed in and extend your session?',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15),
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _overlayEntry?.remove();
                              _overlayEntry = null;
                              _isDialogShown = false;
                              setState(() {
                                _showDashboardWebView = false;
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.close, size: 16),
                                SizedBox(width: 8),
                                Text('Close', style: TextStyle(fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: SizedBox(
                          height: 40,
                          child: ElevatedButton(
                            onPressed: () {
                              _overlayEntry?.remove();
                              _overlayEntry = null;
                              _isDialogShown = false;
                              _refreshDashboardWebView();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.refresh, size: 16),
                                SizedBox(width: 8),
                                Text(
                                  'Extend Session',
                                  style: TextStyle(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Switch back to reports list
  void _showReportsList() {
    setState(() {
      _showDashboardWebView = false;
    });
    _sessionTimer?.cancel();
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // Build black shade shimmer loader
  Widget _buildBlackShimmer() {
    return Container(
      color: Colors.black,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade900,
        highlightColor: Colors.grey.shade700,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: Colors.black,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Show loading when fetching dashboard URL (don't show reports list)
    if (_isLoadingDashboardUrl) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: const Center(
          child: CircularProgressIndicator(color: AppTheme.primaryColor),
        ),
      );
    }

    // Show dashboard webview inline if enabled
    if (_showDashboardWebView && _dashboardWebViewController != null) {
      return Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: Stack(
          children: [
            WebViewWidget(controller: _dashboardWebViewController!),
            if (_isWebViewLoading) _buildBlackShimmer(),
            // Custom back button positioned at top
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 8,
              child: SafeArea(
                child: Material(
                  color: Colors.black.withOpacity(0.5),
                  borderRadius: BorderRadius.circular(8),
                  child: InkWell(
                    onTap: _showReportsList,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white, size: 18),
                          SizedBox(width: 4),
                          Text(
                            'Back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: BlocConsumer<ReportsBloc, ReportsState>(
        listener: (context, state) {
          // Check for dashboard report when reports are loaded (first time only)
          if (state is ReportsLoaded && !_hasShownDashboardReport) {
            // Find report with isDashboard = "Yes"
            ReportsModel? dashboardReport;
            try {
              dashboardReport = state.reportsData.firstWhere(
                (report) => report.isDashboard.toLowerCase() == 'yes',
              );
            } catch (e) {
              // No dashboard report found, continue with normal flow
              dashboardReport = null;
            }

            // If dashboard report found and it's processed, fetch URL and show inline
            if (dashboardReport != null &&
                dashboardReport.status == 'processed' &&
                dashboardReport.reportStatus == 1) {
              _hasShownDashboardReport = true; // Mark as shown
              _isLoadingDashboardUrl =
                  true; // Mark that we're loading dashboard URL
              // Automatically fetch URL for dashboard report
              context.read<ReportsBloc>().add(
                GetReportUrl(reportId: dashboardReport.id),
              );
            }
          }

          if (state is ReportUrlLoaded) {
            // Check if this is from dashboard report (first time) or manual selection
            if (_isLoadingDashboardUrl) {
              // This is dashboard report, show inline
              _isLoadingDashboardUrl = false;
              setState(() {
                _dashboardReportUrl = state.url;
                _showDashboardWebView = true;
              });
              _initDashboardWebView();
            } else {
              // This is a manual selection, navigate to webview screen
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => ReportWebViewScreen(
                        url: state.url,
                        title: state.title,
                      ),
                ),
              );
            }
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
