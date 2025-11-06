import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/profile/domain/models/alert_model.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({super.key});

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  bool _isLoading = false;
  final List<AlertModel> _alerts = [];

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  void _loadAlerts() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _alerts.clear();
        _alerts.addAll(_dummyAlerts);
        _isLoading = false;
      });
    });
  }

  void _markAsRead(String alertId) {
    setState(() {
      final index = _alerts.indexWhere((alert) => alert.id == alertId);
      if (index != -1) {
        _alerts[index] = _alerts[index].copyWith(isRead: true);
      }
    });
  }

  void _deleteAlert(String alertId) {
    setState(() {
      _alerts.removeWhere((alert) => alert.id == alertId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Alerts'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.done_all),
            tooltip: 'Mark all as read',
            onPressed:
                _alerts.any((alert) => !alert.isRead)
                    ? () {
                      setState(() {
                        for (var i = 0; i < _alerts.length; i++) {
                          _alerts[i] = _alerts[i].copyWith(isRead: true);
                        }
                      });
                    }
                    : null,
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : _alerts.isEmpty
              ? _buildEmptyState()
              : _buildAlertsList(),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_outlined,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No alerts',
            style: AppTheme.headingSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any alerts at the moment',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadAlerts,
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadAlerts();
      },
      color: AppTheme.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _alerts.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final alert = _alerts[index];
          return _buildAlertItem(alert);
        },
      ),
    );
  }

  Widget _buildAlertItem(AlertModel alert) {
    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (direction) {
        _deleteAlert(alert.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                alert.isRead
                    ? AppTheme.primaryColor.withOpacity(0.3)
                    : AppTheme.primaryColor,
            width: alert.isRead ? 1 : 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                if (!alert.isRead) {
                  _markAsRead(alert.id);
                }
                _showAlertDetails(context, alert);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildAlertTypeIcon(alert.type),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            alert.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  alert.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (!alert.isRead)
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.only(left: 36),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            alert.message,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.8),
                              fontSize: 14,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            DateFormat(
                              'MMM d, yyyy • h:mm a',
                            ).format(alert.timestamp),
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAlertTypeIcon(AlertType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case AlertType.info:
        iconData = Icons.info_outline;
        iconColor = Colors.blue;
        break;
      case AlertType.warning:
        iconData = Icons.warning_amber_outlined;
        iconColor = Colors.orange;
        break;
      case AlertType.error:
        iconData = Icons.error_outline;
        iconColor = Colors.red;
        break;
      case AlertType.success:
        iconData = Icons.check_circle_outline;
        iconColor = Colors.green;
        break;
    }

    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(iconData, color: iconColor, size: 16),
    );
  }

  void _showAlertDetails(BuildContext context, AlertModel alert) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  _buildAlertTypeIcon(alert.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      alert.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white70),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                DateFormat('MMMM d, yyyy • h:mm a').format(alert.timestamp),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.5),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(
                alert.message,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteAlert(alert.id);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
                    child: const Text('Close'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

// Dummy data for development
final List<AlertModel> _dummyAlerts = [
  AlertModel(
    id: '1',
    title: 'New Document Processed',
    message:
        'Your document "Company Handbook 2025" has been successfully processed and is now available in the knowledge base.',
    timestamp: DateTime.now().subtract(const Duration(hours: 2)),
    type: AlertType.success,
    isRead: false,
  ),
  AlertModel(
    id: '2',
    title: 'System Maintenance',
    message:
        'The system will undergo scheduled maintenance on November 10, 2025, from 2:00 AM to 4:00 AM UTC. Some features may be temporarily unavailable during this time.',
    timestamp: DateTime.now().subtract(const Duration(days: 1)),
    type: AlertType.info,
    isRead: true,
  ),
  AlertModel(
    id: '3',
    title: 'Document Processing Failed',
    message:
        'We encountered an error while processing your document "Technical Documentation". Please check the file format and try uploading again.',
    timestamp: DateTime.now().subtract(const Duration(days: 2)),
    type: AlertType.error,
    isRead: false,
  ),
  AlertModel(
    id: '4',
    title: 'Account Security',
    message:
        'We detected a login attempt from a new device. If this was you, you can ignore this message. Otherwise, please change your password immediately.',
    timestamp: DateTime.now().subtract(const Duration(days: 3)),
    type: AlertType.warning,
    isRead: true,
  ),
  AlertModel(
    id: '5',
    title: 'New Feature Available',
    message:
        'We\'ve added a new feature that allows you to train your AI agent with multiple documents at once. Try it out now!',
    timestamp: DateTime.now().subtract(const Duration(days: 5)),
    type: AlertType.info,
    isRead: true,
  ),
];
