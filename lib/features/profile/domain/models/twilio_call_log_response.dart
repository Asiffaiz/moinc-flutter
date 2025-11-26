class TwilioCallLogResponse {
  final String status;
  final String baseUrl;
  final String accountno;
  final Pagination pagination;
  final int count;
  final List<TwilioCallLogData> data;

  TwilioCallLogResponse({
    required this.status,
    required this.baseUrl,
    required this.accountno,
    required this.pagination,
    required this.count,
    required this.data,
  });

  factory TwilioCallLogResponse.fromJson(Map<String, dynamic> json) {
    try {
      return TwilioCallLogResponse(
        status: json['status'] as String? ?? 'unknown',
        baseUrl: json['base_url'] as String? ?? 'https://logs.voiceadmins.com/',
        accountno: json['accountno'] as String? ?? '',
        pagination:
            json['pagination'] != null
                ? Pagination.fromJson(
                  json['pagination'] as Map<String, dynamic>,
                )
                : Pagination(
                  page: 1,
                  limit: 25,
                  total: 0,
                  totalPages: 1,
                  hasNext: false,
                  hasPrev: false,
                ),
        count: json['count'] as int? ?? 0,
        data:
            json['data'] != null
                ? (json['data'] as List<dynamic>)
                    .map(
                      (e) =>
                          TwilioCallLogData.fromJson(e as Map<String, dynamic>),
                    )
                    .toList()
                : [],
      );
    } catch (e) {
      // If there's an error parsing the JSON, return a default response
      print('Error parsing TwilioCallLogResponse: $e');
      return TwilioCallLogResponse(
        status: 'error',
        baseUrl: 'https://logs.voiceadmins.com/',
        accountno: '',
        pagination: Pagination(
          page: 1,
          limit: 25,
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
}

class Pagination {
  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final int? nextPage;
  final int? prevPage;

  Pagination({
    required this.page,
    required this.limit,
    required this.total,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    this.nextPage,
    this.prevPage,
  });

  factory Pagination.fromJson(Map<String, dynamic> json) {
    try {
      return Pagination(
        page: json['page'] as int? ?? 1,
        limit: json['limit'] as int? ?? 25,
        total: json['total'] as int? ?? 0,
        totalPages: json['total_pages'] as int? ?? 1,
        hasNext: json['has_next'] as bool? ?? false,
        hasPrev: json['has_prev'] as bool? ?? false,
        nextPage: json['next_page'] as int?,
        prevPage: json['prev_page'] as int?,
      );
    } catch (e) {
      // If there's an error parsing the JSON, return a default pagination
      print('Error parsing Pagination: $e');
      return Pagination(
        page: 1,
        limit: 25,
        total: 0,
        totalPages: 1,
        hasNext: false,
        hasPrev: false,
      );
    }
  }
}

class TwilioCallLogData {
  final int id;
  final String fromNumber;
  final String fromFormatted;
  final String toNumber;
  final String toFormatted;
  final String status;
  final String direction;
  final String callerName;
  final int duration;
  final String startTime;
  final String endTime;
  final String dateCreated;
  final String dateUpdated;
  final String? forwardedFrom;
  final String? recording;
  final String accountno;
  final String compName;
  final String? transcript;
  final String? summarizeTranscript;
  final String callerNumber;
  final String logType;

  TwilioCallLogData({
    required this.id,
    required this.fromNumber,
    required this.fromFormatted,
    required this.toNumber,
    required this.toFormatted,
    required this.status,
    required this.direction,
    required this.callerName,
    required this.duration,
    required this.startTime,
    required this.endTime,
    required this.dateCreated,
    required this.dateUpdated,
    this.forwardedFrom,
    this.recording,
    required this.accountno,
    required this.compName,
    this.transcript,
    this.summarizeTranscript,
    required this.callerNumber,
    required this.logType,
  });

  factory TwilioCallLogData.fromJson(Map<String, dynamic> json) {
    return TwilioCallLogData(
      id: json['id'] as int? ?? 0,
      fromNumber: json['from_number'] as String? ?? '',
      fromFormatted: json['from_formatted'] as String? ?? '',
      toNumber: json['to_number'] as String? ?? '',
      toFormatted: json['to_formatted'] as String? ?? '',
      status: json['status'] as String? ?? 'unknown',
      direction: json['direction'] as String? ?? '',
      callerName: json['caller_name'] as String? ?? 'Unknown',
      duration: json['duration'] as int? ?? 0,
      startTime: json['start_time'] as String? ?? DateTime.now().toString(),
      endTime: json['end_time'] as String? ?? DateTime.now().toString(),
      dateCreated: json['date_created'] as String? ?? DateTime.now().toString(),
      dateUpdated: json['date_updated'] as String? ?? DateTime.now().toString(),
      forwardedFrom: json['forwarded_from'] as String?,
      recording: json['recording'] as String?,
      accountno: json['accountno'] as String? ?? '',
      compName: json['comp_name'] as String? ?? '',
      transcript: json['transcript'] as String?,
      summarizeTranscript: json['summarized_transcript'] as String?,
      callerNumber: json['caller_number'] as String? ?? '',
      logType: json['log_type'] as String? ?? 'twillio',
    );
  }
}
