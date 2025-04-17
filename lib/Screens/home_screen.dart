import 'package:emergency_app/Screens/Help_me/first_screen.dart';
import 'package:emergency_app/Screens/Want_to_help/first_screen.dart';
import 'package:emergency_app/Screens/Want_to_help/dashboard_screen.dart';
import 'package:emergency_app/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedButton = ""; // Track selected button

  Future<void> handleButtonTap(String buttonText) async {
    setState(() {
      selectedButton = buttonText;
    });

    if (buttonText == "Help me!") {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => HelpMeScreen1()),
      );
    } else if (buttonText == "I want to help.") {
      // Check if user is already logged in
      final isLoggedIn = await AuthService.isLoggedIn();

      if (isLoggedIn) {
        // User is logged in, go to dashboard
        final userData = await AuthService.getUserData();
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DashboardScreen(
              userEmail: userData['email'],
              userName: userData['name'],
              userProfilePic: userData['profilePic'],
            ),
          ),
        );
      } else {
        // User not logged in, go to volunteer flow
        if (!mounted) return;
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WantToHelpScreen0()),
        );
      }
    } else if (buttonText == "RL Agent Model") {
      await _launchRLAgentURL();
    }
  }

  Future<void> _launchRLAgentURL() async {
    final Uri uri = Uri.parse('https://rescue-and-search-ahmmxngzcelzbrkkydspwc.streamlit.app/');

    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not launch the RL Agent Model')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Background Image
          Image.asset(
            'assets/images/background.jpg',
            fit: BoxFit.cover,
          ),

          // Curved Black Box at the Bottom
          Align(
            alignment: Alignment.bottomCenter,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Curved Top Section
                ClipPath(
                  clipper: CircularCurveClipper(),
                  child: Container(
                    width: double.infinity,
                    height: 150,
                    color: Colors.black,
                    alignment: Alignment.center,
                    child: Text(
                      'RESCUE',
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                // Gray Line Below the Curved Section
                Container(
                  width: double.infinity,
                  height: 2,
                  color: Color(0xFF616161),
                ),

                // Black Box with Buttons
                Container(
                  height: MediaQuery.of(context).size.height * 0.6, // Increased height to accommodate third button
                  width: double.infinity,
                  color: Colors.black,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      HoverButton(
                        text: "Help me!",
                        isSelected: selectedButton == "Help me!",
                        onTap: () => handleButtonTap("Help me!"),
                      ),
                      SizedBox(height: 34),
                      HoverButton(
                        text: "I want to help.",
                        isSelected: selectedButton == "I want to help.",
                        onTap: () => handleButtonTap("I want to help."),
                      ),
                      SizedBox(height: 34),
                      HoverButton(
                        text: "RL Agent Model",
                        isSelected: selectedButton == "RL Agent Model",
                        onTap: () => handleButtonTap("RL Agent Model"),
                      ),
                    ],
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

// Custom Clipper for Rounded Curve
class CircularCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, 75);

    // Create a rounded curve (flipped upwards)
    path.quadraticBezierTo(
      size.width / 2, -75,
      size.width, 75,
    );

    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => true;
}

// Custom Button
class HoverButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final bool isSelected;

  HoverButton({
    required this.text,
    required this.onTap,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 250,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(41),
            border: Border.all(color: Colors.white, width: 2),
          ),
          alignment: Alignment.center,
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.black : Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}