import 'dart:developer';
import 'dart:io';

import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/Profile/data/repository/GetUserData.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/screens/dashboard_view.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileCtrl = TextEditingController();
  final _upiCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  String? _profileImagePath;
  String? _profileImageUrl;
  bool _isSaving = false;
  bool _requiresUpi = true;

  @override
  void initState() {
    super.initState();
    final authRole = (AuthRepository.authEmail ?? '').split('_').first;
    _requiresUpi = AuthRepository.roleRequiresUpi(authRole);
    _loadExistingProfile();
  }

  Future<void> _loadExistingProfile() async {
    final cleanedEmail = AuthRepository.cleanEmail(AuthRepository.authEmail);
    if (cleanedEmail.isEmpty) return;

    try {
      final document = await FirebaseFirestore.instance
          .collection('UserData')
          .doc(cleanedEmail)
          .get();

      if (!document.exists || document.data() == null) return;

      final data = document.data()!;
      final mobile = (data['Mobile No'] ?? '').toString();
      final upi = (data['UPI ID'] ?? '').toString();
      final dob = (data['DOB'] ?? '').toString();
      final profileImage = (data['profileImage'] ?? '').toString();
      final storedRole = data['Role']?.toString() ?? '';
      final authRole = (AuthRepository.authEmail ?? '').split('_').first;

      if (!mounted) return;

      setState(() {
        _requiresUpi = AuthRepository.roleRequiresUpi(
          storedRole.isNotEmpty ? storedRole : authRole,
        );
        if (mobile.trim().isNotEmpty) _mobileCtrl.text = mobile;
        if (upi.trim().isNotEmpty) _upiCtrl.text = upi;
        if (dob.trim().isNotEmpty) _dobCtrl.text = dob;
        if (profileImage.trim().isNotEmpty) _profileImageUrl = profileImage;
      });
    } catch (error, stackTrace) {
      log('Unable to load existing profile data: $error', stackTrace: stackTrace);
    }
  }

  String? _validateMobile(String? value) {
    final mobile = value?.trim() ?? '';
    if (mobile.isEmpty) return 'Mobile number is required';
    if (RegExp(r'\D').hasMatch(mobile)) {
      return 'Mobile number can contain digits only';
    }
    if (mobile.length != 10) return 'Mobile number must be 10 digits';
    if (!RegExp(r'^[6-9]\d{9}$').hasMatch(mobile)) {
      return 'Mobile number must start with 6 to 9';
    }
    return null;
  }

  String? _validateUpi(String? value) {
    final upi = value?.trim() ?? '';
    if (upi.isEmpty) return 'UPI ID is required';
    if (!RegExp(r'^[\w.-]{2,}@[\w.-]{2,}$').hasMatch(upi)) {
      return 'Enter a valid UPI ID (example: name@upi)';
    }
    return null;
  }

  String? _validateDob(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Date of birth is required';
    }
    return null;
  }

  @override
  void dispose() {
    _mobileCtrl.dispose();
    _upiCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickProfileImage() async {
    final pickedFile = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );

    if (pickedFile == null || !mounted) return;

    setState(() {
      _profileImagePath = pickedFile.path;
    });
  }

  Future<void> _pickDob() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      helpText: 'Select date of birth',
      barrierColor: Colors.black54,
    );

    if (pickedDate == null) return;

    final formattedDate = '${pickedDate.day.toString().padLeft(2, '0')}/'
        '${pickedDate.month.toString().padLeft(2, '0')}/${pickedDate.year}';
    _dobCtrl.text = formattedDate;
  }

  Future<void> _saveProfile() async {
    final cleanedEmail = AuthRepository.cleanEmail(AuthRepository.authEmail);
    if (cleanedEmail.isEmpty) {
      _showMessage('Could not identify user account. Please login again.');
      return;
    }

    final hasExistingProfileImage =
        (_profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty) ||
        (_profileImagePath != null && _profileImagePath!.trim().isNotEmpty);

    final hasMobile = _mobileCtrl.text.trim().isNotEmpty;
    final hasUpi = !_requiresUpi || _upiCtrl.text.trim().isNotEmpty;
    final hasDob = _dobCtrl.text.trim().isNotEmpty;

    if (!hasMobile || !hasUpi || !hasDob || !hasExistingProfileImage) {
      final missingFields = <String>[];
      if (!hasMobile) missingFields.add('Mobile Number');
      if (!hasUpi) missingFields.add('UPI ID');
      if (!hasDob) missingFields.add('Date of Birth');
      if (!hasExistingProfileImage) missingFields.add('Profile Picture');

      _showMessage(
        'Missing required fields: ${missingFields.join(', ')}',
      );
      return;
    }

    if (!_formKey.currentState!.validate()) {
      _showMessage('Please correct the highlighted fields.');
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedData = <String, dynamic>{
        'Mobile No': _mobileCtrl.text.trim(),
        'DOB': _dobCtrl.text.trim(),
        if (_requiresUpi) 'UPI ID': _upiCtrl.text.trim(),
      };

      await FirebaseFirestore.instance
          .collection('UserData')
          .doc(cleanedEmail)
          .update(updatedData);

      if (_profileImagePath != null && _profileImagePath!.trim().isNotEmpty) {
        await GetUserData().updateProfileImage(
          email: cleanedEmail,
          filePath: _profileImagePath!,
        );
      }

      if (!mounted) return;

      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const DashboardView()),
        (route) => false,
      );
    } catch (error, stackTrace) {
      log('Profile completion failed: $error', stackTrace: stackTrace);
      _showMessage('Unable to save profile details. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.figtree(fontSize: 13)),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();
    final hasAnySavedValue =
        _mobileCtrl.text.trim().isNotEmpty ||
        (_requiresUpi && _upiCtrl.text.trim().isNotEmpty) ||
        _dobCtrl.text.trim().isNotEmpty ||
        (_profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty);

    return Scaffold(
      backgroundColor: theme.bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Complete your profile',
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontWeight: FontWeight.w700,
          ),
        ),
        automaticallyImplyLeading: false,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.premiumGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    hasAnySavedValue
                        ? 'Complete your remaining profile details.'
                        : 'Before you continue, please fill in your details.',
                    style: GoogleFonts.figtree(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    hasAnySavedValue
                        ? 'Only the remaining fields are required to unlock the app.'
                        : 'These fields are required to unlock the app.',
                    style: GoogleFonts.figtree(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Center(
                    child: GestureDetector(
                      onTap: _pickProfileImage,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: const Color(0xFF12142A),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: const Color(0xFF7C6CFF),
                            width: 2,
                          ),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x33000000),
                              offset: Offset(0, 10),
                              blurRadius: 18,
                            ),
                          ],
                        ),
                        child: _profileImagePath != null
                            ? ClipOval(
                                child: Image.file(
                                  File(_profileImagePath!),
                                  fit: BoxFit.cover,
                                  width: 110,
                                  height: 110,
                                ),
                              )
                            : _profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty
                                ? ClipOval(
                                    child: Image.network(
                                      _profileImageUrl!,
                                      fit: BoxFit.cover,
                                      width: 110,
                                      height: 110,
                                      errorBuilder: (_, _, _) => const Icon(
                                        Icons.person_rounded,
                                        color: Color(0xFF7C6CFF),
                                        size: 42,
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.person_add_alt_1,
                                    color: Color(0xFF7C6CFF),
                                    size: 42,
                                  ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      _profileImageUrl != null && _profileImageUrl!.trim().isNotEmpty
                          ? 'Profile picture available'
                          : 'Add profile picture',
                      style: GoogleFonts.figtree(
                        color: Colors.white70,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  _buildFieldLabel('Mobile Number'),
                  TextFormField(
                    controller: _mobileCtrl,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: _validateMobile,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Enter your mobile number',
                      hintStyle: TextStyle(color: Color(0xFF9A9DB5)),
                    ),
                  ),
                  if (_requiresUpi) ...[
                    const SizedBox(height: 20),
                    _buildFieldLabel('UPI ID'),
                    TextFormField(
                      controller: _upiCtrl,
                      validator: _validateUpi,
                      style: const TextStyle(color: Colors.white),
                      decoration: const InputDecoration(
                        hintText: 'Enter your UPI ID',
                        hintStyle: TextStyle(color: Color(0xFF9A9DB5)),
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _buildFieldLabel('Date of Birth'),
                  TextFormField(
                    controller: _dobCtrl,
                    readOnly: true,
                    onTap: _pickDob,
                    validator: _validateDob,
                    style: const TextStyle(color: Colors.white),
                    decoration: const InputDecoration(
                      hintText: 'Select your date of birth',
                      hintStyle: TextStyle(color: Color(0xFF9A9DB5)),
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _isSaving ? null : _saveProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C6CFF),
                        disabledBackgroundColor: const Color(0xFF2A2D45),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: _isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              'Save & Continue',
                              style: GoogleFonts.figtree(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
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

  Widget _buildFieldLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: GoogleFonts.figtree(
          color: const Color(0xFF9A9DB5),
          fontSize: 12,
        ),
      ),
    );
  }
}
