import 'dart:async';
import 'package:flutter/material.dart';
import 'package:moinc/services/call_hangup_service.dart';

enum CallState { idle, dialing, ringing, connected, onHold, ended, failed }

class CallService extends ChangeNotifier {
  // Singleton instance
  static final CallService _instance = CallService._internal();
  factory CallService() => _instance;
  CallService._internal();

  // Call state
  CallState _callState = CallState.idle;
  CallState get callState => _callState;

  // Call details
  String _phoneNumber = '';
  String get phoneNumber => _phoneNumber;

  String _callId = '';
  String get callId => _callId;

  // LiveKit specific details
  String _roomName = 'moinc_room';
  String get roomName => _roomName;

  String _participantId = '';
  String get participantId => _participantId;

  DateTime? _startTime;
  DateTime? get startTime => _startTime;

  Duration _callDuration = Duration.zero;
  Duration get callDuration => _callDuration;

  bool _isMuted = false;
  bool get isMuted => _isMuted;

  bool _isSpeakerOn = false;
  bool get isSpeakerOn => _isSpeakerOn;

  Timer? _callTimer;

  // Call history
  final List<CallHistoryEntry> _callHistory = [];
  List<CallHistoryEntry> get callHistory => List.unmodifiable(_callHistory);

  // Initiate a call with a phone number and optional session ID
  Future<bool> initiateCall(
    String phoneNumber, {
    String? sessionId,
    Map<String, dynamic>? callData,
  }) async {
    if (_callState != CallState.idle) {
      return false;
    }

    _phoneNumber = phoneNumber;
    _callState = CallState.dialing;
    notifyListeners();

    // If we have a session ID from the API, we can consider the call as already connected
    if (sessionId != null) {
      _callState = CallState.connected;
      _callId = sessionId;
      _startTime = DateTime.now();

      // Extract LiveKit specific details from call data if available
      if (callData != null) {
        _roomName = callData['room'] ?? 'moinc_room';
        _participantId = callData['livekit_participant_id'] ?? '';
      }

      _startCallTimer();

      // Add to call history
      _callHistory.add(
        CallHistoryEntry(
          phoneNumber: _phoneNumber,
          startTime: _startTime!,
          callType: CallType.outgoing,
          callId: _callId,
        ),
      );

      notifyListeners();
      return true;
    }

    // Otherwise use the original dummy logic for testing
    // Simulate API call delay
    await Future.delayed(const Duration(seconds: 2));

    // Simulate successful call connection (90% success rate)
    bool isSuccessful = DateTime.now().millisecondsSinceEpoch % 10 != 0;

    if (isSuccessful) {
      _callState = CallState.connected;
      _callId = 'call_${DateTime.now().millisecondsSinceEpoch}';
      _startTime = DateTime.now();
      _startCallTimer();

      // Add to call history
      _callHistory.add(
        CallHistoryEntry(
          phoneNumber: _phoneNumber,
          startTime: _startTime!,
          callType: CallType.outgoing,
          callId: _callId,
        ),
      );
    } else {
      _callState = CallState.failed;

      // Add failed call to history
      _callHistory.add(
        CallHistoryEntry(
          phoneNumber: _phoneNumber,
          startTime: DateTime.now(),
          callType: CallType.outgoing,
          callId: 'failed_${DateTime.now().millisecondsSinceEpoch}',
          endTime: DateTime.now(),
          callStatus: CallStatus.failed,
        ),
      );
    }

    notifyListeners();
    return isSuccessful;
  }

