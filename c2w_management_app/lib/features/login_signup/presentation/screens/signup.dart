import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpBloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpEvent.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobCtrl = TextEditingController();
  final upiCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;

  String? _validateName(String? value) {
    final name = value?.trim() ?? '';
    if (name.isEmpty) return 'Please enter the full name';
    if (name.length < 2) return 'Name must be at least 2 characters';
    if (RegExp(r"[^\p{L}\s'-]", unicode: true).hasMatch(name)) {
      return 'Name can only contain letters, spaces, apostrophes, and hyphens';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    final email = value ?? '';
    if (email.trim().isEmpty) return 'Please enter your email';
    if (RegExp(r'\s').hasMatch(email)) {
      return 'Spaces are not allowed in email';
    }
    if (RegExp(r'[A-Z]').hasMatch(email)) {
      return 'Capital letters are not allowed in email';
    }
    if (!RegExp(
      r"^[\w.!#$%&'*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$",
    ).hasMatch(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return null;
    if (RegExp(r'\s').hasMatch(mobile)) {
      return 'Spaces are not allowed in mobile number';
    }
    if (RegExp(r'\D').hasMatch(mobile)) {
      return 'Only digits are allowed in mobile number';
    }
    if (mobile.length != 10) return 'Mobile number must be 10 digits';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      return 'Mobile number must start with 6, 7, 8, or 9';
    }
    return null;
  }

  String? _validateUpi(String? value) {
    final upi = value?.trim() ?? '';
    if (upi.isEmpty) return null;
    if (!RegExp(r'^[\w.-]{2,}@[\w.-]{2,}$').hasMatch(upi)) {
      return 'Enter a valid UPI ID, for example name@upi';
    }
    return null;
  }

  String? _validateDob(String? value) =>
      value == null || value.trim().isEmpty ? null : null;

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.isEmpty) return 'Please enter a password';
    final isValid =
        password.length >= 8 &&
        RegExp(r'[A-Z]').hasMatch(password) &&
        RegExp(r'[a-z]').hasMatch(password) &&
        RegExp(r'\d').hasMatch(password) &&
        RegExp(r'[^A-Za-z0-9\s]').hasMatch(password);
    return isValid
        ? null
        : 'Password must be at least 8 characters, include uppercase, lowercase, a number, and a special character';
  }

  @override
  void dispose() {
    fullNameCtrl.dispose();
    emailCtrl.dispose();
    mobCtrl.dispose();
    upiCtrl.dispose();
    dobCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();
    final currentEmail = (AuthRepository.authEmail ?? '').toLowerCase();
    final canAccess =
        currentEmail.startsWith('superadmin_') ||
        currentEmail.startsWith('instructor_');

    if (!canAccess) {
      return const Scaffold(
        backgroundColor: Color(0xFF070A1B),
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Only instructor and superadmin can add new users.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 16),
            ),
          ),
        ),
      );
    }

    final canContinue =
        _validateName(fullNameCtrl.text) == null &&
        _validateEmail(emailCtrl.text) == null &&
        _validatePassword(passCtrl.text) == null &&
        _validateMobile(mobCtrl.text) == null &&
        _validateUpi(upiCtrl.text) == null;

    return Scaffold(
      backgroundColor: theme.bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Create User',
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.premiumGradient),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(18),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: theme.cardBackgroundColor.withValues(alpha: 0.9),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: theme.borderColor, width: 1),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 10),
                            blurRadius: 18,
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Full Name',
                            style: TextStyle(
                              color: Color(0xFF9A9DB5),
                              fontSize: 12,
                            ),
                          ),
                          TextFormField(
                            controller: fullNameCtrl,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                            validator: _validateName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Enter full name',
                              hintStyle: TextStyle(
                                color: Color(0xFF5C6078),
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2A2D45),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1E6FB5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: Color(0xFF9A9DB5),
                              fontSize: 12,
                            ),
                          ),
                          TextFormField(
                            controller: emailCtrl,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'Enter email address',
                              hintStyle: TextStyle(
                                color: Color(0xFF5C6078),
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2A2D45),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1E6FB5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Mobile No.',
                            style: TextStyle(
                              color: Color(0xFF9A9DB5),
                              fontSize: 12,
                            ),
                          ),
                          TextFormField(
                            controller: mobCtrl,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            keyboardType: TextInputType.phone,
                            validator: _validateMobile,
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: '10-digit mobile number (optional)',
                              hintStyle: TextStyle(
                                color: Color(0xFF5C6078),
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2A2D45),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1E6FB5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'UPI ID',
                            style: TextStyle(
                              color: Color(0xFF9A9DB5),
                              fontSize: 12,
                            ),
                          ),
                          TextFormField(
                            controller: upiCtrl,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            onChanged: (_) => setState(() {}),
                            validator: _validateUpi,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            cursorColor: Colors.white,
                            decoration: const InputDecoration(
                              hintText: 'UPI ID (optional)',
                              hintStyle: TextStyle(
                                color: Color(0xFF5C6078),
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2A2D45),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1E6FB5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Date of Birth',
                            style: TextStyle(
                              color: Color(0xFF9A9DB5),
                              fontSize: 12,
                            ),
                          ),
                          TextFormField(
                            controller: dobCtrl,
                            readOnly: true,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: _validateDob,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            onTap: () async {
                              final selectedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now().subtract(
                                  const Duration(days: 365 * 25),
                                ),
                                firstDate: DateTime(1950),
                                lastDate: DateTime.now(),
                              );
                              if (selectedDate != null) {
                                dobCtrl.text =
                                    '${selectedDate.day.toString().padLeft(2, '0')}/${selectedDate.month.toString().padLeft(2, '0')}/${selectedDate.year}';
                                setState(() {});
                              }
                            },
                            decoration: const InputDecoration(
                              hintText: 'Select DOB (optional)',
                              hintStyle: TextStyle(
                                color: Color(0xFF5C6078),
                                fontSize: 14,
                              ),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2A2D45),
                                ),
                              ),
                              focusedBorder: UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1E6FB5),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: Color(0xFF9A9DB5),
                              fontSize: 12,
                            ),
                          ),
                          TextFormField(
                            controller: passCtrl,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText: obscure,
                            onChanged: (_) => setState(() {}),
                            validator: _validatePassword,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            cursorColor: Colors.white,
                            decoration: InputDecoration(
                              hintText: 'Create a strong password',
                              errorMaxLines: 3,
                              hintStyle: const TextStyle(
                                color: Color(0xFF5C6078),
                                fontSize: 14,
                              ),
                              enabledBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF2A2D45),
                                ),
                              ),
                              focusedBorder: const UnderlineInputBorder(
                                borderSide: BorderSide(
                                  color: Color(0xFF1E6FB5),
                                ),
                              ),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  obscure
                                      ? Icons.visibility_outlined
                                      : Icons.visibility_off_outlined,
                                  color: const Color(0xFF5C6078),
                                  size: 20,
                                ),
                                onPressed: () =>
                                    setState(() => obscure = !obscure),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: canContinue
                            ? () {
                                if (!_formKey.currentState!.validate()) return;
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => SelectRoleScreen(
                                      fullName: fullNameCtrl.text.trim(),
                                      email: emailCtrl.text.trim(),
                                      mobile: mobCtrl.text.trim(),
                                      upi: upiCtrl.text.trim(),
                                      dob: dobCtrl.text.trim(),
                                      password: passCtrl.text,
                                    ),
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF7C6CFF),
                          disabledBackgroundColor: const Color(0xFF2A2D45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Continue',
                          style: GoogleFonts.figtree(
                            color: canContinue
                                ? Colors.white
                                : const Color(0xFF7A7D95),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class SelectRoleScreen extends StatefulWidget {
  final String fullName;
  final String email;
  final String mobile;
  final String upi;
  final String dob;
  final String password;

  const SelectRoleScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.mobile,
    required this.upi,
    required this.dob,
    required this.password,
  });

  @override
  State<SelectRoleScreen> createState() => _SelectRoleScreenState();
}

