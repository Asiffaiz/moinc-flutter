import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:livekit_client/livekit_client.dart' as sdk;
import 'package:livekit_components/livekit_components.dart' as components;
import 'package:logging/logging.dart';
import 'package:uuid/uuid.dart';

import '../data/services/agent_service.dart';
import '../domain/models/agent_model.dart';
import '../exts.dart';
import '../services/token_service.dart';

enum AppScreenState { welcome, agent, audioCall }

enum AgentScreenState { visualizer, transcription }

enum ConnectionState { disconnected, connecting, connected }

// System UI visibility controller
class SystemUIVisibility {
  static void hideSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  }

  static void showSystemUI() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  }
}

class AppCtrl extends ChangeNotifier {
  static const uuid = Uuid();
  static final _logger = Logger('AppCtrl');

  // States
  AppScreenState appScreenState = AppScreenState.welcome;
  ConnectionState connectionState = ConnectionState.disconnected;
  AgentScreenState agentScreenState = AgentScreenState.visualizer;

  //Test
  bool isUserCameEnabled = false;
  bool _isFullScreen = false;
  bool isScreenshareEnabled = false;
  bool isHoldEnabled = false;
  bool isDiabledAgentControl = false;
  int remainingDisabledTime = 0; // Track remaining time in seconds
  final messageCtrl = TextEditingController();
  final messageFocusNode = FocusNode();

  late final sdk.Room room = sdk.Room(
    roomOptions: const sdk.RoomOptions(enableVisualizer: true),
  );
  late final roomContext = components.RoomContext(room: room);

  // Add event listeners for debugging
  bool _roomListenersInitialized = false;

  final tokenService = TokenService();
  final agentService = AgentService();

  // Agent information from API
  AgentModel? _agentModel;
  AgentModel? publicAgentModel;

  AgentModel? get agentModel => _agentModel;

  bool isSendButtonEnabled = false;

  // Flag to track if UI wants the call (prevents state mismatch)
  bool _uiWantsCall = false;

  // Timers
  Timer? _agentConnectionTimer;
  Timer? _disableControlTimer;

