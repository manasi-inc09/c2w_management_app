import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() => runApp(const MyApp());

const Color bgColor = Color(0xFF0A0F24);
const Color cardColor = Color(0xFF141B34);
const Color iconBoxColor = Color(0xFF1F2742);
const Color lineColor = Color(0xFF2A3150);
const Color accentColor = Color(0xFFEF4565);
const Color blueColor = Color(0xFF3B82F6);
const Color greyText = Color(0xFF8A90A6);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final base = ThemeData.dark();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: bgColor,
        // textTheme: GoogleFonts.figtreeTextTheme(base.textTheme),
        // primaryTextTheme: GoogleFonts.figtreeTextTheme(base.primaryTextTheme),
      ),
      home: const ProfileScreen(),
    );
  }
}

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  void showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: cardColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Logout Account?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Are you sure you want to logout this account?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: greyText),
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
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Logout', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        leading: const Icon(Icons.arrow_back),
        title: const Text('Profile', style: TextStyle(fontSize: 18)),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            const CircleAvatar(
              radius: 35,
              backgroundColor: Colors.green,
              backgroundImage: AssetImage('assets/images/sales_admin/profile.png'),
            ),
            const SizedBox(height: 10),
            const Text(
              'Manasi Jadhav',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Text('Admin', style: TextStyle(fontSize: 14, color: greyText)),
            const SizedBox(height: 20),
            Container(
              color: cardColor,
              padding: const EdgeInsets.symmetric(vertical: 14),
              child: Row(
                children: const [
                  StatItem(number: '10000', label: 'Total Expense'),
                  StatDivider(),
                  StatItem(number: '3500', label: 'Pending Expense'),
                  StatDivider(),
                  StatItem(number: '6500', label: 'Paid Expense'),
                  StatDivider(),
                  StatItem(number: '100', label: 'Total Enquires'),
                ],
              ),
            ),
            const SizedBox(height: 8),
            ProfileTile(
              icon: Icons.person_outline,
              title: 'Personal Information',
              subtitle: 'Full name, Mobile no., Email id, DOB, Address, UPI',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const PersonalInfoScreen(),
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
                  children: const [
                    Icon(Icons.logout, color: accentColor, size: 20),
                    SizedBox(width: 10),
                    Text(
                      'Log Out',
                      style: TextStyle(color: accentColor, fontSize: 16),
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
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 11, color: greyText),
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
              Text(header!, style: const TextStyle(fontSize: 14, color: greyText)),
              const SizedBox(height: 12),
            ],
            Row(
              children: [
                Icon(icon, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: const TextStyle(fontSize: 15)),
                      if (subtitle != null)
                        Text(
                          subtitle!,
                          style: const TextStyle(fontSize: 11, color: greyText),
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
  const PersonalInfoScreen({super.key});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  bool isEditing = false;

  final List<InfoField> fields = [
    InfoField(Icons.person_outline, 'Full Name', 'Manasi Jadhav', TextInputType.name),
    InfoField(Icons.calendar_today_outlined, 'Date of Birth', '09 June 2004', TextInputType.datetime),
    InfoField(Icons.phone_outlined, 'Mobile No.', '+91 9322762831', TextInputType.phone),
    InfoField(Icons.alternate_email, 'E-mail Id', 'm@gmail.com', TextInputType.emailAddress),
    InfoField(
      Icons.location_on_outlined,
      'Address',
      '3rd Floor, Walhekar Properties, Core2web Technologies, Narhe, above HDFC Bank, Narhe, Pune',
      TextInputType.multiline,
    ),
    InfoField(Icons.alternate_email, 'UPI ID', '9322762831@ybl', TextInputType.text),
  ];

  @override
  void dispose() {
    for (final f in fields) {
      f.controller.dispose();
    }
    super.dispose();
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text, style: const TextStyle(fontSize: 14))),
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
    for (final f in fields) {
      if (f.controller.text.trim().isEmpty) {
        showMessage('${f.label} cannot be empty');
        return;
      }
    }
    FocusScope.of(context).unfocus();
    setState(() {
      for (final f in fields) {
        f.value = f.controller.text.trim();
        f.controller.text = f.value;
      }
      isEditing = false;
    });
    showMessage('Profile updated');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Personal Information', style: TextStyle(fontSize: 17)),
        actions: [
          IconButton(
            icon: Icon(isEditing ? Icons.close : Icons.edit_outlined),
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
                for (final f in fields) InfoRow(field: f, isEditing: isEditing),
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
                    onPressed: saveChanges,
                    child: const Text('Save', style: TextStyle(fontSize: 16)),
                  ),
                ),
              ),
            ),
        ],
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
                Text(field.label, style: const TextStyle(fontSize: 12, color: greyText)),
                const SizedBox(height: 4),
                if (isEditing)
                  TextField(
                    controller: field.controller,
                    keyboardType: field.keyboardType,
                    maxLines: null,
                    style: const TextStyle(fontSize: 14),
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
                  Text(field.value, style: const TextStyle(fontSize: 14)),
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
          Icon(Icons.circle, size: 5, color: done ? Colors.green : Colors.white),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
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
                  child: Icon(Icons.arrow_back, size: 18),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Change Password',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              const Text('New Password', style: TextStyle(fontSize: 13, color: greyText)),
              TextField(
                controller: newPassController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Enter your new password',
                  hintStyle: TextStyle(fontSize: 14, color: greyText),
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
              const Text('Confirm Password', style: TextStyle(fontSize: 13, color: greyText)),
              TextField(
                controller: confirmPassController,
                obscureText: true,
                onChanged: (_) => setState(() {}),
                style: const TextStyle(fontSize: 15),
                decoration: const InputDecoration(
                  hintText: 'Re-enter your password to confirm',
                  hintStyle: TextStyle(fontSize: 14, color: greyText),
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
                  child: const Text('Submit', style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}