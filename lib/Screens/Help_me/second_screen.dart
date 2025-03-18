import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../../Widgets/navigation_bar.dart';
import '../../Widgets/header.dart'; // Import the HeaderWidget

class HelpMeScreen2 extends StatelessWidget {
  final String emergencyType;

  const HelpMeScreen2({super.key, required this.emergencyType});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationBarWidget(),
      body: Stack(
        children: [
          Column(
            children: [
              const Divider(
                color: Color(0xFFE5E5E5), // Gray dividing line
                thickness: 2,
                height: 1,
              ),
              Expanded(
                child: Container(color: Colors.white),
              ),
            ],
          ),

          // Reusable Header Widget with "2" inside the circle
          const HeaderWidget(number: "2"),

          // Scrollable content below the header
          Positioned.fill(
            top: 240, // Adjust to position below the header
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // NAME Field
                    Text(
                      "NAME:",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter your name...",
                          hintStyle: GoogleFonts.poppins(color: Colors.black),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // LOCATION Field
                    Text(
                      "LOCATION:",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 52,
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: "Enter your location...",
                          hintStyle: GoogleFonts.poppins(color: Colors.black),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 20, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(29),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Track my location (aligned to the right)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end, // Moves it to the right
                      children: [
                        const Icon(LucideIcons.mapPin, color: Colors.grey, size: 20), // Location icon
                        const SizedBox(width: 6), // Space between icon and text
                        Text(
                          "Track my location",
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // PERSONALISED MESSAGE Field
                    Text(
                      "PERSONALISED MESSAGE:",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 120,
                      child: TextField(
                        maxLines: 5, // Multiline input
                        decoration: InputDecoration(
                          hintText: "Enter your message...",
                          hintStyle: GoogleFonts.poppins(color: Colors.black),
                          filled: true,
                          fillColor: Colors.transparent,
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 16, horizontal: 16),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(20),
                            borderSide: const BorderSide(
                                color: Colors.black, width: 2),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Submit Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle button press action
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black, // Black background
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                        ),
                        child: Text(
                          "SEND TO ALL VOLUNTEERS",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white, // White text color
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}