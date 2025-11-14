import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moinc/config/constants/strings.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_state.dart';
import 'package:moinc/features/auth/presentation/login_screen.dart';
import 'package:moinc/features/auth/presentation/verification_screen.dart';
import 'package:moinc/utils/validators.dart';
import 'package:moinc/utils/custom_toast.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen>
    with RouteAware {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _focusNode = FocusNode();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Add listener to focus node to detect when screen gets focus
    _focusNode.addListener(_onFocusChange);

    // Request focus when screen is shown
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  void _onFocusChange() {
    // No need to clear messages as we're using toasts now
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // No need to clear messages as we're using toasts now
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _resetPassword() {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      context.read<AuthBloc>().add(
        ResetPasswordRequested(email: _emailController.text),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    return WillPopScope(
      onWillPop: () async {
        // No need to clear messages as we're using toasts now
        return true;
      },
      child: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          setState(() {
            _isLoading = state.status == AuthStatus.loading;
          });

          if (state.status == AuthStatus.unauthenticated) {
            // Show success toast instead of widget message
            CustomToast.showCustomeToast(
              'Verification code sent successfully. Redirecting...',
              AppTheme.successColor,
            );

            // Navigate immediately, no need for delay since we're using toast
            if (mounted) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) =>
                          VerificationScreen(email: _emailController.text),
                ),
              );

              //      context.push(
              //   AppRoutes.verification,
              //   extra: _emailController.text,
              // );
            }
          } else if (state.status == AuthStatus.error) {
            // Show error toast instead of widget message
            CustomToast.showCustomeToast(
              state.errorMessage ?? 'Failed to send verification code',
              AppTheme.errorColor,
            );
          }
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
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                    (route) => false, // removes ALL previous screens
                  ),
              //  context.go(AppRoutes.signIn)
            ),
            title: Text(
              AppStrings.forgotPassword,
              style: TextStyle(color: AppTheme.primaryColor),
            ),
          ),
          body: Focus(
            focusNode: _focusNode,
            child: SafeArea(
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
                          AppStrings.verificationProcessText,
                          style: Theme.of(context).textTheme.bodyLarge
                              ?.copyWith(color: Colors.white70),
                        ),
                        const SizedBox(height: 32),

                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: AppTheme.inputDecoration(
                            labelText: AppStrings.email,
                            hintText: 'Enter your email address',
                            prefixIcon: const Icon(Icons.email_outlined),
                          ),
                          validator: Validators.validateEmail,
                          enabled: !_isLoading,
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
                                      AppStrings.continueText,
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
      ),
    );
  }
}
