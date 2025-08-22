import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile_frontend_argvision/services/accounts_services.dart';
import 'package:mobile_frontend_argvision/services/storage_service.dart';
import 'package:country_picker/country_picker.dart';

class LoginPage extends StatefulWidget {
  final Function(int) onLoginSuccess;

  const LoginPage({super.key, required this.onLoginSuccess});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> with TickerProviderStateMixin {
  // Animation controllers
  late AnimationController _controller;
  late AnimationController _signUpController;

  // Logo / background animations
  late Animation<double> _oBounceScale;
  late Animation<Offset> _oCenterToLeft;
  late Animation<Offset> _restSlideOffset;
  late Animation<Offset> _logoBounceUp;
  late Animation<double> _titleOpacity;
  late Animation<double> _formOpacity;
  late Animation<double> _formOffset;
  late Animation<double> _bgImageOpacity;
  late Animation<double> _bgImageScale;

  // Sign‑up flow animations
  late Animation<Offset> _loginSlideOut;
  late Animation<double> _signUpFormOpacity;
  late Animation<Offset> _signUpFormSlideIn;

  // Page controller for sign‑up wizard
  late PageController _signUpPageController;

  // Sign‑up wizard state
  bool _showSignUp = false;
  int _signUpStep = 0;
  bool _phoneNumberTouched = false;
  bool _rememberMe = false;
  bool _iRememberYou = false;
  bool _youDidNotFinish = false;

  // Form fields
  String _email = '';
  String _password = '';
  String _lemail = '';
  String _lpassword = '';
  String _firstName = '';
  String _lastName = '';
  String _location = '';
  String _username = '';
  String _phoneNumber = '';
  String _confirmPassword = '';
  String _code = '';
  String? _selectedGender;
  String? _selectedRole;
  DateTime? _selectedDate;
  String _bio = '';

  Country? _selectedCountry; // selected country from country picker
  String _address = '';

  bool _youForgotMe = false;
  String _verificationCode = '';

  File? _selectedImage; // mobile
  html.File? _webSelectedImage; // web

  Future<void> _pickImage() async {
    if (kIsWeb) {
      final input = html.FileUploadInputElement()..accept = 'image/*';
      input.click();

      input.onChange.listen((e) {
        if (input.files!.isNotEmpty) {
          setState(() {
            _webSelectedImage = input.files!.first;
          });
        }
      });
    } else {
      final pickedFile = await ImagePicker().pickImage(
        source: ImageSource.gallery,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    }
  }

  // ────────────────────────────────────────────────────────────
  // Validation helpers
  bool _isValidName(String name) => RegExp(r"^[A-Za-z\s]{2,}$").hasMatch(name);

  bool _isOldEnough(DateTime? birthDate) {
    if (birthDate == null) return false;
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age > 13;
  }

  bool _isLocationValid() => _location.trim().length >= 2;

  bool _isEmailValid() =>
      RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email.trim());

  bool _isPasswordValid() => _password.length >= 8;

  bool _passwordsMatch() => _password == _confirmPassword;

  // ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

    _loadRememberMe();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _signUpController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _signUpPageController = PageController();

    // Entrance animations
    _oBounceScale = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.3, curve: Curves.elasticInOut),
      ),
    );
    _oCenterToLeft = Tween<Offset>(
      begin: const Offset(120, -3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.2, 0.4, curve: Curves.bounceOut),
      ),
    );
    _restSlideOffset = Tween<Offset>(
      begin: const Offset(2, 0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.4, 0.6, curve: Curves.easeInOut),
      ),
    );
    _logoBounceUp = Tween<Offset>(
      begin: const Offset(0, 150),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 0.9, curve: Curves.elasticOut),
      ),
    );
    _titleOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.6, curve: Curves.easeIn),
      ),
    );
    _formOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.5, 0.8, curve: Curves.easeIn),
      ),
    );
    _formOffset = Tween<double>(begin: 30, end: 0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.6, 1.0, curve: Curves.easeOut),
      ),
    );
    _bgImageOpacity = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.7, curve: Curves.easeIn),
      ),
    );
    _bgImageScale = Tween<double>(begin: 1.3, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.3, 0.9, curve: Curves.easeOut),
      ),
    );

    // Sign‑up overlay animations
    _loginSlideOut = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0.0),
    ).animate(
      CurvedAnimation(parent: _signUpController, curve: Curves.easeInOut),
    );
    _signUpFormOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _signUpController,
        curve: const Interval(0.3, 1.0, curve: Curves.easeIn),
      ),
    );
    _signUpFormSlideIn = Tween<Offset>(
      begin: const Offset(1.5, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _signUpController, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    _signUpController.dispose();
    _signUpPageController.dispose();
      _resendTimer?.cancel();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // Navigation helpers

  Future<void> _loadRememberMe() async {
    final String? rememberMe = await StorageService.read('rememberMe');
    setState(() {
      _iRememberYou = rememberMe == 'true';
    });
  }

  Future<void> _login() async {
    if (_lemail.isEmpty || _lpassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please insert both username/phone/email and password to login.',
          ),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final Map<String, dynamic> userData = {
      "email": _lemail,
      "password": _lpassword,
    };

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await AccountsServices.login(userData);

    // Close loading
    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);

      await StorageService.write('rememberMe', _rememberMe.toString());
      // Extract tokens & user info
      final String accessToken = decoded['access'];
      final String refreshToken = decoded['refresh'];
      final Map<String, dynamic> user = decoded['user'];

      // Save securely using StorageService
      await StorageService.write('access_token', accessToken);
      await StorageService.write('refresh_token', refreshToken);
      await StorageService.write('user_data', jsonEncode(user));

      final String? userDataJson = await StorageService.read('user_data');
      final Map<String, dynamic> userData = jsonDecode(userDataJson!);
      final String firstName = userData['first_name'] ?? '';
      final String lastName = userData['last_name'] ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome to OnlySport $firstName $lastName!'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      widget.onLoginSuccess(0);
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage = decoded.values
            .map((value) => value.toString())
            .join('\n')
            .replaceAll(RegExp(r'[\[\]]'), '');
      } catch (_) {
        bodyMessage = response.body;
      }


      if (bodyMessage == "Account is ready but needs verification.") {
        setState(() {
        _email = _lemail;
        _password = _lpassword;
        _youDidNotFinish = true;
        });
        print(_youDidNotFinish);
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showSignUpForm() {
    setState(() => _showSignUp = true);
    _signUpController.forward();
  }

  void _hideSignUpForm() {
    _signUpController.reverse().then((_) {
      setState(() {
        _showSignUp = false;
        _signUpStep = 0;
        _email = '';
        _password = '';
        _firstName = '';
        _lastName = '';
        _location = '';
        _username = '';
        _confirmPassword = '';
        _code = '';
        _selectedGender = null;
        _selectedRole = null;
        _selectedDate = null;
      });
    });
  }

  void _goToNextSignUpStep() {
    setState(() => _signUpStep++);
    _signUpPageController.nextPage(
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void _goToPreviousSignUpStep() {
    if (_signUpStep == 0) {
      _hideSignUpForm();
    } else {
      setState(() => _signUpStep--);
      _signUpPageController.previousPage(
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _pickDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() => _selectedDate = picked);
    }
  }

  // ────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF03558F), Color.fromARGB(255, 45, 148, 237)],
            begin: Alignment.bottomLeft,
            end: Alignment.topRight,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _controller,
              builder:
                  (context, child) => Opacity(
                    opacity: _bgImageOpacity.value,
                    child: Transform.scale(
                      scale: _bgImageScale.value,
                      child: Container(
                        decoration: const BoxDecoration(
                          image: DecorationImage(
                            image: AssetImage('assets/images/banner.webp'),
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ),
            ),
            Container(color: Colors.black.withOpacity(0.3)),
            SafeArea(
              child: Center(
                child: Stack(
                  children: [
                    // ─── Login content (slides out) ─────────────
                    AnimatedBuilder(
                      animation: _signUpController,
                      builder: (context, child) {
                        return SlideTransition(
                          position: _loginSlideOut,
                          child: Opacity(
                            opacity:
                                _showSignUp ? 1 - _signUpFormOpacity.value : 1,
                            child: AnimatedBuilder(
                              animation: _controller,
                              builder:
                                  (context, child) => Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      // Logo & title
                                      Opacity(
                                        opacity: _titleOpacity.value,
                                        child: Transform.translate(
                                          offset: _logoBounceUp.value,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Transform.translate(
                                                offset: _oCenterToLeft.value,
                                                child: Transform.scale(
                                                  scale: _oBounceScale.value,
                                                  child: const Text(
                                                    'O',
                                                    style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 60,
                                                      fontWeight:
                                                          FontWeight.bold,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SlideTransition(
                                                position: _restSlideOffset,
                                                child: const Text(
                                                  'nlySport',
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 60,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 40),
                                      // Login form
                                      Opacity(
                                        opacity: _formOpacity.value,
                                        child: Transform.translate(
                                          offset: Offset(0, _formOffset.value),
                                          child: _buildLoginForm(),
                                        ),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                        );
                      },
                    ),
                    // ─── Sign‑up wizard overlay ────────────────
                    if (_showSignUp)
                      AnimatedBuilder(
                        animation: _signUpController,
                        builder: (context, child) {
                          return SlideTransition(
                            position: _signUpFormSlideIn,
                            child: Opacity(
                              opacity: _signUpFormOpacity.value,
                              child: PageView(
                                controller: _signUpPageController,
                                physics: const NeverScrollableScrollPhysics(),
                                children: [
                                  _buildNameStep(),
                                  _buildGenderStep(),
                                  _buildRoleStep(),
                                  _buildAgeLocationStep(),
                                  _buildImageStep(),
                                  _buildBioStep(),
                                  _buildCredentialsStep(),
                                  _buildVerificationStep(),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<Map<String, String>> getUserData() async {
    final String? userDataJson = await StorageService.read('user_data');
    if (userDataJson == null) {
      return {'firstName': '', 'lastName': ''};
    }
    final Map<String, dynamic> userData = jsonDecode(userDataJson);
    final String firstName = userData['first_name'] ?? '';
    final String lastName = userData['last_name'] ?? '';
    return {'firstName': firstName, 'lastName': lastName};
  }

  // ────────────────────────────────────────────────────────────
  // UI BUILDERS
  Widget _buildLoginForm() {
    if (_iRememberYou) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: _formDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FutureBuilder<Map<String, String>>(
              future: getUserData(),
              builder: (
                BuildContext context,
                AsyncSnapshot<Map<String, String>> snapshot,
              ) {
                String welcomeText = 'Welcome Back!';
                if (snapshot.connectionState == ConnectionState.waiting) {
                  welcomeText = 'Welcome Back!';
                } else if (snapshot.hasError) {
                  welcomeText = 'Welcome Back! (Error)';
                } else {
                  final firstName = snapshot.data?['firstName'] ?? '';
                  welcomeText = 'Welcome Back \n$firstName!';
                }
                return Center(
                  child: Text(
                    welcomeText,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                    textAlign: TextAlign.center,
                  ),
                );
              },
            ),
            const SizedBox(height: 20),
            const Text(
              'We\'re logging you in automatically',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 40),
            _gradientButton('CONTINUE', _refresh),
            const SizedBox(height: 20),
            TextButton(
              onPressed: () {
                setState(() {
                  _rememberMe = false;
                  _iRememberYou = false;
                  StorageService.delete('rememberMe');
                  StorageService.delete('access_token');
                  StorageService.delete('refresh_token');
                  StorageService.delete('user_data');
                });
              },
              child: const Text(
                'Sign in as different user',
                style: TextStyle(color: Colors.blue),
              ),
            ),
          ],
        ),
      );
    }


    if (_youDidNotFinish){
      return Container(
      padding: const EdgeInsets.all(24),
      decoration: _formDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Verify Your Email",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "We've sent a verification code to your email address. Please enter it below. Do not forget to check your spam folder!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // Code input
          Row(
            children: [
              Expanded(
                child: _styledTextField(
                  'Enter 6-digit code',
                  Icons.verified,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _code = val),
                  value: _code,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Resend button with timer
          TextButton(
            onPressed: (_resendSeconds == 0) ? _refreshVerify : null,
            child: (_resendSeconds == 0)
                ? const Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(color: Colors.blue),
                  )
                : Text(
                    "Resend code in $_resendSeconds s",
                    style: const TextStyle(color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _gradientButton(
                  'FINISH',
                  (_code.isNotEmpty)
                      ? () async {
                          bool success = await _verifyRegistration();
                          if (success) {
                            _rLogin();
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
    }
      

    if (_youForgotMe) {
      return Container(
        padding: const EdgeInsets.all(24),
        margin: const EdgeInsets.symmetric(horizontal: 24),
        decoration: _formDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Email + Send Code button in one row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _styledTextField(
                    'Email',
                    Icons.email,
                    onChanged: (val) => setState(() => _lemail = val),
                    value: _lemail,
                  ),
                ),
                const SizedBox(width: 10),
              ],
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _styledTextField(
                    'Verification Code',
                    Icons.verified_user,
                    onChanged: (val) => setState(() => _verificationCode = val),
                    value: _verificationCode,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 1,
                  child: ElevatedButton(
                    onPressed: _sendCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Send Code',
                      style: TextStyle(
                        color: Colors.white,
                      ), // button text white
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _styledTextField(
                    "Password",
                    Icons.lock,
                    obscure: true,
                    onChanged: (val) => setState(() => _password = val),
                    value: _password,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'Minimum 8 characters',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _styledTextField(
                "Confirm Password",
                Icons.lock_outline,
                obscure: true,
                onChanged: (val) => setState(() => _confirmPassword = val),
                value: _confirmPassword,
              ),
              if (_password.isNotEmpty &&
                  _confirmPassword.isNotEmpty &&
                  !_passwordsMatch())
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

            const SizedBox(height: 30),

            // Bottom buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () {
                    setState(() {
                      _youForgotMe = false;
                      _password = '';
                      _confirmPassword = '';
                      _lemail = '';
                      _verificationCode = '';
                    });
                  },
                  child: const Text(
                    'Back',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
                _gradientButton(
                  'Reset Password',
                  (_confirmPassword.isNotEmpty &&
                          _password.isNotEmpty &&
                          _lemail.isNotEmpty &&
                          _verificationCode.isNotEmpty &&
                          _isPasswordValid() &&
                          _passwordsMatch())
                      ? _resetPassword
                      : null,
                ),
              ],
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: _formDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _styledTextField(
            'Username/Email/Phone',
            Icons.email,
            onChanged: (val) => setState(() => _lemail = val),
            value: _lemail,
          ),
          const SizedBox(height: 20),
          _styledTextField(
            'Password',
            Icons.lock,
            obscure: true,
            onChanged: (val) => setState(() => _lpassword = val),
            value: _lpassword,
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Checkbox(
                    value: _rememberMe,
                    onChanged: (value) {
                      setState(() {
                        _rememberMe = value!;
                      });
                    },
                  ),
                  const Text('Remember Me'),
                ],
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _youForgotMe = true;
                  });
                },
                child: const Text(
                  'Forgot \nPassword?',
                  style: TextStyle(color: Colors.blue),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 2,
                ),
              ),
            ],
          ),

          const SizedBox(height: 15),
          _gradientButton('LOGIN', _login),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("Don't have an account?"),
              TextButton(
                onPressed: _showSignUpForm,
                child: const Text(
                  'Sign Up',
                  style: TextStyle(color: Colors.blue),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Step 1 : Name ───────────────────────────────────────────
  Widget _buildNameStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 185),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Let's Create Your Account!",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              // First Name
              _styledTextField(
                'First Name',
                Icons.person,
                onChanged: (val) => setState(() => _firstName = val),
                value: _firstName,
              ),
              const SizedBox(height: 12),

              // Last Name
              _styledTextField(
                'Last Name',
                Icons.person_outline,
                onChanged: (val) => setState(() => _lastName = val),
                value: _lastName,
              ),

              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _gradientButton(
                      'BACK',
                      _goToPreviousSignUpStep,
                      isGrey: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _gradientButton(
                      'CONTINUE',
                      (_firstName.isNotEmpty &&
                              _lastName.isNotEmpty &&
                              _isValidName(_firstName) &&
                              _isValidName(_lastName))
                          ? _goToNextSignUpStep
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 2 : Gender ─────────────────────────────────────────
  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 185),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "What is your Gender?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _genderOption(Icons.male, "Male", Colors.blue),
                  _genderOption(Icons.female, "Female", Colors.pink),
                  _genderOption(Icons.transgender, "Others", Colors.grey),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _gradientButton(
                      'BACK',
                      _goToPreviousSignUpStep,
                      isGrey: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _gradientButton(
                      'CONTINUE',
                      _selectedGender != null ? _goToNextSignUpStep : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 3 : Role ───────────────────────────────────────────
  Widget _buildRoleStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 185),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Who are you?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _roleOption(Icons.sports_soccer, "Player"),
                  _roleOption(Icons.school, "Coach"),
                  _roleOption(Icons.stadium, "Owner"),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _gradientButton(
                      'BACK',
                      _goToPreviousSignUpStep,
                      isGrey: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _gradientButton(
                      'CONTINUE',
                      _selectedRole != null ? _goToNextSignUpStep : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 4 : Age & Location ─────────────────────────────────
  Widget _buildAgeLocationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 160),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "How old are you and where are you from?",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Birthdate picker
              GestureDetector(
                onTap: _pickDate,
                child: Column(
                  children: [
                    AbsorbPointer(
                      child: TextField(
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          hintText:
                              _selectedDate == null
                                  ? 'Select your birth date'
                                  : '${_selectedDate!.toLocal()}'.split(' ')[0],
                          prefixIcon: const Icon(
                            Icons.cake,
                            color: Colors.blue,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 16,
                            horizontal: 20,
                          ),
                        ),
                        style: const TextStyle(color: Colors.blue),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'You must be 13 years or older.',
                      textAlign: TextAlign.left,
                      style: TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Country picker
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        showCountryPicker(
                          context: context,
                          showPhoneCode: false,
                          onSelect: (Country country) {
                            setState(() {
                              _selectedCountry = country;
                              _updateLocation();
                            });
                          },
                        );
                      },
                      child: AbsorbPointer(
                        child: TextField(
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            hintText:
                                _selectedCountry == null
                                    ? 'Country'
                                    : '${_selectedCountry!.flagEmoji} ${_selectedCountry!.name}',
                            prefixIcon: const Icon(
                              Icons.flag,
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              vertical: 16,
                              horizontal: 20,
                            ),
                          ),
                          style: const TextStyle(color: Colors.blue),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _styledTextField(
                      'Address',
                      Icons.location_city,
                      onChanged: (val) {
                        setState(() {
                          _address = val;
                          _updateLocation();
                        });
                      },
                      value: _address,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _gradientButton(
                      'BACK',
                      _goToPreviousSignUpStep,
                      isGrey: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _gradientButton(
                      'CONTINUE',
                      (_isOldEnough(_selectedDate) && _isLocationValid())
                          ? _goToNextSignUpStep
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Combine country + address
  void _updateLocation() {
    if (_selectedCountry != null && _address.isNotEmpty) {
      _location = '${_address.trim()}, ${_selectedCountry!.name}';
    } else if (_selectedCountry != null) {
      _location = _selectedCountry!.name;
    } else {
      _location = _address;
    }
  }

  // ── Step 6 : Profile Image ───────────────────────────────
  Widget _buildImageStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 180),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Add a profile picture",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey.shade200,
                backgroundImage:
                    kIsWeb
                        ? null
                        : (_selectedImage != null
                            ? FileImage(_selectedImage!)
                            : null),
                child:
                    (_selectedImage == null && _webSelectedImage == null)
                        ? const Icon(
                          Icons.add_a_photo,
                          size: 40,
                          color: Colors.blue,
                        )
                        : null,
              ),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _gradientButton(
                    'BACK',
                    _goToPreviousSignUpStep,
                    isGrey: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _gradientButton(
                    'CONTINUE',
                    (_isOldEnough(_selectedDate) && _isLocationValid())
                        ? _goToNextSignUpStep
                        : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBioStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 160),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Tell us a little about yourself",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            TextField(
              maxLines: 5,
              minLines: 3,
              decoration: InputDecoration(
                hintText: "Write something about yourself...",
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              onChanged: (val) => setState(() => _bio = val),
            ),
            const SizedBox(height: 30),
            Row(
              children: [
                Expanded(
                  child: _gradientButton(
                    'BACK',
                    _goToPreviousSignUpStep,
                    isGrey: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _gradientButton(
                    'CONTINUE',
                    _bio.isNotEmpty ? _goToNextSignUpStep : null,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Step 5 : Credentials ────────────────────────────────────
  Widget _buildCredentialsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 75),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Create your credentials",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 20),

              _styledTextField(
                "Username",
                Icons.person,
                onChanged: (val) => setState(() => _username = val),
                value: _username,
              ),
              const SizedBox(height: 12),

              // Phone number field with validation
              IntlPhoneField(
                decoration: InputDecoration(
                  labelText: 'Phone Number',
                  filled: true,
                  fillColor: Colors.grey.shade50,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 16,
                    horizontal: 20,
                  ),
                  errorText:
                      _phoneNumber.isEmpty && _phoneNumberTouched
                          ? 'Please enter a valid phone number'
                          : null,
                ),
                initialCountryCode: 'US',
                onChanged: (phone) {
                  setState(() {
                    _phoneNumber = phone.completeNumber;
                    _phoneNumberTouched = true;
                  });
                },
                validator: (phone) {
                  if (phone == null || phone.number.isEmpty) {
                    return 'Please enter a phone number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              _styledTextField(
                "Email",
                Icons.email,
                onChanged: (val) => setState(() => _email = val),
                value: _email,
              ),
              const SizedBox(height: 12),

              // Password field with requirements
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _styledTextField(
                    "Password",
                    Icons.lock,
                    obscure: true,
                    onChanged: (val) => setState(() => _password = val),
                    value: _password,
                  ),
                  const Padding(
                    padding: EdgeInsets.only(left: 16, top: 4),
                    child: Text(
                      'Minimum 8 characters',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              _styledTextField(
                "Confirm Password",
                Icons.lock_outline,
                obscure: true,
                onChanged: (val) => setState(() => _confirmPassword = val),
                value: _confirmPassword,
              ),
              if (_password.isNotEmpty &&
                  _confirmPassword.isNotEmpty &&
                  !_passwordsMatch())
                const Padding(
                  padding: EdgeInsets.only(left: 16, top: 4),
                  child: Text(
                    'Passwords do not match',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ),

              const SizedBox(height: 30),
              Row(
                children: [
                  Expanded(
                    child: _gradientButton(
                      'BACK',
                      _goToPreviousSignUpStep,
                      isGrey: true,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _gradientButton(
                      'SEND CODE',
                      (_username.isNotEmpty &&
                              _phoneNumber.isNotEmpty &&
                              _email.isNotEmpty &&
                              _isEmailValid() &&
                              _password.isNotEmpty &&
                              _confirmPassword.isNotEmpty &&
                              _isPasswordValid() &&
                              _passwordsMatch())
                          ? () async {
                            bool success = await _submitRegistration();
                            if (success) {
                              _goToNextSignUpStep();
                            }
                          }
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Step 6 : Verification ──────────────────────────────────
int _resendSeconds = 0; // countdown timer
Timer? _resendTimer;

void _startResendTimer() {
  setState(() {
    _resendSeconds = 30;
  });

  _resendTimer?.cancel();
  _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
    if (_resendSeconds == 0) {
      timer.cancel();
    } else {
      setState(() {
        _resendSeconds--;
      });
    }
  });
}

Widget _buildVerificationStep() {
  return Padding(
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 150),
    child: Container(
      padding: const EdgeInsets.all(24),
      decoration: _formDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Verify Your Email",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "We've sent a verification code to your email address. Please enter it below. Do not forget to check your spam folder!",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.black54, fontSize: 16),
          ),
          const SizedBox(height: 30),

          // Code input
          Row(
            children: [
              Expanded(
                child: _styledTextField(
                  'Enter 6-digit code',
                  Icons.verified,
                  keyboardType: TextInputType.number,
                  onChanged: (val) => setState(() => _code = val),
                  value: _code,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Resend button with timer
          TextButton(
            onPressed: (_resendSeconds == 0) ? _refreshVerify : null,
            child: (_resendSeconds == 0)
                ? const Text(
                    "Didn't receive code? Resend",
                    style: TextStyle(color: Colors.blue),
                  )
                : Text(
                    "Resend code in $_resendSeconds s",
                    style: const TextStyle(color: Colors.grey),
                  ),
          ),
          const SizedBox(height: 30),

          Row(
            children: [
              Expanded(
                child: _gradientButton(
                  'FINISH',
                  (_code.isNotEmpty)
                      ? () async {
                          bool success = await _verifyRegistration();
                          if (success) {
                            _rLogin();
                          }
                        }
                      : null,
                ),
              ),
            ],
          ),
        ],
      ),
    ),
  );
}


  // ────────────────────────────────────────────────────────────
  // Helper widgets
  Widget _genderOption(IconData icon, String label, Color color) {
    final isSelected = _selectedGender == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedGender = label),
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color: isSelected ? color.withOpacity(0.9) : color.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  Widget _roleOption(IconData icon, String label) {
    final isSelected = _selectedRole == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedRole = label),
      child: Container(
        width: 80,
        height: 100,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? Colors.blue.shade700.withOpacity(0.9)
                  : Colors.blue.shade500.withOpacity(0.6),
          borderRadius: BorderRadius.circular(20),
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white)),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.grey.shade50,
      hintText: hint,
      prefixIcon: Icon(icon, color: Colors.blue),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
    );
  }

  Widget _styledTextField(
    String hint,
    IconData icon, {
    bool obscure = false,
    TextInputType keyboardType = TextInputType.text,
    required Function(String) onChanged,
    required String value,
  }) {
    return TextField(
      obscureText: obscure,
      keyboardType: keyboardType,
      onChanged: onChanged,
      decoration: _inputDecoration(hint, icon),
      style: const TextStyle(color: Colors.black),
      controller: TextEditingController.fromValue(
        TextEditingValue(
          text: value,
          selection: TextSelection.collapsed(offset: value.length),
        ),
      ),
    );
  }

  Widget _gradientButton(
    String text,
    VoidCallback? onPressed, {
    bool isGrey = false,
  }) {
    final colors =
        isGrey
            ? [Colors.grey.shade600, Colors.grey.shade500]
            : [
              const Color(0xFF03558F),
              const Color.fromARGB(255, 45, 148, 237),
            ];
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        boxShadow: [
          BoxShadow(
            color: colors[1],
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  BoxDecoration _formDecoration() {
    return BoxDecoration(
      color: Colors.white.withOpacity(0.8),
      borderRadius: BorderRadius.circular(20),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.2),
          blurRadius: 10,
          offset: const Offset(0, 5),
        ),
      ],
    );
  }

  Future<bool> _submitRegistration() async {
    final Map<String, dynamic> userData = {
      "first_name": _firstName.trim(),
      "last_name": _lastName.trim(),
      "birthdate":
          _selectedDate != null
              ? _selectedDate!.toIso8601String().split('T')[0]
              : null,
      "location": _location.trim(),
      "role": _selectedRole,
      "gender": _selectedGender,
      "username": _username.trim(),
      "email": _email.trim(),
      "phone": _phoneNumber,
      "password": _password,
      "password2": _password,
      "bio": _bio,
    };

    print(userData);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await AccountsServices.signUp(
      userData,
      imageFile: _selectedImage,
      webImageFile: _webSelectedImage,
    );

    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Code sent for signup confirmation. Do not forget to check your spam folder!',
          ),
          backgroundColor: Colors.blue,
          duration: Duration(seconds: 5),
        ),
      );
      return true;
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage = decoded.values
            .map((v) => v.toString())
            .join('\n')
            .replaceAll(RegExp(r'[\[\]]'), '');
      } catch (_) {
        bodyMessage = response.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
      return false;
    }
  }

  Future<bool> _verifyRegistration() async {
    final Map<String, dynamic> userData = {
      "email": _email.trim(),
      "code": _code,
    };

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await AccountsServices.verify(userData);

    // Close loading
    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Code verified successfully. \nWelcome to OnlySport!'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      return true;
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage =
            decoded.values
                .map((value) => value.toString())
                .join('\n')
                .replaceAll(RegExp(r'[\[\]]'), '') ??
            response.body;
      } catch (_) {
        bodyMessage = response.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  _rLogin() async {
    final Map<String, dynamic> userData = {
      "email": _email,
      "password": _password,
    };

    final responsee = await AccountsServices.login(userData);

    final decoded = jsonDecode(responsee.body);

    await StorageService.write('rememberMe', _rememberMe.toString());
    // Extract tokens & user info
    final String accessToken = decoded['access'];
    final String refreshToken = decoded['refresh'];
    final Map<String, dynamic> user = decoded['user'];

    // Save securely using StorageService
    await StorageService.write('access_token', accessToken);
    await StorageService.write('refresh_token', refreshToken);
    await StorageService.write('user_data', jsonEncode(user));

    widget.onLoginSuccess(0);
  }

  Future<bool> _refresh() async {
    final String? refreshString = await StorageService.read('refresh_token');

    final Map<String, dynamic> userData = {"refresh": refreshString};

    final response = await AccountsServices.refresh(userData);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      final decoded = jsonDecode(response.body);
      final String accessToken = decoded['access'];
      await StorageService.write('access_token', accessToken);

      final String? userDataJson = await StorageService.read('user_data');
      final Map<String, dynamic> userData = jsonDecode(userDataJson!);
      final String firstName = userData['first_name'] ?? '';
      final String lastName = userData['last_name'] ?? '';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome Back $firstName $lastName!'),
          duration: const Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      widget.onLoginSuccess(0);
      return true;
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage = decoded.values
            .map((value) => value.toString())
            .join('\n')
            .replaceAll(RegExp(r'[\[\]]'), '');
      } catch (_) {
        bodyMessage = response.body;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _sendCode() async {
    final Map<String, dynamic> userData = {"email": _lemail.trim()};

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await AccountsServices.forgotPasswordCode(userData);

    // Close loading
    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Code for password reset confirmation, sent to your email.',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      return true;
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage =
            decoded.values
                .map((value) => value.toString())
                .join('\n')
                .replaceAll(RegExp(r'[\[\]]'), '') ??
            response.body;
      } catch (_) {
        bodyMessage = response.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _resetPassword() async {
    final Map<String, dynamic> userData = {
      "email": _lemail.trim(),
      "code": _verificationCode,
      "password": _password,
      "password2": _confirmPassword,
    };

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await AccountsServices.forgotPasswordChange(userData);

    // Close loading
    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Password reset successfully!'),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      setState(() {
        _youForgotMe = false;
        _password = '';
        _confirmPassword = '';
        _lemail = '';
      });

      return true;
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage =
            decoded.values
                .map((value) => value.toString())
                .join('\n')
                .replaceAll(RegExp(r'[\[\]]'), '') ??
            response.body;
      } catch (_) {
        bodyMessage = response.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }

  Future<bool> _refreshVerify() async {
    final Map<String, dynamic> userData = {"email": _email.trim()};
      _startResendTimer();

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await AccountsServices.refreshVerify(userData);

    // Close loading
    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Verification code was resent to your email. Do not forget to check your spam folder!',
          ),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.blue,
        ),
      );

      return true;
    } else {
      String bodyMessage;
      try {
        final decoded = jsonDecode(response.body);
        bodyMessage =
            decoded.values
                .map((value) => value.toString())
                .join('\n')
                .replaceAll(RegExp(r'[\[\]]'), '') ??
            response.body;
      } catch (_) {
        bodyMessage = response.body;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(bodyMessage),
          duration: Duration(seconds: 5),
          backgroundColor: Colors.red,
        ),
      );
      return false;
    }
  }
}
