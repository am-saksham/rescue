import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/navigation_bar.dart';
import '../../Widgets/header.dart';
import 'fourth_screen.dart';

class HelpMeScreen3 extends StatelessWidget {
  HelpMeScreen3({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey,),
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

          // Reusable Header Widget with "3" inside the circle
          const HeaderWidget(number: "3"),

          // Text just below the header
          Positioned(
            top: 240, // Adjust based on header height
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                "WHAT DO YOU NEED?",
                style: GoogleFonts.poppins(
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          // Items in a column
          Positioned(
            top: 300, // Adjust spacing below the text
            left: 20,
            right: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center, // Align everything in center
              children: [
                _buildRowItem(context, Icons.local_hospital_outlined, "Medical Assistance"),
                _buildRowItem(context, Icons.fastfood_outlined, "Food and Water"),
                _buildRowItem(context, Icons.house_outlined, "Shelter"),
                _buildRowItem(context, Icons.directions_bus_outlined, "Evacuation"),
              ],
            ),
          ),

          // "Other" text at the bottom right (trailing side)
          Positioned(
            bottom: 40, // Adjust vertical position
            right: 40, // Align to the trailing side
            child: GestureDetector(
              onTap: () {
                // Navigate to Screen 4 when tapped
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => HelpMeScreen4()),
                );
              },
              child: Text(
                "Other",
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF939393), // Gray color
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowItem(BuildContext context, IconData icon, String text) {
    return GestureDetector(
      onTap: () {
        // Navigate to Screen 4 when tapped
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => HelpMeScreen4()),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12), // Spacing between rows
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center, // Center row content
          crossAxisAlignment: CrossAxisAlignment.center, // Align text & icon properly
          children: [
            Container(
              width: 77,
              height: 77,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.black, width: 2), // Black stroke
                color: Colors.transparent, // Transparent fill
              ),
              child: Center(
                child: Icon(icon, size: 40, color: Colors.black), // Icon inside circle
              ),
            ),
            const SizedBox(width: 22), // Spacing between icon and text
            SizedBox(
              width: 180, // Fixed width ensures alignment
              child: Text(
                text,
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}