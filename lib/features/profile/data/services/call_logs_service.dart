import 'package:moinc/core/dependency_injection.dart';
import 'package:moinc/features/profile/domain/models/twilio_call_log_response.dart';
import 'package:moinc/features/profile/domain/models/call_log_model.dart';
import 'package:moinc/features/profile/domain/repositories/call_logs_repository.dart';

class CallLogsService {
  // Singleton instance
  static final CallLogsService _instance = CallLogsService._internal();
  factory CallLogsService() => _instance;

  // Repository
  final CallLogsRepository _callLogsRepository;

  // Private constructor
  CallLogsService._internal()
    : _callLogsRepository = getIt<CallLogsRepository>();

  // Get call logs from API via repository
  Future<TwilioCallLogResponse> fetchCallLogs({
    int page = 1,
    int limit = 25,
    String? partnerAccountNo,
  }) async {
    return await _callLogsRepository.fetchCallLogs(
      page: page,
      limit: limit,
      partnerAccountNo: partnerAccountNo,
    );
  }

  // Convert API response to CallLog model via repository
  List<CallLog> convertApiResponseToCallLogs(TwilioCallLogResponse response) {
    return _callLogsRepository.convertApiResponseToCallLogs(response);
  }

  // Get dummy call logs for testing (keeping this for fallback)
  List<CallLog> getDummyCallLogs() {
    return _callLogsRepository.getDummyCallLogs();
  }
}