class _SelectRoleScreenState extends State<SelectRoleScreen> {
  String? selectedRole;
  final List<String> _roles = const [
    'TeamLead',
    'Mentor',
    'SalesAdmin',
    'Instructor',
  ];

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();

    return BlocConsumer<Loginsignupbloc, LoginSignupState>(
      listener: (context, state) {
        if (state is SignupSuccessful) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('User created successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).popUntil((route) => route.isFirst);
        } else if (state is SignupInvalidCredentials) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('This email is already registered.'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is SignupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state is SignupLoading;

        return Scaffold(
          backgroundColor: theme.bodyBackgroundColor,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.arrow_back, color: Colors.white),
            ),
            title: Text(
              'Create User',
              style: GoogleFonts.figtree(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: Container(
            decoration: BoxDecoration(gradient: theme.premiumGradient),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    Text(
                      'Select user role',
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        itemCount: _roles.length,
                        separatorBuilder: (_, _) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final role = _roles[index];
                          final isSelected = selectedRole == role;

                          return GestureDetector(
                            onTap: () => setState(() => selectedRole = role),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 18,
                              ),
                              decoration: BoxDecoration(
                                color: theme.cardBackgroundColor.withValues(
                                  alpha: 0.9,
                                ),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: isSelected
                                      ? theme.primaryColor
                                      : theme.borderColor,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    role,
                                    style: GoogleFonts.figtree(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Container(
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? theme.primaryColor
                                            : Colors.white24,
                                        width: 2,
                                      ),
                                    ),
                                    child: isSelected
                                        ? Center(
                                            child: Container(
                                              width: 10,
                                              height: 10,
                                              decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Color(0xFF7C6CFF),
                                              ),
                                            ),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: selectedRole != null && !isSubmitting
                            ? () {
                                context.read<Loginsignupbloc>().add(
                                  SignupDataEvent(
                                    widget.fullName,
                                    widget.email,
                                    widget.mobile,
                                    widget.upi,
                                    widget.dob,
                                    selectedRole!,
                                    widget.password,
                                  ),
                                );
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.primaryColor,
                          disabledBackgroundColor: const Color(0xFF2A2D45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Create User',
                                style: GoogleFonts.figtree(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
