import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';
import 'package:moinc/utils/custom_toast.dart';

class CallLogDetailScreen extends StatefulWidget {
  final CallLog callLog;

  const CallLogDetailScreen({Key? key, required this.callLog})
    : super(key: key);

  @override
  State<CallLogDetailScreen> createState() => _CallLogDetailScreenState();
}

class _CallLogDetailScreenState extends State<CallLogDetailScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;

  // Audio player
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isLoading = false;
  double _playbackPosition = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  String? _audioUrl;

  // Stream subscriptions
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _positionSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _processingStateSubscription;

  @override
  void initState() {
    super.initState();
    // Register observer for app lifecycle changes
    WidgetsBinding.instance.addObserver(this);

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      // This is called when the tab selection changes
      // We need to rebuild the UI to update the tab appearance
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    // Setup audio player
    _setupAudioPlayer();
  }

  void _setupAudioPlayer() {
    // Check if this call log has a recording
    if (widget.callLog is TwilioCallLog) {
      final twilioLog = widget.callLog as TwilioCallLog;
      _audioUrl = twilioLog.recordingUrl;
    }

    // Setup listeners with proper subscription tracking
    _playerStateSubscription = _audioPlayer.playerStateStream.listen((state) {
      if (state.playing != _isPlaying && mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });

    _positionSubscription = _audioPlayer.positionStream.listen((position) {
      if (mounted) {
        setState(() {
          _position = position;
          if (_duration.inSeconds > 0) {
            _playbackPosition = position.inSeconds / _duration.inSeconds;
          }
        });
      }
    });

    _durationSubscription = _audioPlayer.durationStream.listen((duration) {
      if (duration != null && mounted) {
        setState(() {
          _duration = duration;
        });
      }
    });

    _processingStateSubscription = _audioPlayer.processingStateStream.listen((
      state,
    ) async {
      if (state == ProcessingState.completed) {
        // First pause the player to prevent auto-play
        await _audioPlayer.pause();

        // Then seek back to beginning
        await _audioPlayer.seek(Duration.zero);

        // Finally update the UI state - this ensures icon and position update together
        if (mounted) {
          setState(() {
            _isPlaying = false;
            _playbackPosition = 0.0;
            _position = Duration.zero;
          });
        }
      }
    });
  }

  Future<void> _loadAudio() async {
    if (_audioUrl == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      await _audioPlayer.setUrl(_audioUrl!);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      CustomToast.showCustomeToast(
        'Failed to load audio: $e',
        AppTheme.errorColor,
      );
    }
  }

  void _togglePlayPause() async {
    if (_audioUrl == null) {
      CustomToast.showCustomeToast(
        'No recording available for this call',
        AppTheme.errorColor,
      );

      return;
    }

    if (_audioPlayer.playerState.processingState == ProcessingState.idle) {
      // First time playing, need to load audio
      await _loadAudio();
    } else if (_audioPlayer.playerState.processingState ==
        ProcessingState.completed) {
      // If audio was completed, seek to beginning before playing again
      await _audioPlayer.seek(Duration.zero);
      setState(() {
        _playbackPosition = 0.0;
        _position = Duration.zero;
      });
    }

    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.play();
    }
  }

  void _seekAudio(double value) {
    final position = Duration(seconds: (value * _duration.inSeconds).toInt());
    _audioPlayer.seek(position);
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions first to prevent setState after dispose errors
    _playerStateSubscription?.cancel();
    _positionSubscription?.cancel();
    _durationSubscription?.cancel();
    _processingStateSubscription?.cancel();

    // Dispose the audio player when screen is disposed (navigating back)
    // Make sure audio is stopped before disposing
    _audioPlayer.stop().then((_) {
      _audioPlayer.dispose();
    });

    _tabController.dispose();
    // Remove observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void deactivate() {
    // Called when widget is being removed from the widget tree
    // Stop audio playback immediately when navigating away
    _audioPlayer.stop();
    // Don't call setState here to avoid exceptions
    _isPlaying = false;
    super.deactivate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle changes (minimize, background, etc.)
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      // App is minimized or in background
      if (_isPlaying) {
        _audioPlayer.pause();
        if (mounted) {
          setState(() {
            _isPlaying = false;
          });
        }
      }
    }
    super.didChangeAppLifecycleState(state);
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
                                  :
                                  //  Text(
                                  //   initials,
                                  //   style: TextStyle(
                                  //     color:
                                  //         widget.callLog.status ==
                                  //                     CallStatus.missed ||
                                  //                 widget.callLog.status ==
                                  //                     CallStatus.failed
                                  //             ? Colors.red
                                  //             : AppTheme.primaryColor,
                                  //     fontWeight: FontWeight.bold,
                                  //     fontSize: 28,
                                  //   ),
                                  // ),
                                  Icon(
                                    Icons.person,
                                    color:
                                        widget.callLog.status ==
                                                    CallStatus.missed ||
                                                widget.callLog.status ==
                                                    CallStatus.failed
                                            ? Colors.red
                                            : AppTheme.primaryColor,
                                    size: 40,
                                  ),

                          //  Text(
                          //   initials,
                          //   style: TextStyle(
                          //     color:
                          //         widget.callLog.status ==
                          //                     CallStatus.missed ||
                          //                 widget.callLog.status ==
                          //                     CallStatus.failed
                          //             ? Colors.red
                          //             : AppTheme.primaryColor,
                          //     fontWeight: FontWeight.bold,
                          //     fontSize: 28,
                          //   ),
                          // ),
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
            widget.callLog is TwilioCallLog &&
                    (widget.callLog as TwilioCallLog).recordingUrl != null
                ? Row(
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
                )
                : const SizedBox.shrink(),
            const SizedBox(height: 16),
            widget.callLog is TwilioCallLog &&
                    (widget.callLog as TwilioCallLog).recordingUrl != null
                ? Container(
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
                      // Text(
                      //   "URL: ${(widget.callLog as TwilioCallLog).recordingUrl ?? ''}",
                      //   style: TextStyle(color: Colors.white),
                      // ),
                      // Audio player title
                      Row(
                        children: [
                          Icon(
                            Icons.mic,
                            color: AppTheme.primaryColor,
                            size: 20,
                          ),
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
                          value: _playbackPosition.clamp(0.0, 1.0),
                          onChanged: (value) {
                            _seekAudio(value);
                          },
                        ),
                      ),

                      // Time and controls with fixed layout
                      SizedBox(
                        height: 80, // Fixed height for the controls row
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            // Current position - Fixed width container
                            SizedBox(
                              width: 70, // Fixed width to prevent shifting
                              child: Container(
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
                                    _position.inSeconds.toDouble(),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center, // Center text
                                ),
                              ),
                            ),

                            // Play/Pause button - Fixed size container
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
                                    color: AppTheme.primaryColor.withOpacity(
                                      0.3,
                                    ),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  customBorder: const CircleBorder(),
                                  onTap: _togglePlayPause,
                                  child:
                                      _isLoading
                                          ? const Center(
                                            child: SizedBox(
                                              width: 24,
                                              height: 24,
                                              child: CircularProgressIndicator(
                                                color: Colors.white,
                                                strokeWidth: 2,
                                              ),
                                            ),
                                          )
                                          : Center(
                                            child: Icon(
                                              _isPlaying
                                                  ? Icons.pause
                                                  : Icons.play_arrow,
                                              color: Colors.white,
                                              size: 32,
                                            ),
                                          ),
                                ),
                              ),
                            ),

                            // Total duration - Fixed width container
                            SizedBox(
                              width: 70, // Fixed width to prevent shifting
                              child: Container(
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
                                    _duration.inSeconds.toDouble(),
                                  ),
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.9),
                                  ),
                                  textAlign: TextAlign.center, // Center text
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                : const SizedBox.shrink(),

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
    // Check if this is a Twilio call with transcript
    String? transcript;
    String? summary;
    if (widget.callLog is TwilioCallLog) {
      final twilioLog = widget.callLog as TwilioCallLog;
      transcript = twilioLog.transcript;
      summary = twilioLog.summarizeTranscript;
    }

    // If no transcript available, show empty list
    if (transcript == null || transcript.isEmpty) {
      return _buildTranscriptionContent([], summary: summary);
    }

    List<Map<String, dynamic>> transcriptionData = [];

    try {
      // Try to parse as JSON
      final List<dynamic> parsed = jsonDecode(transcript);
      transcriptionData =
          parsed.map((e) => Map<String, dynamic>.from(e)).toList();
    } catch (e) {
      // Fallback for plain text
      transcriptionData = [
        {
          'speaker': '', // Empty speaker
          'text': transcript,
        },
      ];
    }

    return _buildTranscriptionContent(transcriptionData, summary: summary);
  }

  Widget _buildTranscriptionContent(
    List<Map<String, dynamic>> transcription, {
    String? summary,
  }) {
    return ListView(
      shrinkWrap: true,
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
              child:
                  summary != null && summary.isNotEmpty
                      ? Theme(
                        data: Theme.of(
                          context,
                        ).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          initiallyExpanded: false,
                          tilePadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 12,
                          ),
                          childrenPadding: const EdgeInsets.only(
                            bottom: 20,
                            left: 20,
                            right: 20,
                          ),
                          title: const Text(
                            'Summary',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              summary,
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 14,
                                height: 1.5,
                              ),
                              maxLines: 10,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          iconColor: AppTheme.primaryColor,
                          collapsedIconColor: AppTheme.primaryColor,
                          children: [
                            if (transcription.isEmpty)
                              const Padding(
                                padding: EdgeInsets.all(16.0),
                                child: Text(
                                  'No transcription available for this call',
                                  style: TextStyle(color: Colors.white70),
                                ),
                              )
                            else
                              ...transcription.map(
                                (entry) => _buildTranscriptionEntry(
                                  entry['speaker'] ?? '',
                                  entry['text'] ?? '',
                                ),
                              ),
                          ],
                        ),
                      )
                      : Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (transcription.isEmpty)
                              const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(16.0),
                                  child: Text(
                                    'No transcription available for this call',
                                    style: TextStyle(color: Colors.white70),
                                  ),
                                ),
                              )
                            else
                              for (final entry in transcription)
                                _buildTranscriptionEntry(
                                  entry['speaker'] ?? '',
                                  entry['text'] ?? '',
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

  Widget _buildTranscriptionEntry(String speaker, String text) {
    // If speaker is empty, it's a simple text transcription (old format)
    if (speaker.isEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 16.0),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white.withOpacity(0.9),
            fontSize: 16,
            height: 1.5,
          ),
        ),
      );
    }

    final isAgent = speaker.toLowerCase() == 'agent';
    final isCustomer = speaker.toLowerCase() == 'customer';

    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 4.0),
            child: Text(
              speaker,
              style: TextStyle(
                color:
                    isAgent
                        ? AppTheme.primaryColor
                        : (isCustomer ? Colors.blue : Colors.white70),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withOpacity(0.1)),
            ),
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: 16,
                height: 1.5,
              ),
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
