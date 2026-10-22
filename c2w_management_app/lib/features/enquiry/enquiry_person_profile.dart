import 'dart:developer';

import 'package:c2w_management_app/features/enquiry/domain/usecase/calling.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class EnquiryPersonProfile extends StatefulWidget {
  const EnquiryPersonProfile({super.key});

  @override
  State<EnquiryPersonProfile> createState() => _EnquiryPersonProfileState();
}

class _EnquiryPersonProfileState extends State<EnquiryPersonProfile>
    with SingleTickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  late final TabController _tabController;

  bool isCollapsed = false;

  static const double expandedHeight = 280;

  static const double bottomHeight = 90;

  static const bgColor = Color.fromRGBO(14, 16, 32, 1);
  static const appBarColor = Color.fromRGBO(20, 22, 39, 1);
  static const cardColor = Color.fromRGBO(22, 27, 46, 1);
  static const blue = Color.fromRGBO(43, 163, 232, 1);

  // final List<Map<String, String>> history = [
  //   {
  //     'title': '1st Enquiry',
  //     'date': '8 June 2025',
  //     'interest': 'Java offline',
  //     'status': 'On hold',
  //     'feedback': 'I will complete my Admission next 2 day',
  //   },
  //   {
  //     'title': '2nd Enquiry',
  //     'date': '25 Sep 2025',
  //     'interest': 'Python & AI/ML',
  //     'status': 'On hold',
  //     'feedback': 'I will complete my Admission next 2 day',
  //   },
  // ];

   final List<Map<String, String>> history = [];

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));

    _scrollController.addListener(() {
      // how much the big header can shrink
      const collapseDistance = expandedHeight - kToolbarHeight - bottomHeight;

      // show the small title a little before it is fully closed
      final collapsed = _scrollController.offset > collapseDistance - 20;
      if (collapsed != isCollapsed) {
        setState(() => isCollapsed = collapsed);
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bgColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: expandedHeight,
            backgroundColor: appBarColor,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),

            centerTitle: false,
            titleSpacing: 0,

            title: AnimatedOpacity(
              opacity: isCollapsed ? 1 : 0,
              duration: const Duration(milliseconds: 200),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Priyanka Jadhav",
                    style: GoogleFonts.figtree(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    "Interested for- Flutter Online • 16 Oct 2025",
                    style: GoogleFonts.figtree(
                      fontSize: 13,
                      color: Colors.white54,
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              AnimatedOpacity(
                opacity: isCollapsed ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: Center(
                  child: Text(
                    "Raised on: 16 Oct 2025",
                    style: GoogleFonts.figtree(
                      fontSize: 15,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
            ],

            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: AnimatedOpacity(
                opacity: isCollapsed ? 0 : 1,
                duration: const Duration(milliseconds: 200),
                child: _bigHeader(context),
              ),
            ),

            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(bottomHeight),
              child: _staticPart(),
            ),
          ),

          SliverToBoxAdapter(
            child: TabBar(
              controller: _tabController,
              indicatorColor: blue,
              labelColor: blue,
              unselectedLabelColor: Colors.grey,
              dividerColor: Colors.white12,
              tabs: const [Tab(text: "Details"), Tab(text: "History")],
            ),
          ),

          SliverToBoxAdapter(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: _tabController.index == 0 ? _detailsTab() : _historyTab(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _staticPart() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
     
          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  "Call Status",
                  style: GoogleFonts.figtree(fontSize: 16, color: Colors.grey),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: const Color.fromRGBO(70, 52, 14, 1),
                  ),
                  child: Row(
                    children: [
                      Text(
                        "• Pending",
                        style: GoogleFonts.figtree(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: Colors.orange,
                        ),
                      ),
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.orange,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Colors.white12),

          SizedBox(
            height: 44,
            child: Row(
              children: [
                Text(
                  "Admission Status",
                  style: GoogleFonts.figtree(fontSize: 16, color: Colors.grey),
                ),
                const Spacer(),
                Text(
                  "• Not yet",
                  style: GoogleFonts.figtree(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _bigHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        kToolbarHeight + MediaQuery.of(context).padding.top + 8,
        16,
        0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
         
          Row(
            children: [
              Container(
                height: 50,
                width: 50,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: const Color.fromARGB(255, 233, 186, 169),
                ),
                child: Center(
                  child: Text(
                    "P",
                    style: GoogleFonts.figtree(
                      fontSize: 25,
                      fontWeight: FontWeight.w600,
                      color: Colors.brown,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "Priyanka Jadhav",
                style: GoogleFonts.figtree(
                  fontSize: 25,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          Row(
            children: [
              Text(
                "Interested for",
                style: GoogleFonts.figtree(fontSize: 16, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                  color: const Color.fromRGBO(42, 45, 62, 1),
                  border: Border.all(color: Colors.white24),
                ),
                child: Text(
                  "Flutter Online",
                  style: GoogleFonts.figtree(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _detailsTab() {
    return Column(
      children: [
        _card("Contact Details", [
          Row(
            children: [
              const Icon(Icons.phone_outlined, color: Colors.white54),
              const SizedBox(width: 12),
              Expanded(child: _field("Mobile No", "+91 80798 17713")),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromRGBO(25, 229, 122, 1),
                  foregroundColor: Colors.black,
                  shape: const StadiumBorder(),
                ),
                onPressed: () {
                  makePhoneCall("9322762831");
                },
                child: const Text("Call"),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _field("E-mail Id", "e.g., xyz@example.com"),
        ]),
        _card("User side", [
          _field("User feedback", "I will complete my Admission next 2 day"),
          const SizedBox(height: 12),
          _field("Our side", "Type here"),
          const SizedBox(height: 12),
          _field("Follow-up call date", "DD-MM-YYYY"),
        ]),
        _card("Academic Details", [
          _field("College name", "JSPM Narhe Technical Campus"),
          const SizedBox(height: 12),
          _field("Branch", "e.g., civil, mechanical, electronics"),
        ]),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _historyTab() {
    if(history.isEmpty){
      log("in null list of enquiry history");
      return Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            // decoration: BoxDecoration(),
            height: 230,
            width: 260,
            child: Image.asset("assets/images/sales_admin/nulllist.png"),
          
          ),
        ],
      );

    }else{
      log("in not null list of enquiry history");
    return Column(
      children: [
        for (final item in history)
          _card(item['title']!, [
            _row("Interested for", item['interest']!, Colors.white),
            const SizedBox(height: 8),
            _row("Admission status", "• ${item['status']}", Colors.redAccent),
            const SizedBox(height: 12),
            _field("User feedback", item['feedback']!),
          ], date: item['date']),
        const SizedBox(height: 40),
      ],
    );
    }
  }

  Widget _card(String title, List<Widget> children, {String? date}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 12, 12, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                title,
                style: GoogleFonts.figtree(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              if (date != null)
                Text(
                  date,
                  style: GoogleFonts.figtree(
                    fontSize: 13,
                    color: Colors.white54,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _field(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(fontSize: 12, color: Colors.white54),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: GoogleFonts.figtree(fontSize: 14, color: Colors.white),
        ),
      ],
    );
  }

  Widget _row(String label, String value, Color valueColor) {
    return Row(
      children: [
        Text(
          label,
          style: GoogleFonts.figtree(fontSize: 13, color: Colors.white54),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.figtree(fontSize: 13, color: valueColor),
        ),
      ],
    );
  }
}