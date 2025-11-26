import 'package:intl/intl.dart';
import 'package:moinc/features/ai%20agent/app.dart';
import 'package:moinc/features/auth/network/api_client.dart';
import 'package:moinc/features/profile/domain/models/twilio_call_log_response.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';
import 'package:moinc/features/profile/domain/repositories/call_logs_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CallLogsRepositoryImpl implements CallLogsRepository {
  final ApiClient _apiClient;
  var accountNo = '';
  // API endpoint
  static const String _apiUrl =
      'https://logs.voiceadmins.com/get_twilio_calls.php';
  static const String _baseUrl = 'https://logs.voiceadmins.com/';

  // Account number - in a real app, this would come from user authentication
  // static const String _accountNo = '562224562224';
  // static const String _accountNo = '3703637036';

  CallLogsRepositoryImpl({required ApiClient apiClient})
    : _apiClient = apiClient;

  @override
  Future<TwilioCallLogResponse> fetchCallLogs({
    int page = 1,
    int limit = 25,
    String? partnerAccountNo,
  }) async {
    try {
      const String _accountNoKey = 'client_acn__';
      final prefs = await SharedPreferences.getInstance();
      accountNo = prefs.getString(_accountNoKey) ?? '';

      final response = await _apiClient.postWithoutToken(_apiUrl, {
        'client_accountno': accountNo,
        'accountno': partnerAccountNo,
        'page': page,
        'limit': limit,
      });
      // 'accountno': "3703637036",
      print(
        'API Response: ${response.statusCode}, ${response.data != null ? 'Has data' : 'No data'}',
      );

      if (response.isSuccess && response.data != null) {
        try {
          return TwilioCallLogResponse.fromJson(response.data);
        } catch (parseError) {
          print('Error parsing response data: $parseError');
          // Return an empty response instead of throwing
          return TwilioCallLogResponse(
            status: 'error',
            baseUrl: _baseUrl,
            accountno: accountNo,
            pagination: Pagination(
              page: page,
              limit: limit,
              total: 0,
              totalPages: 1,
              hasNext: false,
              hasPrev: false,
            ),
            count: 0,
            data: [],
          );
        }
      } else {
        print('API error: ${response.errorMessage}');
        // Return an empty response instead of throwing
        return TwilioCallLogResponse(
          status: 'error',
          baseUrl: _baseUrl,
          accountno: accountNo,
          pagination: Pagination(
            page: page,
            limit: limit,
            total: 0,
            totalPages: 1,
            hasNext: false,
            hasPrev: false,
          ),
          count: 0,
          data: [],
        );
      }
    } catch (e) {
      print('Exception in fetchCallLogs: $e');
      // Return an empty response instead of throwing
      return TwilioCallLogResponse(
        status: 'error',
        baseUrl: _baseUrl,
        accountno: accountNo,
        pagination: Pagination(
          page: page,
          limit: limit,
          total: 0,
          totalPages: 1,
          hasNext: false,
          hasPrev: false,
        ),
        count: 0,
        data: [],
      );
    }
  }

  @override
  List<CallLog> convertApiResponseToCallLogs(TwilioCallLogResponse response) {
    try {
      return response.data.map((callData) {
        try {
          // Parse the start time string to DateTime
          DateTime startTime;
          try {
            startTime = DateFormat(
              "yyyy-MM-dd HH:mm:ssZ",
            ).parse(callData.startTime);
          } catch (e) {
            // If date parsing fails, use current time
            print('Error parsing date: ${callData.startTime}, error: $e');
            startTime = DateTime.now();
          }

          // Determine call status
          CallStatus status;
          switch (callData.status.toLowerCase()) {
            case 'completed':
              status = CallStatus.completed;
              break;
            case 'no-answer':
            case 'busy':
              status = CallStatus.missed;
              break;
            case 'failed':
              status = CallStatus.failed;
              break;
            default:
              status = CallStatus.completed;
          }

          // Determine if the call is outgoing based on direction
          final isOutgoing = callData.direction == 'trunking-terminating';

          // Create a TwilioCallLog object
          return TwilioCallLog(
            id: callData.id.toString(),
            timestamp: startTime,
            duration: Duration(seconds: callData.duration),
            status: status,
            phoneNumber:
                isOutgoing ? callData.toFormatted : callData.fromFormatted,
            callerName: callData.callerName,
            isOutgoing: isOutgoing,
            recordingUrl:
                callData.recording != null && callData.recording!.isNotEmpty
                    ? '${response.baseUrl}get_recording.php?file=${_extractFilePath(callData.recording!)}'
                    : null,
            transcript: callData.transcript,
            summarizeTranscript: callData.summarizeTranscript,
          );
        } catch (e) {
          // If there's an error processing a single call log, log it and return a placeholder
          print('Error processing call log: $e');
          return TwilioCallLog(
            id: '0',
            timestamp: DateTime.now(),
            duration: Duration.zero,
            status: CallStatus.failed,
            phoneNumber: 'Error',
            isOutgoing: false,
          );
        }
      }).toList();
    } catch (e) {
      // If there's an error processing the entire list, return an empty list
      print('Error converting API response to call logs: $e');
      return [];
    }
  }

  // Extract the file path from the full recording path
  String _extractFilePath(String fullPath) {
    // The recording path in the API response is like:
    // /mnt/call_recordings_twilio/CAf6548d28405f00eca57779a31fc91e9a/RE128d62f298117a7a3816f01f20613150.mp3
    // We need to extract just: CAf6548d28405f00eca57779a31fc91e9a/RE128d62f298117a7a3816f01f20613150.mp3
    // For the final URL: https://logs.voiceadmins.com/get_recording.php?file=CA.../RE....mp3

    final parts = fullPath.split('/');
    if (parts.length >= 4) {
      // Extract just the call ID and recording ID parts (last two segments)
      return "${parts[parts.length - 2]}/${parts[parts.length - 1]}";
    }
    return fullPath;
  }

  @override
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
      // More dummy data...
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
