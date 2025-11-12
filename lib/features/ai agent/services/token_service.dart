import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:logging/logging.dart';
import 'package:moinc/config/api_config.dart';

/// Data class representing the connection details needed to join a LiveKit room
/// This includes the server URL, room name, participant info, and auth token
class ConnectionDetails {
  final String serverUrl;
  final String roomName;
  final String participantName;
  final String participantToken;

  ConnectionDetails({
    required this.serverUrl,
    required this.roomName,
    required this.participantName,
    required this.participantToken,
  });

  factory ConnectionDetails.fromJson(Map<String, dynamic> json) {
    return ConnectionDetails(
      serverUrl: json['serverUrl'],
      roomName: json['roomName'],
      participantName: json['participantName'],
      participantToken: json['participantToken'],
    );
  }
}

/// Service for fetching LiveKit authentication tokens from the API
class TokenService {
  static final _logger = Logger('TokenService');

  // API endpoint for token generation
  final String tokenEndpoint =
      '${ApiConfig.baseApiUrl}/mobile/token'; // Replace with your actual base URL

  // LiveKit server URL
  final String serverUrl = "wss://voiceadmin-q6nhb8k6.livekit.cloud";

  // For hardcoded token usage (development only)
  final String? hardcodedServerUrl = null;
  final String? hardcodedToken = null;

  /// Generate token from API
  Future<String> generateToken({
    required String agentId,
    required String roomName,
    required String agentName,
  }) async {
    _logger.info('Generating token for agent: $agentName, room: $roomName');

    final uri = Uri.parse(tokenEndpoint);
    final payload = {
      'agent_id': agentId,
      'room_name': roomName,
      'agent_name': agentName,
    };

    try {
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (response.statusCode >= 200 && response.statusCode < 300) {
        try {
          final data = jsonDecode(response.body);
          final token = data['token'];
          _logger.info('Token generated successfully');
          return token;
        } catch (e) {
          _logger.severe(
            'Error parsing token from API response: ${response.body}',
          );
          throw Exception('Error parsing token from API response');
        }
      } else {
        _logger.severe(
          'Error from token API: ${response.statusCode}, response: ${response.body}',
        );
        throw Exception('Error from token API: ${response.statusCode}');
      }
    } catch (e) {
      _logger.severe('Failed to connect to token API: $e');
      throw Exception('Failed to connect to token API: $e');
    }
  }

  /// Get connection details using the generated token
  Future<ConnectionDetails> fetchConnectionDetails({
    required String agentId,
    required String roomName,
    required String agentName,
  }) async {
    try {
      final token = await generateToken(
        agentId: agentId,
        roomName: roomName,
        agentName: agentName,
      );

      return ConnectionDetails(
        serverUrl: serverUrl,
        roomName: roomName,
        participantName: agentName,
        participantToken: token,
      );
    } catch (e) {
      _logger.severe('Failed to fetch connection details: $e');
      throw Exception('Failed to fetch connection details: $e');
    }
  }

  ConnectionDetails? fetchHardcodedConnectionDetails({
    required String roomName,
    required String participantName,
  }) {
    if (hardcodedServerUrl == null || hardcodedToken == null) {
      return null;
    }

    return ConnectionDetails(
      serverUrl: hardcodedServerUrl!,
      roomName: roomName,
      participantName: participantName,
      participantToken: hardcodedToken!,
    );
  }
}
