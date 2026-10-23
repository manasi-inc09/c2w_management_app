import 'dart:developer';

import 'package:c2w_management_app/features/Profile/data/models/UserModel.dart';
import 'package:c2w_management_app/features/Profile/presentation/bloc/ProfileBloc.dart';
import 'package:c2w_management_app/features/Profile/presentation/bloc/ProfileEvent.dart';
import 'package:c2w_management_app/features/Profile/presentation/bloc/ProfileState.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

const Color bgColor = Color(0xFF0A0F24);
const Color cardColor = Color(0xFF141B34);
const Color iconBoxColor = Color(0xFF1F2742);
const Color lineColor = Color(0xFF2A3150);
const Color accentColor = Color(0xFFEF4565);
const Color blueColor = Color(0xFF3B82F6);
const Color greyText = Color(0xFF8A90A6);

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String? profileDocumentId;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  @override
  void initState() {
    super.initState();

    final email = FirebaseAuth.instance.currentUser?.email;

    if (email != null) {
      final cleanedEmail = email.replaceFirst(
        RegExp(r'^(admin|mentor|instructor|salesadmin|teamlead)_'),
        '',
      );

      profileDocumentId = cleanedEmail;

      context.read<ProfileBloc>().add(GetUserDataEvent(cleanedEmail));
    }
  }

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Logout Account?',
                  style: GoogleFonts.figtree(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to logout this account?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.figtree(fontSize: 14, color: greyText),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 45,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    onPressed: () => Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(builder: (context) => LoginScreen()),
                      (route) => false,
                    ),
                    child: Text(
                      'Logout',
                      style: GoogleFonts.figtree(fontSize: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: GoogleFonts.figtree(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _pickProfileImage() async {
    final email = profileDocumentId;
    if (email == null) {
      showMessage('Could not identify this profile. Please sign in again.');
      return;
    }

    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );
      if (image == null || !mounted) return;

      context.read<ProfileBloc>().add(
        UploadProfileImageEvent(email: email, filePath: image.path),
      );
    } on PlatformException catch (error) {
      showMessage(error.message ?? 'Could not select an image.');
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: GoogleFonts.figtree(fontSize: 14))),
    );
  }

  Widget _buildProfileAvatar(String imageUrl, {required bool isUploading}) {
    final fallback = Image.asset(
      'assets/images/sales_admin/profile.png',
      fit: BoxFit.cover,
    );

    return GestureDetector(
      onTap: isUploading ? null : _pickProfileImage,
      child: Stack(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.green,
            child: ClipOval(
              child: SizedBox(
                width: 70,
                height: 70,
                child: imageUrl.isEmpty
                    ? fallback
                    : Image.network(
                        imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => fallback,
                      ),
              ),
            ),
          ),
          if (isUploading)
            const Positioned.fill(
              child: CircleAvatar(
                radius: 35,
                backgroundColor: Color(0x99000000),
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            const Positioned(
              right: 0,
              bottom: 0,
              child: CircleAvatar(
                radius: 12,
                backgroundColor: blueColor,
                child: Icon(Icons.camera_alt, size: 14, color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A1B),
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: Text(
          'Profile',
          style: GoogleFonts.figtree(fontSize: 18, color: Colors.white),
        ),
      ),
      body: BlocConsumer<ProfileBloc, ProfileState>(
        listener: (context, state) {
          if (state is ProfileImageUploadSuccess) {
            showMessage('Profile picture updated successfully.');
          } else if (state is ProfileImageUploadFailure) {
            showMessage(state.message);
          }
        },
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = switch (state) {
            ProfileSuccess(:final user) => user,
            ProfileImageUploadLoading(:final user) => user,
            ProfileImageUploadSuccess(:final user) => user,
            ProfileImageUploadFailure(:final user) => user,
            _ => null,
          };
          if (user != null) {
            final isUploading = state is ProfileImageUploadLoading;

            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  _buildProfileAvatar(
                    user.profileImage,
                    isUploading: isUploading,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    user.fullName,
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    user.role.toUpperCase(),
                    style: GoogleFonts.figtree(fontSize: 14, color: greyText),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    color: cardColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Row(
                      children: [
                        StatItem(
                          number: user.totalExpense.toStringAsFixed(0),
                          label: 'Total Expense',
                        ),
                        const StatDivider(),
                        StatItem(
                          number: user.pendingExpense.toStringAsFixed(0),
                          label: 'Pending Expense',
                        ),
                        const StatDivider(),
                        StatItem(
                          number: user.paidExpense.toStringAsFixed(0),
                          label: 'Paid Expense',
                        ),
                        const StatDivider(),
                        StatItem(
                          number: user.totalEnquiries.toString(),
                          label: 'Total Enquiries',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ProfileTile(
                    icon: Icons.person_outline,
                    title: 'Personal Information',
                    subtitle: 'Full name, Mobile no., Email id, DOB, UPI',
                    onTap: () {
                      final email = profileDocumentId;

                      if (email == null) {
                        return;
                      }

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              PersonalInfoScreen(user: user, email: email),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  ProfileTile(
                    header: 'Security Settings',
                    icon: Icons.vpn_key_outlined,
                    title: 'Change Password',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () => showLogoutDialog(context),
                    child: Container(
                      width: double.infinity,
                      color: cardColor,
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(Icons.logout, color: accentColor, size: 20),
                          SizedBox(width: 10),
                          Text(
                            'Log Out',
                            style: GoogleFonts.figtree(
                              color: accentColor,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          }
          if (state is ProfileNotFound) {
            return const Center(
              child: Text(
                'User data not found',
                style: TextStyle(color: Colors.white),
              ),
            );
          }

          if (state is ProfileFailure) {
            return Center(
              child: Text(
                state.message,
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}

class StatItem extends StatelessWidget {
  final String number;
  final String label;

  const StatItem({super.key, required this.number, required this.label});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            number,
            style: GoogleFonts.figtree(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: GoogleFonts.figtree(fontSize: 11, color: greyText),
          ),
        ],
      ),
    );
  }
}

class StatDivider extends StatelessWidget {
  const StatDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      height: 30,
      child: VerticalDivider(width: 1, thickness: 1, color: lineColor),
    );
  }
}

class ProfileTile extends StatelessWidget {
  final String? header;
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const ProfileTile({
    super.key,
    this.header,
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        color: cardColor,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (header != null) ...[
              Text(
                header!,
                style: GoogleFonts.figtree(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(icon, size: 22, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: GoogleFonts.figtree(
                          fontSize: 15,
                          color: Colors.white,
                        ),
                      ),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: GoogleFonts.figtree(
                            fontSize: 13,
                            color: greyText,
                          ),
                        ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: greyText),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class InfoField {
  final IconData icon;
  final String label;
  final TextInputType keyboardType;
  String value;
  final TextEditingController controller;

  InfoField(this.icon, this.label, this.value, this.keyboardType)
    : controller = TextEditingController(text: value);
}

class PersonalInfoScreen extends StatefulWidget {
  final UserModel user;
  final String email;

  const PersonalInfoScreen({
    super.key,
    required this.user,
    required this.email,
  });

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool isEditing = false;
  bool isSaving = false;

  late final List<InfoField> fields;

  @override
  void initState() {
    super.initState();

    final user = widget.user;

    fields = [
      InfoField(
        Icons.person_outline,
        'Full Name',
        user.fullName,
        TextInputType.name,
      ),
      InfoField(
        Icons.calendar_today_outlined,
        'Date of Birth',
        user.dob,
        TextInputType.datetime,
      ),
      InfoField(
        Icons.phone_outlined,
        'Mobile No.',
        user.mobile,
        TextInputType.phone,
      ),
      InfoField(
        Icons.alternate_email,
        'E-mail Id',
        user.email,
        TextInputType.emailAddress,
      ),

      InfoField(
        Icons.account_balance_wallet_outlined,
        'UPI ID',
        user.upiId,
        TextInputType.text,
      ),
    ];
  }

  @override
  void dispose() {
    for (final f in fields) {
      f.controller.dispose();
    }
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: GoogleFonts.figtree(fontSize: 14))),
    );
  }

  void startEditing() {
    setState(() => isEditing = true);
  }

  void cancelEditing() {
    FocusScope.of(context).unfocus();
    setState(() {
      for (final f in fields) {
        f.controller.text = f.value;
      }
      isEditing = false;
    });
  }

  void saveChanges() {
    if (isSaving) return;

    for (final field in fields) {
      if (field.controller.text.trim().isEmpty) {
        showMessage('${field.label} cannot be empty');
        return;
      }
    }

    final updatedData = <String, dynamic>{
      'Name': fields[0].controller.text.trim(),
      'DOB': fields[1].controller.text.trim(),
      'Mobile No': fields[2].controller.text.trim(),
      'UPI ID': fields[4].controller.text.trim(),
    };

    FocusScope.of(context).unfocus();

    setState(() {
      isSaving = true;
    });
    log("in save changes...");
    context.read<ProfileBloc>().add(
      UpdateUserDataEvent(email: widget.email, updatedData: updatedData),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ProfileBloc, ProfileState>(
      listener: (context, state) {
        if (state is ProfileUpdateSuccess) {
          setState(() {
            isSaving = false;
            isEditing = false;

            for (final field in fields) {
              field.value = field.controller.text.trim();
            }
          });

          showMessage('Profile updated successfully');
        } else if (state is ProfileUpdateFailure) {
          setState(() {
            isSaving = false;
          });

          showMessage(state.message);
        }
      },

      child: Scaffold(
        backgroundColor: const Color(0xFF070A1B),
        appBar: AppBar(
          backgroundColor: bgColor,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          title: Text(
            'Personal Information',
            style: GoogleFonts.figtree(fontSize: 17, color: Colors.white),
          ),
          actions: [
            IconButton(
              icon: Icon(
                isEditing ? Icons.close : Icons.edit_outlined,
                color: Colors.white,
              ),
              onPressed: isEditing ? cancelEditing : startEditing,
            ),
          ],
        ),
        body: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(top: 10),
                children: [
                  for (final f in fields)
                    InfoRow(field: f, isEditing: isEditing),
                ],
              ),
            ),
            if (isEditing)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: accentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      onPressed: isSaving ? null : saveChanges,
                      child: isSaving
                          ? const SizedBox(
                              height: 22,
                              width: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save',
                              style: GoogleFonts.figtree(fontSize: 16),
                            ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class InfoRow extends StatelessWidget {
  final InfoField field;
  final bool isEditing;

  const InfoRow({super.key, required this.field, required this.isEditing});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      color: cardColor,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: iconBoxColor,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(field.icon, size: 18, color: greyText),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  field.label,
                  style: GoogleFonts.figtree(fontSize: 14, color: greyText),
                ),
                const SizedBox(height: 4),
                if (isEditing && field.label != 'E-mail Id')
                  TextField(
                    controller: field.controller,
                    keyboardType: field.keyboardType,
                    maxLines: null,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 6),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: lineColor),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: blueColor),
                      ),
                    ),
                  )
                else
                  Text(
                    field.value,
                    style: GoogleFonts.figtree(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final newPassController = TextEditingController();
  final confirmPassController = TextEditingController();

  bool get hasLength =>
      newPassController.text.length >= 8 && newPassController.text.length <= 20;
  bool get hasUpper => newPassController.text.contains(RegExp(r'[A-Z]'));
  bool get hasLower => newPassController.text.contains(RegExp(r'[a-z]'));
  bool get hasNumber => newPassController.text.contains(RegExp(r'[0-9]'));
  bool get hasSymbol => newPassController.text.contains(RegExp(r'[!@#$&*]'));

  bool get canSubmit =>
      hasLength &&
      hasUpper &&
      hasLower &&
      hasNumber &&
      hasSymbol &&
      newPassController.text == confirmPassController.text;

  @override
  void dispose() {
    newPassController.dispose();
    confirmPassController.dispose();
    super.dispose();
  }

  Widget ruleText(String text, bool done) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 5,
            color: done ? Colors.green : Colors.white,
          ),
          const SizedBox(width: 8),
          Text(
            text,
            style: GoogleFonts.figtree(
              fontSize: 13,
              color: done ? Colors.green : Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF070A1B),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Navigator.pop(context),
                child: const CircleAvatar(
                  radius: 18,
                  backgroundColor: cardColor,
                  child: Icon(Icons.arrow_back, size: 18, color: Colors.white),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Change Password',
                style: GoogleFonts.figtree(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'New Password',
                style: GoogleFonts.figtree(fontSize: 13, color: greyText),
              ),
              TextField(
                controller: newPassController,

                obscureText: true,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.figtree(fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Enter your new password',
                  hintStyle: GoogleFonts.figtree(fontSize: 14, color: greyText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: blueColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: blueColor),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              ruleText('8-20 characters', hasLength),
              ruleText('At least one uppercase letter', hasUpper),
              ruleText('At least one lowercase letter', hasLower),
              ruleText('At least one number', hasNumber),
              ruleText('At least one special symbol (!@#\$&*)', hasSymbol),
              const SizedBox(height: 14),
              Text(
                'Confirm Password',
                style: GoogleFonts.figtree(fontSize: 13, color: greyText),
              ),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                style: GoogleFonts.figtree(fontSize: 15, color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Re-enter your password to confirm',
                  hintStyle: GoogleFonts.figtree(fontSize: 14, color: greyText),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: lineColor),
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(color: blueColor),
                  ),
                ),
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    disabledBackgroundColor: lineColor,
                    foregroundColor: Colors.white,
                    disabledForegroundColor: greyText,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: canSubmit ? () => Navigator.pop(context) : null,
                  child: Text(
                    'Submit',
                    style: GoogleFonts.figtree(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
