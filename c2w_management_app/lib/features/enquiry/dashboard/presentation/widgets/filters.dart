import 'package:c2w_management_app/features/enquiry/dashboard/data/models/EnquiryModel.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardBloc.dart';
import 'package:c2w_management_app/features/enquiry/dashboard/presentation/bloc/DashBoardState.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';

Future<Map<String, String?>?> showFilterSheet(
  BuildContext context, {
  Map<String, String?>? initialFilters,
}) {
  return showModalBottomSheet<Map<String, String?>>(
    context: context,
    isScrollControlled: true,
    backgroundColor: const Color(0xFF1F2433),
    builder: (_) => BlocProvider.value(
      value: context.read<DashBoardBloc>(),
      child: FilterSheet(initialFilters: initialFilters),
    ),
  );
}

class FilterSheet extends StatefulWidget {
  const FilterSheet({super.key, this.initialFilters});

  final Map<String, String?>? initialFilters;

  @override
  State<FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<FilterSheet> {
  static const _categories = [
    'Call Status',
    'Interested for',
    'Raised on',
    'Admission Status',
    'Enquiry Source',
    'Enquiry Taken By',
  ];

  late Map<String, String?> selected;
  int current = 0;

  @override
  void initState() {
    super.initState();
    selected = Map<String, String?>.from(widget.initialFilters ?? {});
  }

  Map<String, List<String>> _optionsFrom(List<EnquiryModel> enquiries) {
    final history = enquiries.expand((item) => item.enquiryHistory);
    List<String> uniqueSorted(Iterable<String> values) => values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toSet()
        .toList()
      ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

    return {
      'Call Status': uniqueSorted([
        ...enquiries.map((item) => item.callStatus),
        ...history.map((item) => item.callStatus),
      ]),
      'Interested for': uniqueSorted(
        [
          ...enquiries.expand((item) => item.interestedBatches),
          ...history.expand((item) => item.interestedBatches),
        ],
      ),
      'Raised on': const ['Today', 'Yesterday', 'Last 7 days'],
      'Admission Status': uniqueSorted(
        [
          ...enquiries.map((item) => item.admissionStatus),
          ...history.map((item) => item.admissionStatus),
        ],
      ),
      'Enquiry Source': uniqueSorted(
        [
          ...enquiries.map((item) => item.enquirySource),
          ...history.map((item) => item.enquirySource),
        ],
      ),
      'Enquiry Taken By': const ['Instructor', 'SalesAdmin', 'Mentor', 'Teamlead'],
    };
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DashBoardBloc, DashBoardState>(
      builder: (context, state) {
        final enquiries = state is DashBoardLoaded
            ? state.enquiries
            : const <EnquiryModel>[];
        final options = _optionsFrom(enquiries);
        final category = _categories[current];
        final categoryOptions = options[category] ?? const <String>[];

        return SizedBox(
          height: MediaQuery.of(context).size.height * 0.85,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    const Text(
                      'Filters & Sort',
                      style: TextStyle(fontSize: 24, color: Colors.white),
                    ),
                    const Spacer(),
                    if (selected.values.any(
                      (value) => value != null && value.isNotEmpty,
                    ))
                      TextButton(
                        onPressed: () => setState(selected.clear),
                        child: Text(
                          'Reset',
                          style: GoogleFonts.figtree(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.red,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                

                child:Wrap(
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
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${entry.key}: ${entry.value}',
                          style: GoogleFonts.figtree(
                            color: const Color(0xFFFFB74D),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 4),
                        InkWell(
                          onTap: () => setState(
                            () => selected[entry.key] = null,
                          ),
                          borderRadius: BorderRadius.circular(12),
                          child: const Padding(
                            padding: EdgeInsets.all(2),
                            child: Icon(
                              Icons.close,
                              size: 15,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  );
                })
                .toList(),
          ),
              ),
              const SizedBox(height: 15),
              const Divider(height: 1, color: Colors.white24),
              Expanded(
                child: Row(
                  children: [
                    SizedBox(
                      width: 150,
                      child: ListView.builder(
                        itemCount: _categories.length,
                        itemBuilder: (context, index) {
                          final isSelected = index == current;
                          return InkWell(
                            onTap: () => setState(() => current = index),
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
                                  bottom: const BorderSide(
                                    color: Colors.white24,
                                  ),
                                ),
                              ),
                              child: Text(
                                _categories[index],
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const VerticalDivider(width: 1, color: Colors.white24),
                    Expanded(
                      child: categoryOptions.isEmpty
                          ? const Center(
                              child: Text(
                                'No values available',
                                style: TextStyle(color: Colors.white54),
                              ),
                            )
                          : ListView(
                              children: categoryOptions.map((value) {
                                final isOn = selected[category] == value;
                                return ListTile(
                                  onTap: () => setState(
                                    () => selected[category] =
                                        isOn ? null : value,
                                  ),
                                  leading: Icon(
                                    isOn
                                        ? Icons.radio_button_checked
                                        : Icons.radio_button_unchecked,
                                    color: isOn
                                        ? Colors.lightBlue
                                        : Colors.white54,
                                  ),
                                  title: Text(
                                    value,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                    ),
                                  ),
                                );
                              }).toList(),
                            ),
                    ),
                  ],
                ),
              ),
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
                        onPressed: () => Navigator.pop(context),
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
                        onPressed: () => Navigator.pop(context, selected),
                        child: const Text('Apply filters'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
