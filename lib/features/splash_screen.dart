import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/constants/shared_prefence_keys.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;
  bool _animationComplete = false;
  bool _timeoutReached = false;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startAnimationAndCheckAuth();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeInOut),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
  }

  void _startAnimationAndCheckAuth() {
    // Start animation
    _animationController.forward().then((_) {
      if (mounted) {
        setState(() {
          _animationComplete = true;
        });

        // Trigger auth check
        context.read<AuthBloc>().add(const AuthCheckRequested());

        // Set a timeout to prevent getting stuck on splash screen
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) {
            setState(() {
              _timeoutReached = true;
            });
            _proceedWithNavigation(context, context.read<AuthBloc>().state);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _proceedWithNavigation(
    BuildContext context,
    AuthState state,
  ) async {
    if (!_animationComplete) return;

    // Check if user is authenticated
    final token = await _checkTokenExists();
    final isAuthenticated = state.isAuthenticated || token;

    if (mounted) {
      if (isAuthenticated) {
        // User is authenticated, navigate to dashboard
        Navigator.pushReplacementNamed(context, AppConstants.dashboardRoute);
      } else {
        // User is not authenticated, navigate to login
        Navigator.pushReplacementNamed(context, AppConstants.loginRoute);
      }
    }
  }

  Future<bool> _checkTokenExists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('client_tkn__');
      final accountNo = prefs.getString(SharedPreferenceKeys.accountNoKey);
      return token != null && token.isNotEmpty ||
          accountNo != null && accountNo.isNotEmpty && accountNo != 'null';
    } catch (e) {
      print("Error checking token: $e");
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) {
        // Only proceed when animation is complete and auth state has changed
        return _animationComplete &&
            !_timeoutReached &&
            (previous.isAuthenticated != current.isAuthenticated ||
                previous.status != current.status);
      },
      listener: (context, state) {
        _proceedWithNavigation(context, state);
      },
      child: Scaffold(
        backgroundColor: AppTheme.secondaryColor,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppTheme.secondaryColor,
                Color(0xFF00142A), // Darker shade of navy blue
              ],
            ),
          ),
          child: SafeArea(
            child: Center(
              child: AnimatedBuilder(
                animation: _animationController,
                builder: (context, child) {
                  return FadeTransition(
                    opacity: _fadeAnimation,
                    child: ScaleTransition(
                      scale: _scaleAnimation,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Logo
                          Center(
                            child: SizedBox(
                              width: 180,
                              height: 180,
                              child: Image.asset(
                                'assets/images/logo1.png',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          // App name
                          Text(
                            AppConstants.appName,
                            style: AppTheme.headingLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Tagline
                          Text(
                            'Your Personal AI Assistant',
                            style: AppTheme.bodyLarge.copyWith(
                              color: Colors.white.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 60),
                          // Loading indicator
                          const SpinKitThreeBounce(
                            color: Colors.white,
                            size: 30.0,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}
