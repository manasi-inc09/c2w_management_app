import 'package:flutter/material.dart';
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
  TextEditingController nameController = TextEditingController();
  TextEditingController mobileController = TextEditingController();
  TextEditingController clgController = TextEditingController();
  TextEditingController feedbackController = TextEditingController();
  TextEditingController refController = TextEditingController();
  TextEditingController sourceController = TextEditingController();

  final List<String> colleges = [
    'College of Engineering Pune',
    'MIT Pune',
    'VIT Pune',
    'Symbiosis',
    'Other',
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
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
 
        child: Column(
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
            TextField(
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                hintText: 'Type here student name',
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
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
            TextField(
              controller: mobileController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: '000 0000 000',
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
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
              dropdownColor: const Color(0xFF161B2E),
              iconEnabledColor: Colors.white,
              style: const TextStyle(color: Colors.white),
              hint: const Text(
                'Select college',
                style: TextStyle(color: Colors.white54),
              ),
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              items: colleges
                  .map(
                    (college) =>
                        DropdownMenuItem(value: college, child: Text(college)),
                  )
                  .toList(),
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
            TextField(
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
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
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
            TextField(
              controller: mobileController,
              style: TextStyle(color: Colors.white),
              keyboardType: TextInputType.text,
              decoration: InputDecoration(
                hintText: 'Type here...',
                hintStyle: const TextStyle(color: Colors.white54),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
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
              decoration: InputDecoration(
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.white),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                ),
              ),
              items: sources
                  .map(
                    (sources) =>
                        DropdownMenuItem(value: sources, child: Text(sources)),
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
                child: Text(
                  "Create",
                  style: GoogleFonts.figtree(
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  ),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                  toastification.show(
                    context: context,
                    type: ToastificationType.success,
                    style: ToastificationStyle.flat,
                    title: Text(
                      "✅ Enquiry Successfully Created",
                      style: GoogleFonts.figtree(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                    ),
                    alignment: Alignment.topCenter,
                    autoCloseDuration: const Duration(seconds: 2),
                    animationDuration: const Duration(milliseconds: 400),
                    primaryColor: Colors.green,
                    backgroundColor: const Color.fromRGBO(255,255,255,0.08),
                    foregroundColor: Colors.white,
                    borderSide: const BorderSide(color: Colors.white12),
                    borderRadius: BorderRadius.circular(10),
                    showProgressBar: false,
                    closeButton: const ToastCloseButton(
                      showType: CloseButtonShowType.none,
                    ),
                    dragToClose: true,
                  );
                },
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              ),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
