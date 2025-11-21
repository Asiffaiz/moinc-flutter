import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moinc/config/constants/strings.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_state.dart';
import 'package:moinc/features/auth/presentation/forgot_password_screen.dart';
import 'package:moinc/features/auth/presentation/login_screen.dart';
import 'package:moinc/utils/validators.dart';
import 'package:moinc/widgets/password_text_field.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String? email;
  final String? code;

  const ResetPasswordScreen({super.key, this.email, this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  String? _errorMessage;
  String? _email;
  String? _code;

  @override
  void initState() {
    super.initState();
    _email = widget.email;
    _code = widget.code;

    // If email or code is missing, try to get from AuthBloc state
    // if (_email == null || _code == null) {
    //   final authState = context.read<AuthBloc>().state;
    //   if (authState.additionalData != null) {
    //     _email = authState.additionalData!['email'] as String?;
    //     _code = authState.additionalData!['code'] as String?;
    //   }
    // }

    // // If still missing, show error
    // if (_email == null || _code == null) {
    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     setState(() {
    //       _errorMessage = 'Missing verification information. Please try again.';
    //     });
    //   });
    // }
  }

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_email == null || _code == null) {
        setState(() {
          _errorMessage = 'Missing verification information. Please try again.';
        });
        return;
      }

      context.read<AuthBloc>().add(
        SetNewPasswordRequested(
          newPassword: _newPasswordController.text,
          email: _email!,
          code: _code!,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // Navigate to forgot password screen when back button is pressed
        // context.go(AppRoutes.forgotPassword);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
          (route) => false, // removes ALL previous screens
        );
        return false; // Prevent default back behavior
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Password reset successfully! Please sign in.'),
              ),
            );
            // context.go(AppRoutes.signIn);

            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => LoginScreen()),
              (route) => false, // removes ALL previous screens
            );
            setState(() {
              _errorMessage = "";
            });
          } else if (state.status == AuthStatus.error) {
            setState(() {
              _errorMessage = state.errorMessage ?? 'An error occurred';
            });
          }

          setState(() {
            _isLoading = state.status == AuthStatus.loading;
          });
        },
        child: Scaffold(
          backgroundColor: AppTheme.secondaryColor,
          appBar: AppBar(
            backgroundColor: AppTheme.secondaryColor,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: AppTheme.primaryColor),
              onPressed:
                  () => Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ForgotPasswordScreen(),
                    ),
                    (route) => false, // removes ALL previous screens
                  ),
              //  context.go(AppRoutes.forgotPassword)
            ),
            title: Text(
              AppStrings.resetPassword,
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          body: SafeArea(
            child: SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  vertical: 24,
                  horizontal: 24,
                ),
                constraints: BoxConstraints(
                  minHeight:
                      screenSize.height -
                      (MediaQuery.of(context).padding.top +
                          MediaQuery.of(context).padding.bottom +
                          kToolbarHeight),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.passwordDifferentText,
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

                      PasswordTextField(
                        svgPath: 'assets/icons/ic_password.svg',
                        label: AppStrings.newPassword,
                        controller: _newPasswordController,
                        validator: Validators.validatePassword,
                      ),
                      const SizedBox(height: 16),
                      PasswordTextField(
                        svgPath: 'assets/icons/ic_password.svg',
                        label: AppStrings.confirmPassword,
                        controller: _confirmPasswordController,
                        validator:
                            (value) => Validators.validateConfirmPassword(
                              value,
                              _newPasswordController.text,
                            ),
                      ),
                      const SizedBox(height: 32),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _resetPassword,
                          style: AppTheme.primaryButtonStyle.copyWith(
                            backgroundColor: MaterialStateProperty.resolveWith<
                              Color
                            >((states) {
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
                                  : const Text(
                                    AppStrings.resetPassword,
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
