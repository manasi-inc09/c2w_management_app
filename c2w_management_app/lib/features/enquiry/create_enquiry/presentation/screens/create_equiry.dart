import 'dart:async';

import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryBloc.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryEvent.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/presentation/bloc/AddEnquiryState.dart';
import 'package:c2w_management_app/features/enquiry/create_enquiry/data/repository/AddEnquiry.dart';
import 'package:c2w_management_app/features/login_signup/data/repository/Auth_Repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
  Timer? _mobileLookupTimer;
  int _mobileLookupRequest = 0;
  bool _isLookingUpMobile = false;
  String? _mobileLookupError;
  List<Map<String, String>> _mobileMatches = [];

  final List<String> colleges = [
    "SKNCOE Smt. Kashibai Navale College of Engineering, Vadgaon, Pune",
    "Zeal College of Engineering & Research, Narhe, Pune",
    "SITS Sinhgad Institute of Technology & Science Narhe, Pune",
    "SCOE Sinhgad College of Engineering, Vadgaon",
    "JSPM NTC RSSOE, Narhe, Pune",
    "Tssm's BSCOER, Narhe",
    "NBNSTIC NBN Sinhgad Technical Institute Campus, Pune",
    "RMDSSOE Sinhgad School of Engineering, Warje, Pune",
    "SAE Sinhgad Academy of Engineering, Kondhawa",
    "NBN Sinhgad School Of Engineering, Pune",
    "VIT Vishwakarma Institute of Technology, Pune",
    "SCOS Sinhgad College Of Science, Ambegaon, Pune",
    "Trinity Academy of Engineering, Pune",
    "KJ College of Engineering & Management Research",
    "PVPIT Padmabhooshan Vasantdada Patil Institute of Technology, Bavdhan",
    "SIT Sinhgad Institute of Technology & Science, Lonavala",
    "SIOM Sinhgad Institute of Management, Pune",
    "Abhinav Education Society's College of Engineering & Technology, Pune",
    "Dr DY Patil Institute of Technology, Pimpri",
    "PVG Pune Vidyarthi Grihas College of Engineering & Technology, Pune",
    "PES's Modern College of Engineering, Pune",
    "JSPM's Jayawantrao Sawant college of Engineering, Hadapsar, Pune",
    "VIIT Vishwakarma Institute Of Information Technology Pune",
    "MMCOE Marathwada MitraMandal's College of Engineering",
    "Trinity College of Engineering and Technology",
    "JSPM's Bhivarabai Sawant Institute of Technology & Research, Wagholi, Pune",
    "Rajgad Dnyanpeeth Technical Campus College of Engineering",
    "PICT Pune Institute of Computer Technology, Pune",
    "AISSMS College of Engineering",
    "JSPM's RSCOE Rajarshi shahu college of engineering, Tathawade, Pune",
    "Modern College Of Sceince, Shivajinagar, Pune",
    "Navsahyadri Group of Institutes - College of Engineering",
    "Bharati Vidyapeeth College of Engineering, Pune",
    "Bharati Vidyapeeth's College of Engineering for Women",
    "FC Fergusson College, Pune",
    "Modern Education Society's College of Engineering, Pune",
    "SARHAD COLLAGE, KATRAJ, Pune",
    "Anantrao Pawar College Of Engineering and Research",
    "GH Raisoni College of Engineering & Management, Wagholi, Pune",
    "MIT WPU Kothrud, Pune",
    "PCCOE Pimpri Chinchwad College of Engineering PCCOE Akurdi",
    "Ajeenkya DY Patil University - School of Engineering",
    "DY Patil Institute of Engineering & Technology, Akurdi",
    "MIT Academy of Engineering, Alandi Road, Pune, Maharashtra",
    "Siddhant College of Engineering, Sudumbare, Mawal, Pune",
    "Sinhgad College of arts and Commerce, Warje",
    "SVCP Sou. Venutai Chavan Polytechnic Pune",
    "H V Desai College, Pune",
    "Sanjivani College of Engineering Kopargaon",
    "Amrutvahini College of Engineering, Sangamner",
    "MES Wadia College of Engineering Pune",
    "SKN SINHGAD INSTITUTE OF TECHNOLOGY AND SCIENCE -[SKNSITS] LONAVALA, PUNE",
    "Trinity Institute of Technology & Research",
    "Bharati Vidyapeeth collegr of enginnering, Lavale, Pune",
    "ISBM School of Technology",
    "JSPM's Imperial College of Engineering & Research, Wagholi, Pune",
    "PCET's Nutan Maharashtra Institute of Engineering & Technology",
    "Sandip Institute of Technology & Research Center, Nashik",
    "AISSMS Institute of Information Technology",
    "GS Moze College of Eng. Balewadi, Pune",
    "Keystone Group of Institutions - College of Engineering",
    "Rajarambapu Institute of Technology",
    "Universal College of Engineering & Research - Pune",
    "Bharti College of Engineering & Technology",
    "NK Orchid College of Engineering & Technology",
    "PCCOE Pimpri Chinchwad College of Engineering, Ravet",
    "Pratibha College of Commerce and Computer Studies, Chinchwad, Pune.",
    "Pravara Rural Engineering College, Loni",
    "Savitribai Phule Pune University",
    "SVKM’s Institute Of Technology, Dhule",
    "Vishwakarma College of Arts Commerce And Science, Pune",
    "Dr Vithalrao Vikhe Patil College of Engineering, Ahmednagar",
    "DY Patil College of Engineering & Technology, Kolhapur",
    "MIT ADT, Loni Kalbhor, Pune, Maharashtra",
    "MIT College of Engineering & Management",
    "Pune District Education Association's (PDEA's) College of Engineering",
    "Samaj Bhushan Baburao alias Appasaheb Jedhe Arts, Commerce & Science College, Pune.",
    "Suryadatta College of Management, Information Research & Technology (SCMIRT)",
    "SVERI'S COLLEGE OF ENGINEERING, PANDHARPUR",
    "SVPM's Institute of Technology & Engineering",
    "Tatyasaheb Kore Institute of Engineering & Technology - Waranagar",
    "Alard College of Engineering & Management",
    "Annasaheb Dange College Engineering & Technology",
    "Bharati Vidyapeeth's College of Engineering, Kolhapur",
    "COEP College of Engineering, Pune",
    "Cummins College of Engineering for Women, Pune",
    "Dattakala Group of Institute, Faculty of Engineering, Chincholi, Daund",
    "GH Raisoni Institute of Engineering and Business Management, Jalgaon",
    "Indira College of Engineering & Management",
    "Jaikranti College Of Computer Science & Managment Studies, Katraj",
    "Maharashtra Institute of Technology",
    "Matoshri College of Engineering & Research Centre",
    "MMCC Marathwada Mitramandal college of commerce, Deccan, Pune",
    "New arts commerce and science college, Ahamadnagar",
    "ASM IBMR, Pimpri-Chinchwad",
    "COCSIT College of Computer Science and Information Technology, Latur",
    "Datta Meghe College of Engineering",
    "Dhole Patil College of Engineering",
    "Dr JJ Magdum College of Engineering",
    "GH Raisoni College of Engineering, Nagpur",
    "Government Polytechnic, Pune",
    "KIT College of Engineering",
    "KK Wagh Institute of Engineering Education & Research, Nashik",
    "Marathwada Mitra Mandals Institute of Technology",
    "MES Abasaheb Garware College, Pune",
    "PR Pote Patil College of Engineering & Technology, Amravati",
    "Prof Ram Meghe Institute of Technology & Research",
    "RMD Engineering College, Chennai",
    "Samarth Group of Institutions - College of Engineering",
    "University of Mumbai",
    "Vidya Pratishthan's College of Engineering",
    "Vidya Pratishthan's Kamalnayan Bajaj Institute of Engineering and Technology",
    "AAER's Asian College of Science and Commerce, Narhe, Pune",
    "Adsul's Technical Campus, Ahilyanagar",
    "Annasaheb Magar Mahavidyalay, Hadapsar, Pune",
    "Babasaheb Naik College of Engineering",
    "Dada Patil College, Karjat",
    "Dr. Sudhakarrao Jadhavar Arts, Commerce and Science College, Pune",
    "GH Raisoni Institute of Engineering & Technology, Nagpur",
    "Government College of Engineering, Jalgaon",
    "GS Mandal's Maharashtra Institute of Technology, Chhatrapati Sambhaji Nagar",
    "Karmayogi Engineering College",
    "KJ Institute of Engineering & Technology",
    "MGM's College of Engineering, Nanded",
    "New Horizon Institute of Technology & Management",
    "Nowrosjee Wadia College, Pune",
    "Padmabhushan Vasantdada Patil Pratishthan's College of Engineering",
    "SHIVNAGAR VIDYA PRASARAK MANDAL'S COLLEGE OF ENGINEERING",
    "Shree Hanuman Vyayam Prasarak Mandal College of Engineering & Technology, Amaravati",
    "Sipna College of Engineering & Technology",
    "SKN Sinhgad College of engineering, Korti, Pandharpur",
    "spcoet Sharadchandra Pawar College of Engineering and Technology, Someshwarnagar, baramati",
    "Walchand College of Engineering",
    "Aditya College of Engineering & Technology",
    "AMGOI Ashokrao Mane Group of Institutions, Vathar",
    "Angadi Institute of Technology & Management",
    "Anuradha Engineering College",
    "Bapusaheb Shivajirao Deore College of Engineering",
    "Chhatrapati Shivaji Institute of Technology",
    "Chhatrapati Shivaji Maharaj University, Panvel, Mumbai",
    "College of Engineering & Technology, Akola",
    "College of Engineering, Phaltan",
    "DKTE Society's Textile & Engineering Institute",
    "Dr Babasaheb Ambedkar Technological University",
    "Guru Nanak Institute of Engineering & Technology, Nagpur",
    "Karmaveer Bhaurao Patil College of Engineering",
    "Kavikulguru Institute of Technology & Science",
    "KBTCOE Karmaveer Adv. Baburao Ganpatrao Thakare College of Engineering, Nashik",
    "Kolhapur institute of technology, kolhapur",
    "Konkan Gyanpeeth College of Engineering",
    "Late GN Sapkal College of Engineering, Anjaneri, Nashik, Maharashtra 42221",
    "Loknete Gopinathji Munde Institute of Engineering Education & Research",
    "Modern Engineering & Management Studies",
    "MS Bidve Engineering College, Latur",
    "New arts commerce and science college, parner",
    "PES College of Engineering, Phaltan",
    "Pravara Rural Education Society's Sir Visvesvaraya Institute of Technology, Nashik",
    "Rajiv Gandhi College of Engineering",
    "RC Patel Institute of Technology",
    "S B Patil College of Engineering, Indapur",
    "Samarth College of Engineering & Management, Belhe, Pune",
    "Sandip University, Nashik",
    "Sanjay Ghodawat Engineering College",
    "Saraswati College of Engineering",
    "Sharad Institute of Technology College of Engineering",
    "Shree Ramchandra College of Engineering",
    "Shri Chhatrapati Shivaji Maharaj College of Engineering",
    "Shriram Institute of Technologies",
    "Sinhgad Institute of Business Administration and Research, Kondhwa, Pune.",
    "SSGMCE, Shegaon",
    "St Vincent Pallotti College of Engineering & Technology, Nagpur",
    "Symbiosis Institute of Technology",
    "Terna Engineering College - Mumbai",
    "Terna Public Charitable Trust's College of Engineering Osmanabad",
    "VDF School of Engineering & Technology, Latur",
    "Walchand Institute Of Technology",
    "Yashoda Technical Campus, Wadhe, Satara",
    "Yeshwantrao Chavan College of Engineering",
    "Allard College of Engineering",
    "MKSSS's K B Joshi Institute Of Information Technology, Karve Nagar, Pune, Maharashtra 411052",
    "A C Patil College of Engineering,Kharghar, Navi Mumbai,",
    "Abhilashi University - Faculty of Engineering & Management",
    "Abhinav Hi-Tech College of Engineering",
    "ABIT Satara",
    "Acharya College of Engineering",
    "Aditya Engineering College - Beed",
    "Ahmednagar college, Ahilyanagar",
    "Akole taluka education society technical compus, Akole",
    "Al-Falah School of Engineering & Technology",
    "Amal Jyothi College of Engineering",
    "Amity School of Engineering & Technology - Jaipur",
    "Amity School of Engineering & Technology - Mumbai",
    "Annasaheb Dange College of Engineering & Technology",
    "Asansol Engineering College",
    "Atharva College of Engineering",
    "Bharati Vidyapeeth College of Engineering, Navi Mumbai",
    "Chhatrapati Sahu College of Engineering",
    "Christ University - Faculty of Engnieering",
    "City Premier College, Nagpur",
    "CKT Changu Kana Thakur Arts Commerce & Science College, Panvel",
    "Cummins College of Engineering for Women, Nagpur",
    "Devi Ahilya Vishwavidhyalaya, Indore",
    "Dilkap College of Engineering",
    "Dr Daulatrao Aher College of Engineering",
    "Fr. C. Rodrigues Institute of Technology",
    "Gharda Institute of Technology",
    "GHRUA G H Raisoni University, Amravati",
    "GMVIT G. M. Vedak Institute of Technology, Raigad",
    "Government College of Engineering, Amravati",
    "Government College of Engineering, Karad",
    "Government College of Engineering, Nagpur",
    "Govt. College of Engineering, Navsari",
    "GPP, Pune",
    "Guru Nanak Khalsa College, Matunga, Mumbai",
    "Hon. Shree Babanrao Pachpute Vichardhara Trust's Group of Institutes, Faculty of Engineering",
    "HRM Hutatma Rajguru Arts, Science & Commerce College, RajguruNagar",
    "ICEM Indira College of Engineering and Management, Pune",
    "International Institute of Information Technology, Pune",
    "Jai Hind College of Engineering, Junnar, Pune",
    "Jaihind College of Engineering, Junnar",
    "Jain College of Engineering",
    "Jawaharlal Darda Institute of Engineering & Technology",
    "Jawaharlal Nehru Engineering College, Aurangabad",
    "Jhulelal Institute of Technology",
    "JT Mahajan College of Engineering",
    "Karmaveer Adv. Baburao Thakare College of Engineering",
    "Kholeshwar Mahavidyalaya, Ambejogai",
    "KLS Gogte Institute of Technology",
    "KT Patil College of Engineering & Technology",
    "Late Narayandas Bhawandas Chhabada Institute of Engineering & Technology",
    "M.B.E. Society's T.B.Girwalkar Polytechnic, Ambajogai TBG",
    "Manipal University - College of Engineering",
    "Maratha Mandal's Engineering College",
    "Mauli Group of Institution's,College of Engineering and Technology",
    "MES Garware College of Commerce, Pune",
    "MES Mukunddas Lohia College of Engineering, Pune",
    "MET Bhujbal Knowledge City Institute of Engineering",
    "Nabira Mahavidyalaya, Katol",
    "Nanasaheb Mahadik College of Engineering",
    "National Institute of Technology, Hamirpur",
    "National Institute of Technology, Rourkela",
    "NCER - Nutan College Of Engineering And Research, Pune",
    "NDMVP Samaj's Karmaveer Baburao Thakare College of Engineering, Nashik",
    "new art commerce science college, Parner",
    "Padmabhooshan Vasantraodada Patil Institute of Technology, Bhudgoan",
    "Parikrama College Of Engineering, Kashti",
    "PDVVP COE Ahmednagar",
    "PES College of Engineering, Aurangabad",
    "PGM moze college, wagholi",
    "Pillai College of Engineering",
    "Pillai HOC College of Engineering & Technology",
    "Priyadarshini College of Engineering, Nagpur",
    "PVG Pune Vidyarthi Grihas College of Engineering, Nashik",
    "PVPIT, Sangali",
    "Rajarshi Shahu College of Engineering",
    "Rajiv Gandhi College of Engineering Research & Technology",
    "Ramrao Adik Institute of Technology",
    "RJSPM-ICMR RJSPM's - Institute Of Computer and Management Research, Alandi, Pune.",
    "S.G.Balekundri Institute of Technology",
    "Sahyadri College of Engineering & Technology",
    "Sanjeevan Engineering & Technology Institute",
    "Sarada Institute of Technology & Science",
    "Sha-Shib College of Technology",
    "Shah & Anchor Kutchhi Engineering College, Mumbai",
    "Shankarrao Bhelke College, Nasarapur, Pune",
    "Sharda University - College of Engineering",
    "Shivajirao S Jondhale College of Engineering",
    "Shree Mahavir Education Society`s Sanghvi College of Engineering",
    "Shree Ram Institute of Engineering & Technology",
    "Shree Tuljabhavani Bhavani College of Engineering",
    "Shri Ramdeobaba College of Engineering and Management",
    "SND College of Engineering & Research Centre",
    "SNJB's College of Engineering",
    "Someshwar Engineering College",
    "SS & SS's Vidhydhan Commerce Collage, Dhule",
    "SSPM College of Engineering",
    "Swami Vivekanand University - College of Engineering",
    "Symbiosis Skills and Professional University",
    "Takshshila Institute of Engineering & Technology",
    "Usha Mittal Institute of Technology",
    "Vidyalankar Institute of Technology",
    "Vishwabharati Academy's College of Engineering, Ahilyanagar",
    "Vishwakarma Government Engineering College",
    "Vivekanand Education Society's Institute of Technology",
    "VP College Indapur",
    "Wainganga College of Engineering & Management",
    "Watumull Institute of Electronics Engineering & Computer Technology",
    "YCIP College, Beed",
  ];
  final List<String> sources = ['Website', 'YouTube', 'Instagram','Google','In person','Reference'];
  String? selectedCollege;
  String? selectedAcademicYear;
  String? selectedBranch;
  String? selectedSource;
  final List<String> branches = [
    "Computer Science (CS)",
  "Information Technology (IT)",
  "Electronics & Telecommunication (ENTC)",
  "AIDS Engineering",
  "Computer Application (CA)",
  "AIML Engineering",
  "Electronics and Computer",
  "Artificial Intelligence",
  "Mechanical Engineering",
  "Other",
  "Computer science and Design Engineering",
  "Electrical Engineering",
  "Industrial Mathematics with Computer Applications (IMCA)",
  "Computer Application",
  "Information Technology (IT)",
  "Data Science",
  "Computer Science Engineering-Artificial intelligence",
  "Biotechnology",
  "Electronics & Telecommunication (E&TC)",
  "Robotics and Automation Engineering",
  "information technology",
  "Electronics Engineering",
    "Other",
  ];
  final List<String> academicYears = ["BE Third Year",
  "BE Fourth Year",
  "BTech Third Year",
  "BE Second Year",
  "BTech Second Year",
  "BE Passout 2026",
  "BTech Fourth Year",
  "BCA Passout 2026",
  "BCS Third Year",
  "BCA Third Year",
  "MCA First Year",
  "MCA Second Year",
  "BTech First Year",
  "BTech Passout 2026",
  "BCA Passout 2025",
  "BCS Second Year",
  "MCA Passout 2024",
  "BCS Passout 2026",
  "Diploma Passout 2025",
  "BE Passout 2018",
  "BSC Third Year",
  "BE Passout 2024",
  "Diploma Passout 2026",
  "BCA Passout 2024",
  "BE Passout 2023",
  "BE Passout 2019",
  "BE Passout 2022",
  "MSC First Year",
  "BTech Passout 2022",
  "MCA Passout 2026",
  "MCS Second Year",
  "BSC Second Year",
  "BE Final Year",
  "Undergraduate",
  "MCS First Year",
  "BCS Passout 2024"];

  final List<String> batches = [
    'Flutter',
    'Java FullStack',
    'Java',
    'Python',
    'C,C++,DSA',
    "AI",
    "OS",
    "Java DSA",
    "C",
    "C,C++",
    "C DSA",
    "Data Science",
    "Data Analytics",
    "ML",
    "IOT"
  ];
  final List<String> selectedBatches = [];
  final List<String> modes = ['Offline', 'Online', 'Virtual'];
  String? selectedMode;
  @override
  void dispose() {
    _mobileLookupTimer?.cancel();
    nameController.dispose();
    mobileController.dispose();
    clgController.dispose();
    feedbackController.dispose();
    refController.dispose();
    sourceController.dispose();
    super.dispose();
  }

  void _onMobileChanged(String value) {
    _mobileLookupTimer?.cancel();
    final request = ++_mobileLookupRequest;
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.length < 4) {
      setState(() {
        _mobileMatches = [];
        _isLookingUpMobile = false;
        _mobileLookupError = null;
      });
      return;
    }

    setState(() => _isLookingUpMobile = true);
    setState(() => _mobileLookupError = null);
    _mobileLookupTimer = Timer(const Duration(milliseconds: 300), () async {
      try {
        final matches = await AddEnquiryRepository().findEnquiriesByMobilePrefix(
          digits,
        );
        if (!mounted || request != _mobileLookupRequest) return;
        setState(() {
          _mobileMatches = matches;
          _isLookingUpMobile = false;
        });
      } catch (error) {
        if (!mounted || request != _mobileLookupRequest) return;
        setState(() {
          _mobileMatches = [];
          _isLookingUpMobile = false;
          _mobileLookupError = 'Could not search enquiries: $error';
        });
      }
    });
  }

  void _selectMobileMatch(Map<String, String> match) {
    _mobileLookupTimer?.cancel();
    _mobileLookupRequest++;
    final college = match['collegeName'] ?? '';
    final source = match['enquirySource'] ?? '';
    setState(() {
      mobileController.text = match['mobileNo'] ?? '';
      nameController.text = match['studentName'] ?? '';
      refController.text = match['referenceBy'] ?? '';
      if (college.isNotEmpty) {
        if (!colleges.contains(college)) colleges.add(college);
        selectedCollege = college;
      }
      if (source.isNotEmpty) {
        if (!sources.contains(source)) sources.add(source);
        selectedSource = source;
      }
      _mobileMatches = [];
      _isLookingUpMobile = false;
      _mobileLookupError = null;
    });
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
                onChanged: _onMobileChanged,
                validator: (value) => value == null || !RegExp(r'^[6-9]\d{9}$').hasMatch(value.trim()) ? 'Enter a valid mobile number' : null,
                decoration: InputDecoration(
                  hintText: 'Enter 10-digit mobile no.',
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
              if (_isLookingUpMobile ||
                  _mobileMatches.isNotEmpty ||
                  _mobileLookupError != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF161B2E),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: _isLookingUpMobile
                      ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: Center(
                            child: SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        )
                      : _mobileLookupError != null
                      ? Padding(
                          padding: const EdgeInsets.all(12),
                          child: Text(
                            _mobileLookupError!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        )
                      : Column(
                          mainAxisSize: MainAxisSize.min,
                          children: _mobileMatches.map((match) {
                            return ListTile(
                              dense: true,
                              leading: const Icon(
                                Icons.phone_outlined,
                                color: Colors.white70,
                                size: 20,
                              ),
                              title: Text(
                                match['mobileNo'] ?? '',
                                style: const TextStyle(color: Colors.white),
                              ),
                              subtitle: Text(
                                match['studentName'] ?? '',
                                style: const TextStyle(color: Colors.white60),
                              ),
                              onTap: () => _selectMobileMatch(match),
                            );
                          }).toList(),
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
              Autocomplete<String>(
                initialValue: TextEditingValue(text: selectedCollege ?? ''),
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return colleges;
                  return colleges.where((college) => college.toLowerCase().contains(query));
                },
                displayStringForOption: (college) => college,
                onSelected: (college) => setState(() => selectedCollege = college),
                fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                  if (selectedCollege != null && controller.text != selectedCollege) {
                    controller.text = selectedCollege!;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    validator: (_) => selectedCollege == null ? 'Select a college' : null,
                    onChanged: (_) => setState(() => selectedCollege = null),
                    decoration: InputDecoration(
                      hintText: 'Search or select college',
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: const Color(0xFF161B2E),
                    elevation: 4,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxHeight: 260, maxWidth: 680),
                      child: ListView.builder(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        itemBuilder: (context, index) {
                          final college = options.elementAt(index);
                          return ListTile(
                            dense: true,
                            title: Text(college, style: const TextStyle(color: Colors.white)),
                            onTap: () => onSelected(college),
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text("Academic Year", style: GoogleFonts.figtree(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 10),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: selectedAcademicYear ?? ''),
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return academicYears;
                  return academicYears.where(
                    (year) => year.toLowerCase().contains(query),
                  );
                },
                displayStringForOption: (year) => year,
                onSelected: (year) => setState(() => selectedAcademicYear = year),
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  if (selectedAcademicYear != null &&
                      controller.text != selectedAcademicYear) {
                    controller.text = selectedAcademicYear!;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    validator: (_) => selectedAcademicYear == null
                        ? 'Select an academic year'
                        : null,
                    onChanged: (_) => setState(() => selectedAcademicYear = null),
                    decoration: InputDecoration(
                      hintText: 'Search or select academic year',
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: const Color(0xFF161B2E),
                    elevation: 4,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width < 712
                          ? MediaQuery.sizeOf(context).width - 32
                          : 680,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final year = options.elementAt(index);
                            return ListTile(
                              dense: true,
                              title: Text(
                                year,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () => onSelected(year),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text("Branch", style: GoogleFonts.figtree(fontWeight: FontWeight.w400, fontSize: 14, color: Colors.white)),
              const SizedBox(height: 10),
              Autocomplete<String>(
                initialValue: TextEditingValue(text: selectedBranch ?? ''),
                optionsBuilder: (value) {
                  final query = value.text.trim().toLowerCase();
                  if (query.isEmpty) return branches;
                  return branches.where(
                    (branch) => branch.toLowerCase().contains(query),
                  );
                },
                displayStringForOption: (branch) => branch,
                onSelected: (branch) => setState(() => selectedBranch = branch),
                fieldViewBuilder: (context, controller, focusNode, onSubmitted) {
                  if (selectedBranch != null && controller.text != selectedBranch) {
                    controller.text = selectedBranch!;
                  }
                  return TextFormField(
                    controller: controller,
                    focusNode: focusNode,
                    style: const TextStyle(color: Colors.white),
                    validator: (_) => selectedBranch == null ? 'Select a branch' : null,
                    onChanged: (_) => setState(() => selectedBranch = null),
                    decoration: InputDecoration(
                      hintText: 'Search or select branch',
                      hintStyle: const TextStyle(color: Colors.white54),
                      suffixIcon: const Icon(Icons.search, color: Colors.white70),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                        borderSide: const BorderSide(color: Colors.blue, width: 1.5),
                      ),
                    ),
                  );
                },
                optionsViewBuilder: (context, onSelected, options) => Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    color: const Color(0xFF161B2E),
                    elevation: 4,
                    child: SizedBox(
                      width: MediaQuery.sizeOf(context).width < 712
                          ? MediaQuery.sizeOf(context).width - 32
                          : 680,
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxHeight: 220),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          itemCount: options.length,
                          itemBuilder: (context, index) {
                            final branch = options.elementAt(index);
                            return ListTile(
                              dense: true,
                              title: Text(
                                branch,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(color: Colors.white),
                              ),
                              onTap: () => onSelected(branch),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
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
                  ButtonSegment(value: 'Virtual', label: Text('Virtual')),
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
              Text(
                "Reference By",
                style: GoogleFonts.figtree(
                  fontWeight: FontWeight.w400,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: 10),
              TextFormField(
                controller: refController,
                style: const TextStyle(color: Colors.white),
                textCapitalization: TextCapitalization.words,
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Enter a reference name'
                    : null,
                decoration: InputDecoration(
                  hintText: 'Enter reference name',
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
                          if (!_formKey.currentState!.validate() || selectedBatches.isEmpty || selectedMode == null) {
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
                              academicYear: selectedAcademicYear!,
                              branch: selectedBranch!,
                              interestedBatches: List<String>.from(
                                selectedBatches,
                              ),
                              mode: selectedMode!,
                              studentFeedback: feedbackController.text.trim(),
                              referenceBy: refController.text.trim(),
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