  AppCtrl() {
    final format = DateFormat('HH:mm:ss');
    // configure logs for debugging
    Logger.root.level = Level.FINE;
    Logger.root.onRecord.listen((record) {
      debugPrint('${format.format(record.time)}: ${record.message}');
    });

    messageCtrl.addListener(() {
      final newValue = messageCtrl.text.isNotEmpty;
      if (newValue != isSendButtonEnabled) {
        isSendButtonEnabled = newValue;
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    messageCtrl.dispose();
    _cancelAgentTimer();
    _disableControlTimer?.cancel();
    super.dispose();
  }

  void disableAgentControlFor30Seconds() {
    // Cancel any existing timer
    _disableControlTimer?.cancel();

    // Set initial values
    isDiabledAgentControl = true;
    remainingDisabledTime = 30;
    notifyListeners();

    // Create a periodic timer that fires every second
    _disableControlTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Decrement the remaining time
      remainingDisabledTime--;

      // Notify listeners to update UI
      notifyListeners();

      // Check if we've reached zero
      if (remainingDisabledTime <= 0) {
        // Cancel the timer
        timer.cancel();
        _disableControlTimer = null;

        // Reset the disabled state
        isDiabledAgentControl = false;
        notifyListeners();
      }
    });
  }

  void sendMessage() async {
    isSendButtonEnabled = false;

    final text = messageCtrl.text;
    messageCtrl.clear();
    notifyListeners();

    final lp = room.localParticipant;
    if (lp == null) return;

    final nowUtc = DateTime.now().toUtc();
    final segment = sdk.TranscriptionSegment(
      id: uuid.v4(),
      text: text,
      firstReceivedTime: nowUtc,
      lastReceivedTime: nowUtc,
      isFinal: true,
      language: 'en',
    );
    roomContext.insertTranscription(
      components.TranscriptionForParticipant(segment, lp),
    );

    await lp.sendText(text, options: sdk.SendTextOptions(topic: 'lk.chat'));
  }

  void toggleUserCamera(components.MediaDeviceContext? deviceCtx) {
    isUserCameEnabled = !isUserCameEnabled;
    isUserCameEnabled ? deviceCtx?.enableCamera() : deviceCtx?.disableCamera();
    notifyListeners();
  }

  void toggleScreenShare() {
    isScreenshareEnabled = !isScreenshareEnabled;
    notifyListeners();
  }

  void toggleAgentScreenMode() {
    agentScreenState =
        agentScreenState == AgentScreenState.visualizer
            ? AgentScreenState.transcription
            : AgentScreenState.visualizer;
    notifyListeners();
  }

  void _setupRoomListeners() {
    if (_roomListenersInitialized) return;

    _logger.info("Setting up room event listeners");

    // Listen for participant connected events
    room.addListener(() {
      _logger.info("Room state changed: ${room.connectionState}");

      // Log remote participants whenever the room state changes
      _logger.info(
        "Remote participants count: ${room.remoteParticipants.length}",
      );
      if (room.remoteParticipants.isNotEmpty) {
        room.remoteParticipants.forEach((sid, participant) {
          _logger.info(
            "Remote participant: ${participant.identity} (${participant.sid})",
          );
          _logger.info("Participant kind: ${participant.kind}");
        });
      }

      // Check if room disconnected
      if (room.connectionState == sdk.ConnectionState.disconnected) {
        _logger.warning("Room disconnected - checking reason");

        // CRITICAL: If room disconnected but UI doesn't want call, ensure we're synced
        if (!_uiWantsCall) {
          _logger.info(
            "Room disconnected and UI doesn't want call - state is correct",
          );
        }

        // Reset UI state when room disconnects
        connectionState = ConnectionState.disconnected;
        _uiWantsCall = false; // Ensure flag is synced

        // Show toast message to inform the user
        // Fluttertoast.showToast(
        //     msg: "Agent disconnected. Please try again later.",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 3,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);

        notifyListeners();
      } else if (room.connectionState == sdk.ConnectionState.connected) {
        // CRITICAL: If room is connected but UI doesn't want call, disconnect immediately
        if (!_uiWantsCall) {
          _logger.warning(
            "Room connected but UI doesn't want call - disconnecting immediately",
          );
          room.disconnect();
          connectionState = ConnectionState.disconnected;
          notifyListeners();
          return;
        }
      }

      notifyListeners();
    });

    // Add a listener for disconnection events
    room.createListener().on<sdk.RoomDisconnectedEvent>((event) {
      _logger.severe("Room disconnected event received");
      // Reset UI state when disconnection event is received
      connectionState = ConnectionState.disconnected;
      _uiWantsCall = false; // Ensure flag is synced on disconnect

      // Show toast message to inform the user about the disconnection
      // Fluttertoast.showToast(
      //     msg: "Connection to agent lost. Please try again later.",
      //     toastLength: Toast.LENGTH_LONG,
      //     gravity: ToastGravity.BOTTOM,
      //     timeInSecForIosWeb: 3,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);

      notifyListeners();
    });

    _roomListenersInitialized = true;
  }

  void connect() async {
    _logger.info("Connect called at ${DateTime.now()}");

    // Block duplicate connect calls
    if (connectionState == ConnectionState.connecting ||
        connectionState == ConnectionState.connected) {
      _logger.warning("BLOCKED: Already connecting/connected");
      return;
    }

    // Set UI intent flag
    _uiWantsCall = true;

    connectionState = ConnectionState.connecting;
    notifyListeners();

    // Hide system UI (status bar and bottom navigation) when connecting
    SystemUIVisibility.hideSystemUI();

    try {
      // Set up room event listeners
      _setupRoomListeners();

      // Use agent information from API, fallback to defaults if not available
      if (_agentModel == null) {
        _logger.warning(
          "Agent model not set, using default values. Make sure to fetch agent before connecting.",
        );
      }

      final String roomName = _agentModel?.livekitRoom ?? "moinc_room";
      final String agentName = _agentModel?.agentName ?? "Maya";
      final String agentId =
          _agentModel?.agentId ?? "1d1b9e95-f4cd-46d7-985e-fb4884bb08e7";

      _logger.info("Requesting token for room: $roomName, agent: $agentName");

      try {
        // Get connection details with token from API
        final connectionDetails = await tokenService.fetchConnectionDetails(
          agentId: agentId,
          roomName: roomName,
          agentName: agentName,
        );

        final serverUrl = connectionDetails.serverUrl;
        final token = connectionDetails.participantToken;

        _logger.info("Token received successfully");

        // Decode token to understand what's in it (for debugging)
        final parts = token.split('.');
        if (parts.length > 1) {
          final payload = parts[1];
          final normalized = base64Url.normalize(payload);
          final decoded = utf8.decode(base64Url.decode(normalized));
          _logger.info("Token payload: $decoded");
        }

        _logger.info("Connecting to LiveKit server: $serverUrl");

        // Log the current state of remote participants before connecting
        _logger.info(
          "Remote participants before connect: ${room.remoteParticipants.length}",
        );

        // Connect to the room with the generated token
        await room.connect(serverUrl, token);

        _logger.info("Room connection state: ${room.connectionState}");
        _logger.info("Local participant: ${room.localParticipant?.identity}");
        _logger.info("Room name: ${room.name}");

        // CRITICAL: Check if UI still wants the call after connection
        // This prevents agent from staying connected when UI shows "Connect" button
        if (!_uiWantsCall) {
          _logger.warning(
            "UI canceled while connecting → disconnecting immediately",
          );
          await room.disconnect();
          connectionState = ConnectionState.disconnected;
          _exitFullScreen();
          notifyListeners();
          return;
        }
      } catch (e) {
        _logger.severe("Error generating token or connecting: $e");
        connectionState = ConnectionState.disconnected;
        notifyListeners();
        rethrow;
      }

      // Enable microphone
      await room.localParticipant?.setMicrophoneEnabled(true);
      _logger.info("Microphone enabled");

      // Log the current state of remote participants after connecting
      _logger.info(
        "Remote participants after connect: ${room.remoteParticipants.length}",
      );
      if (room.remoteParticipants.isNotEmpty) {
        room.remoteParticipants.forEach((sid, participant) {
          _logger.info(
            "Remote participant: ${participant.identity} (${participant.sid})",
          );
          _logger.info("Participant kind: ${participant.kind}");
          _logger.info("Participant state: ${participant.connectionQuality}");
        });
      } else {
        _logger.warning("No remote participants found after connection");
      }

      connectionState = ConnectionState.connected;

      // If we're in audio call screen, stay there, otherwise go to agent screen
      if (appScreenState != AppScreenState.audioCall) {
        appScreenState = AppScreenState.agent;
      }

      // Start the timer to check for AGENT participant
      _startAgentConnectionTimer();
      _enterFullScreen();
      notifyListeners();
    } catch (error) {
      _logger.severe('Connection error: $error');

      connectionState = ConnectionState.disconnected;
      _exitFullScreen();
      // appScreenState = AppScreenState.welcome;
      notifyListeners();
    }
  }

  void _enterFullScreen() {
    // Hide status bar and navigation bar
    SystemUIVisibility.hideSystemUI();
    _isFullScreen = true;
    notifyListeners();
  }

  void _exitFullScreen() {
    // Restore system UI
    SystemUIVisibility.showSystemUI();
    _isFullScreen = false;
    notifyListeners();
  }

  void disconnect() async {
    _logger.info("Disconnect called at ${DateTime.now()}");

    // Set UI intent flag to false immediately
    _uiWantsCall = false;

    // If already disconnected, return early
    if (connectionState == ConnectionState.disconnected) {
      _logger.info("Already disconnected, returning");
      return;
    }

    // First update the connection state to trigger UI changes
    connectionState = ConnectionState.disconnected;
    notifyListeners();

    // Add a small delay for smooth transition before showing system UI
    await Future.delayed(const Duration(milliseconds: 300));

    // Show system UI with a smooth transition
    SystemUIVisibility.showSystemUI();

    // Disconnect from the room and clean up
    room.disconnect();
    _cancelAgentTimer();

    // If we're in audio call screen, stay there, otherwise go back to welcome
    if (appScreenState != AppScreenState.audioCall) {
      appScreenState = AppScreenState.welcome;
    }
    agentScreenState = AgentScreenState.visualizer;

    notifyListeners();
  }

  // Start a 60-second timer to check for agent connection
  void _startAgentConnectionTimer() {
    _cancelAgentTimer(); // Cancel any existing timer
    _logger.info("Starting 60-second timer to check for AGENT participant...");

    _agentConnectionTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // First check if room is still connected
      if (room.connectionState == sdk.ConnectionState.disconnected) {
        _logger.warning(
          "Room disconnected during agent check, cancelling timer",
        );
        _cancelAgentTimer();
        connectionState = ConnectionState.disconnected;

        // Show toast message to inform the user
        // Fluttertoast.showToast(
        //     msg: "Connection lost while waiting for agent.",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 3,
        //     backgroundColor: Colors.red,
        //     textColor: Colors.white,
        //     fontSize: 16.0);

        notifyListeners();
        return;
      }

      // Log detailed information about remote participants every 5 seconds
      if (timer.tick % 5 == 0) {
        _logger.info(
          "Timer tick: ${timer.tick}, checking remote participants...",
        );
        _logger.info("Room state: ${room.connectionState}");
        _logger.info(
          "Remote participants count: ${room.remoteParticipants.length}",
        );

        if (room.remoteParticipants.isEmpty) {
          _logger.warning("No remote participants found");
        } else {
          room.remoteParticipants.forEach((sid, participant) {
            _logger.info(
              "Remote participant: ${participant.identity} (${participant.sid})",
            );
            _logger.info("Participant kind: ${participant.kind}");
            _logger.info("Participant metadata: ${participant.metadata}");
            _logger.info("Participant attributes: ${participant.attributes}");
            _logger.info(
              "Participant tracks: ${participant.trackPublications.length}",
            );
          });
        }
      }

      // Check if there's an agent participant
      final hasAgent = room.remoteParticipants.values.any(
        (participant) => participant.isAgent,
      );

      if (hasAgent) {
        _logger.info("AGENT participant found, cancelling timer");
        _cancelAgentTimer();
        return;
      }

      // If 60 seconds have elapsed and no agent found, disconnect
      if (timer.tick >= 60) {
        _logger.warning(
          "No AGENT participant found after 60 seconds, disconnecting...",
        );
        _cancelAgentTimer();

        // Show toast message to inform the user about the timeout
        // Fluttertoast.showToast(
        //     msg: "Could not connect to an agent. Please try again later.",
        //     toastLength: Toast.LENGTH_LONG,
        //     gravity: ToastGravity.BOTTOM,
        //     timeInSecForIosWeb: 3,
        //     backgroundColor: Colors.orange,
        //     textColor: Colors.white,
        //     fontSize: 16.0);

        disconnect();
      }
    });
  }

  // Cancel the agent connection timer
  void _cancelAgentTimer() {
    _agentConnectionTimer?.cancel();
    _agentConnectionTimer = null;
  }

  void toggleHold() {
    isHoldEnabled = !isHoldEnabled;
    notifyListeners();
  }

  /// Sets the agent model from API response
  void setAgentModel(AgentModel agentModel) {
    _agentModel = agentModel;
    publicAgentModel = agentModel;
    _logger.info(
      "Agent model set: ${agentModel.agentName} (${agentModel.agentId})",
    );
    notifyListeners();
  }

  /// Fetches agent information from API
  Future<void> fetchAgent() async {
    try {
      _logger.info("Fetching agent information from API...");
      final agent = await agentService.getAgentWithClientAccountNo();
      setAgentModel(agent);
      _logger.info("Agent information fetched successfully");
    } catch (e) {
      _logger.severe("Failed to fetch agent information: $e");
      // Don't throw, allow app to continue with default values
    }
  }
}
