import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/ai%20agent/screens/custom_dialer_screen.dart';
import 'package:moinc/features/ai%20agent/widgets/control_bar.dart';
import 'package:moinc/features/auth/presentation/bloc/user_cubit.dart';
import 'package:moinc/services/telephony_service.dart';
// import 'package:moinc/services/call_service.dart'; // Commented out as it's not currently used
// import 'package:moinc/services/telephony_service.dart'; // Commented out as it's not currently used
import 'package:moinc/utils/custom_toast.dart';
import 'package:moinc/utils/validators.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/app_ctrl.dart' as app_ctrl;
import '../widgets/button.dart';

class AudioCallScreen extends StatefulWidget {
  const AudioCallScreen({super.key});

  @override
  State<AudioCallScreen> createState() => _AudioCallScreenState();
}

class _AudioCallScreenState extends State<AudioCallScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool isCallActive = false;
  bool isMuted = false;
  bool isOnHold = false;
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _animation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(_animationController);
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _animationController.dispose();

    // Restore system UI when screen is disposed
    app_ctrl.SystemUIVisibility.showSystemUI();

    super.dispose();
  }

  void _showCallMeDialog(BuildContext context) {
    // Get the AppCtrl instance from the current context
    final appCtrl = context.read<app_ctrl.AppCtrl>();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Important for keyboard handling
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        // Calculate bottom padding to avoid keyboard overlap
        final bottomPadding = MediaQuery.of(context).viewInsets.bottom;
        // Get the navigation bar height to avoid buttons being hidden
        final bottomNavHeight = MediaQuery.of(context).padding.bottom;

        return _CallMeBottomSheet(
          bottomPadding: bottomPadding,
          bottomNavHeight: bottomNavHeight,
          nameController: _nameController,
          emailController: _emailController,
          phoneController: _phoneController,
          appCtrl: appCtrl, // Pass the AppCtrl instance to the bottom sheet
        );
      },
    );
  }

  // void _dialIn() {
  //   // Navigate to the custom dialer screen
  //   Navigator.push(
  //     context,
  //     MaterialPageRoute(builder: (context) => const CustomDialerScreen()),
  //   );
  // }

  void _dialIn() async {
    // Replace with your actual phone number
    final appCtrl = context.read<app_ctrl.AppCtrl>();
    final phoneNumber = appCtrl.publicAgentModel?.sipNumber ?? '';
    final Uri uri = Uri(scheme: 'tel', path: phoneNumber);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not launch dialer')),
        );
      }
    }
  }

  void _toggleCall() {
    final appCtrl = context.read<app_ctrl.AppCtrl>();

    // Get current connection state to determine action
    final currentState = appCtrl.connectionState;

    if (currentState == app_ctrl.ConnectionState.connected ||
        currentState == app_ctrl.ConnectionState.connecting) {
      // If connected or connecting, disconnect
      appCtrl.disconnect();
    } else {
      // If disconnected, connect
      appCtrl.connect();
    }

    // DO NOT toggle isCallActive here - let it be updated by listening to connectionState
    // The UI will update automatically via the BlocBuilder/Selector watching connectionState
  }

  // Update UI when connection state changes
  void _updateUIBasedOnConnectionState(
    app_ctrl.ConnectionState connectionState,
  ) {
    // Sync isCallActive with actual connection state
    final shouldBeActive =
        connectionState == app_ctrl.ConnectionState.connected ||
        connectionState == app_ctrl.ConnectionState.connecting;

    if (shouldBeActive != isCallActive) {
      setState(() {
        isCallActive = shouldBeActive;
      });

      // Update animation speed based on call state
      if (shouldBeActive) {
        _animationController.duration = const Duration(milliseconds: 800);
        _animationController.repeat(reverse: true);
      } else {
        _animationController.duration = const Duration(seconds: 2);
        _animationController.repeat(reverse: true);
      }
    }
  }

  // Build a shiny glassmorphic button with icon and label
  Widget _buildGlassmorphicButton({
    required Widget icon,
    required String label,
    required VoidCallback onPressed,
    required bool isDisabled,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(30),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                AppTheme.primaryColor,
                AppTheme.primaryColor.withValues(alpha: 0.8),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppTheme.lightTextColor),
            boxShadow: [
              BoxShadow(
                color: AppTheme.secondaryColor.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: isDisabled ? null : onPressed,
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 12,
                  horizontal: 24,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    icon,
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white),
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Stack(
            children: [
              // Main content
              Center(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,

                  children: [
                    BlocBuilder<UserCubit, UserState>(
                      builder: (context, state) {
                        return Text(
                          'Hello, ${state.name}!',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textColor,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        );
                      },
                    ),
                    const Text(
                      'How can I help you today?',
                      style: TextStyle(fontSize: 18, color: AppTheme.textColor),
                    ),
                    const SizedBox(height: 40),
                    // Audio Visualizer - Enhanced Design
                    Builder(
                      builder: (context) {
                        final connectionState =
                            context.watch<app_ctrl.AppCtrl>().connectionState;
                        final isActive =
                            connectionState ==
                                app_ctrl.ConnectionState.connected ||
                            connectionState ==
                                app_ctrl.ConnectionState.connecting;

                        return AnimatedBuilder(
                          animation: _animationController,
                          builder: (context, child) {
                            return Container(
                              height: 200,
                              width: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    AppTheme.primaryColor.withValues(
                                      alpha: 0.3,
                                    ),
                                    AppTheme.primaryColor.withValues(
                                      alpha: 0.1,
                                    ),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 0.5, 1.0],
                                ),
                              ),
                              child: Center(
                                child: Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    // Outer glow ring
                                    Container(
                                      height: 180,
                                      width: 180,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        gradient: LinearGradient(
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                          colors: [
                                            AppTheme.primaryColor.withValues(
                                              alpha: 0.6,
                                            ),
                                            const Color.fromARGB(
                                              255,
                                              62,
                                              166,
                                              214,
                                            ).withValues(alpha: 0.8),
                                          ],
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppTheme.primaryColor
                                                .withValues(alpha: 0.4),
                                            blurRadius: 20,
                                            spreadRadius: 5,
                                          ),
                                        ],
                                      ),
                                    ),
                                    // Animated pulse rings (when active)
                                    if (isActive)
                                      ...List.generate(3, (index) {
                                        return AnimatedOpacity(
                                          opacity: isActive ? 1.0 : 0.0,
                                          duration: const Duration(
                                            milliseconds: 500,
                                          ),
                                          child: Container(
                                            width:
                                                140 +
                                                (index * 25 * _animation.value),
                                            height:
                                                140 +
                                                (index * 25 * _animation.value),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              border: Border.all(
                                                color: Colors.white.withValues(
                                                  alpha: 0.3 - (index * 0.08),
                                                ),
                                                width: 2,
                                              ),
                                            ),
                                          ),
                                        );
                                      }),
                                    // Inner circle with mic icon
                                    Container(
                                      height: 140,
                                      width: 140,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: const Color.fromARGB(
                                          255,
                                          62,
                                          166,
                                          214,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withValues(
                                              alpha: 0.2,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Icon(
                                        isActive ? Icons.mic : Icons.mic_none,
                                        size: 70,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(height: 40),
                    // Talk Now / Cancel Button
                    Builder(
                      builder: (context) {
                        // Listen for connection state changes
                        final connectionState =
                            context.watch<app_ctrl.AppCtrl>().connectionState;

                        // Update UI based on connection state
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          _updateUIBasedOnConnectionState(connectionState);
                        });

                        return ConstrainedBox(
                          constraints: const BoxConstraints(minWidth: 250),
                          child: Button(
                            isDisabled:
                                context
                                    .watch<app_ctrl.AppCtrl>()
                                    .isDiabledAgentControl,
                            text:
                                connectionState ==
                                        app_ctrl.ConnectionState.connecting
                                    ? 'Connecting'
                                    : connectionState ==
                                        app_ctrl.ConnectionState.connected
                                    ? 'Disconnect'
                                    : 'Talk Now',
                            onPressed: _toggleCall,
                            color:
                                connectionState ==
                                            app_ctrl
                                                .ConnectionState
                                                .connecting ||
                                        connectionState ==
                                            app_ctrl.ConnectionState.connected
                                    ? Colors.red
                                    : const Color.fromARGB(255, 55, 212, 144),
                            isProgressing:
                                connectionState ==
                                app_ctrl.ConnectionState.connecting,
                          ),
                        );
                      },
                    ),
                    const Spacer(),

                    // Glassmorphic Dial In and Call Me buttons

                    //========> This working code is commented due to clinet demand <=========

                    // context.read<app_ctrl.AppCtrl>().publicAgentModel != null
                    //     ? context
                    //                 .read<app_ctrl.AppCtrl>()
                    //                 .publicAgentModel!
                    //                 .userFormEnabled !=
                    //             "No"
                    //         ? SingleChildScrollView(
                    //           child: Visibility(
                    //             child: Padding(
                    //               padding: const EdgeInsets.symmetric(
                    //                 horizontal: 24.0,
                    //               ),
                    //               child:
                    //                   isCallActive
                    //                       ? const ControlBar()
                    //                       : Row(
                    //                         children: [
                    //                           Expanded(
                    //                             child: _buildGlassmorphicButton(
                    //                               isDisabled:
                    //                                   context
                    //                                       .watch<
                    //                                         app_ctrl.AppCtrl
                    //                                       >()
                    //                                       .isDiabledAgentControl,
                    //                               icon: const Icon(
                    //                                 Icons.dialpad_rounded,
                    //                                 color: Colors.white,
                    //                                 size: 20,
                    //                               ),
                    //                               label: 'Dial In',
                    //                               onPressed: _dialIn,
                    //                             ),
                    //                           ),
                    //                           const SizedBox(width: 16),
                    //                           Expanded(
                    //                             child: _buildGlassmorphicButton(
                    //                               isDisabled:
                    //                                   context
                    //                                       .watch<
                    //                                         app_ctrl.AppCtrl
                    //                                       >()
                    //                                       .isDiabledAgentControl,
                    //                               icon: const Icon(
                    //                                 Icons.call,
                    //                                 color: Colors.white,
                    //                                 size: 20,
                    //                               ),
                    //                               label: 'Call Me',
                    //                               onPressed:
                    //                                   () => _showCallMeDialog(
                    //                                     context,
                    //                                   ),
                    //                             ),
                    //                           ),
                    //                         ],
                    //                       ),
                    //             ),
                    //           ),
                    //         )
                    //         : const SizedBox.shrink()
                    //     : const SizedBox.shrink(),

                    //========> This working code is commented due to clinet demand <=========
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // Countdown timer in yellow circle (top-right corner)
              Positioned(
                top: 10,
                right: 10,
                child: Selector<app_ctrl.AppCtrl, int>(
                  selector: (_, appCtrl) => appCtrl.remainingDisabledTime,
                  builder: (_, remainingTime, __) {
                    // Only show when there's remaining time
                    if (remainingTime <= 0) {
                      return const SizedBox.shrink();
                    }

                    return Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(color: Colors.amber, width: 2.0),
                      ),
                      child: Center(
                        child: Text(
                          '$remainingTime',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Separate StatefulWidget for the bottom sheet to manage its own loading state
class _CallMeBottomSheet extends StatefulWidget {
  final double bottomPadding;
  final double bottomNavHeight;
  final TextEditingController nameController;
  final TextEditingController emailController;
  final TextEditingController phoneController;
  final app_ctrl.AppCtrl appCtrl; // Add AppCtrl instance

  const _CallMeBottomSheet({
    required this.bottomPadding,
    required this.bottomNavHeight,
    required this.nameController,
    required this.emailController,
    required this.phoneController,
    required this.appCtrl, // Required parameter
  });

  @override
  State<_CallMeBottomSheet> createState() => _CallMeBottomSheetState();
}

class _CallMeBottomSheetState extends State<_CallMeBottomSheet> {
  bool isLoading = false;
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: widget.bottomPadding),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, 24 + widget.bottomNavHeight),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Form content
              AbsorbPointer(
                absorbing: isLoading,
                child: SingleChildScrollView(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // User icon logo at the top
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppTheme.primaryColor,
                            boxShadow: [
                              BoxShadow(
                                color: AppTheme.primaryColor.withValues(
                                  alpha: 0.3,
                                ),
                                blurRadius: 10,
                                spreadRadius: 2,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.person,
                            size: 45,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 24),
                        const Text(
                          'Enter your information',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: widget.nameController,
                          keyboardType: TextInputType.name,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          validator: Validators.validateName,
                          decoration: InputDecoration(
                            hintText: 'Full Name',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.person,
                              color: HexColor("#0033A0"),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 198, 196, 232),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: widget.emailController,
                          keyboardType: TextInputType.emailAddress,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          validator: Validators.validateEmail,
                          decoration: InputDecoration(
                            hintText: 'Email Address',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.email,
                              color: HexColor("#0033A0"),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 198, 196, 232),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: widget.phoneController,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                            color: Colors.black87,
                            fontSize: 16,
                          ),
                          validator: Validators.validatePhone,
                          decoration: InputDecoration(
                            hintText: 'Please add US number only',
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            prefixIcon: Icon(
                              Icons.phone,
                              color: HexColor("#0033A0"),
                            ),
                            filled: true,
                            fillColor: Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Color.fromARGB(255, 198, 196, 232),
                                width: 2,
                              ),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 1,
                              ),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: const BorderSide(
                                color: Colors.red,
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed:
                                    isLoading
                                        ? null
                                        : () => Navigator.pop(context),
                                style: TextButton.styleFrom(
                                  foregroundColor: Colors.grey.shade700,
                                ),
                                child: const Text('Cancel'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: SizedBox(
                                height: 40,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 4,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 3,
                                  ),
                                  onPressed: isLoading ? null : _submitForm,
                                  child: const Text(
                                    'Submit',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
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

              // Loading indicator overlay - only shows within the form area
              if (isLoading)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.transparent,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          SizedBox(
                            width: 40,
                            height: 40,
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                AppTheme.primaryColor,
                              ),
                              strokeWidth: 3,
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Processing...',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
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

  Future<void> _submitForm() async {
    // Validate form before submitting
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Show loading state
    setState(() {
      isLoading = true;
    });

    try {
      // Make the API call
      final telephonyService = TelephonyService();
      final result = await telephonyService.initiateCall(
        widget.phoneController.text,
        name: widget.nameController.text,
        email: widget.emailController.text,
        agentId: widget.appCtrl.publicAgentModel?.agentId,
        roomName: widget.appCtrl.publicAgentModel?.livekitRoom,
        agentModel: widget.appCtrl.publicAgentModel,
      );

      // await Future.delayed(const Duration(seconds: 3), () {});
      print(result);
      // Hide loading state and close the dialog
      if (result['success']) {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        }

        // Handle the result as success
        if (context.mounted) {
          // Use the passed AppCtrl instance instead of trying to read from context
          widget.appCtrl.disableAgentControlFor30Seconds();

          // Show success message
          CustomToast.showCustomeToast(
            'Please wait, your agent will be available in 30 seconds',
            AppTheme.primaryColor,
          );

          // Commented out navigation to custom dialer screen
          // Will be used in the future
          /*
        Navigator.push(
          context,
          MaterialPageRoute(
            builder:
                (context) => CustomDialerScreen(
                  initialPhoneNumber:
                      widget.phoneController.text,
                  isRinging: true,
                ),
          ),
        );
        */
        }
      } else {
        if (mounted) {
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        }
        if (context.mounted) {
          // CustomToast.showCustomeToast(
          //   'Error: ${result['message']}',
          //   AppTheme.errorColor,
          // );

          widget.appCtrl.disableAgentControlFor30Seconds();

          // Show success message
          CustomToast.showCustomeToast(
            'Please wait, your agent will be available in 30 seconds',
            AppTheme.primaryColor,
          );
        }
      }
    } catch (e) {
      // Handle any exceptions
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        Navigator.pop(context);

        if (context.mounted) {
          CustomToast.showCustomeToast('Error: $e', AppTheme.errorColor);
        }
      }
    }
  }
}
