import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:moinc/config/api_config.dart';

class CallHangupService {
  // Singleton instance
  static final CallHangupService _instance = CallHangupService._internal();
  factory CallHangupService() => _instance;
  CallHangupService._internal();

  /// Terminates an active call using either LiveKit SIP or Twilio API
  ///
  /// Parameters:
  /// - `callSid`: The call SID (Twilio call ID or LiveKit SIP call ID)
  /// - `roomName`: The LiveKit room name (only needed for LiveKit calls)
  /// - `participantId`: The participant ID (only needed for LiveKit calls)
  ///
  /// Returns a map with success status and message
  Future<Map<String, dynamic>> hangupCall({
    required String callSid,
    String? roomName,
    String? participantId,
  }) async {
    try {
      if (kDebugMode) {
        print('Hangup call requested for SID: $callSid');
        print(
          'Call provider details - Room: $roomName, Participant: $participantId',
        );
      }

      // Check if it's a LiveKit SIP call (starts with SCL_) or a Twilio call
      if (callSid.startsWith('SCL_')) {
        if (kDebugMode) {
          print('Detected LiveKit SIP call: $callSid');
        }

        // LiveKit SIP Call - requires room name and participant ID
        if (roomName == null || participantId == null) {
          throw Exception(
            'Room name and participant ID are required for LiveKit SIP calls',
          );
        }

        return await _hangupLiveKitCall(callSid, roomName, participantId);
      } else {
        if (kDebugMode) {
          print('Detected Twilio call: $callSid');
        }

        // Twilio Call - use Twilio API
        return await _hangupTwilioCall(callSid);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error terminating call: $e');
      }
      return {
        'success': false,
        'message': 'An error occurred while terminating the call: $e',
      };
    }
  }

  /// Terminates a LiveKit SIP call
  Future<Map<String, dynamic>> _hangupLiveKitCall(
    String callSid,
    String roomName,
    String participantId,
  ) async {
    try {
      // Construct the URL with query parameters
      final uri = Uri.parse(ApiConfig.telephonyHangupEndpoint).replace(
        queryParameters: {
          'sid': callSid,
          'room': roomName,
          'participant': participantId,
        },
      );

      // Make the API call to terminate the call
      final response = await http.patch(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      );

      if (kDebugMode) {
        print('LiveKit Hangup API response: ${response.statusCode}');
        print('LiveKit Hangup API body: ${response.body}');
      }

      // Parse the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message':
              responseData['message'] ?? 'LiveKit call terminated successfully',
          'provider': 'livekit',
        };
      } else {
        return {
          'success': false,
          'message':
              'Failed to terminate LiveKit call. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error terminating LiveKit call: $e');
      }
      return {
        'success': false,
        'message': 'An error occurred while terminating the LiveKit call: $e',
      };
    }
  }

  /// Terminates a Twilio call
  Future<Map<String, dynamic>> _hangupTwilioCall(String callSid) async {
    try {
      // Create Basic Auth header
      final authHeader =
          'Basic ' +
          base64Encode(
            utf8.encode(
              '${ApiConfig.twilioAccountSid}:${ApiConfig.twilioAuthToken}',
            ),
          );

      // Construct the URL for the Twilio API call
      final uri = Uri.parse(ApiConfig.twilioCallEndpoint(callSid));

      // Make the API call to terminate the call
      final response = await http.post(
        uri,
        headers: {
          'Authorization': authHeader,
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: {'Status': 'completed'},
      );

      if (kDebugMode) {
        print('Twilio Hangup API response: ${response.statusCode}');
        print('Twilio Hangup API body: ${response.body}');
      }

      // Parse the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': 'Twilio call terminated successfully',
          'provider': 'twilio',
          'data': responseData,
        };
      } else {
        final error = response.body;
        return {
          'success': false,
          'message': 'Failed to terminate Twilio call: $error',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error terminating Twilio call: $e');
      }
      return {
        'success': false,
        'message': 'An error occurred while terminating the Twilio call: $e',
      };
    }
  }
}
