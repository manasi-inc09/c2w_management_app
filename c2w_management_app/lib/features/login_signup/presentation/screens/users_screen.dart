import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:c2w_management_app/features/login_signup/presentation/screens/signup.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});

  @override
  State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _searchController = TextEditingController();
  bool _isSearchOpen = false;
  String _searchQuery = '';

  String get _email => AuthRepository.authEmail ?? '';

  bool get _canAddUser =>
      _email.startsWith('superadmin_') || _email.startsWith('instructor_');

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = AppTheme();

    if (!_canAddUser) {
      return const Scaffold(
        backgroundColor: Color(0xFF070A1B),
        body: Center(
          child: Text(
            'Users list is only available for instructor and superadmin.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white70),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: theme.bodyBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: _isSearchOpen
            ? TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.figtree(color: Colors.white),
                cursorColor: Colors.white,
                decoration: InputDecoration(
                  hintText: 'Search name, email, role, or mobile',
                  hintStyle: GoogleFonts.figtree(color: Colors.white54),
                  border: InputBorder.none,
                ),
              )
            : Text(
                'Users',
                style: GoogleFonts.figtree(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: _isSearchOpen ? 'Close search' : 'Search users',
            onPressed: () {
              setState(() {
                _isSearchOpen = !_isSearchOpen;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            icon: Icon(_isSearchOpen ? Icons.close : Icons.search),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const SignUpScreen()),
          );
        },
        backgroundColor:  Colors.blue,
        icon: const Icon(Icons.person_add_alt_1, color: Colors.white),
        label: Text(
          'Add user',
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(gradient: theme.premiumGradient),
        child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _firestore.collection('UserData').snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: Color(0xFF7C6CFF)),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Unable to load users right now.',
                  style: GoogleFonts.figtree(color: Colors.white70),
                ),
              );
            }

            final allUsers =
                snapshot.data?.docs ??
                const <QueryDocumentSnapshot<Map<String, dynamic>>>[];

            if (allUsers.isEmpty) {
              return Center(
                child: Text(
                  'No users found.',
                  style: GoogleFonts.figtree(color: Colors.white70, fontSize: 16),
                ),
              );
            }

            final query = _searchQuery.trim().toLowerCase();
            final users = query.isEmpty
                ? allUsers
                : allUsers.where((doc) {
                    final user = doc.data();
                    return [
                      user['Name'],
                      user['Email'],
                      user['Role'],
                      user['Mobile No'],
                    ].any(
                      (value) =>
                          (value ?? '').toString().toLowerCase().contains(
                            query,
                          ),
                    );
                  }).toList();

            if (users.isEmpty) {
              return Center(
                child: Text(
                  'No users match your search.',
                  style: GoogleFonts.figtree(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: users.length,
              separatorBuilder: (context, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final user = users[index].data();
                final name = (user['Name'] ?? 'Unknown User').toString();
                final email = (user['Email'] ?? '').toString();
                final role = (user['Role'] ?? '').toString();
                final mobile = (user['Mobile No'] ?? '').toString();
                final profileImageUrl =
                    (user['profileImage'] ?? '').toString().trim();
                final initials = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

                return Container(
                  decoration: BoxDecoration(
                    color: const Color(0xFF12142A).withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: const Color(0xFF2A3357),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.blue,
                      child: profileImageUrl.isEmpty
                          ? Text(
                              initials,
                              style: GoogleFonts.figtree(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            )
                          : ClipOval(
                              child: Image.network(
                                profileImageUrl,
                                width: 48,
                                height: 48,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                    Text(
                                      initials,
                                      style: GoogleFonts.figtree(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                              ),
                            ),
                    ),
                    title: Text(
                      name,
                      style: GoogleFonts.figtree(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(
                          email,
                          style: GoogleFonts.figtree(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          role.isNotEmpty ? role.toUpperCase() : 'ROLE NOT AVAILABLE',
                          style: GoogleFonts.figtree(
                            color: const Color(0xFF00A3FF),
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    trailing: Text(
                      mobile.isNotEmpty ? mobile : 'N/A',
                      style: GoogleFonts.figtree(
                        color: Colors.white70,
                        fontSize: 11,
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
