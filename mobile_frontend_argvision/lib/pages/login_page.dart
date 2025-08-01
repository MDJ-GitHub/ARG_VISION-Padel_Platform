import 'package:flutter/material.dart';

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

  // Step‑level data
String? _firstName;
String? _lastName;
  String? _selectedGender;
  String? _selectedRole;
  DateTime? _selectedDate;

  // Controllers

final TextEditingController _firstNameController = TextEditingController();
final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final TextEditingController _codeController = TextEditingController();

  // ────────────────────────────────────────────────────────────
  // Validation helpers
  bool _isValidName(String name) => RegExp(r"^[A-Za-z\s]{2,}$").hasMatch(name);

  bool _isOldEnough(DateTime? birthDate) {
    if (birthDate == null) return false;
    final age = DateTime.now().difference(birthDate).inDays ~/ 365;
    return age > 13;
  }

  bool _isLocationValid() => _locationController.text.trim().length >= 2;

  // ────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();

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
        curve: const Interval(0.2, 0.4, curve: Curves.easeOut),
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
    _locationController.dispose();
    _firstNameController.dispose(); 
    _lastNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  // ────────────────────────────────────────────────────────────
  // Navigation helpers
  void _login() => widget.onLoginSuccess(0);

  void _showSignUpForm() {
    setState(() => _showSignUp = true);
    _signUpController.forward();
  }

  void _hideSignUpForm() {
    _signUpController.reverse().then((_) {
      setState(() {
        _showSignUp = false;
        _signUpStep = 0;
        _selectedGender = null;
        _selectedRole = null;
        _selectedDate = null;
        _locationController.clear();
        _usernameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _confirmPasswordController.clear();
        _codeController.clear();
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
                                  _buildCredentialsStep(),
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

  // ────────────────────────────────────────────────────────────
  // UI BUILDERS
  Widget _buildLoginForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      margin: const EdgeInsets.symmetric(horizontal: 24),
      decoration: _formDecoration(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _styledTextField('Email', Icons.email),
          const SizedBox(height: 20),
          _styledTextField('Password', Icons.lock, obscure: true),
          const SizedBox(height: 30),
          _gradientButton('LOGIN', _login),
          const SizedBox(height: 16),
          TextButton(
            onPressed: () {},
            child: const Text(
              'Forgot Password?',
              style: TextStyle(color: Colors.blue),
            ),
          ),
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
          TextField(
            controller: _firstNameController,
            onChanged: (val) => setState(() => _firstName = val),
            decoration: _inputDecoration('First Name', Icons.person),
            style: const TextStyle(color: Colors.black),
          ),
          const SizedBox(height: 12),

          // Last Name
          TextField(
            controller: _lastNameController,
            onChanged: (val) => setState(() => _lastName = val),
            decoration: _inputDecoration('Last Name', Icons.person_outline),
            style: const TextStyle(color: Colors.black),
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
                  (_firstName != null &&
                          _lastName != null &&
                          _isValidName(_firstName!) &&
                          _isValidName(_lastName!))
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


  // ── Step 2 : Gender ─────────────────────────────────────────
  Widget _buildGenderStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 255),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
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
    );
  }

  // ── Step 3 : Role ───────────────────────────────────────────
  Widget _buildRoleStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 253),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
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
    );
  }

  // ── Step 4 : Age & Location ─────────────────────────────────
  Widget _buildAgeLocationStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 210),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
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
  child: Column( // Wrap in a Column to include additional text
    children: [
      AbsorbPointer(
        child: TextField(
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey.shade50,
            hintText: _selectedDate == null
                ? 'Select your birth date'
                : '${_selectedDate!.toLocal()}'.split(' ')[0],
            prefixIcon: const Icon(Icons.cake, color: Colors.blue),
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
      const SizedBox(height: 8), // Adding some space between TextField and message
      const Text(
        'You must be 13 years or older.',
        textAlign: TextAlign.left, // Aligns the text to the left
        style: TextStyle(
          color: Colors.black54,// Change color as desired
          fontSize: 12, // Adjust font size
        ),
      ),
    ],
  ),
),
            const SizedBox(height: 20),
            // Location
            TextField(
              controller: _locationController,
              onChanged: (_) => setState(() {}), // ADD THIS LINE
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.grey.shade50,
                hintText: 'Where are you from?',
                prefixIcon: const Icon(Icons.location_on, color: Colors.blue),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 16,
                  horizontal: 20,
                ),
              ),
              style: const TextStyle(color: Colors.black),
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

  // ── Step 5 : Credentials ────────────────────────────────────
  Widget _buildCredentialsStep() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 143),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: _formDecoration(),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Finally, your credentials?",
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
                controller: _usernameController,
              ),
              const SizedBox(height: 12),

                     
              _styledTextField(
                "Password",
                Icons.lock,
                obscure: true,
                controller: _passwordController,
              ),
              const SizedBox(height: 12),
              _styledTextField(
                "Confirm Password",
                Icons.lock_outline,
                obscure: true,
                controller: _confirmPasswordController,
              ),
       const SizedBox(height: 12),
              // Email with send code button
              Row(
                children: [
                  Expanded(
                    child: _styledTextField(
                      "Email",
                      Icons.email,
                      controller: _emailController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // TODO: implement send code
                    },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 14),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      "Send Code",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),


              const SizedBox(height: 12),
              _styledTextField(
                "Enter Code",
                Icons.verified,
                controller: _codeController,
              ),

              const SizedBox(height: 20),
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
                    child: _gradientButton('FINISH', _submitRegistration),

                  ),
                ],
              ),
            ],
          ),
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
    TextEditingController? controller,
  }) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      decoration: _inputDecoration(hint, icon),
      style: const TextStyle(color: Colors.black),
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
          padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 24),
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

  void _submitRegistration() {
  final Map<String, dynamic> userData = {
    "firstName": _firstName?.trim(),
    "lastName": _lastName?.trim(),
    "birthDate": _selectedDate?.toIso8601String(),
    "location": _locationController.text.trim(),
    "role": _selectedRole,
    "gender": _selectedGender,
    "username": _usernameController.text.trim(),
    "email": _emailController.text.trim(),
    "password": _passwordController.text,
  };

  print("User Registration Data: \$userData");

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Registration Complete'),
      content: Text('JSON:\n${userData.toString()}'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );
}
}
