import 'package:flutter/material.dart';
import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/header.dart';
import '../../Widgets/navigation_bar.dart';

class WantToHelpScreen2 extends StatelessWidget {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  WantToHelpScreen2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedItem: 'I Want to Help'),
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
                child: Container(
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const HeaderWidget(number: "2"),
          Positioned(
            top: 280, // Adjust this value based on the height of your header
            left: MediaQuery.of(context).size.width * 0.5 - 90, // Centers the icon horizontally
            child: Container(
              width: 180, // Width of the circle (2 * radius)
              height: 180, // Height of the circle (2 * radius)
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: Colors.black, // Black border color
                  width: 4, // Border width
                ),
              ),
              child: CircleAvatar(
                radius: 90, // Size of the avatar
                backgroundColor: Colors.white, // Background color for the avatar
                child: Icon(
                  Icons.person_outline, // Person icon
                  size: 90, // Size of the icon
                  color: Colors.black, // Icon color
                ),
              ),
            ),
          ),
          Positioned(
            top: 520, // Adjust this value to make sure the button is below the circle
            left: MediaQuery.of(context).size.width * 0.5 - 130, // Adjust to center the button
            child: ElevatedButton(
              onPressed: () {
                // Define the action for the button here
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // Button color
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(29), // Border radius of 29
                ),
                padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15), // Increase horizontal padding for wider button
              ),
              child: Text(
                'UPLOAD MY PICTURE', // Button text
                style: GoogleFonts.poppins(
                  color: Colors.white, // Text color
                  fontSize: 18, // Font size
                  fontWeight: FontWeight.w500
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}