import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class CallHangupService {
  static const String _baseUrl = 'https://amd.voiceadmins.com/api';

  // Singleton instance
  static final CallHangupService _instance = CallHangupService._internal();
  factory CallHangupService() => _instance;
  CallHangupService._internal();

  /// Terminates an active call using the LiveKit SIP integration
  ///
  /// Parameters:
  /// - `callSid`: The SIP call ID (starts with SCL_)
  /// - `roomName`: The LiveKit room name
  /// - `participantId`: The participant ID to remove
  ///
  /// Returns a map with success status and message
  Future<Map<String, dynamic>> hangupCall({
    required String callSid,
    required String roomName,
    required String participantId,
  }) async {
    try {
      // Construct the URL with query parameters
      final uri = Uri.parse('$_baseUrl/telephony/hangup').replace(
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
        print('Hangup API response: ${response.statusCode}');
        print('Hangup API body: ${response.body}');
      }

      // Parse the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        return {
          'success': true,
          'message': responseData['message'] ?? 'Call terminated successfully',
          'provider': responseData['provider'] ?? 'unknown',
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to terminate call. Status: ${response.statusCode}',
        };
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
}
