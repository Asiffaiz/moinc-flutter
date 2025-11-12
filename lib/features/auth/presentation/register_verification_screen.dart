import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/home/home_screen.dart';

import 'dart:async';

import 'bloc/auth_bloc.dart';
import 'bloc/auth_event.dart';
import 'bloc/auth_state.dart';

class RegisterVerificationScreen extends StatefulWidget {
  final String email;
  final Map<String, dynamic> registrationData;

  const RegisterVerificationScreen({
    super.key,
    required this.email,
    required this.registrationData,
  });

  @override
  State<RegisterVerificationScreen> createState() =>
      _RegisterVerificationScreenState();
}

class _RegisterVerificationScreenState
    extends State<RegisterVerificationScreen> {
  final List<TextEditingController> _codeControllers = List.generate(
    4,
    (index) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());
  bool _isLoading = false;
  bool _isResending = false;
  bool _isExpired = false;

  // Timer for PIN expiration (60 seconds)
  int _timeLeft = 60;
  Timer? _timer;
  String? _errorMessage;
  String? _successMessage;

  @override
  void initState() {
    super.initState();

    // context.read<AuthBloc>().add(
    //   SendVerifyRegisterCodeRequested(email: widget.email),
    // );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startTimer();
    });
  }

  void _startTimer() {
    // Cancel any existing timer
    _timer?.cancel();
    _timer = null;

    // Immediately update the state with new timer values
    setState(() {
      _timeLeft = 60; // Reset to 60 seconds
      _isExpired = false;

      // Clear all code fields when starting a new timer
      for (var controller in _codeControllers) {
        controller.clear();
      }
    });

    // Force a rebuild to ensure the UI shows the updated timer value
    Future.microtask(() {
      if (mounted) {
        setState(() {}); // Force rebuild with updated _timeLeft
      }
    });

    // Create a new timer after the state has been updated
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          if (_timeLeft > 0) {
            _timeLeft--;
          } else {
            _isExpired = true;
            timer.cancel();
          }
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _codeControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  bool get _isCodeComplete {
    return _codeControllers.every((controller) => controller.text.isNotEmpty);
  }

  void _verifyCode() {
    if (_isCodeComplete) {
      setState(() {
        _errorMessage = null;
        _successMessage = null;
      });

      // Get the complete 4-digit code
      final pincode =
          _codeControllers.map((controller) => controller.text).join();

      context.read<AuthBloc>().add(
        VerifyCodeRequested(
          email: widget.email,
          code: pincode,
          pincodeFor: 'registration',
        ),
      );
    }
  }

  void _resendCode() {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
      _isExpired = false; // Reset expired state immediately on resend
      _timeLeft = 60; // Immediately update the time display
    });

    context.read<AuthBloc>().add(
      // ResendVerificationCodeRequested(email: widget.email),
      SendVerifyRegisterResendCodeRequested(email: widget.email),
    );
  }

  String _formatTime(int seconds) {
    // For a 60-second timer, just show the seconds
    return seconds.toString();
  }

  void _signUp() {
    // Dispatch the registration event
    if (widget.registrationData != null) {
      context.read<AuthBloc>().add(
        RegisterWithApiRequested(userData: widget.registrationData),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.registerPinVerified) {
          _signUp();
        } else if (state.status == AuthStatus.hasMandatoryAgreements) {
          // context.go(AppRoutes.unsignedAgreements);
        } else if (state.status == AuthStatus.registeredSuccessfully) {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
            (route) => false,
          );
        } else if (state.status == AuthStatus.registerCodeResent) {
          // For resend code success
          setState(() {
            _isResending = false;
            // _isExpired = false; // Ensure expired state is reset
            // _timeLeft = 60; // Explicitly set the time to 60 seconds
            //   _successMessage = 'Verification code resent successfully';
          });

          // Call _startTimer() outside of setState to ensure proper timer initialization
          // Use a small delay to ensure the UI updates first
          Future.delayed(Duration.zero, () {
            if (mounted) {
              _startTimer();
            }
          });
        } else if (state.status == AuthStatus.registerPinVerificationError) {
          setState(() {
            _errorMessage = 'Something went wrong please try again later';
            _isResending = false; // Ensure resend loader is stopped on error
          });
        } else if (state.errorMessage == "already_created" &&
            state.status == AuthStatus.error) {
          setState(() {
            _isLoading = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Account already created with this email address. Please choose another one',
              ),
              backgroundColor: AppTheme.errorColor,
            ),
          );
        }

        setState(() {
          _isLoading = state.status == AuthStatus.loading;
          // Ensure resending state is reset if we're no longer in a loading state
          if (state.status != AuthStatus.loading &&
              state.status != AuthStatus.registerCodeResent) {
            _isResending = false;
          }
        });
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Verification'),
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.primaryColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              constraints: BoxConstraints(
                minHeight:
                    screenSize.height -
                    (MediaQuery.of(context).padding.top +
                        MediaQuery.of(context).padding.bottom +
                        kToolbarHeight),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Enter the 4-digit verification code sent to your email to reset your password.',
                    style: AppTheme.bodyLarge.copyWith(color: Colors.white70),
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.errorColor.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: AppTheme.errorColor),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: TextStyle(color: AppTheme.errorColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  // Success message
                  if (_successMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.successColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.successColor.withOpacity(0.5),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: TextStyle(color: AppTheme.successColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Code sent to your email: ',
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white,
                        ),
                      ),
                      Flexible(
                        child: Text(
                          widget.email,
                          style: AppTheme.bodyMedium.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Countdown Timer
                  Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 8,
                      horizontal: 16,
                    ),
                    decoration: BoxDecoration(
                      color:
                          _isExpired
                              ? AppTheme.errorColor.withOpacity(0.1)
                              : AppTheme.secondaryColor.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            _isExpired
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor.withOpacity(0.5),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.timer,
                          color:
                              _isExpired
                                  ? AppTheme.errorColor
                                  : AppTheme.primaryColor,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          _isExpired
                              ? 'Code expired'
                              : (_timeLeft > 0
                                  ? 'Code expires in: ${_formatTime(_timeLeft)} seconds'
                                  : 'Code expires in: 60 seconds'),
                          style: TextStyle(
                            color:
                                _isExpired
                                    ? AppTheme.errorColor
                                    : AppTheme.primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  _buildVerificationCodeFields(),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed:
                          (_isLoading || !_isCodeComplete || _isExpired)
                              ? null
                              : _verifyCode,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.black,
                        disabledBackgroundColor: Colors.grey.shade700,
                        disabledForegroundColor: Colors.grey.shade300,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child:
                          _isLoading
                              ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.black,
                                ),
                              )
                              : Text(
                                _isExpired ? 'Code Expired' : 'Continue',
                                style: AppTheme.buttonText,
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpired ? "Code expired. " : "Didn't receive code? ",
                        style: AppTheme.bodyMedium.copyWith(
                          color: Colors.white70,
                        ),
                      ),
                      TextButton(
                        onPressed:
                            (_isLoading ||
                                    _isResending ||
                                    (!_isExpired && _timeLeft > 0))
                                ? null
                                : _resendCode,

                        style: TextButton.styleFrom(
                          foregroundColor: AppTheme.primaryColor,
                        ),
                        child:
                            _isResending
                                ? const SizedBox(
                                  height: 16,
                                  width: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: AppTheme.primaryColor,
                                  ),
                                )
                                : Text(
                                  _isExpired
                                      ? "Resend Now"
                                      : (_timeLeft > 0
                                          ? "Wait ${_formatTime(_timeLeft)}s"
                                          : "Resend Now"),
                                  style: TextStyle(
                                    color: AppTheme.primaryColor,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVerificationCodeFields() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(
        4,
        (index) => SizedBox(
          width: 60,
          height: 60,
          child: TextField(
            controller: _codeControllers[index],
            focusNode: _focusNodes[index],
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              filled: true,
              fillColor:
                  _isExpired
                      ? AppTheme.secondaryColor.withOpacity(0.3)
                      : AppTheme.secondaryColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppTheme.primaryColor.withOpacity(0.5),
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              errorBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.errorColor),
              ),
              counterText: '',
            ),
            inputFormatters: [
              LengthLimitingTextInputFormatter(1),
              FilteringTextInputFormatter.digitsOnly,
            ],
            enabled: !_isExpired,
            onChanged: (value) {
              if (value.isNotEmpty && index < 3) {
                _focusNodes[index + 1].requestFocus();
              }
              if (_isCodeComplete) {
                FocusScope.of(context).unfocus();
              }
              setState(() {});
            },
          ),
        ),
      ),
    );
  }
}
