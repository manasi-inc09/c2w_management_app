import 'dart:developer';
import 'package:c2w_management_app/features/enquiry/presentation/widgets/enquiry_list.dart';
import 'package:c2w_management_app/features/enquiry/presentation/widgets/filters.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class Enquiry extends StatefulWidget {
  const Enquiry({super.key});

  @override
  State<Enquiry> createState() => _EnquiryState();
}

class _EnquiryState extends State<Enquiry> {
  Map<String, String?> appliedFilters = {};
  bool isSearchVisible = false;
  String searchQuery = '';
  @override
  Widget build(BuildContext context) {
    Widget searchBar = const SizedBox();

    if (isSearchVisible) {
      searchBar = Padding(
        padding: const EdgeInsets.all(12),
        child: TextField(
          onChanged: (value) {
            setState(() {
              searchQuery = value;
            });
          },
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Search enquiries...',
            hintStyle: TextStyle(color: Colors.white54),
            prefixIcon: Icon(Icons.search, color: Colors.white54),
          ),
        ),
      );
    }
    log("in  enquiry");
    return Scaffold(
      backgroundColor: const Color(0xFF070A1B),
      appBar: AppBar(
        backgroundColor:  const Color(0xFF141627),
        surfaceTintColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Enquiry Overview',
          style: GoogleFonts.figtree(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              border: Border.all(color: Colors.white24),
            ),

            child: IconButton(
              onPressed: () {
                setState(() {
                  isSearchVisible = !isSearchVisible;

                  if (!isSearchVisible) {
                    searchQuery = '';
                  }
                });
              },
              icon: Icon(
                isSearchVisible ? Icons.close : Icons.search,
                color: Colors.white,
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                Center(
                  child: Badge(
                    label: Text('2'),
                    backgroundColor: Color.fromRGBO(5, 164, 255, 1),
                    child: IconButton(
                      icon: const Icon(Icons.filter_alt_outlined),
                      onPressed: () async {
                        final result = await showFilterSheet(
                          context,
                          initialFilters: appliedFilters,
                        );

                        if (result != null) {
                          setState(() {
                            appliedFilters = result; // page rebuilds after this
                          });
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                for (final label in [
                  'Call status',
                  'Interested for',
                  'Raised on',
                ])
                  Center(
                    child: Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF161B2E),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: Colors.white24),
                      ),
                      child: Text(
                        label,
                        style: GoogleFonts.figtree(
                          color: Colors.white,
                          fontSize: 13,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10),
          Text(
            "350 enquiries",
            style: GoogleFonts.figtree(fontSize: 13, color: Colors.white),
          ),
          searchBar,

          Expanded(
            child: EnquiryList(
              searchQuery: searchQuery,
              filters: appliedFilters,
            
            ),
          ),
        ],
      ),
    );
  }
}
