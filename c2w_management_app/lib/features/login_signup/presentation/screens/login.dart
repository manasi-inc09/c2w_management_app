import 'dart:developer';

import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpBloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpEvent.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/signup.dart';
import 'package:c2w_management_app/features/sales_admin/dashboard/presentation/screens/dashboard_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

//String loginAs = "instructor";

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _roleCtrl = TextEditingController();
  bool _obscure = true;
  bool _loading = false;
  // static String? authEmail;

  static const _bg = Color.fromRGBO(7, 10, 27, 1);
  static const _accent = Color(0xFF00A3FF);
  static const _hint = Color(0xFF5C6078);

  bool get _canSubmit =>
      _userCtrl.text.trim().isNotEmpty && _passCtrl.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _userCtrl.addListener(() => setState(() {}));
    _passCtrl.addListener(() => setState(() {}));
    _roleCtrl.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _userCtrl.dispose();
    _passCtrl.dispose();
    _roleCtrl.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) setState(() => _loading = false);
  }

  InputDecoration _decoration(String hint, {Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        color: Colors.grey, // Hint text color
        fontSize: 14,
      ),
      suffixIcon: suffix,
      enabledBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
      focusedBorder: const UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 4),
    child: Text(
      text,
      style: GoogleFonts.figtree(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w400,
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<Loginsignupbloc,LoginSignupState>(
      listener: (context, state) {
        if(state is LoginSuccessful){
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text("Login Successful!!",style: TextStyle(color: Colors.white),),
            backgroundColor: Colors.green,
          ),);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (context)=>DashboardView())
          );

        }else if(state is LoginInvalidCredentials){
          ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Invalid username or password'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (state is LoginFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
      builder:(context,state){
        final isLoading = state is LoginSignupState;
      
       return Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: _bg,
        body: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color.fromRGBO(32, 34, 58, 1),
                  Color.fromRGBO(7, 10, 27, 0),
                ],
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 60),
                    Text(
                      'Welcome back!',
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Enter username or password to continue',
                      style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 14),
                    ),
                    const SizedBox(height: 30),
      
                    _label('User Name'),
                    TextField(
                      controller: _userCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      cursorColor: Colors.white,
                      decoration: _decoration('Enter your registered username'),
                    ),
      
                    _label('Password'),
                    TextField(
                      controller: _passCtrl,
                      obscureText: _obscure,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                      cursorColor: Colors.white,
                      decoration: _decoration(
                        'Enter a password',
                        suffix: IconButton(
                          icon: Icon(
                            _obscure
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: _hint,
                            size: 20,
                          ),
                          onPressed: () => setState(() => _obscure = !_obscure),
                        ),
                      ),
                    ),
      
                    _label('Role'),
                    DropdownButtonFormField<String>(
                      value: _roleCtrl.text.isEmpty ? null : _roleCtrl.text,
                      dropdownColor: const Color(0xFF12142A),
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                      decoration: const InputDecoration(
                        hintText: 'Select your registered role',
                        hintStyle: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'instructor',
                          child: Text('Instructor'),
                        ),
                        DropdownMenuItem(value: 'mentor', child: Text('Mentor')),
                        DropdownMenuItem(
                          value: 'teamlead',
                          child: Text('Team Lead'),
                        ),
                        DropdownMenuItem(
                          value: 'salesadmin',
                          child: Text('Sales Admin'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _roleCtrl.text = value ?? '';
                        });
                      },
                    ),
      
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        child: const Text(
                          'Forgot Password',
                          style: TextStyle(
                            color: Color(0xFF9A9DB5),
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
      
                    const SizedBox(height: 200),
      
                    // Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: (_canSubmit && !_loading)
                            ? () async {
                                if (_userCtrl.text.isNotEmpty &&
                                    _passCtrl.text.isNotEmpty &&
                                    _roleCtrl.text.isNotEmpty) {
                                  context.read<Loginsignupbloc>().add(
                                    LoginEvent(
                                      _userCtrl.text.trim(),
                                      _passCtrl.text.trim(),
                                      _roleCtrl.text.trim(),
                                    ),
                                  );
                                  
                                //   Navigator.of(context).push(
                                //   MaterialPageRoute(
                                //     builder: (context) => DashboardView(),
                                //   ),
                                // );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Invalid Credentials.Please Enter Correct Username and Password"),
                                    ),
                                  );
                                }
      
                                setState(() => _loading = true);
                                await Future.delayed(const Duration(seconds: 2));
                                if (!mounted) return;
                                setState(() => _loading = false);
                                //  LoginScreen.authEmail=_userCtrl.text;
                                // log("login email: ${LoginScreen.authEmail}");
                                _userCtrl.clear();
                                _passCtrl.clear();
                                _roleCtrl.clear();
                                
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _accent,
                          disabledBackgroundColor: _loading
                              ? const Color(0xFF0B77B5)
                              : const Color(0xFF2A2D45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: _loading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : Text(
                                'Log In',
                                style: TextStyle(
                                  color: _canSubmit
                                      ? const Color.fromARGB(255, 198, 184, 184)
                                      : Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => SignUpScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          'Create an Account',
                          style: TextStyle(
                            color: Color(0xFF9A9DB5),
                            fontSize: 16,
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
      );
      }
    );
  }
}
