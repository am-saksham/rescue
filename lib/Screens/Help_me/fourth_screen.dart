import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/navigation_bar.dart';
import '../../Widgets/header.dart';
import 'fifth_screen.dart';

class HelpMeScreen4 extends StatefulWidget {
  HelpMeScreen4({super.key});

  @override
  State<HelpMeScreen4> createState() => _HelpMeScreen4State();
}

class _HelpMeScreen4State extends State<HelpMeScreen4> {
  bool _isLoading = false; // State to control the loading bar

  void _startLoading() {
    setState(() {
      _isLoading = true;
    });

    // Simulate a delay for the loading bar (3 seconds)
    Future.delayed(const Duration(seconds: 3), () {
      setState(() {
        _isLoading = false; // Hide the loading bar

        // Navigate to HelpMeScreen5
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => HelpMeScreen5()),
        );
      });
    });
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey,), // Navigation bar
      drawer: AppDrawer(selectedItem: 'Help me!',),
      body: Stack(
        children: [
          Column(
            children: [
              const Divider(
                color: Color(0xFFE5E5E5),
                thickness: 2,
                height: 1,
              ),
              Expanded(
                child: Container(color: Colors.white),
              ),
            ],
          ),

          // Header with "4" inside the circle
          const HeaderWidget(number: "4"),

          // Transparent circle with text inside
          Positioned(
            top: 250, // Adjust this based on your layout
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _startLoading, // Click to show the loading bar
                child: Container(
                  width: 247,
                  height: 247,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.black, width: 3), // Black stroke
                    color: Colors.transparent, // Transparent background
                  ),
                  child: Center(
                    child: Text(
                      "SEARCH FOR VOLUNTEERS",
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 30,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Loading bar and "Searching..." text (visible only when _isLoading is true)
          if (_isLoading)
            Positioned(
              top: 600, // Positioning below the circle
              left: 50,
              right: 50,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end, // Align to the right
                children: [
                  LinearProgressIndicator(
                    backgroundColor: Colors.grey, // Gray background
                    color: Colors.black, // Black progress
                    minHeight: 8, // Adjust thickness
                  ),
                  const SizedBox(height: 5), // Small spacing between bar and text
                  Text(
                    "Searching for volunteers...",
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic, // Italic text
                      color: Colors.grey,
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