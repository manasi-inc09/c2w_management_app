
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Map<String, String?>?> showFilterSheet(
  BuildContext context, {
  Map<String, String?>? initialFilters,
}) {
  return showModalBottomSheet<Map<String, String?>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1F2433),
    builder: (_) => FilterSheet(initialFilters: initialFilters),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, this.initialFilters});

  final Map<String, String?>? initialFilters;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  final options = {
    'Call Status': ['Done', 'Pending', 'Not Received'],
    'Interested for': ['Flutter Online', 'DSA', 'C++'],
    'Raised on': ['Today', 'Yesterday', 'Last 7 days'],
    'Admission Status': ['Admitted', 'In Progress', 'Not Admitted'],
    'Enquiry Source': ['Walk-in', 'Website', 'Referral'],
    'Enquiry Taken By': ['Community Member', 'TeamLead', 'Mentor'],
  };

  late List<String> categories;
  late Map<String, String?> selected;
  int current = 0;

  @override
  void initState() {
    super.initState();
    categories = options.keys.toList();
    selected = Map<String, String?>.from(widget.initialFilters ?? {});
  }

  @override
  Widget build(BuildContext context) {
    
    return SizedBox(
      height: MediaQuery.of(context).size.height * 0.85,
      child: Column(
        children: [
          // Title
           Padding(
            padding: EdgeInsets.all(20),
            child: Row(
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Filters & Sort',
                    style: TextStyle(fontSize: 24, color: Colors.white),
                  ),
                ),
                Spacer(),
                if(selected.values.any((value)=>value!=null))
                  TextButton(onPressed: (){
                    setState(() {
                      selected.clear();
                    });
                  }, child: Text("Reset",style: GoogleFonts.figtree(fontSize: 18,fontWeight: FontWeight.w500,color: Colors.red),))
                
              ],
            ),
          ),

          Wrap(
            spacing: 15,
            runSpacing: 8,
            children: selected.entries
                .where((entry) => entry.value != null)
                .map((entry) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB74D).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '• ${entry.key}: ${entry.value}',
                      style: GoogleFonts.figtree(
                        color: const Color(0xFFFFB74D),
                        fontSize: 13,
                      ),
                    ),
                  );
                })
                .toList(),
          ),
          const SizedBox(height: 15),
          const Divider(height: 1, color: Colors.white24),

          // Left menu + right options
          Expanded(
            child: Row(
              children: [
                // Left menu
                SizedBox(
                  width: 150,
                  child: ListView(
                    children: List.generate(categories.length, (i) {
                      final isSelected = i == current;
                      return InkWell(
                        onTap: () => setState(() => current = i),
                        child: Container(
                          height: 70,
                          padding: const EdgeInsets.only(left: 16),
                          alignment: Alignment.centerLeft,
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white10 : null,
                            border: Border(
                              left: BorderSide(
                                width: 4,
                                color: isSelected
                                    ? Colors.lightBlue
                                    : Colors.transparent,
                              ),
                              bottom: const BorderSide(color: Colors.white24),
                            ),
                          ),
                          child: Text(
                            categories[i],
                            style: const TextStyle(color: Colors.white),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const VerticalDivider(width: 1, color: Colors.white24),

                // Right options
                Expanded(
                  child: ListView(
                    children: options[categories[current]]!.map((item) {
                      final key = categories[current];
                      final isOn = selected[key] == item;
                      return ListTile(
                        onTap: () => setState(
                          () => selected[key] = isOn ? null : item,
                        ),
                        leading: Icon(
                          isOn
                              ? Icons.radio_button_checked
                              : Icons.radio_button_unchecked,
                          color: isOn ? Colors.lightBlue : Colors.white54,
                        ),
                        title: Text(
                          item,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ),

          // Buttons
          const Divider(height: 1, color: Colors.white24),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.lightBlue),
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () => Navigator.pop(context), // returns null
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.lightBlue,
                      foregroundColor: Colors.white,
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    // Send the selected filters back to the screen
                    onPressed: () {
                      print(selected);
                      Navigator.pop(context, selected);
                    },
                    child: const Text('Apply filters'),
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