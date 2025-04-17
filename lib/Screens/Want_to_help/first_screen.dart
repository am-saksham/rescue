import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:emergency_app/Screens/Want_to_help/second_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/app_drawer.dart';
import '../../Widgets/header.dart';
import '../../Widgets/navigation_bar.dart';
import 'otp_screen.dart';

class WantToHelpScreen0 extends StatelessWidget {
  WantToHelpScreen0({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _emailController = TextEditingController();

  void _handleSubmit(BuildContext context) async {
    String email = _emailController.text.trim();

    // Basic email validation
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid email address")),
      );
      return;
    }

    try {
      // Check if email exists in the system
      final response = await http.get(
        Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/email/$email'),
      );

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);

        if (responseData['exists'] == true) {
          // Email exists, proceed to OTP screen
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(to_email: email),
            ),
          );
        } else {
          // Email not found
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Email not registered. Please register first.")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Error verifying email. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Connection error: ${e.toString()}")),
      );
    }
  }

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
          const HeaderWidget(number: "1"),
          Positioned.fill(
            top: 240,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "EMAIL ADDRESS:",
                      style: GoogleFonts.poppins(
                        fontSize: 22,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter your email address...",
                        hintStyle: GoogleFonts.poppins(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => _handleSubmit(context),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                        ),
                        child: Text(
                          'Send OTP',
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: RichText(
                        text: TextSpan(
                          text: 'First time here? ',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                          ),
                          children: [
                            TextSpan(
                              text: 'Register Now',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.black87,
                                fontWeight: FontWeight.w400,
                                decoration: TextDecoration.underline,
                              ),
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (context) => WantToHelpScreen1()),
                                  );
                                },
                            ),
                          ],
                        ),
                      ),
                    ),
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