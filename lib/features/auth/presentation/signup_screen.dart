import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:moinc/config/constants.dart';
import 'package:moinc/config/constants/strings.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/auth/network/api_endpoints.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:moinc/features/auth/domain/models/address_model.dart';
import 'package:moinc/features/auth/presentation/bloc/auth_event.dart';

import 'package:moinc/features/auth/presentation/bloc/auth_state.dart';
import 'package:moinc/features/auth/presentation/register_verification_screen.dart';
import 'package:moinc/features/auth/presentation/widgets/address_autocomplete.dart';
import 'package:moinc/features/auth/presentation/widgets/consent_checkbox.dart';
import 'package:moinc/features/auth/presentation/widgets/country_dropdown.dart';
import 'package:moinc/features/auth/presentation/widgets/phone_number_field.dart';
import 'package:moinc/features/auth/presentation/widgets/social_auth_buttons_register.dart';
import 'package:moinc/utils/custom_toast.dart';

import 'package:moinc/utils/form_label.dart';
import 'package:moinc/utils/validators.dart';
import 'package:moinc/widgets/password_text_field.dart';

class SignUpScreen extends StatefulWidget {
  final Map<String, dynamic>? additionalData;
  final Map<String, dynamic>? businessCardData;
  const SignUpScreen({super.key, this.additionalData, this.businessCardData});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _apartmentController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _addressController = TextEditingController();

  String? _selectedCountry;

  String _countryCode = '';
  String _phoneNumber = '';
  bool _isLoading = false;
  AddressModel? _selectedAddress;
  bool _isPoBox = false; // Add this line to track if user is entering a PO Box

  bool _dataConsentChecked = false;
  bool _marketingConsentChecked = false;
  String? _dataConsentError;
  String? _marketingConsentError;

  bool _hidePassowrdFields = false;
  String _signupHash = '';

  Map<String, dynamic> registrationData = {};