  // End an active call
  Future<bool> endCall() async {
    if (_callState != CallState.connected && _callState != CallState.onHold) {
      return false;
    }

    // If we have a LiveKit SIP call ID and participant ID, use the hangup service
    if (_callId.startsWith('SCL_') && _participantId.isNotEmpty) {
      try {
        final hangupService = CallHangupService();
        final result = await hangupService.hangupCall(
          callSid: _callId,
          roomName: _roomName,
          participantId: _participantId,
        );

        if (!result['success']) {
          // If API call failed, still proceed with local call cleanup
          print(
            'Warning: API call to terminate call failed: ${result['message']}',
          );
        }
      } catch (e) {
        print('Error terminating call via API: $e');
        // Continue with local cleanup even if API call fails
      }
    } else {
      // Simulate API call delay for non-LiveKit calls
      await Future.delayed(const Duration(milliseconds: 500));
    }

    _stopCallTimer();
    _callState = CallState.ended;

    // Update call history entry
    final historyEntry = _callHistory.firstWhere(
      (entry) => entry.callId == _callId,
      orElse:
          () => CallHistoryEntry(
            phoneNumber: _phoneNumber,
            startTime: _startTime ?? DateTime.now(),
            callType: CallType.outgoing,
            callId: _callId,
          ),
    );

    final updatedEntry = historyEntry.copyWith(
      endTime: DateTime.now(),
      callStatus: CallStatus.completed,
      duration: _callDuration,
    );

    final index = _callHistory.indexOf(historyEntry);
    if (index != -1) {
      _callHistory[index] = updatedEntry;
    } else {
      _callHistory.add(updatedEntry);
    }

    // Reset call state
    _resetCallState();
    notifyListeners();
    return true;
  }

  // Toggle mute state
  void toggleMute() {
    if (_callState == CallState.connected) {
      _isMuted = !_isMuted;
      notifyListeners();
    }
  }

  // Toggle speaker state
  void toggleSpeaker() {
    if (_callState == CallState.connected) {
      _isSpeakerOn = !_isSpeakerOn;
      notifyListeners();
    }
  }

  // Toggle hold state
  Future<bool> toggleHold() async {
    if (_callState != CallState.connected && _callState != CallState.onHold) {
      return false;
    }

    // Simulate API call delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (_callState == CallState.connected) {
      _callState = CallState.onHold;
    } else {
      _callState = CallState.connected;
    }

    notifyListeners();
    return true;
  }

  // Start call timer to track duration
  void _startCallTimer() {
    _callTimer?.cancel();
    _callDuration = Duration.zero;

    _callTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _callDuration = Duration(seconds: timer.tick);
      notifyListeners();
    });
  }

  // Stop call timer
  void _stopCallTimer() {
    _callTimer?.cancel();
    _callTimer = null;
  }

  // Reset call state
  void _resetCallState() {
    _callState = CallState.idle;
    _phoneNumber = '';
    _callId = '';
    _roomName = 'moinc_room';
    _participantId = '';
    _startTime = null;
    _callDuration = Duration.zero;
    _isMuted = false;
    _isSpeakerOn = false;
    _stopCallTimer();
  }

  // Format call duration as MM:SS
  String get formattedCallDuration {
    final minutes = _callDuration.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _callDuration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _stopCallTimer();
    super.dispose();
  }
}

// Call history entry model
class CallHistoryEntry {
  final String phoneNumber;
  final DateTime startTime;
  final CallType callType;
  final String callId;
  final DateTime? endTime;
  final CallStatus callStatus;
  final Duration? duration;

  CallHistoryEntry({
    required this.phoneNumber,
    required this.startTime,
    required this.callType,
    required this.callId,
    this.endTime,
    this.callStatus = CallStatus.inProgress,
    this.duration,
  });

  CallHistoryEntry copyWith({
    String? phoneNumber,
    DateTime? startTime,
    CallType? callType,
    String? callId,
    DateTime? endTime,
    CallStatus? callStatus,
    Duration? duration,
  }) {
    return CallHistoryEntry(
      phoneNumber: phoneNumber ?? this.phoneNumber,
      startTime: startTime ?? this.startTime,
      callType: callType ?? this.callType,
      callId: callId ?? this.callId,
      endTime: endTime ?? this.endTime,
      callStatus: callStatus ?? this.callStatus,
      duration: duration ?? this.duration,
    );
  }
}

enum CallType { incoming, outgoing, missed }

enum CallStatus { inProgress, completed, missed, failed, rejected }
