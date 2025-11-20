import 'package:moinc/features/profile/domain/models/twilio_call_log_response.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';

/// Repository interface for call logs
abstract class CallLogsRepository {
  /// Fetch call logs from the API
  Future<TwilioCallLogResponse> fetchCallLogs({int page = 1, int limit = 25, String? partnerAccountNo});

  /// Convert API response to CallLog model
  List<CallLog> convertApiResponseToCallLogs(TwilioCallLogResponse response);

  /// Get dummy call logs for testing or fallback
  List<CallLog> getDummyCallLogs();
}
