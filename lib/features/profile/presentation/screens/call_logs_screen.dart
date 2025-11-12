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
      padding: EdgeInsets.zero,
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
                    nameInitial,
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
}
