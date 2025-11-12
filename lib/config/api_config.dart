class ApiConfig {
  // Private constructor to prevent instantiation
  ApiConfig._();

  // Base URLs
  static const String baseApiUrl = 'https://amd.voiceadmins.com/api';
  static const String twilioBaseUrl = 'https://api.twilio.com/2010-04-01';

  // Twilio credentials
  static const String twilioAccountSid =
      'ACc4f271440ea1ae0b4854a3781ec9c647'; // Replace with your actual SID
  static const String twilioAuthToken =
      'cb5c5a6ebe6829fd0f1c8067767de868'; // Replace with your actual token

  // LiveKit credentials
  static const String livekitApiKey = 'APIaZo9J6XbaSQa';
  static const String livekitApiSecret =
      'WeYcq9tQruYShGPajHpyLpUatKhfiuTd37ScSaznFtV';
  static const String livekitUrl = 'wss://voiceadmin-q6nhb8k6.livekit.cloud';

  // Telephony API endpoints
  static const String telephonyCallEndpoint = '$baseApiUrl/telephony/call';
  static const String telephonyHangupEndpoint = '$baseApiUrl/telephony/hangup';

  // Twilio API endpoints
  static String twilioCallEndpoint(String callSid) =>
      '$twilioBaseUrl/Accounts/$twilioAccountSid/Calls/$callSid.json';
}
