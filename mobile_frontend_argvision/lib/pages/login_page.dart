import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:mobile_frontend_argvision/services/accounts_services.dart';
import 'package:mobile_frontend_argvision/services/storage_service.dart';

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

    final response = await OrganizationsServices.login(userData);

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

  void _sendVerificationCode() {
    if (_isEmailValid()) {
      // In a real app, you would send the code to the email here
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Verification code sent to your email'),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid email address'),
          duration: Duration(seconds: 2),
        ),
      );
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
          builder: (BuildContext context, AsyncSnapshot<Map<String, String>> snapshot) {
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

    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: _formDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _styledTextField(
            'Username or Email or Phone',
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
                onPressed: () {},
                child: const Text(
                  'Forgot Password?',
                  style: TextStyle(color: Colors.blue),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 240),
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
                  fontSize: 24,
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 255),
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
                  _genderOption(Icons.transgender, "Other", Colors.grey),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 253),
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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 210),
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
              // Birth date picker
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
              // Location
              _styledTextField(
                'Where are you from?',
                Icons.location_on,
                onChanged: (val) => setState(() => _location = val),
                value: _location,
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

  // ── Step 5 : Credentials ────────────────────────────────────
  Widget _buildCredentialsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 140),
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
  Widget _buildVerificationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 210),
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
              "We've sent a verification code to your email address. Please enter it below.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.black54, fontSize: 16),
            ),
            const SizedBox(height: 30),

            // Code input with send button
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
            TextButton(
              onPressed: _sendVerificationCode,
              child: const Text(
                "Didn't receive code? Resend",
                style: TextStyle(color: Colors.blue),
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
      "birthDate": _selectedDate?.toIso8601String(),
      "location": _location.trim(),
      "role": _selectedRole,
      "gender": _selectedGender,
      "username": _username.trim(),
      "email": _email.trim(),
      "phone": _phoneNumber,
      "password": _password,
      "password2": _password,
    };

    print("User Registration Data: ${jsonEncode(userData)}");

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    final response = await OrganizationsServices.signUp(userData);

    // Close loading
    Navigator.of(context).pop();

    if (response.statusCode >= 200 && response.statusCode < 300) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Code was sent to your email for signing up confirmation.',
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

    final response = await OrganizationsServices.verify(userData);

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

  _rLogin() {
    widget.onLoginSuccess(0);
  }

  Future<bool> _refresh() async {
    final String? refreshString = await StorageService.read('refresh_token');

    final Map<String, dynamic> userData = {"refresh": refreshString};

    final response = await OrganizationsServices.refresh(userData);

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
}
