import 'dart:developer';

import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpBloc.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpEvent.dart';
import 'package:c2w_management_app/features/login_signup/presentation/bloc/LoginSignUpState.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final fullNameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final mobCtrl = TextEditingController();
  final upiCtrl = TextEditingController();
  final dobCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  bool obscure = true;


  @override
  Widget build(BuildContext context) {
    final canContinue =
        fullNameCtrl.text.trim().isNotEmpty &&
        emailCtrl.text.trim().isNotEmpty &&
        dobCtrl.text.isNotEmpty &&
        passCtrl.text.isNotEmpty;

    return Scaffold(
      backgroundColor: const Color(0xFF070A1B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                'Sign Up',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 48),
              const Text(
                'Full Name',
                style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 12),
              ),
              TextField(
                controller: fullNameCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Enter your full name',
                  hintStyle: TextStyle(color: Color(0xFF5C6078), fontSize: 14),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A2D45)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E6FB5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Email',
                style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 12),
              ),
              TextField(
                controller: emailCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Enter your email',
                  hintStyle: TextStyle(color: Color(0xFF5C6078), fontSize: 14),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A2D45)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E6FB5)),
                  ),
                ),
              ),

              const SizedBox(height: 20,),
              const Text(
                'Mobile No.',
                style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 12),
              ),
              TextField(
                controller: mobCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                keyboardType: TextInputType.number,
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Enter your mobile no. (+91)',
                  hintStyle: TextStyle(color: Color(0xFF5C6078), fontSize: 14),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A2D45)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E6FB5)),
                  ),
                ),
              ),

              const SizedBox(height: 20,),
              const Text(
                'UPI ID',
                style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 12),
              ),
              TextField(
                controller: upiCtrl,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: const InputDecoration(
                  hintText: 'Enter your UPI ID',
                  hintStyle: TextStyle(color: Color(0xFF5C6078), fontSize: 14),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A2D45)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E6FB5)),
                  ),
                ),
              ),
              
              Row(
                children: [
                  const Text(
                    'DOB',
                    style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 12),
                  ),
                  Spacer(),
                  IconButton(
                    onPressed: () async {
                      final date = await showDatePicker(
                        context: context,
                        initialDate: DateTime(2000),
                        firstDate: DateTime(1950),
                        lastDate: DateTime.now(),
                      );
                      if (date != null) {
                        setState(() {
                          dobCtrl.text =
                              '${date.day}/${date.month}/${date.year}';
                        });
                      }
                    },

                    icon: Icon(Icons.calendar_month),
                  ),
                ],
              ),
              TextField(
                controller: dobCtrl,
                readOnly: true,

                style: const TextStyle(color: Colors.white, fontSize: 14),
                decoration: const InputDecoration(
                  hintText: 'Enter your DOB',
                  hintStyle: TextStyle(color: Color(0xFF5C6078), fontSize: 14),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A2D45)),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E6FB5)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Password',
                style: TextStyle(color: Color(0xFF9A9DB5), fontSize: 12),
              ),
              TextField(
                controller: passCtrl,
                obscureText: obscure,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(color: Colors.white, fontSize: 14),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Enter a password',
                  hintStyle: const TextStyle(
                    color: Color(0xFF5C6078),
                    fontSize: 14,
                  ),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2A2D45)),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF1E6FB5)),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      obscure
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: const Color(0xFF5C6078),
                      size: 20,
                    ),
                    onPressed: () => setState(() => obscure = !obscure),
                  ),
                ),
              ),
              
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: canContinue
    ? () {
        final fullName = fullNameCtrl.text.trim();
        final email = emailCtrl.text.trim();
        final mobile = mobCtrl.text.trim();

        // Validate email
        final emailRegex = RegExp(
  r"^[\w.!#$%&'*+/=?^`{|}~-]+@[\w-]+(\.[\w-]+)+$",
);

        if (!emailRegex.hasMatch(email)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid email address'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Validate mobile number
        if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please enter a valid 10-digit mobile number'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        // Navigate only if validations pass
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SelectRoleScreen(
              fullName: fullName,
              email: email,
              mobile: mobile,
              upi: upiCtrl.text.trim(),
              dob: dobCtrl.text.trim(),
              password: passCtrl.text,
            ),
          ),
        );
      }
    : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00A3FF),
                    disabledBackgroundColor: const Color(0xFF2A2D45),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'Continue',
                    style: TextStyle(
                      color: canContinue
                          ? Colors.white
                          : const Color(0xFF7A7D95),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  
                  Navigator.of(context).pop();
                },
                child: Center(child: Text("Back to Login Page",style: TextStyle(color: Colors.blue,fontSize: 15,fontWeight: FontWeight(400)),))),
              const SizedBox(height: 20),
            ],
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
  void showSignupData() {
    String name = widget.fullName;
    String email = widget.email;
    String mobile = widget.mobile;
    String upi = widget.upi;
    String dob = widget.dob;
  }
  

  @override
  Widget build(BuildContext context) {
    final roles = ['Instructor', 'Mentor', 'TeamLead','SalesAdmin'];

    return BlocConsumer<Loginsignupbloc, LoginSignupState>(
    listener: (context, state) {
      if (state is SignupSuccessful) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Signup successful!'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => LoginScreen(),
          ),
        );
      } else if (state is SignupInvalidCredentials) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This email is already registered.'),
            backgroundColor: Colors.red,
          ),
        );
      } else if (state is SignupFailure) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    },
    builder: (context, state) {
      final isLoading = state is SignupLoading;

    return Scaffold(
      backgroundColor: const Color(0xFF070A1B),
      body: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: Color(0xFF0E1128),
                border: Border(bottom: BorderSide(color: Color(0xFF1C1F3A))),
              ),
              child: Row(
                children: [
                  IconButton(onPressed: (){
                    Navigator.of(context).pop();
                  }, icon: Icon(Icons.arrow_back,color: Colors.white,)),
                 
                  Image.asset(
                    "assets/images/sales_admin/logo.png",
                    height: 50,
                    width: 50,
                  ),
                  // SizedBox(width: 5,),
                  Image.asset(
                    "assets/images/sales_admin/c2wtext.png",
                    height: 70,
                    width: 100,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Select Your Role',
              style: TextStyle(color: Colors.white, fontSize: 15),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    ...roles.map(
                      (role) => GestureDetector(
                        onTap: () => setState(() => selectedRole = role),
                        child: Container(
                          width: double.infinity,
                          margin: const EdgeInsets.only(bottom: 14),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 22,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF12142A),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: selectedRole == role
                                  ? const Color(0xFF00A3FF)
                                  : const Color(0xFF24274A),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                role,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                ),
                              ),
                              Container(
                                width: 20,
                                height: 20,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: selectedRole == role
                                        ? const Color(0xFF00A3FF)
                                        : const Color(0xFF7A7D95),
                                    width: 1.5,
                                  ),
                                ),
                                child: selectedRole == role
                                    ? Center(
                                        child: Container(
                                          width: 10,
                                          height: 10,
                                          decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Color(0xFF00A3FF),
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: selectedRole != null
                            ? () {
                                context.read<Loginsignupbloc>().add(SignupDataEvent(widget.fullName,widget.email,widget.mobile, widget.upi, widget.dob, widget.password,selectedRole!));
                                context.read<Loginsignupbloc>().add(SignupAuthEvent(widget.email, widget.password,selectedRole!));
                                log(widget.email);
                                
                                
                                Navigator.of(context).push(MaterialPageRoute(builder: (context)=>LoginScreen()));
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00A3FF),
                          disabledBackgroundColor: const Color(0xFF2A2D45),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Text(
                          'Sign Up',
                          style: TextStyle(
                            color: selectedRole != null
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
          ],
        ),
      ),
    );
    }
    );
  }
}
