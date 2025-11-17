import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class TelephonyService {
  static const String _baseUrl = 'https://amd.voiceadmins.com/api';

  // Singleton instance
  static final TelephonyService _instance = TelephonyService._internal();
  factory TelephonyService() => _instance;
  TelephonyService._internal();

  /// Initiates a call with the provided information
  /// Returns a map with success status and data or error message
  Future<Map<String, dynamic>> initiateCall(
    String phoneNumber, {
    String? name,
    String? email,
    String? agentId,
    String? roomName,
  }) async {
    try {
      // Format phone number if needed (ensure it has country code)
      String formattedNumber = _formatPhoneNumber(phoneNumber);

      // Prepare the payload
      // final payload = {
      //   "agent_id": "1d1b9e95-f4cd-46d7-985e-fb4884bb08e7",
      //   "number_id": "PN121d84b1628b15c46031cc1bed4f834f",
      //   "sip_number": "+15072047942",
      //   "sip_trunk_id": "ST_oafQcvwdUJU8",
      //   "sip_call_to": formattedNumber, // User's phone number
      //   "room_name": "moinc_room",
      //   "participant_identity": name ?? "User",
      //   "participant_name": name ?? "User",
      //   "wait_until_answered": true,
      //   "krisp_enabled": true,
      //   // Additional lead information
      //   "lead_info": {
      //     "name": name ?? "",
      //     "email": email ?? "",
      //     "phone": formattedNumber,
      //     "timestamp": DateTime.now().toIso8601String(),
      //   },
      // };

      final payload = {
        "agent_id": agentId,
        "number_id": "PN121d84b1628b15c46031cc1bed4f834f",
        "sip_number": "+15072047942",
        "sip_trunk_id": "ST_oafQcvwdUJU8",
        "sip_call_to": formattedNumber, // User's phone number
        "room_name": roomName,
        "participant_identity": name ?? "User",
        "participant_name": name ?? "User",
        "wait_until_answered": true,
        "krisp_enabled": true,
        // Additional lead information
        "lead_info": {
          "name": name ?? "",
          "email": email ?? "",
          "phone": formattedNumber,
          "timestamp": DateTime.now().toIso8601String(),
        },
      };

      // Make the API call
      final response = await http.post(
        Uri.parse('$_baseUrl/telephony/call'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(payload),
      );
      // .timeout(const Duration(seconds: 30));

      if (kDebugMode) {
        print('Call API response: ${response.statusCode}');
        print('Call API body: ${response.body}');
      }

      // Parse the response
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final responseData = jsonDecode(response.body);
        // Extract LiveKit SIP call ID if available
        final sipCallId = responseData['livekit_sip_call_id'] ?? '';

        return {
          'success': true,
          'data': responseData,
          'phoneNumber': formattedNumber,
          'sessionId': responseData['session_id'] ?? '',
          'sipCallId': sipCallId,
        };
      } else {
        return {
          'success': false,
          'message': 'Failed to initiate call. Status: ${response.statusCode}',
        };
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error initiating call: $e');
      }
      return {'success': false, 'message': 'An error occurred: $e'};
    }
  }

  /// Format phone number to ensure it has country code
  String _formatPhoneNumber(String phoneNumber) {
    // Remove any non-digit characters
    // String digits = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');

    // // If it doesn't start with +, add +1 (US code) as default
    // if (!digits.startsWith('+')) {
    //   // If it already starts with 1, just add +
    //   if (digits.startsWith('1')) {
    //     digits = '+$digits';
    //   } else {
    //     // Otherwise add +1
    //     digits = '+1$digits';
    //   }
    // }

    // return digits;
    return phoneNumber;
  }
}