  @override
  void dispose() {
    _fullNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _apartmentController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    _zipCodeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  void _populateFormWithGoogleData() {
    if (widget.additionalData != null) {
      final data = widget.additionalData!;
      _fullNameController.text = data['fullName'] ?? '';
      _emailController.text = data['email'] ?? '';
      _hidePassowrdFields = true;
      _signupHash = data['signupHash'] ?? '';
    }
  }

  void _handlePhoneNumberChange(String dialCode, String number) {
    _countryCode = dialCode;
    _phoneNumber = number;
  }

  void _handleAddressSelected(AddressModel address) {
    setState(() {
      _selectedAddress = address;
      _addressController.text = address.street;
      _apartmentController.text = address.apartment;
      _cityController.text = address.city;
      _stateController.text = address.state;
      _zipCodeController.text = address.zipCode;

      final countriesList = countries.map((country) => country.name).toList();
      final matchingCountry = countriesList.firstWhere(
        (country) =>
            country == address.country ||
            country.contains(address.country) ||
            address.country.contains(country),
        orElse: () => countries.first.name,
      );
      _selectedCountry = matchingCountry;
      setState(() {});
    });
  }

  void _handleCountrySelected(String country) {
    setState(() {
      _selectedCountry = country;
    });
  }

  String generate4DigitPassword() {
    final random = Random();
    // ensures it's always 4 digits (1000–9999)
    int number = 1000 + random.nextInt(9000);
    return number.toString();
  }

  void _signUp() {
    setState(() {
      _dataConsentError = null;
      _marketingConsentError = null;
    });

    final isFormValid = _formKey.currentState?.validate() ?? false;

    if (!_dataConsentChecked) {
      setState(() {
        _dataConsentError = 'You must consent to data collection to continue';
      });
    }

    if (isFormValid && _dataConsentChecked) {
      if (_addressController.text.isEmpty) {
        CustomToast.showCustomeToast(
          'Please enter an address',
          AppTheme.errorColor,
        );

        return;
      }

      if (_selectedCountry == null) {
        CustomToast.showCustomeToast(
          'Please select a country',
          AppTheme.errorColor,
        );

        return;
      }

      final nameParts = _fullNameController.text.split(' ');
      final firstName = nameParts.first;
      final lastName =
          nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

      final password = generate4DigitPassword();
      // Prepare registration data for API
      registrationData = {
        'legal_name':
            _companyNameController.text.isNotEmpty
                ? _companyNameController.text
                : '${_fullNameController.text} Enterprise',
        'company_name':
            _companyNameController.text.isNotEmpty
                ? _companyNameController.text
                : '${_fullNameController.text} Enterprise',
        'email': _emailController.text,

        'password': _hidePassowrdFields ? password : _passwordController.text,
        'full_name': _fullNameController.text,
        'phone': _phoneNumber.isNotEmpty ? _countryCode + _phoneNumber : '',
        'address': _addressController.text,
        'address2': _apartmentController.text,
        'city': _cityController.text,
        'state': _stateController.text,
        'zip': _zipCodeController.text,
        'country': _selectedCountry ?? 'United States',
        'role_type': 'E', // Default role type for enterprise
        'agent_accountno': '', // Empty for direct registration
        'reseller_accountno': '', // Empty for direct registration
        'market_consent_policy': _marketingConsentChecked ? 1 : 0,
        'signup_hash': _signupHash,
      };

      context.read<AuthBloc>().add(
        SendVerifyRegisterCodeRequested(email: _emailController.text),
      );
      // Dispa
      //
      //tch the registration event
    }
  }

  @override
  void initState() {
    super.initState();

    // Populate form fields if business card data is available
    if (widget.businessCardData != null) {
      _populateFormWithBusinessCardData();
    }
    _populateFormWithGoogleData();
  }

  void _populateFormWithBusinessCardData() {
    final data = widget.businessCardData!;

    // Split the name into first and last name if available
    if (data['fullName'] != null) {
      _fullNameController.text = data['fullName'];
    }

    if (data['companyName'] != null) {
      _companyNameController.text = data['companyName'];
    }

    if (data['email'] != null) {
      _emailController.text = data['email'];
    }

    if (data['phoneNumber'] != null) {
      // The phone field requires special handling as it uses a custom widget
      _phoneNumber = data['phoneNumber'];
    }

    if (data['address'] != null) {
      _addressController.text = data['address'];
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width >= 600;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        // Update loading state based on AuthBloc state
        setState(() {
          _isLoading = state.status == AuthStatus.loading;
        });

        if (state.status == AuthStatus.googleUserDataReady &&
            state.additionalData != null) {
          // Fill form with Google user data
          setState(() {
            _fullNameController.text = state.additionalData!['fullName'] ?? '';
            _emailController.text = state.additionalData!['email'] ?? '';
            _hidePassowrdFields = true;
            _signupHash = state.additionalData!['signupHash'] ?? '';
            // Optional: Pre-fill other fields if available
            // For example, you could extract address components if Google provides them
          });
        } else if (state.status == AuthStatus.registerCodeSent) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => RegisterVerificationScreen(
                    email: _emailController.text,
                    registrationData: registrationData,
                  ),
            ),
          );
        } else if (state.status == AuthStatus.error) {
          CustomToast.showCustomeToast(
            state.errorMessage ?? 'An error occurred',
            AppTheme.errorColor,
          );
        }
        //<===============WORKING CODE WITHOUT VERIFICATION CODE===============>

        // if (state.status == AuthStatus.authenticated) {
        //   print('authenticated');
        //   // context.go(AppRoutes.home);
        // } else if (state.status == AuthStatus.apiAuthenticated) {
        //   // context.go(AppRoutes.home);
        //   print('authenticated');
        // } else if (state.status == AuthStatus.error) {
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(content: Text(state.errorMessage ?? 'An error occurred')),
        //   );
        // } else if (state.status == AuthStatus.googleUserDataReady &&
        //     state.additionalData != null) {
        //   // Fill form with Google user data
        //   setState(() {
        //     _fullNameController.text = state.additionalData!['fullName'] ?? '';
        //     _emailController.text = state.additionalData!['email'] ?? '';

        //     // Optional: Pre-fill other fields if available
        //     // For example, you could extract address components if Google provides them
        //   });

