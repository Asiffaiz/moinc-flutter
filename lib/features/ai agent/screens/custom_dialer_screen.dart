import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/services/call_service.dart';
import 'package:provider/provider.dart';

class CustomDialerScreen extends StatefulWidget {
  const CustomDialerScreen({Key? key}) : super(key: key);

  @override
  State<CustomDialerScreen> createState() => _CustomDialerScreenState();
}

class _CustomDialerScreenState extends State<CustomDialerScreen> {
  final TextEditingController _phoneController = TextEditingController(
    text: '+18555552368',
  );
  bool _isDialing = false;

  @override
  void initState() {
    super.initState();
    // Default number is already set in the controller
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _addDigit(String digit) {
    setState(() {
      _phoneController.text = _phoneController.text + digit;
    });
    HapticFeedback.lightImpact();
  }

  void _removeDigit() {
    if (_phoneController.text.isNotEmpty) {
      setState(() {
        _phoneController.text = _phoneController.text.substring(
          0,
          _phoneController.text.length - 1,
        );
      });
      HapticFeedback.lightImpact();
    }
  }

  Future<void> _initiateCall() async {
    if (_phoneController.text.isEmpty) return;

    setState(() {
      _isDialing = true;
    });

    final callService = Provider.of<CallService>(context, listen: false);
    final success = await callService.initiateCall(_phoneController.text);

    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Failed to connect call. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() {
        _isDialing = false;
      });

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const ActiveCallScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      appBar: AppBar(
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        title: const Text('Dialer'),
        elevation: 0,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 32),
              // Phone number display
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.secondaryColor.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryColor.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        _phoneController.text.isEmpty
                            ? 'Enter phone number'
                            : _phoneController.text,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color:
                              _phoneController.text.isEmpty
                                  ? Colors.white.withOpacity(0.5)
                                  : Colors.white,
                          letterSpacing: 1.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    if (_phoneController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.backspace_outlined,
                          color: Colors.white70,
                        ),
                        onPressed: _removeDigit,
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              // Dialer pad
              Expanded(
                child: Column(
                  children: [
                    _buildDialerRow(['1', '2', '3']),
                    _buildDialerRow(['4', '5', '6']),
                    _buildDialerRow(['7', '8', '9']),
                    _buildDialerRow(['*', '0', '#']),
                  ],
                ),
              ),
              // Call button
              Padding(
                padding: const EdgeInsets.only(bottom: 24.0),
                child: SizedBox(
                  height: 70,
                  width: 70,
                  child: ElevatedButton(
                    onPressed: _isDialing ? null : _initiateCall,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.black,
                      shape: const CircleBorder(),
                      padding: EdgeInsets.zero,
                      elevation: 3,
                    ),
                    child:
                        _isDialing
                            ? const CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 3,
                            )
                            : const Icon(
                              Icons.call,
                              size: 32,
                              color: Colors.black,
                            ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialerRow(List<String> digits) {
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: digits.map((digit) => _buildDialerButton(digit)).toList(),
      ),
    );
  }

  Widget _buildDialerButton(String digit) {
    return Expanded(
      child: AspectRatio(
        aspectRatio: 1.0,
        child: Padding(
          padding: const EdgeInsets.all(14.0),
          child: ElevatedButton(
            onPressed: () => _addDigit(digit),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.secondaryColor.withOpacity(0.7),
              foregroundColor: Colors.white,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              side: BorderSide(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  digit,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                if (digit == '2' ||
                    digit == '3' ||
                    digit == '4' ||
                    digit == '5' ||
                    digit == '6' ||
                    digit == '7' ||
                    digit == '8' ||
                    digit == '9')
                  Text(
                    _getLetters(digit),
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _getLetters(String digit) {
    switch (digit) {
      case '2':
        return 'ABC';
      case '3':
        return 'DEF';
      case '4':
        return 'GHI';
      case '5':
        return 'JKL';
      case '6':
        return 'MNO';
      case '7':
        return 'PQRS';
      case '8':
        return 'TUV';
      case '9':
        return 'WXYZ';
      default:
        return '';
    }
  }
}

class ActiveCallScreen extends StatefulWidget {
  const ActiveCallScreen({Key? key}) : super(key: key);

  @override
  State<ActiveCallScreen> createState() => _ActiveCallScreenState();
}

class _ActiveCallScreenState extends State<ActiveCallScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.secondaryColor,
      body: Consumer<CallService>(
        builder: (context, callService, child) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  // Caller info
                  Text(
                    callService.phoneNumber,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getCallStateText(callService.callState),
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (callService.callState == CallState.connected)
                    Text(
                      callService.formattedCallDuration,
                      style: const TextStyle(
                        fontSize: 16,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  const SizedBox(height: 60),
                  // Caller avatar
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppTheme.primaryColor,
                    ),
                    child: Center(
                      child: Text(
                        callService.phoneNumber.isNotEmpty
                            ? callService.phoneNumber[0].toUpperCase()
                            : '?',
                        style: const TextStyle(
                          fontSize: 48,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Call controls
                  _buildCallControls(callService),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  String _getCallStateText(CallState state) {
    switch (state) {
      case CallState.dialing:
        return 'Dialing...';
      case CallState.ringing:
        return 'Ringing...';
      case CallState.connected:
        return 'Connected';
      case CallState.onHold:
        return 'On Hold';
      case CallState.ended:
        return 'Call Ended';
      case CallState.failed:
        return 'Call Failed';
      default:
        return '';
    }
  }

  Widget _buildCallControls(CallService callService) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.mic_off,
              label: 'Mute',
              isActive: callService.isMuted,
              onPressed: () => callService.toggleMute(),
            ),
            _buildControlButton(
              icon: Icons.dialpad,
              label: 'Keypad',
              isActive: false,
              onPressed: () {
                // Show keypad dialog
              },
            ),
            _buildControlButton(
              icon: Icons.volume_up,
              label: 'Speaker',
              isActive: callService.isSpeakerOn,
              onPressed: () => callService.toggleSpeaker(),
            ),
          ],
        ),
        const SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildControlButton(
              icon: Icons.add_call,
              label: 'Add Call',
              isActive: false,
              onPressed: () {
                // Add call functionality
              },
            ),
            _buildControlButton(
              icon: Icons.pause,
              label: 'Hold',
              isActive: callService.callState == CallState.onHold,
              onPressed: () => callService.toggleHold(),
            ),
            _buildControlButton(
              icon: Icons.record_voice_over,
              label: 'Record',
              isActive: false,
              onPressed: () {
                // Record call functionality
              },
            ),
          ],
        ),
        const SizedBox(height: 32),
        // End call button
        SizedBox(
          height: 70,
          width: 70,
          child: ElevatedButton(
            onPressed: () async {
              await callService.endCall();
              if (mounted) {
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: const CircleBorder(),
              padding: EdgeInsets.zero,
              elevation: 3,
            ),
            child: const Icon(Icons.call_end, size: 32, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                isActive
                    ? AppTheme.primaryColor
                    : AppTheme.secondaryColor.withOpacity(0.7),
            border: Border.all(
              color:
                  isActive
                      ? AppTheme.primaryColor
                      : AppTheme.primaryColor.withOpacity(0.3),
              width: 1,
            ),
          ),
          child: IconButton(
            icon: Icon(icon, color: isActive ? Colors.black : Colors.white),
            onPressed: onPressed,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? AppTheme.primaryColor : Colors.white70,
          ),
        ),
      ],
    );
  }
}
