import 'package:c2w_management_app/core/app_theme.dart';
import 'package:c2w_management_app/features/super_admin/presentation/widgets/settle_button.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BottomsheetSettle {
  String selectedOption = "Option 1";
  Widget getBottomSheetOpen() {
    String localSelectedOption = selectedOption;
    bool isChecked = false;

    return BottomSheet(
      onClosing: () {},
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            void handleCheckBox(bool? value) {
              if (value != null) {
                setState(() {
                  isChecked = value; // Update your state variable
                });
              }
            }

            // Helper widget to build each custom radio box
            Widget buildRadioBox({
              required String title,
              required String value,
            }) {
              bool isSelected = localSelectedOption == value;

              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      localSelectedOption = value;
                    });
                    setState(() {
                      selectedOption = value; // Update main page state
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(
                        7,
                        10,
                        27,
                        1,
                      ), // Dark container background
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? Colors.blue
                            : Colors
                                  .grey
                                  .shade800, // Blue border if selected, grey otherwise
                        width: isSelected ? 1.5 : 1.0,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        // Custom Radio Circle Indicator
                        Container(
                          width: 22,
                          height: 22,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: isSelected ? Colors.blue : Colors.grey,
                              width: 2,
                            ),
                          ),
                          child: isSelected
                              ? Center(
                                  child: Container(
                                    width: 10,
                                    height: 10,
                                    decoration: const BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.blue,
                                    ),
                                  ),
                                )
                              : null,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            return Container(
              padding: const EdgeInsets.all(20),
              width: MediaQuery.of(context).size.width,
              decoration: BoxDecoration(
                color: AppTheme()
                    .appBarBackgroundColor, // Sheet background color matching your theme
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top drag handle bar like in the image
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade700,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  // Row containing both option boxes side-by-side
                  Row(
                    children: [
                      buildRadioBox(title: "Total", value: "Option 1"),
                      const SizedBox(width: 12),
                      buildRadioBox(title: "Custom", value: "Option 2"),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      children: [
                        Text(
                          "Total Amount",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight(500),
                            color: Colors.white,
                          ),
                        ),
                        Spacer(),
                        Text(
                          "8590",
                          style: GoogleFonts.roboto(
                            fontSize: 20,
                            fontWeight: FontWeight(500),
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(),
                  const SizedBox(height: 10),
                  Container(
                    height: 60,
                    width: 400,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        colors: [
                          Color.fromRGBO(90, 36, 118, 1),
                          Color.fromRGBO(59, 46, 116, 1),
                        ],
                      ),
                    ),
                    child: Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Settle from Wallet",
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight(400),
                                  color: Colors.white,
                                ),
                              ),
                              RichText(
                                text: TextSpan(
                                  text: "Available Balance: ",
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300,
                                    color: Colors.white,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: "10,000",
                                      style: GoogleFonts.poppins(
                                        fontSize: 14,
                                        fontWeight: FontWeight
                                            .w500, // Optional: slightly bolder for emphasis
                                        color: Colors.green,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        Checkbox(
                          value: isChecked,
                          onChanged: handleCheckBox,
                          activeColor: Colors.green,
                          side: BorderSide(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  SettleButton().getSettleButton(context,"Settle")
                ],
              ),
            );
          },
        );
      },
    );
  }
}