import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/profile/data/services/call_logs_service.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';

class CallLogsScreen extends StatefulWidget {
  const CallLogsScreen({super.key});

  @override
  State<CallLogsScreen> createState() => _CallLogsScreenState();
}

class _CallLogsScreenState extends State<CallLogsScreen> {
  // Removed SingleTickerProviderStateMixin as we don't need tabs
  // late TabController _tabController;
  late List<CallLog> _callLogs;
  final CallLogsService _callLogsService = CallLogsService();

  @override
  void initState() {
    super.initState();
    // Commented out tab controller as we're showing all logs without tabs
    // _tabController = TabController(length: 3, vsync: this);
    _callLogs = _callLogsService.getDummyCallLogs();
    _callLogs.sort(
      (a, b) => b.timestamp.compareTo(a.timestamp),
    ); // Sort by date (newest first)
  }

  @override
  void dispose() {
    // _tabController.dispose();
    super.dispose();
  }

  // Using all logs directly since we don't have tabs
  List<CallLog> get _allLogs => _callLogs;

  // Commented out since we're not using tabs
  // List<CallLog> get _livekitLogs =>
  //     _callLogs.where((log) => log.type == CallLogType.liveKit).toList();

  // List<CallLog> get _twilioLogs =>
  //     _callLogs.where((log) => log.type == CallLogType.twilio).toList();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Call Logs'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        // Commented out tab bar
        // bottom: TabBar(
        //   controller: _tabController,
        //   labelColor: AppTheme.primaryColor,
        //   unselectedLabelColor: Colors.white70,
        //   indicatorColor: AppTheme.primaryColor,
        //   tabs: const [
        //     Tab(text: 'All'),
        //     Tab(text: 'LiveKit'),
        //     Tab(text: 'Twilio'),
        //   ],
        // ),
      ),
      body: _buildCallLogsList(_allLogs),
      // Commented out tab bar view
      // body: TabBarView(
      //   controller: _tabController,
      //   children: [
      //     _buildCallLogsList(_allLogs),
      //     _buildCallLogsList(_livekitLogs),
      //     _buildCallLogsList(_twilioLogs),
      //   ],
      // ),
    );
  }

  Widget _buildCallLogsList(List<CallLog> logs) {
    if (logs.isEmpty) {
      return const Center(
        child: Text(
          'No call logs found',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }

    return ListView.builder(
      itemCount: logs.length,
      itemBuilder: (context, index) {
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
    final statusColor = _getStatusColor(log.status);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: const Icon(Icons.call, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.userName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        log.userEmail,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Agent: ${log.agentName ?? 'Maya'}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Audio Call',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.white.withOpacity(0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log.formattedDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                if (log.status == CallStatus.completed)
                  Text(
                    log.formattedDuration,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTwilioCallLogItem(TwilioCallLog log) {
    final statusColor = _getStatusColor(log.status);
    final callIcon = log.isOutgoing ? Icons.call_made : Icons.call_received;
    final callDirection = log.isOutgoing ? 'Outgoing' : 'Incoming';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppTheme.secondaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.2),
                  child: Icon(callIcon, color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        log.callerName ?? 'Unknown Caller',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        log.phoneNumber,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    log.statusText,
                    style: TextStyle(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  callDirection,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                Text(
                  'Audio Call',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Divider(color: Colors.white.withOpacity(0.1)),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  log.formattedDate,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.7),
                    fontSize: 14,
                  ),
                ),
                if (log.status == CallStatus.completed)
                  Text(
                    log.formattedDuration,
                    style: const TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(CallStatus status) {
    switch (status) {
      case CallStatus.completed:
        return Colors.green;
      case CallStatus.missed:
        return Colors.amber;
      case CallStatus.failed:
        return Colors.red;
      case CallStatus.ongoing:
        return AppTheme.primaryColor;
    }
  }
}
