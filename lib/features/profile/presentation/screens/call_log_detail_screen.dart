import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';

class CallLogDetailScreen extends StatefulWidget {
  final CallLog callLog;

  const CallLogDetailScreen({Key? key, required this.callLog})
    : super(key: key);

  @override
  State<CallLogDetailScreen> createState() => _CallLogDetailScreenState();
}

class _CallLogDetailScreenState extends State<CallLogDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isPlaying = false;
  double _playbackPosition = 0.0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // This is called when the tab selection changes
      // We need to rebuild the UI to update the tab appearance
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  // Get initials for avatar
  String _getInitials() {
    if (widget.callLog is LiveKitCallLog) {
      final liveKitLog = widget.callLog as LiveKitCallLog;
      if (liveKitLog.userName.isEmpty ||
          liveKitLog.userName.toLowerCase() == 'unknown') {
        return '';
      }
      return liveKitLog.userName
          .split(' ')
          .map((e) => e.isNotEmpty ? e[0].toUpperCase() : '')
          .take(2)
          .join('');
    } else if (widget.callLog is TwilioCallLog) {
      final twilioLog = widget.callLog as TwilioCallLog;
      if (twilioLog.callerName == null ||
          twilioLog.callerName!.isEmpty ||
          twilioLog.callerName!.toLowerCase() == 'unknown') {
        return '';
      }
      return twilioLog.callerName![0].toUpperCase();
    }
    return '';
  }

  // Check if caller is unknown
  bool _isUnknown() {
    if (widget.callLog is LiveKitCallLog) {
      final liveKitLog = widget.callLog as LiveKitCallLog;
      return liveKitLog.userName.isEmpty ||
          liveKitLog.userName.toLowerCase() == 'unknown';
    } else if (widget.callLog is TwilioCallLog) {
      final twilioLog = widget.callLog as TwilioCallLog;
      return twilioLog.callerName == null ||
          twilioLog.callerName!.isEmpty ||
          twilioLog.callerName!.toLowerCase() == 'unknown';
    }
    return true;
  }

  // Get caller name
  String _getCallerName() {
    if (widget.callLog is LiveKitCallLog) {
      return (widget.callLog as LiveKitCallLog).userName;
    } else if (widget.callLog is TwilioCallLog) {
      return (widget.callLog as TwilioCallLog).callerName ?? 'Unknown';
    }
    return 'Unknown';
  }

  // Get caller subtitle (email or phone)
  String _getCallerSubtitle() {
    if (widget.callLog is LiveKitCallLog) {
      return (widget.callLog as LiveKitCallLog).userEmail;
    } else if (widget.callLog is TwilioCallLog) {
      return (widget.callLog as TwilioCallLog).phoneNumber;
    }
    return '';
  }

  // Get call direction
  String _getCallDirection() {
    if (widget.callLog is TwilioCallLog) {
      return (widget.callLog as TwilioCallLog).isOutgoing
          ? 'Outgoing Call'
          : 'Incoming Call';
    }
    return 'Call';
  }

  @override
  Widget build(BuildContext context) {
    final initials = _getInitials();
    final isUnknown = _isUnknown();
    final callerName = _getCallerName();
    final callerSubtitle = _getCallerSubtitle();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            // App Bar with caller info
            SliverAppBar(
              expandedHeight: 200.0,
              floating: false,
              pinned: true,
              backgroundColor: AppTheme.secondaryColor,
              stretch: true,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: Container(
                  color: AppTheme.secondaryColor,
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        // Avatar
                        CircleAvatar(
                          radius: 40,
                          backgroundColor:
                              widget.callLog.status == CallStatus.missed ||
                                      widget.callLog.status == CallStatus.failed
                                  ? Colors.red.withOpacity(0.2)
                                  : AppTheme.primaryColor.withOpacity(0.2),
                          child:
                              isUnknown
                                  ? Icon(
                                    Icons.person,
                                    color:
                                        widget.callLog.status ==
                                                    CallStatus.missed ||
                                                widget.callLog.status ==
                                                    CallStatus.failed
                                            ? Colors.red
                                            : AppTheme.primaryColor,
                                    size: 40,
                                  )
                                  : Text(
                                    initials,
                                    style: TextStyle(
                                      color:
                                          widget.callLog.status ==
                                                      CallStatus.missed ||
                                                  widget.callLog.status ==
                                                      CallStatus.failed
                                              ? Colors.red
                                              : AppTheme.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 28,
                                    ),
                                  ),
                        ),
                        const SizedBox(height: 16),
                        // Caller name
                        Text(
                          callerName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 24,
                          ),
                        ),
                        const SizedBox(height: 4),
                        // Subtitle (email or phone)
                        Text(
                          callerSubtitle,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Tabs
            SliverPersistentHeader(
              delegate: _SliverAppBarDelegate(
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 8,
                  ),
                  color: AppTheme.secondaryColor,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          _tabController.animateTo(0);
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _tabController.index == 0
                                    ? AppTheme.primaryColor
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Details',
                              style: TextStyle(
                                color:
                                    _tabController.index == 0
                                        ? Colors.black
                                        : Colors.white,
                                fontWeight:
                                    _tabController.index == 0
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      GestureDetector(
                        onTap: () {
                          _tabController.animateTo(1);
                        },
                        child: Container(
                          height: 36,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 0,
                          ),
                          decoration: BoxDecoration(
                            color:
                                _tabController.index == 1
                                    ? AppTheme.primaryColor
                                    : Colors.grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Text(
                              'Transcription',
                              style: TextStyle(
                                color:
                                    _tabController.index == 1
                                        ? Colors.black
                                        : Colors.white,
                                fontWeight:
                                    _tabController.index == 1
                                        ? FontWeight.bold
                                        : FontWeight.normal,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              pinned: true,
            ),
          ];
        },
        body: TabBarView(
          controller: _tabController,
          children: [
            // Details Tab
            _buildDetailsTab(),

            // Transcription Tab
            _buildTranscriptionTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsTab() {
    final callDirection = _getCallDirection();
    final callDate = widget.callLog.timestamp;
    final formattedTime =
        '${callDate.hour}:${callDate.minute.toString().padLeft(2, '0')} ${callDate.hour >= 12 ? 'PM' : 'AM'}';

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Call info card
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              color: AppTheme.secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color:
                                widget.callLog is TwilioCallLog &&
                                        (widget.callLog as TwilioCallLog)
                                            .isOutgoing
                                    ? Colors.green.withOpacity(0.2)
                                    : Colors.blue.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            widget.callLog is TwilioCallLog &&
                                    (widget.callLog as TwilioCallLog).isOutgoing
                                ? Icons.call_made
                                : Icons.call_received,
                            color:
                                widget.callLog is TwilioCallLog &&
                                        (widget.callLog as TwilioCallLog)
                                            .isOutgoing
                                    ? Colors.green
                                    : Colors.blue,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                callDirection,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 18,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${widget.callLog.formattedDuration}',
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              formattedTime,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 4),
                            // Status indicator
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: _getStatusColor().withOpacity(0.1),
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: Text(
                                widget.callLog.statusText,
                                style: TextStyle(
                                  color: _getStatusColor(),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Audio player section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Audio Recording',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: AppTheme.primaryColor.withOpacity(0.1),
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   child: Text(
                //     widget.callLog.formattedDuration,
                //     style: TextStyle(
                //       color: AppTheme.primaryColor,
                //       fontWeight: FontWeight.bold,
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(20.0),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.secondaryColor,
                    AppTheme.secondaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
                border: Border.all(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Column(
                children: [
                  // Audio player title
                  Row(
                    children: [
                      Icon(Icons.mic, color: AppTheme.primaryColor, size: 20),
                      // const SizedBox(width: 8),
                      // Text(
                      //   'Audio Recording',
                      //   style: TextStyle(
                      //     color: Colors.white,
                      //     fontWeight: FontWeight.w500,
                      //     fontSize: 16,
                      //   ),
                      // ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Audio progress bar
                  SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 6,
                      thumbShape: const RoundSliderThumbShape(
                        enabledThumbRadius: 8,
                      ),
                      overlayShape: const RoundSliderOverlayShape(
                        overlayRadius: 16,
                      ),
                      activeTrackColor: AppTheme.primaryColor,
                      inactiveTrackColor: Colors.grey.withOpacity(0.3),
                      thumbColor: Colors.white,
                      overlayColor: AppTheme.primaryColor.withOpacity(0.2),
                    ),
                    child: Slider(
                      value: _playbackPosition,
                      onChanged: (value) {
                        setState(() {
                          _playbackPosition = value;
                        });
                      },
                    ),
                  ),

                  // Time and controls
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Current position
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDuration(
                            _playbackPosition *
                                widget.callLog.duration.inSeconds,
                          ),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),

                      // Play/Pause button
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(
                            colors: [
                              AppTheme.primaryColor,
                              AppTheme.primaryColor.withOpacity(0.8),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryColor.withOpacity(0.3),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            _isPlaying ? Icons.pause : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                          onPressed: () {
                            setState(() {
                              _isPlaying = !_isPlaying;
                            });
                          },
                        ),
                      ),

                      // Total duration
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _formatDuration(
                            widget.callLog.duration.inSeconds.toDouble(),
                          ),
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Additional call details
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Call Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                // Container(
                //   padding: const EdgeInsets.symmetric(
                //     horizontal: 12,
                //     vertical: 6,
                //   ),
                //   decoration: BoxDecoration(
                //     color: Colors.grey.withOpacity(0.2),
                //     borderRadius: BorderRadius.circular(16),
                //   ),
                //   child: Text(
                //     widget.callLog.formattedDate,
                //     style: TextStyle(
                //       color: Colors.white.withOpacity(0.9),
                //       fontWeight: FontWeight.w500,
                //     ),
                //   ),
                // ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              color: AppTheme.secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    _buildDetailRowCard('Date', widget.callLog.formattedDate),
                    //   const Divider(color: Colors.grey),
                    _buildDetailRowCard('Time', formattedTime),
                    //  const Divider(color: Colors.grey),
                    _buildDetailRowCard(
                      'Duration',
                      widget.callLog.formattedDuration,
                    ),
                    //    const Divider(color: Colors.grey),
                    _buildDetailRowCard(
                      'Status',
                      widget.callLog.statusText,
                      statusColor: _getStatusColor(),
                    ),
                    if (widget.callLog is LiveKitCallLog) ...[
                      //    const Divider(color: Colors.grey),
                      _buildDetailRowCard(
                        'Agent',
                        (widget.callLog as LiveKitCallLog).agentName ?? 'Maya',
                      ),
                      //   const Divider(color: Colors.grey),
                      // _buildDetailRowCard(
                      //   'Email',
                      //   (widget.callLog as LiveKitCallLog).userEmail,
                      // ),
                    ] else if (widget.callLog is TwilioCallLog) ...[
                      //   const Divider(color: Colors.grey),
                      _buildDetailRowCard(
                        'Type',
                        (widget.callLog as TwilioCallLog).isOutgoing
                            ? 'Outgoing'
                            : 'Incoming',
                      ),
                      //   const Divider(color: Colors.grey),
                      // _buildDetailRowCard(
                      //   'Phone',
                      //   (widget.callLog as TwilioCallLog).phoneNumber,
                      // ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTranscriptionTab() {
    // Dummy transcription data
    final List<Map<String, dynamic>> transcription = [
      {
        'speaker': 'Agent',
        'text':
            'Hello, thank you for calling Moinc support. How can I help you today?',
        'timestamp': '00:05',
      },
      {
        'speaker': 'User',
        'text':
            'Hi, I\'m having an issue with my account. I can\'t seem to log in.',
        'timestamp': '00:12',
      },
      {
        'speaker': 'Agent',
        'text':
            'I\'m sorry to hear that. Let me help you troubleshoot this issue. Can you please provide your email address?',
        'timestamp': '00:18',
      },
      {
        'speaker': 'User',
        'text': 'Sure, it\'s user@example.com',
        'timestamp': '00:25',
      },
      {
        'speaker': 'Agent',
        'text':
            'Thank you. I\'m checking your account now. It looks like your account was temporarily locked due to multiple failed login attempts. I can help you reset it.',
        'timestamp': '00:32',
      },
      {
        'speaker': 'User',
        'text': 'That would be great, thank you.',
        'timestamp': '00:45',
      },
      {
        'speaker': 'Agent',
        'text':
            'I\'ve sent a password reset link to your email. Please check your inbox and follow the instructions to reset your password.',
        'timestamp': '00:52',
      },
      {
        'speaker': 'User',
        'text': 'Got it, I\'ll check my email. Thanks for your help!',
        'timestamp': '01:05',
      },
      {
        'speaker': 'Agent',
        'text':
            'You\'re welcome! Is there anything else I can help you with today?',
        'timestamp': '01:12',
      },
      {
        'speaker': 'User',
        'text': 'No, that\'s all. Have a great day!',
        'timestamp': '01:18',
      },
      {
        'speaker': 'Agent',
        'text': 'You too! Thank you for calling Moinc support. Goodbye!',
        'timestamp': '01:25',
      },
    ];

    return ListView(
      padding: const EdgeInsets.all(16.0),
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Call Transcription',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    widget.callLog.formattedDuration,
                    style: TextStyle(
                      color: AppTheme.primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              color: AppTheme.secondaryColor,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final entry in transcription)
                      _buildTranscriptionEntry(
                        entry['speaker'],
                        entry['text'],
                        entry['timestamp'],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDetailRowCard(String label, String value, {Color? statusColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withOpacity(0.7),
              fontSize: 16,
            ),
          ),
          if (statusColor != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                value,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                ),
              ),
            )
          else
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTranscriptionEntry(
    String speaker,
    String text,
    String timestamp,
  ) {
    final isAgent = speaker.toLowerCase() == 'agent';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Speaker avatar
          CircleAvatar(
            radius: 16,
            backgroundColor:
                isAgent
                    ? AppTheme.primaryColor.withOpacity(0.2)
                    : Colors.grey.withOpacity(0.2),
            child: Text(
              speaker[0].toUpperCase(),
              style: TextStyle(
                color: isAgent ? AppTheme.primaryColor : Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          const SizedBox(width: 12),

          // Message content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Speaker name and timestamp
                Row(
                  children: [
                    Text(
                      speaker,
                      style: TextStyle(
                        color: isAgent ? AppTheme.primaryColor : Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      timestamp,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.5),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),

                // Message text
                Text(
                  text,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (widget.callLog.status) {
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

  String _formatDuration(double seconds) {
    final int mins = seconds ~/ 60;
    final int secs = seconds.toInt() % 60;
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  final Widget _child;

  _SliverAppBarDelegate(this._child);

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return SizedBox(height: maxExtent, child: _child);
  }

  @override
  double get maxExtent => 70; // Height for the tab bar container

  @override
  double get minExtent => 70; // Height for the tab bar container

  @override
  bool shouldRebuild(covariant _SliverAppBarDelegate oldDelegate) {
    return true;
  }
}