        //   // Show a snackbar to inform the user
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text(
        //         'Please complete your registration with additional details',
        //       ),
        //       duration: Duration(seconds: 3),
        //     ),
        //   );
        // } else if (state.status == AuthStatus.businessCardUserDataReady &&
        //     state.additionalData != null) {
        //   // Fill form with Google user data
        //   setState(() {
        //     _fullNameController.text = state.additionalData!['fullName'] ?? '';
        //     _emailController.text = state.additionalData!['email'] ?? '';
        //     _companyNameController.text =
        //         state.additionalData!['companyName'] ?? '';
        //     // Optional: Pre-fill other fields if available
        //     // For example, you could extract address components if Google provides them
        //   });

        //   // Show a snackbar to inform the user
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     const SnackBar(
        //       content: Text(
        //         'Please complete your registration with additional details',
        //       ),
        //       duration: Duration(seconds: 3),
        //     ),
        //   );
        // }

        // setState(() {
        //   _isLoading = state.status == AuthStatus.loading;
        // });

        //<===============WORKING CODE WITHOUT VERIFICATION CODE===============>
      },
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Create Account'),
          backgroundColor: AppTheme.secondaryColor,
          foregroundColor: AppTheme.primaryColor,
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Container(
                padding: EdgeInsets.symmetric(
                  vertical: isTablet ? 48 : 24,
                  horizontal: isTablet ? 48 : 0.0,
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
                        AppStrings.signUp,
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: Colors.white),
                      ),

                      // const SizedBox(height: 8),
                      // Text(
                      //   'Create an account to access our telecom services',
                      //   style: Theme.of(
                      //     context,
                      //   ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
                      // ),
                      const SocialAuthButtonsRegister(),
                      // Business Card Scan button
                      //   ScanWithBusinessCardSignup(),
                      const SizedBox(height: 22),
                      formLabel(
                        AppStrings.fullName,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _fullNameController,
                        decoration: InputDecoration(
                          hintText: AppStrings.fullName,
                          filled: true,
                          fillColor: AppTheme.secondaryColor,
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Full Name is required';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.companyName,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _companyNameController,
                        decoration: InputDecoration(
                          hintText: AppStrings.companyName,
                          filled: true,
                          fillColor: AppTheme.secondaryColor,
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.emailAddress,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: AppStrings.emailAddress,
                          filled: true,
                          fillColor: AppTheme.secondaryColor,
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                        // validator: Validators.validateEmail,
                        validator: Validators.validateEmail,
                      ),
                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.phoneNumber,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      PhoneNumberField(
                        onPhoneNumberChanged: _handlePhoneNumberChange,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a phone number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),
                      formLabel(
                        AppStrings.address,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Text(
                            _isPoBox ? 'PO Box' : 'Street Address',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white70,
                            ),
                          ),
                          Transform.scale(
                            scale:
                                0.8, // Increase/decrease this for custom size
                            child: Switch(
                              value: _isPoBox,
                              onChanged: (value) {
                                setState(() {
                                  _isPoBox = value;
                                });
                              },
                            ),
                          ),

                          // SizedBox(
                          //   height: 14,
                          //   child: Switch(
                          //     value: !_isPoBox,
                          //     activeColor: AppColors.appButtonColor,
                          //     onChanged: (value) {
                          //       setState(() {
                          //         _isPoBox = !value;
                          //         // Clear address fields when switching modes
                          //         if (_isPoBox) {
                          //           _addressController.clear();
                          //           _selectedAddress = null;
                          //         }
                          //       });
                          //     },
                          //   ),
                          // ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      _isPoBox
                          ? TextFormField(
                            controller: _addressController,
                            decoration: InputDecoration(
                              hintText: 'Enter PO Box number',
                              filled: true,
                              fillColor: AppTheme.secondaryColor,
                              hintStyle: TextStyle(color: Colors.white70),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 1,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            style: TextStyle(color: Colors.white),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'PO Box is required';
                              }
                              return null;
                            },
                          )
                          : AddressAutocomplete(
                            controller: _addressController,
                            onAddressSelected: _handleAddressSelected,
                            label: 'Address',
                            errorText: null,
                          ),
                      const SizedBox(height: 16),
                      formLabel(AppStrings.apartment, textColor: Colors.white),
                      SizedBox(height: 10),
                      TextFormField(
                        controller: _apartmentController,
                        decoration: InputDecoration(
                          hintText: AppStrings.apartment,
                          filled: true,
                          fillColor: AppTheme.secondaryColor,
                          hintStyle: TextStyle(color: Colors.white70),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: AppTheme.primaryColor,
                              width: 2,
                            ),
                          ),
                        ),
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.city,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _cityController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.city,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'City is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.state,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _stateController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.state,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'State/Province is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.zipCode,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        controller: _zipCodeController,
                        decoration: const InputDecoration(
                          hintText: AppStrings.zipCode,
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Zip/Postal Code is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),
                      formLabel(
                        AppStrings.country,
                        isRequired: true,
                        textColor: Colors.white,
                      ),
                      SizedBox(height: 10),
                      CountryDropdown(
                        onCountrySelected: _handleCountrySelected,
                        initialCountryCode: _selectedCountry,
                        validator: (value) {
                          if (value == null) {
                            return 'Country is required';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      // Text(
                      //   'Password ',
                      //   style: Theme.of(context).textTheme.titleMedium
                      //       ?.copyWith(fontWeight: FontWeight.bold),
                      // ),
                      if (!_hidePassowrdFields)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            formLabel(
                              AppStrings.password,
                              isRequired: true,
                              textColor: Colors.white,
                            ),
                            SizedBox(height: 10),
                            PasswordTextField(
                              svgPath: 'assets/icons/ic_password.svg',
                              label: AppStrings.password,
                              controller: _passwordController,
                              validator: Validators.validatePassword,
                            ),
                            const SizedBox(height: 16),
                            formLabel(
                              AppStrings.confirmPassword,
                              isRequired: true,
                              textColor: Colors.white,
                            ),
                            SizedBox(height: 10),
                            PasswordTextField(
                              svgPath: 'assets/icons/ic_password.svg',
                              label: 'Confirm Password',
                              controller: _confirmPasswordController,
                              validator:
                                  (value) => Validators.validateConfirmPassword(
                                    value,
                                    _passwordController.text,
                                  ),
                            ),
                          ],
                        ),
                      const SizedBox(height: 24),
                      ConsentCheckbox(
                        value: _dataConsentChecked,
                        onChanged: (value) {
                          setState(() {
                            _dataConsentChecked = value ?? false;
                            if (_dataConsentChecked) {
                              _dataConsentError = null;
                            }
                          });
                        },
                        text:
                            'I consent to Moinc collecting my personal data in accordance with the Privacy Policy and contacting me via phone or email. By submitting this form, you agree to our Privacy Policy.',
                        links: {'Privacy Policy': ApiEndpoints.privacyPolicy},
                        isRequired: true,
                        errorText: _dataConsentError,
                      ),
                      const SizedBox(height: 16),
                      ConsentCheckbox(
                        value: _marketingConsentChecked,
                        onChanged: (value) {
                          setState(() {
                            _marketingConsentChecked = value ?? false;
                          });
                        },
                        text:
                            'I agree to receive marketing communications from Moinc.',
                        isRequired: false,
                        errorText: _marketingConsentError,
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed:
                              _isLoading || (_dataConsentChecked == false)
                                  ? null
                                  : _signUp,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.black,
                            disabledBackgroundColor: Colors.grey.shade700,
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
                                      color: Colors.white,
                                    ),
                                  )
                                  : Text(
                                    AppStrings.signUp,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                    ),
                                  ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Align(
                        alignment: Alignment.center,
                        child: TextButton(
                          onPressed:
                              _isLoading
                                  ? null
                                  : () {
                                    context.push(AppConstants.loginRoute);
                                  },
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                AppStrings.alreadyHaveAccount,
                                style: TextStyle(color: Colors.white),
                              ),
                              SizedBox(width: 4),
                              Text(
                                AppStrings.signIn,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      // const SocialAuthButtons(),
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
