import 'package:moinc/features/profile/domain/models/call_log_model.dart';

class CallLogsService {
  // Singleton instance
  static final CallLogsService _instance = CallLogsService._internal();
  factory CallLogsService() => _instance;
  CallLogsService._internal();

  // Get dummy call logs for testing
  List<CallLog> getDummyCallLogs() {
    final now = DateTime.now();

    return [
      // LiveKit call logs
      LiveKitCallLog(
        id: '1',
        timestamp: now.subtract(const Duration(minutes: 30)),
        duration: const Duration(minutes: 12, seconds: 45),
        status: CallStatus.completed,
        userName: 'John Doe',
        userEmail: 'john.doe@example.com',
        roomName: 'audio_room',
        agentName: 'Maya',
      ),
      LiveKitCallLog(
        id: '2',
        timestamp: now.subtract(const Duration(hours: 3)),
        duration: const Duration(minutes: 5, seconds: 12),
        status: CallStatus.completed,
        userName: 'Sarah Johnson',
        userEmail: 'sarah.j@example.com',
        roomName: 'audio_room',
        agentName: 'Maya',
      ),
      LiveKitCallLog(
        id: '3',
        timestamp: now.subtract(const Duration(days: 1, hours: 4)),
        duration: const Duration(seconds: 0),
        status: CallStatus.failed,
        userName: 'Michael Brown',
        userEmail: 'michael.b@example.com',
        roomName: 'audio_room',
        agentName: 'Maya',
      ),

      // Twilio call logs
      TwilioCallLog(
        id: '4',
        timestamp: now.subtract(const Duration(hours: 1)),
        duration: const Duration(minutes: 8, seconds: 32),
        status: CallStatus.completed,
        phoneNumber: '+1 (555) 123-4567',
        callerName: 'Alice Smith',
        isOutgoing: false,
      ),
      TwilioCallLog(
        id: '5',
        timestamp: now.subtract(const Duration(days: 1, hours: 2)),
        duration: const Duration(seconds: 0),
        status: CallStatus.missed,
        phoneNumber: '+1 (555) 987-6543',
        isOutgoing: false,
      ),
      TwilioCallLog(
        id: '6',
        timestamp: now.subtract(const Duration(days: 2)),
        duration: const Duration(minutes: 3, seconds: 15),
        status: CallStatus.completed,
        phoneNumber: '+1 (555) 456-7890',
        callerName: 'Robert Wilson',
        isOutgoing: true,
      ),
      LiveKitCallLog(
        id: '7',
        timestamp: now.subtract(const Duration(days: 3, hours: 5)),
        duration: const Duration(minutes: 15, seconds: 20),
        status: CallStatus.completed,
        userName: 'Emily Davis',
        userEmail: 'emily.d@example.com',
        roomName: 'audio_room',
        agentName: 'Maya',
      ),
      TwilioCallLog(
        id: '8',
        timestamp: now.subtract(const Duration(days: 3, hours: 7)),
        duration: const Duration(seconds: 0),
        status: CallStatus.failed,
        phoneNumber: '+1 (555) 222-3333',
        isOutgoing: true,
      ),
      LiveKitCallLog(
        id: '9',
        timestamp: now.subtract(const Duration(days: 4, hours: 2)),
        duration: const Duration(minutes: 1, seconds: 45),
        status: CallStatus.completed,
        userName: 'David Miller',
        userEmail: 'david.m@example.com',
        roomName: 'audio_room',
        agentName: 'Maya',
      ),
      TwilioCallLog(
        id: '10',
        timestamp: now.subtract(const Duration(days: 5)),
        duration: const Duration(minutes: 4, seconds: 50),
        status: CallStatus.completed,
        phoneNumber: '+1 (555) 444-5555',
        callerName: 'Jennifer White',
        isOutgoing: false,
      ),
    ];
  }
}
