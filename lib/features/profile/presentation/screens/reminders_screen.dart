import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/profile/domain/models/reminder_model.dart';

class RemindersScreen extends StatefulWidget {
  const RemindersScreen({super.key});

  @override
  State<RemindersScreen> createState() => _RemindersScreenState();
}

class _RemindersScreenState extends State<RemindersScreen> {
  bool _isLoading = false;
  final List<ReminderModel> _reminders = [];

  @override
  void initState() {
    super.initState();
    _loadReminders();
  }

  void _loadReminders() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _reminders.clear();
        _reminders.addAll(_dummyReminders);
        _isLoading = false;
      });
    });
  }

  void _markAsCompleted(String reminderId) {
    setState(() {
      final index = _reminders.indexWhere(
        (reminder) => reminder.id == reminderId,
      );
      if (index != -1) {
        _reminders[index] = _reminders[index].copyWith(isCompleted: true);
      }
    });
  }

  void _deleteReminder(String reminderId) {
    setState(() {
      _reminders.removeWhere((reminder) => reminder.id == reminderId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('My Reminders'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        actions: [
          IconButton(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort reminders',
            onPressed: () {
              _showSortOptions(context);
            },
          ),
        ],
      ),
      body:
          _isLoading
              ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryColor),
              )
              : _reminders.isEmpty
              ? _buildEmptyState()
              : _buildRemindersList(),
    );
  }

  void _showSortOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.secondaryColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Text(
                  'Sort Reminders By',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              _buildSortOption(
                context,
                'Date (Upcoming first)',
                Icons.calendar_today,
              ),
              _buildSortOption(
                context,
                'Date (Recent first)',
                Icons.calendar_today_outlined,
              ),
              _buildSortOption(context, 'Importance', Icons.star),
              _buildSortOption(context, 'Type', Icons.category),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSortOption(BuildContext context, String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(title, style: const TextStyle(color: AppTheme.textColor)),
      onTap: () {
        Navigator.pop(context);
        // Implement sorting logic
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.event_note,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No reminders',
            style: AppTheme.headingSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'You don\'t have any reminders set up yet',
            style: AppTheme.bodyMedium.copyWith(color: AppTheme.lightTextColor),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _loadReminders, // For demo, reload dummy data
            icon: const Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildRemindersList() {
    return RefreshIndicator(
      onRefresh: () async {
        _loadReminders();
      },
      color: AppTheme.primaryColor,
      child: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _reminders.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final reminder = _reminders[index];
          return _buildReminderItem(reminder);
        },
      ),
    );
  }

  Widget _buildReminderItem(ReminderModel reminder) {
    final bool isUpcoming = reminder.reminderDate.isAfter(DateTime.now());
    final bool isToday =
        reminder.reminderDate.day == DateTime.now().day &&
        reminder.reminderDate.month == DateTime.now().month &&
        reminder.reminderDate.year == DateTime.now().year;

    return Dismissible(
      key: Key(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AppTheme.errorColor.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: AppTheme.textColor),
      ),
      onDismissed: (direction) {
        _deleteReminder(reminder.id);
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.secondaryColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color:
                reminder.isCompleted
                    ? Colors.grey.withOpacity(0.3)
                    : reminder.isImportant
                    ? AppTheme.primaryColor
                    : AppTheme.primaryColor.withOpacity(0.3),
            width: reminder.isImportant && !reminder.isCompleted ? 2 : 1,
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
                _showReminderDetails(context, reminder);
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        _buildReminderTypeIcon(reminder.type),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            reminder.title,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight:
                                  reminder.isCompleted
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                              decoration:
                                  reminder.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (reminder.isImportant)
                          const Icon(
                            Icons.star,
                            color: AppTheme.primaryColor,
                            size: 20,
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
                            reminder.description,
                            style: TextStyle(
                              color: AppTheme.lightTextColor,
                              fontSize: 14,
                              decoration:
                                  reminder.isCompleted
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                isToday
                                    ? Icons.today
                                    : isUpcoming
                                    ? Icons.calendar_month
                                    : Icons.event_busy,
                                size: 14,
                                color:
                                    isToday
                                        ? AppTheme.primaryColor
                                        : isUpcoming
                                        ? Colors.green
                                        : Colors.red.withOpacity(0.7),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                isToday
                                    ? 'Today, ${DateFormat('h:mm a').format(reminder.reminderDate)}'
                                    : DateFormat(
                                      'MMM d, yyyy • h:mm a',
                                    ).format(reminder.reminderDate),
                                style: TextStyle(
                                  color:
                                      isToday
                                          ? AppTheme.primaryColor
                                          : Colors.white.withOpacity(0.5),
                                  fontSize: 12,
                                  fontWeight:
                                      isToday
                                          ? FontWeight.bold
                                          : FontWeight.normal,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    if (!reminder.isCompleted && isUpcoming)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: TextButton.icon(
                            onPressed: () {
                              _markAsCompleted(reminder.id);
                            },
                            icon: const Icon(Icons.check, size: 16),
                            label: const Text('Mark as done'),
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.green,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                          ),
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

  Widget _buildReminderTypeIcon(ReminderType type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case ReminderType.birthday:
        iconData = Icons.cake;
        iconColor = Colors.pink;
        break;
      case ReminderType.meeting:
        iconData = Icons.people;
        iconColor = Colors.blue;
        break;
      case ReminderType.task:
        iconData = Icons.task_alt;
        iconColor = Colors.green;
        break;
      case ReminderType.anniversary:
        iconData = Icons.favorite;
        iconColor = Colors.red;
        break;
      case ReminderType.medication:
        iconData = Icons.medication;
        iconColor = Colors.orange;
        break;
      case ReminderType.payment:
        iconData = Icons.payment;
        iconColor = Colors.purple;
        break;
      case ReminderType.general:
        iconData = Icons.notifications;
        iconColor = AppTheme.primaryColor;
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

  void _showReminderDetails(BuildContext context, ReminderModel reminder) {
    final bool isUpcoming = reminder.reminderDate.isAfter(DateTime.now());

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
                  _buildReminderTypeIcon(reminder.type),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      reminder.title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (reminder.isImportant)
                    const Icon(Icons.star, color: AppTheme.primaryColor),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppTheme.lightTextColor),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(Icons.event, size: 16, color: AppTheme.primaryColor),
                  const SizedBox(width: 8),
                  Text(
                    DateFormat(
                      'EEEE, MMMM d, yyyy • h:mm a',
                    ).format(reminder.reminderDate),
                    style: TextStyle(
                      color: AppTheme.lightTextColor,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.primaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created on ${DateFormat('MMM d, yyyy').format(reminder.createdAt)}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: Colors.white.withOpacity(0.1)),
              const SizedBox(height: 16),
              Text(
                'Description',
                style: TextStyle(
                  color: AppTheme.primaryColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                reminder.description,
                style: const TextStyle(color: AppTheme.textColor, fontSize: 16),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (!reminder.isCompleted && isUpcoming)
                    TextButton.icon(
                      onPressed: () {
                        _markAsCompleted(reminder.id);
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text('Mark as done'),
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.green,
                      ),
                    ),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteReminder(reminder.id);
                    },
                    icon: const Icon(Icons.delete_outline, size: 18),
                    label: const Text('Delete'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // Edit reminder
                      Navigator.pop(context);
                    },
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                    ),
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
final List<ReminderModel> _dummyReminders = [
  ReminderModel(
    id: '1',
    title: 'Wife\'s Birthday',
    description: 'Buy flowers and a cake for Sarah\'s birthday celebration',
    reminderDate: DateTime.now().add(const Duration(days: 8)),
    createdAt: DateTime.now().subtract(const Duration(days: 30)),
    type: ReminderType.birthday,
    isImportant: true,
  ),
  ReminderModel(
    id: '2',
    title: 'Team Meeting',
    description: 'Weekly team meeting to discuss project progress',
    reminderDate: DateTime.now().add(const Duration(days: 1, hours: 3)),
    createdAt: DateTime.now().subtract(const Duration(days: 5)),
    type: ReminderType.meeting,
  ),
  ReminderModel(
    id: '3',
    title: 'Pay Electricity Bill',
    description:
        'Pay the electricity bill before the due date to avoid late fees',
    reminderDate: DateTime.now().subtract(const Duration(days: 2)),
    createdAt: DateTime.now().subtract(const Duration(days: 15)),
    type: ReminderType.payment,
    isCompleted: true,
  ),
  ReminderModel(
    id: '4',
    title: 'Take Blood Pressure Medication',
    description:
        'Remember to take the blood pressure medication with breakfast',
    reminderDate: DateTime(
      DateTime.now().year,
      DateTime.now().month,
      DateTime.now().day,
      9,
      0,
    ), // Today at 9:00 AM
    createdAt: DateTime.now().subtract(const Duration(days: 10)),
    type: ReminderType.medication,
    isImportant: true,
  ),
  ReminderModel(
    id: '5',
    title: 'Wedding Anniversary',
    description:
        'Our 5th wedding anniversary. Make dinner reservations at La Maison',
    reminderDate: DateTime.now().add(const Duration(days: 15)),
    createdAt: DateTime.now().subtract(const Duration(days: 60)),
    type: ReminderType.anniversary,
    isImportant: true,
  ),
  ReminderModel(
    id: '6',
    title: 'Submit Project Proposal',
    description: 'Finalize and submit the project proposal to the client',
    reminderDate: DateTime.now().add(const Duration(days: 3)),
    createdAt: DateTime.now().subtract(const Duration(days: 7)),
    type: ReminderType.task,
  ),
  ReminderModel(
    id: '7',
    title: 'Call Mom',
    description: 'Call mom to check how she\'s doing',
    reminderDate: DateTime.now().subtract(const Duration(days: 1)),
    createdAt: DateTime.now().subtract(const Duration(days: 3)),
    type: ReminderType.general,
  ),
];
