import 'package:moinc/config/constants/shared_prefence_keys.dart';
import 'package:moinc/features/ai%20agent/domain/models/agent_model.dart';
import 'package:moinc/features/auth/network/api_client.dart';
import 'package:moinc/features/auth/network/api_endpoints.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AgentService {
  final ApiClient _apiClient = ApiClient();

  /// Fetches agent details from the API
  /// Returns AgentModel if successful, throws exception otherwise
  Future<AgentModel> getAgentWithClientAccountNo() async {
    try {
      // Get user data from shared preferences
      final prefs = await SharedPreferences.getInstance();
      final clientAccountNo =
          prefs.getString(SharedPreferenceKeys.accountNoKey) ?? '';
      final email = prefs.getString(SharedPreferenceKeys.emailKey) ?? '';

      if (clientAccountNo.isEmpty || email.isEmpty) {
        throw Exception('Client account number or email not found');
      }

      // Make API call
      final response = await _apiClient.post(
        ApiEndpoints.getAgentWithClientAccountNo,
        {'client_accountno': clientAccountNo, 'email': email},
      );

      // Check response
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        if (data['status'] == 200 &&
            data['data'] != null &&
            (data['data'] as List).isNotEmpty) {
          // Parse the first agent from the response
          return AgentModel.fromJson(data['data'][0]);
        } else {
          throw Exception(data['message'] ?? 'Failed to get agent information');
        }
      } else {
        throw Exception(
          'API request failed with status: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error fetching agent: $e');
    }
  }
}
