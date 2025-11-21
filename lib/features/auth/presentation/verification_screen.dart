import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moinc/config/constants/strings.dart';
import 'package:moinc/config/theme.dart';

import 'dart:async';

import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_state.dart';
import 'package:moinc/features/auth/presentation/reset_password_screen.dart';
import 'package:moinc/utils/custom_toast.dart';

class VerificationScreen extends StatefulWidget {
  final String email;

  const VerificationScreen({super.key, required this.email});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
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
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();
    setState(() {
      _timeLeft = 60; // Reset to 60 seconds
      _isExpired = false;
    });

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _isExpired = true;
          timer.cancel();
        }
      });
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
          pincodeFor: 'forget_password',
        ),
      );
    }
  }

  void _resendCode() {
    setState(() {
      _isResending = true;
      _errorMessage = null;
      _successMessage = null;
    });

    context.read<AuthBloc>().add(
      ResendVerificationCodeRequested(email: widget.email),
    );
  }

  String _formatTime(int seconds) {
    // For a 60-second timer, just show the seconds
    return seconds.toString();
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.pinVerified) {
          // For verification code success
          // Navigate to reset password screen with email and code
          final pincode =
              _codeControllers.map((controller) => controller.text).join();

          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      ResetPasswordScreen(email: widget.email, code: pincode),
            ),
          );
        } else if (state.status == AuthStatus.forgotPasswordCodeResent) {
          // For resend code success
          setState(() {
            _isResending = false;
            _isLoading = false; // Ensure main button doesn't show loader
            _successMessage = null; // Don't show message in widget
            _startTimer(); // Restart timer after resending
          });

          // Show toast for success
          CustomToast.showCustomeToast(
            'Verification code resent successfully',
            AppTheme.successColor,
          );

          // Clear PIN fields after resend
          for (var controller in _codeControllers) {
            controller.clear();
          }
          // Focus on first field
          if (_focusNodes.isNotEmpty) {
            _focusNodes[0].requestFocus();
          }
        } else if (state.status == AuthStatus.error ||
            state.status == AuthStatus.registerPinVerificationError) {
          setState(() {
            _errorMessage = null; // Don't show message in widget
            _isResending = false;
          });

          // Show toast message for error
          CustomToast.showCustomeToast(
            state.errorMessage ??
                'Invalid verification code. Please try again.',
            AppTheme.errorColor,
          );

          // Don't clear PIN fields on error - user may want to make small corrections
        }

        // Only update loading state if not currently resending
        if (!_isResending) {
          setState(() {
            _isLoading = state.status == AuthStatus.loading;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.secondaryColor,
        appBar: AppBar(
          backgroundColor: AppTheme.secondaryColor,
          title: Text(
            'Verification',
            style: TextStyle(color: AppTheme.primaryColor),
          ),
          iconTheme: IconThemeData(color: AppTheme.primaryColor),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
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
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.copyWith(color: AppTheme.lightTextColor),
                  ),
                  const SizedBox(height: 32),

                  // Error message
                  if (_errorMessage != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.errorColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.errorColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.error_outline,
                            color: AppTheme.errorColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppTheme.textColor),
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
                        color: AppTheme.successColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.successColor),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.check_circle_outline,
                            color: AppTheme.successColor,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: AppTheme.textColor),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],

                  Row(
                    children: [
                      Text(
                        '${AppStrings.codeSentText} ',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.copyWith(color: Colors.white),
                      ),
                      Text(
                        widget.email,
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryColor,
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
                              ? AppTheme.errorColor.withOpacity(0.2)
                              : AppTheme.primaryColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color:
                            _isExpired
                                ? AppTheme.errorColor
                                : AppTheme.primaryColor,
                        width: 1,
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
                              : 'Code expires in: ${_formatTime(_timeLeft)} seconds',
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
                      style: AppTheme.primaryButtonStyle.copyWith(
                        backgroundColor:
                            MaterialStateProperty.resolveWith<Color>((states) {
                              // Don't change color when disabled due to loading
                              if (states.contains(MaterialState.disabled) &&
                                  _isLoading) {
                                return AppTheme.primaryColor;
                              }
                              if (states.contains(MaterialState.disabled)) {
                                return Colors.grey.shade700;
                              }
                              return AppTheme.primaryColor;
                            }),
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
                                _isExpired
                                    ? 'Code Expired'
                                    : AppStrings.continueText,
                                style: const TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        _isExpired ? "Code expired. " : "Didn't receive code? ",
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: Colors.white),
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
                                  style: const TextStyle(
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
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              contentPadding: EdgeInsets.zero,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: AppTheme.primaryColor),
              ),
              counterText: '',
              filled: true,
              fillColor:
                  _isExpired
                      ? Colors.grey.shade800.withOpacity(0.5)
                      : AppTheme.secondaryColor.withOpacity(0.7),
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
