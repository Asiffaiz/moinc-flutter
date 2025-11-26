import 'package:intl/intl.dart';

enum CallLogType { liveKit, twilio }

enum CallStatus { completed, missed, failed, ongoing }

abstract class CallLog {
  final String id;
  final DateTime timestamp;
  final Duration duration;
  final CallStatus status;
  final CallLogType type;

  CallLog({
    required this.id,
    required this.timestamp,
    required this.duration,
    required this.status,
    required this.type,
  });

  String get formattedDate {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final logDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (logDate == today) {
      return 'Today';
    } else if (logDate == yesterday) {
      return 'Yesterday';
    } else {
      return DateFormat('MMM d, yyyy').format(timestamp);
    }
  }


  String get formattedDuration {
    if (duration.inSeconds < 60) {
      return '${duration.inSeconds} sec';
    } else if (duration.inMinutes < 60) {
      return '${duration.inMinutes} min ${duration.inSeconds % 60} sec';
    } else {
      return '${duration.inHours} hr ${duration.inMinutes % 60} min';
    }
  }

  String get statusText {
    switch (status) {
      case CallStatus.completed:
        return 'Completed';
      case CallStatus.missed:
        return 'Missed';
      case CallStatus.failed:
        return 'Failed';
      case CallStatus.ongoing:
        return 'Ongoing';
    }
  }
}

class LiveKitCallLog extends CallLog {
  final String userName;
  final String userEmail;
  final String? roomName;
  final String? agentName;

  LiveKitCallLog({
    required String id,
    required DateTime timestamp,
    required Duration duration,
    required CallStatus status,
    required this.userName,
    required this.userEmail,
    this.roomName,
    this.agentName,
  }) : super(
         id: id,
         timestamp: timestamp,
         duration: duration,
         status: status,
         type: CallLogType.liveKit,
       );
}

class TwilioCallLog extends CallLog {
  final String phoneNumber;
  final String? callerName;
  final bool isOutgoing;
  final String? recordingUrl;
  final String? transcript;
  final String? summarizeTranscript;

  TwilioCallLog({
    required String id,
    required DateTime timestamp,
    required Duration duration,
    required CallStatus status,
    required this.phoneNumber,
    this.callerName,
    this.isOutgoing = false,
    this.recordingUrl,
    this.transcript,
    this.summarizeTranscript,
  }) : super(
         id: id,
         timestamp: timestamp,
         duration: duration,
         status: status,
         type: CallLogType.twilio,
       );
}
