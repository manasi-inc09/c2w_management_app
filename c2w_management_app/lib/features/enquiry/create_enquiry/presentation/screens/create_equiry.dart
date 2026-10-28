import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryBloc.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryEvent.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryState.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:toastification/toastification.dart';

void main() {
  runApp(const CreateEquiry());
}

class CreateEquiry extends StatefulWidget {
  const CreateEquiry({super.key});

  @override
  State<CreateEquiry> createState() => _CreateEquiryState();
}

class _CreateEquiryState extends State<CreateEquiry> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController clgController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  final List<String> colleges = [
    "Abhinav College of Engineering",
    "Bharati Vidyapeeth Deemed University College of Engineering",
    "Dr. D. Y. Patil Institute of Technology",
    "JSPM's Bhivarabai Sawant Institute of Technology and Research",
    "JSPM's Narhe Technical Campus (NTC)",
    "Sinhgad Institute of Technology and Science (SITS)",
    "Sinhgad Institute of Management and Computer Application (SIMCA)",
    "SKN Sinhgad Institute of Technology and Science, Lonavala",
    "Zeal College of Engineering and Research (ZCOER)",
    "MIT Pune",
    "VIT Pune",
    "Symbiosis",
    "Other",
  ];
  final List<String> sources = ['Website', 'YouTube', 'Instagram'];
  String? selectedCollege;
  String? selectedSource;

  final List<String> batches = [
    'Flutter',
    'Java FullStack',
    'Java',
    'Python',
    'C,C++,DSA',
    "AI",
  ];
  final List<String> selectedBatches = [];
  final List<String> modes = ['Offline', 'Online', 'Recorded'];
  String? selectedMode;
  String? selectedReference;
  List<String> _referenceOptions = const [];
  bool _referencesLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReferences();
  }

  Future<void> _loadReferences() async {
    final currentEmail = AuthRepository.authEmail;
    try {
      final snapshot = await FirebaseFirestore.instance.collection('UserData').get();
      final references = <String>[];
      String? ownName;
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final email = (data['Email'] ?? doc.id).toString();
        final role = (data['Role'] ?? '').toString().toLowerCase();
        final name = (data['Name'] ?? email).toString().trim();
        if (currentEmail != null && (doc.id == currentEmail || email == currentEmail)) {
          ownName = name;
        }
        if (role == 'teamlead' || role == 'mentor' || role == 'instructor') {
          if (name.isNotEmpty) references.add(name);
        }
      }
      final own = ownName == null ? 'Own' : 'Own ($ownName)';
      references.remove(own);
      references.remove(ownName);
      references.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      if (!mounted) return;
      setState(() {
        _referenceOptions = [own, ...references.toSet()];
        selectedReference = own;
        _referencesLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _referenceOptions = ['Own'];
        selectedReference = 'Own';
        _referencesLoading = false;
      });
    }
  }

  Future<void> _searchReference() async {
    final selection = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        var query = '';
        return StatefulBuilder(builder: (context, setDialogState) {
          final options = _referenceOptions.where((name) => name.toLowerCase().contains(query.toLowerCase())).toList();
          return AlertDialog(
            backgroundColor: const Color(0xFF161B2E),
            title: const Text('Search reference', style: TextStyle(color: Colors.white)),
            content: SizedBox(
              width: MediaQuery.sizeOf(context).width * .8,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                  autofocus: true,
                  style: const TextStyle(color: Colors.white),
                  decoration: const InputDecoration(hintText: 'Search name', hintStyle: TextStyle(color: Colors.white54), prefixIcon: Icon(Icons.search, color: Colors.white54)),
                  onChanged: (value) => setDialogState(() => query = value),
                ),
                const SizedBox(height: 8),
                Flexible(child: options.isEmpty
                    ? const Center(child: Text('No matching references', style: TextStyle(color: Colors.white70)))
                    : ListView.builder(shrinkWrap: true, itemCount: options.length, itemBuilder: (_, index) => ListTile(title: Text(options[index], style: const TextStyle(color: Colors.white)), onTap: () => Navigator.pop(dialogContext, options[index])))),
              ]),
            ),
          );
        });
      },
    );
    if (selection != null) setState(() => selectedReference = selection);
  }

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    clgController.dispose();
    feedbackController.dispose();
    refController.dispose();
    sourceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final horizontalPadding = screenWidth < 360 ? 14.0 : 20.0;
    final isLoading =
        context.watch<AddEnquiryBloc>().state is AddEnquiryLoading;
    return BlocListener<AddEnquiryBloc, AddEnquiryState>(
      listener: (context, state) {
        if (state is AddEnquirySuccess) {
          toastification.show(
            context: context,
            type: ToastificationType.success,
            style: ToastificationStyle.flat,
            title: Text(
              state.wasRepeatEnquiry
                  ? 'New enquiry added; previous enquiry moved to history'
                  : 'Enquiry Successfully Created',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 18,
                fontWeight: FontWeight.w400,
              ),
            ),
            alignment: Alignment.topCenter,
            autoCloseDuration: const Duration(seconds: 2),
            animationDuration: const Duration(milliseconds: 400),
            primaryColor: Colors.green,
            backgroundColor: const Color.fromRGBO(255, 255, 255, 0.08),
            foregroundColor: Colors.white,
            borderSide: const BorderSide(color: Colors.white12),
            borderRadius: BorderRadius.circular(10),
            showProgressBar: false,
            closeButton: const ToastCloseButton(
              showType: CloseButtonShowType.none,
            ),
            dragToClose: true,
          );

          Navigator.of(context).pop();
        }

        if (state is AddEnquiryFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF070A1B),
        appBar: AppBar(
          backgroundColor: const Color(0xFF070A1B),
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.arrow_back),
            color: Colors.white,
          ),
          title: Center(
            child: Text(
              "Create New Enquiry",
              style: GoogleFonts.figtree(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
          ),
        ),
        body: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
          child: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 720), child: Form(key: _formKey, child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10),
              Text(
                "Student Name",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: nameController,
                style: TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty ? 'Enter student name' : null,
                decoration: InputDecoration(
                  hintText: 'Type here student name',
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),

              //mobile no
              SizedBox(height: 10),
              Text(
                "Mobile No",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: mobileController,
                style: TextStyle(color: Colors.white),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly, LengthLimitingTextInputFormatter(10)],
                validator: (value) => value == null || !RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim()) ? 'Enter a valid 10-digit mobile number' : null,
                decoration: InputDecoration(
                  hintText: '000 0000 000',
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),

              ///clg
              ///
              ///
              SizedBox(height: 10),
              Text(
                "College Name",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCollege,
                isExpanded: true, // Prevents horizontal overflow
                dropdownColor: const Color(0xFF161B2E),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                hint: const Text(
                  'Select college',
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.white54),
                ),
                validator: (value) => value == null ? 'Select a college' : null,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 14,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                ),
                items: colleges.map((college) {
                  return DropdownMenuItem<String>(
                    value: college,
                    child: Text(
                      college,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }).toList(),
                selectedItemBuilder: (context) {
                  return colleges.map((college) {
                    return Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        college,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList();
                },
                onChanged: (value) {
                  setState(() {
                    selectedCollege = value;
                  });
                },
              ),
              const SizedBox(height: 10),
              Text(
                "Interested Batch",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: batches.map((batch) {
                  final isSelected = selectedBatches.contains(batch);
                  return FilterChip(
                    label: Text(batch),
                    selected: isSelected,
                    labelStyle: const TextStyle(color: Colors.white),
                    backgroundColor: const Color(0xFF161B2E),
                    selectedColor: const Color.fromRGBO(5, 164, 255, 1),
                    checkmarkColor: Colors.white,
                    side: const BorderSide(color: Colors.white24),
                    onSelected: (value) {
                      setState(() {
                        if (value) {
                          selectedBatches.add(batch);
                        } else {
                          selectedBatches.remove(batch);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              if (selectedBatches.isEmpty) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Select at least one batch', style: TextStyle(color: Colors.redAccent, fontSize: 12))),

              SizedBox(height: 10),
              Text(
                "Mode",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              SegmentedButton<String>(
                expandedInsets: EdgeInsets.zero,
                emptySelectionAllowed: true,
                showSelectedIcon: false,
                segments: const [
                  ButtonSegment(value: 'Offline', label: Text('Offline')),
                  ButtonSegment(value: 'Online', label: Text('Online')),
                  ButtonSegment(value: 'Recorded', label: Text('Recorded')),
                ],
                selected: selectedMode == null ? {} : {selectedMode!},
                onSelectionChanged: (newSelection) {
                  setState(() {
                    selectedMode = newSelection.isEmpty
                        ? null
                        : newSelection.first;
                  });
                },
                style: SegmentedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  selectedBackgroundColor: const Color.fromRGBO(5, 164, 255, 1),
                  selectedForegroundColor: Colors.white,
                  side: const BorderSide(
                    color: Colors.white24,
                  ), // border and dividers
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: GoogleFonts.figtree(fontSize: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              if (selectedMode == null) const Padding(padding: EdgeInsets.only(top: 6), child: Text('Select a mode', style: TextStyle(color: Colors.redAccent, fontSize: 12))),

              SizedBox(height: 10),
              Text(
                "Student Feedback",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: feedbackController,
                style: TextStyle(color: Colors.white),
                maxLines: 4,
                maxLength: 150,
                keyboardType: TextInputType.multiline,
                decoration: InputDecoration(
                  hintText: 'Type here...',
                  hintStyle: const TextStyle(color: Colors.white54),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 10),
              Text(
                "Reference By",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              InkWell(
                onTap: _referencesLoading ? null : _searchReference,
                child: InputDecorator(
                  decoration: InputDecoration(
                    hintText: 'Select or search reference',
                    suffixIcon: _referencesLoading ? const SizedBox(width: 20, height: 20, child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator(strokeWidth: 2))) : const Icon(Icons.search, color: Colors.white70),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                    border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                ),
                  child: Text(selectedReference ?? 'Select reference', style: TextStyle(color: selectedReference == null ? Colors.white54 : Colors.white)),
                ),
              ),

              SizedBox(height: 10),
              Text(
                "Enquiry Source",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),

              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedSource,
                dropdownColor: const Color(0xFF161B2E),
                iconEnabledColor: Colors.white,
                style: const TextStyle(color: Colors.white),
                hint: const Text(
                  'Select Source',
                  style: TextStyle(color: Colors.white54),
                ),
                validator: (value) => value == null ? 'Select an enquiry source' : null,
                decoration: InputDecoration(
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Colors.white),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Colors.blue,
                      width: 1.5,
                    ),
                  ),
                ),
                items: sources
                    .map(
                      (sources) => DropdownMenuItem(
                        value: sources,
                        child: Text(sources),
                      ),
                    )
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedSource = value;
                  });
                },
              ),
              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  child: isLoading
                      ? const SizedBox(
                          height: 22,
                          width: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          "Create",
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),

                  onPressed: isLoading
                      ? null
                      : () {
                          if (!_formKey.currentState!.validate() || selectedBatches.isEmpty || selectedMode == null || selectedReference == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Please fill all required fields',
                                ),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                                behavior: SnackBarBehavior.floating,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            );

                            return;
                          }

                          context.read<AddEnquiryBloc>().add(
                            CreateEnquiryEvent(
                              studentName: nameController.text.trim(),
                              mobileNo: mobileController.text.trim(),
                              collegeName: selectedCollege!,
                              interestedBatches: List<String>.from(
                                selectedBatches,
                              ),
                              mode: selectedMode!,
                              studentFeedback: feedbackController.text.trim(),
                              referenceBy: selectedReference!,
                              enquirySource: selectedSource!,
                              enquiryAddedBy: AuthRepository.authEmail!,
                              enquiryType: "General",
                            ),
                          );
                        },

                  style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                ),
              ),
              SizedBox(height: 20),
            ],
          ))),
        ),
      ),
    )
    );

  }
}
