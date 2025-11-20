import 'dart:convert';

class AgentModel {
  final String agentId;
  final String agentName;
  final String livekitRoom;
  final String telephonyToken;
  final String userFormEnabled;

  final String sipNumber;
  final String numberId;
  final String accountSid;
  final String partnerAccountNo;

  AgentModel({
    required this.agentId,
    required this.agentName,
    required this.livekitRoom,
    required this.telephonyToken,
    required this.userFormEnabled,
    required this.sipNumber,
    required this.numberId,
    required this.accountSid,
    required this.partnerAccountNo,
  });

  factory AgentModel.fromJson(Map<String, dynamic> json) {
    // Parse popup_data which is a JSON string
    final popupDataStr = json['popup_data'] as String? ?? '{}';
    final popupData = jsonDecode(popupDataStr) as Map<String, dynamic>;

    return AgentModel(
      agentId: json['agent_id'] as String? ?? '',
      agentName: popupData['agentName'] as String? ?? '',
      livekitRoom: popupData['livekit_room'] as String? ?? '',
      telephonyToken: popupData['telephony_token'] as String? ?? '',
      userFormEnabled: popupData['userFormEnabled'] as String? ?? 'No',
      sipNumber: json['sip_number'] as String? ?? '',
      numberId: json['number_id'] as String? ?? '',
      accountSid: json['account_sid'] as String? ?? '',
      partnerAccountNo: json['agent_accountno'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'agent_id': agentId,
      'popup_data': jsonEncode({
        'agentName': agentName,
        'livekit_room': livekitRoom,
        'telephony_token': telephonyToken,
        'userFormEnabled': userFormEnabled,
      }),
    };
  }
}
