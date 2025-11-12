import 'dart:async';
import 'package:flutter/foundation.dart';
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

  // Call provider type (twilio or livekit)
  String _callProvider = 'twilio'; // Default to Twilio for outbound calls
  String get callProvider => _callProvider;

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

  // Start a call in ringing state (before API response)
  void startRinging(String phoneNumber) {
    if (_callState != CallState.idle) {
      return;
    }

    _phoneNumber = phoneNumber;
    _callState = CallState.ringing;
    notifyListeners();
  }

  // Initiate a call with a phone number and optional session ID
  Future<bool> initiateCall(
    String phoneNumber, {
    String? sessionId,
    Map<String, dynamic>? callData,
    bool skipRingingState = false,
  }) async {
    // If we're not already in ringing state and not skipping it, start in ringing state
    if (_callState != CallState.ringing && !skipRingingState) {
      _phoneNumber = phoneNumber;
      _callState = CallState.dialing;
      notifyListeners();
    }

    // If we have a session ID from the API, we can consider the call as already connected
    if (sessionId != null) {
      _callState = CallState.connected;
      _callId = sessionId;
      _startTime = DateTime.now();

      // Extract call details from API response
      if (callData != null) {
        // Check if this is a LiveKit SIP call by looking for livekit_sip_call_id in the response
        if (callData['livekit_sip_call_id'] != null) {
          _callProvider = 'livekit';
          // Use the actual SIP call ID from the response, not the session ID
          _callId = callData['livekit_sip_call_id'] ?? sessionId;
          _roomName = callData['room'] ?? 'moinc_room';
          _participantId = callData['livekit_participant_id'] ?? '';
        } else {
          // This is a Twilio call
          _callProvider = 'twilio';
        }
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

    // Use the hangup service for both LiveKit and Twilio calls
    if (_callId.isNotEmpty) {
      try {
        if (kDebugMode) {
          print('Ending call with ID: $_callId');
          print('Call provider: $_callProvider');
          print('Room name: $_roomName');
          print('Participant ID: $_participantId');
        }

        final hangupService = CallHangupService();

        // For LiveKit calls, we need room name and participant ID
        // For Twilio calls, we just need the call SID
        final result = await hangupService.hangupCall(
          callSid: _callId,
          roomName: _callProvider == 'livekit' ? _roomName : null,
          participantId: _callProvider == 'livekit' ? _participantId : null,
        );

        if (kDebugMode) {
          print('Hangup result: ${result['success']} - ${result['message']}');
          if (result.containsKey('provider')) {
            print('Provider used: ${result['provider']}');
          }
        }

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
      if (kDebugMode) {
        print('No call ID available, skipping API hangup');
      }
      // Simulate API call delay for calls without an ID
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
    _callProvider = 'twilio'; // Default back to twilio
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
