import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/ai%20agent/controllers/app_ctrl.dart'
    as app_ctrl;
import 'package:moinc/features/profile/data/services/call_logs_service.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';
import 'package:moinc/features/profile/presentation/screens/call_log_detail_screen.dart';
import 'package:provider/provider.dart';

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({super.key});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  final CallLogsService _callLogsService = CallLogsService();

  // API response data
  List<CallLog> _callLogs = [];
  bool _isLoading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Pagination
  int _currentPage = 1;
  int _totalPages = 1;
  bool _hasMoreData = false;
  bool _isLoadingMore = false;
  final int _itemsPerPage = 25;

  // Scroll controller for pagination
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchCallLogs();

    // Add scroll listener for pagination
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_scrollListener);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll listener for pagination
  void _scrollListener() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent - 200 &&
        !_isLoadingMore &&
        _hasMoreData) {
      _loadMoreData();
    }
  }

  // Fetch initial call logs
  Future<void> _fetchCallLogs() async {
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final appCtrl = context.read<app_ctrl.AppCtrl>();
      final partnerAccountNo = appCtrl.publicAgentModel?.partnerAccountNo ?? "";
      final response = await _callLogsService.fetchCallLogs(
        page: _currentPage,
        limit: _itemsPerPage,
        partnerAccountNo: partnerAccountNo,
      );
      final logs = _callLogsService.convertApiResponseToCallLogs(response);

      setState(() {
        _callLogs = logs;
        _totalPages = response.pagination.totalPages;
        _hasMoreData = response.pagination.hasNext;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
        _errorMessage = e.toString();

        // Fallback to dummy data if API fails
        _callLogs = _callLogsService.getDummyCallLogs();
      });
    }
  }

  // Load more data when scrolling
  Future<void> _loadMoreData() async {
    if (_isLoadingMore) return;

    setState(() {
      _isLoadingMore = true;
    });

    try {
      final nextPage = _currentPage + 1;
      final response = await _callLogsService.fetchCallLogs(
        page: nextPage,
        limit: _itemsPerPage,
      );
      final newLogs = _callLogsService.convertApiResponseToCallLogs(response);

      setState(() {
        _callLogs.addAll(newLogs);
        _currentPage = nextPage;
        _hasMoreData = response.pagination.hasNext;
        _isLoadingMore = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingMore = false;
      });
    }
  }

  // Refresh call logs
  Future<void> _refreshCallLogs() async {
    setState(() {
      _currentPage = 1;
    });
    await _fetchCallLogs();
    return Future.value();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body:
          _isLoading
              ? _buildLoadingIndicator()
              : _hasError
              ? _buildErrorView()
              : RefreshIndicator(
                onRefresh: _refreshCallLogs,
                color: AppTheme.primaryColor,
                child: _buildCallLogsList(_callLogs),
              ),
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: CircularProgressIndicator(color: AppTheme.primaryColor),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(
            'Failed to load call logs',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 8),
          Text(
            _errorMessage,
            style: TextStyle(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _fetchCallLogs,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildCallLogsList(List<CallLog> logs) {
    if (logs.isEmpty) {
      // Return a scrollable widget for RefreshIndicator to work
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height * 0.6,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'No call logs found',
                    style: TextStyle(color: Colors.white70),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _refreshCallLogs,
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
      );
    }

    return ListView.builder(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(), // Enable pull-to-refresh
      itemCount: logs.length + (_hasMoreData ? 1 : 0),
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        if (index == logs.length) {
          // Show loading indicator at the bottom
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Center(
              child: CircularProgressIndicator(color: AppTheme.primaryColor),
            ),
          );
        }

        final log = logs[index];
        return _buildCallLogItem(log);
      },
    );
  }

  Widget _buildCallLogItem(CallLog log) {
    // Different UI based on call type
    if (log is LiveKitCallLog) {
      return _buildLiveKitCallLogItem(log);
    } else if (log is TwilioCallLog) {
      return _buildTwilioCallLogItem(log);
    }

    return const SizedBox.shrink(); // Fallback
  }

  Widget _buildLiveKitCallLogItem(LiveKitCallLog log) {
    // Status color is now handled directly in the UI
    // Get initials for known users, use icon for unknown
    final nameInitials =
        log.userName.isNotEmpty
            ? log.userName
                .split(' ')
                .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
                .take(2)
                .join('')
            : '';
    final isUnknown =
        log.userName.isEmpty || log.userName.toLowerCase() == 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
        ),
      ),
      child: ListTile(
        onTap: () => _navigateToCallDetails(log),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              log.status == CallStatus.missed || log.status == CallStatus.failed
                  ? Colors.red.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.2),
          child:
              isUnknown
                  ? Icon(
                    Icons.person,
                    color:
                        log.status == CallStatus.missed ||
                                log.status == CallStatus.failed
                            ? Colors.red
                            : AppTheme.primaryColor,
                    size: 20,
                  )
                  : Text(
                    nameInitials,
                    style: TextStyle(
                      color:
                          log.status == CallStatus.missed ||
                                  log.status == CallStatus.failed
                              ? Colors.red
                              : AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
        ),
        title: Text(
          log.userName,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.userEmail,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            // Audio Call label removed as requested
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              log.formattedDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            if (log.status == CallStatus.missed ||
                log.status == CallStatus.failed)
              Text(
                log.statusText,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              )
            else if (log.status == CallStatus.completed)
              Text(
                log.formattedDuration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwilioCallLogItem(TwilioCallLog log) {
    final callIcon = log.isOutgoing ? Icons.call_made : Icons.call_received;
    final callDirection = log.isOutgoing ? 'Outgoing' : 'Incoming';

    // Get first letter of caller name for known callers, use person icon for unknown
    final nameInitial =
        (log.callerName?.isNotEmpty == true)
            ? log.callerName![0].toUpperCase()
            : '';
    final isUnknown =
        log.callerName == null ||
        log.callerName!.isEmpty ||
        log.callerName!.toLowerCase() == 'unknown';

    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        border: Border(
          bottom: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
        ),
      ),
      child: ListTile(
        onTap: () => _navigateToCallDetails(log),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: CircleAvatar(
          backgroundColor:
              log.status == CallStatus.missed || log.status == CallStatus.failed
                  ? Colors.red.withOpacity(0.2)
                  : AppTheme.primaryColor.withOpacity(0.2),
          child:
              isUnknown
                  ? Icon(
                    Icons.person,
                    color:
                        log.status == CallStatus.missed ||
                                log.status == CallStatus.failed
                            ? Colors.red
                            : AppTheme.primaryColor,
                    size: 20,
                  )
                  : Icon(
                    Icons.person,
                    color:
                        log.status == CallStatus.missed ||
                                log.status == CallStatus.failed
                            ? Colors.red
                            : AppTheme.primaryColor,
                    size: 20,
                  ),
          // Text(
          //   nameInitial,
          //   style: TextStyle(
          //     color:
          //         log.status == CallStatus.missed ||
          //                 log.status == CallStatus.failed
          //             ? Colors.red
          //             : AppTheme.primaryColor,
          //     fontWeight: FontWeight.bold,
          //   ),
          // ),
        ),
        title: Text(
          log.callerName ?? 'Unknown',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              log.phoneNumber,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Icon(
                  callIcon,
                  size: 14,
                  color:
                      log.status == CallStatus.missed ||
                              log.status == CallStatus.failed
                          ? Colors.red
                          : Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  callDirection,
                  style: TextStyle(
                    color:
                        log.status == CallStatus.missed ||
                                log.status == CallStatus.failed
                            ? Colors.red
                            : Colors.white.withOpacity(0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              log.formattedDate,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            if (log.status == CallStatus.missed ||
                log.status == CallStatus.failed)
              Text(
                log.statusText,
                style: const TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w500,
                  fontSize: 12,
                ),
              )
            else if (log.status == CallStatus.completed)
              Text(
                log.formattedDuration,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Status colors are now handled directly in the UI

  // Navigate to call details screen
  void _navigateToCallDetails(CallLog log) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CallLogDetailScreen(callLog: log),
      ),
    );
  }
}
