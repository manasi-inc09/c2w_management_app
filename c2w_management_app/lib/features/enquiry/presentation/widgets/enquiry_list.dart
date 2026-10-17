import 'package:c2w_management_app/features/enquiry/enquiry_person_profile.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnquiryList extends StatefulWidget {
  const EnquiryList({
    super.key,
    this.searchQuery = '',
    this.filters = const {},
  });

  final String searchQuery;
  final Map<String, String?> filters;

  @override
  State<EnquiryList> createState() => _EnquiryListState();
}

class _EnquiryListState extends State<EnquiryList> {
  final List<Map<String, dynamic>> enquiries = [
    {
      'name': 'RAMESH SHARMA',
      'date': '10 Oct 2025',
      'interest': 'Interested for- C, C++, DSA',
      'status': 'Done',
      'phone': '+91 80798 17713',
      'chat': true,
      'tick': true,
    },
    {
      'name': 'SIBANI MOHAPATRA',
      'date': '16 Oct 2025',
      'interest': 'Interested for- Flutter Online',
      'status': 'Not Received',
      'phone': '+91 80798 17713',
      'chat': false,
      'tick': false,
    },
    {
      'name': 'KAVYA JAIN',
      'date': '16 Oct 2025',
      'interest': 'Interested for- Flutter Online',
      'status': 'Pending',
      'phone': '+91 80798 17713',
      'chat': false,
      'tick': false,
    },
    {
      'name': 'PRIYANKA JADHAV',
      'date': '16 Oct 2025',
      'interest': 'Interested for- Flutter Online',
      'status': 'Pending',
      'phone': '+91 80798 17713',
      'chat': false,
      'tick': false,
    },
    {
      'name': 'KAPIL OJHA',
      'date': '16 Oct 2025',
      'interest': 'Interested for- Flutter Online',
      'status': 'Pending',
      'phone': '+91 80798 17713',
      'chat': false,
      'tick': false,
    },
    {
      'name': 'SURAJ PANDEY',
      'date': '16 Oct 2025',
      'interest': 'Interested for- Flutter Online',
      'status': 'Pending',
      'phone': '+91 80798 17713',
      'chat': true,
      'tick': false,
    },
    {
      'name': 'RAMESH SHARMA',
      'date': '16 Oct 2025',
      'interest': 'Interested for- Flutter Online',
      'status': 'Pending',
      'phone': '+91 80798 17713',
      'chat': true,
      'tick': false,
    },
  ];

  Color _statusColor(String status) {
    switch (status) {
      case 'Done':
        return Colors.green;
      case 'Not Received':
        return Colors.redAccent;
      default:
        return Colors.orange;
    }
  }

  List<Map<String, dynamic>> _getFilteredEnquiries() {
    final query = widget.searchQuery.toLowerCase().trim();
    final filters = widget.filters;

    return enquiries.where((item) {
      final matchesSearch = query.isEmpty ||
          item['name'].toString().toLowerCase().contains(query) ||
          item['interest'].toString().toLowerCase().contains(query) ||
          item['status'].toString().toLowerCase().contains(query) ||
          item['date'].toString().toLowerCase().contains(query);

      final statusFilter = filters['Call Status'];
      final matchesStatus = statusFilter == null || item['status'] == statusFilter;

      final interestFilter = filters['Interested for'];
      final matchesInterest = interestFilter == null ||
          item['interest']
              .toString()
              .toLowerCase()
              .contains(interestFilter.toLowerCase());

      return matchesSearch && matchesStatus && matchesInterest;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filteredEnquiries = _getFilteredEnquiries();

    if (filteredEnquiries.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Text(
            'No enquiries found',
            style: GoogleFonts.figtree(color: Colors.white54, fontSize: 14),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(8),
      itemCount: filteredEnquiries.length,
      itemBuilder: (context, index) {
        final item = filteredEnquiries[index];
        final statusColor = _statusColor(item['status'].toString());

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Material(
            color: const Color(0xFF161B2E),
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              borderRadius: BorderRadius.circular(10),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    // TODO: pass the selected enquiry if your profile page accepts it
                    builder: (_) => const EnquiryPersonProfile(),
                  ),
                );
              },
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Container(width: 3, height: 50, color: Colors.white),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                item['date'].toString(),
                                style: GoogleFonts.figtree(
                                  color: Colors.white54,
                                  fontSize: 12,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 1,
                                height: 12,
                                color: Colors.white24,
                              ),
                              const SizedBox(width: 8),
                              if (item['chat'] == true)
                                const Icon(
                                  Icons.chat_bubble,
                                  color: Colors.redAccent,
                                  size: 14,
                                ),
                              if (item['tick'] == true) ...[
                                const SizedBox(width: 6),
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                  size: 16,
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            item['name'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.figtree(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            item['interest'].toString(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.figtree(
                              color: Colors.white54,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '• ${item['status']}',
                            style: GoogleFonts.figtree(
                              color: statusColor,
                              fontSize: 11,
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          item['phone'].toString(),
                          style: GoogleFonts.figtree(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
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