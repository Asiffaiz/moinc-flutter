import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/constants/strings.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_state.dart';
import 'package:moinc/features/auth/presentation/signup_screen.dart';
import 'package:moinc/features/auth/presentation/widgets/social_auth_buttons.dart';
import 'package:moinc/utils/form_label.dart';
import 'package:moinc/utils/validators.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;
  
  // SharedPreferences keys
  static const String _keyRememberMe = 'remember_me';
  static const String _keyEmail = 'email';
  static const String _keyPassword = 'password';
  
  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  // Load saved credentials if Remember Me was checked
  Future<void> _loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    final rememberMe = prefs.getBool(_keyRememberMe) ?? false;
    
    if (rememberMe) {
      final email = prefs.getString(_keyEmail) ?? '';
      final password = prefs.getString(_keyPassword) ?? '';
      
      setState(() {
        _rememberMe = rememberMe;
        _emailController.text = email;
        _passwordController.text = password;
      });
    }
  }
  
  // Save credentials if Remember Me is checked
  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    
    if (_rememberMe) {
      await prefs.setBool(_keyRememberMe, true);
      await prefs.setString(_keyEmail, _emailController.text);
      await prefs.setString(_keyPassword, _passwordController.text);
    } else {
      // Clear saved credentials if Remember Me is unchecked
      await prefs.setBool(_keyRememberMe, false);
      await prefs.remove(_keyEmail);
      await prefs.remove(_keyPassword);
    }
  }

  void _togglePasswordVisibility() {
    setState(() {
      _isPasswordVisible = !_isPasswordVisible;
    });
  }

  void _login() async {
    if (_formKey.currentState!.validate()) {
      // Save credentials if Remember Me is checked
      await _saveCredentials();
      
      setState(() {
        _isLoading = true;
      });

      // Simulate API call
      context.read<AuthBloc>().add(
        LoginWithApiRequested(
          email: _emailController.text,
          password: _passwordController.text,
        ),
      );

      // Navigate to dashboard
      // Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
    }
  }

  void _navigateToRegister() {
    Navigator.pushNamed(context, AppConstants.registerRoute);
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state.status == AuthStatus.apiAuthenticated) {
          setState(() {
            _isLoading = false;
          });

          // Navigate to dashboard after a short delay
          Future.delayed(const Duration(seconds: 1), () {
            // Check if this is a Google Sign-In
            final isGoogleSignIn =
                state.additionalData?['isGoogleSignIn'] == true;

            if (isGoogleSignIn) {
              // For Google Sign-In, use named route to preserve providers
              Navigator.of(context).pushNamedAndRemoveUntil(
                AppConstants.dashboardRoute,
                (route) => false, // Remove all previous routes
              );
            } else {
              // For regular login, use pushReplacementNamed
              Navigator.pushReplacementNamed(
                context,
                AppConstants.dashboardRoute,
              );
            }
          });
        } else if (state.status == AuthStatus.hasMandatoryAgreements) {
          // context.go(AppRoutes.unsignedAgreements);
        } else if (state.status ==
            AuthStatus.googleSigninUserNotExistFromGoogleSignIn) {
          if (mounted) {
            setState(() {
              _isLoading = false;
            });
          }
          /////////////
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) =>
                      SignUpScreen(additionalData: state.additionalData),
            ),
          );
        } else if (state.status == AuthStatus.loginError) {
          if (state.errorMessage == "Invalid Email OR Password") {
            setState(() {
              //  _errorMessage = 'Invalid Email OR Password';
              _isLoading = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Invalid Email OR Password'),
                backgroundColor: AppTheme.errorColor,
              ),
            );
          }
          //  else if (state.errorMessage == "already_created") {
          //   setState(() {
          //     _isLoading = false;
          //   });

          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text(
          //         'Account already created with this email address. Please choose another one',
          //       ),
          //       backgroundColor: AppTheme.errorColor,
          //     ),
          //   );
          // } else {
          //   setState(() {
          //     //  _errorMessage = 'Something went wrong please try again later';
          //     _isLoading = false;
          //   });

          //   ScaffoldMessenger.of(context).showSnackBar(
          //     const SnackBar(
          //       content: Text('Something went wrong please try again later'),
          //       backgroundColor: AppTheme.errorColor,
          //     ),
          //   );
          // }
        } else if (state.status == AuthStatus.loading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });
        }
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 12),
                  // Header
                  Center(
                    child: Column(
                      children: [
                        // Logo placeholder
                        // Container(
                        //   width: 80,
                        //   height: 80,
                        //   decoration: BoxDecoration(
                        //     color: AppTheme.primaryColor,
                        //     borderRadius: BorderRadius.circular(16),
                        //     boxShadow: [
                        //       BoxShadow(
                        //         color: Colors.black.withOpacity(0.1),
                        //         blurRadius: 10,
                        //         offset: const Offset(0, 4),
                        //       ),
                        //     ],
                        //   ),
                        //   child: Center(
                        //     child: Text(
                        //       'M',
                        //       style: AppTheme.headingLarge.copyWith(
                        //         fontSize: 40,
                        //         color: AppTheme.secondaryColor,
                        //         fontWeight: FontWeight.bold,
                        //       ),
                        //     ),
                        //   ),
                        // ),

                        // Logo
                        Center(
                          child: SizedBox(
                            width: 110,
                            height: 110,
                            child: Image.asset(
                              'assets/images/logo1.png',
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                        // const SizedBox(height: 24),
                        // Text(
                        //   'Welcome Back',
                        //   style: AppTheme.headingLarge.copyWith(
                        //     color: Colors.white,
                        //   ),
                        // ),
                        // const SizedBox(height: 8),
                        // Text(
                        //   'Sign in to continue',
                        //   style: AppTheme.bodyMedium.copyWith(
                        //     color: Colors.white70,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Login Form
                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Email Field
                        formLabel(
                          AppStrings.emailAddress,
                          isRequired: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(color: Colors.white),
                          decoration: AppTheme.inputDecoration(
                            labelText: 'Email',

                            hintText: 'Enter your email',

                            prefixIcon: const Icon(
                              Icons.email_outlined,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Password Field
                        formLabel(
                          AppStrings.password,
                          isRequired: false,
                          textColor: Colors.white,
                        ),
                        SizedBox(height: 10),
                        TextFormField(
                          controller: _passwordController,
                          obscureText: !_isPasswordVisible,
                          style: const TextStyle(color: Colors.white),
                          decoration: AppTheme.inputDecoration(
                            labelText: 'Password',
                            hintText: 'Enter your password',
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.white,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _isPasswordVisible
                                    ? Icons.visibility_outlined
                                    : Icons.visibility_off_outlined,
                                color: Colors.white,
                              ),
                              onPressed: _togglePasswordVisibility,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your password';
                            }
                            if (value.length < 6) {
                              return 'Password must be at least 6 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Remember Me & Forgot Password
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Checkbox(
                                  value: _rememberMe,
                                  onChanged: (value) {
                                    setState(() {
                                      _rememberMe = value ?? false;
                                    });
                                  },
                                  activeColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  side: BorderSide(
                                    color: AppTheme.primaryColor,
                                    width: 2,
                                  ),
                                  // fillColor: WidgetStateProperty.resolveWith<
                                  //   Color
                                  // >((Set<WidgetState> states) {
                                  //   if (states.contains(WidgetState.selected)) {
                                  //     return AppTheme
                                  //         .primaryColor; // active color
                                  //   }
                                  //   return Colors
                                  //       .black; // 👈 inactive (unchecked) color
                                  // }),
                                ),
                                Text(
                                  'Remember me',
                                  style: AppTheme.bodySmall.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            TextButton(
                              onPressed: () {
                                // Handle forgot password
                              },
                              child: Text(
                                'Forgot Password?',
                                style: AppTheme.bodySmall.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Login Button
                        SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _login,
                            style: AppTheme.primaryButtonStyle,
                            child:
                                _isLoading
                                    ? const SizedBox(
                                      width: 24,
                                      height: 24,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                    : Text(
                                      'Sign In',
                                      style: AppTheme.buttonText,
                                    ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Register Option
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Don\'t have an account?',
                              style: AppTheme.bodyMedium.copyWith(
                                color: Colors.white,
                              ),
                            ),
                            TextButton(
                              onPressed: _navigateToRegister,
                              child: Text(
                                'Register',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.primaryColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        // Social auth buttons
                        const SocialAuthButtons(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
