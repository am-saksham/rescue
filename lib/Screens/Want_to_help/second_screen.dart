import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:emergency_app/Screens/Want_to_help/third_screen.dart';
import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:geolocator/geolocator.dart';
import '../../Widgets/header.dart';
import '../../Widgets/navigation_bar.dart';

class WantToHelpScreen1 extends StatelessWidget {
  WantToHelpScreen1({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  Future<String> getDeviceIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "unknown"; // Return a default value if the API fails
      }
    } catch (e) {
      debugPrint("Error getting IP address: $e");
      return "unknown"; // Return a default value if there's an error
    }
  }

  Future<void> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return;
    }

    Position position = await Geolocator.getCurrentPosition();
    _locationController.text = "${position.latitude}, ${position.longitude}";
  }

  void _saveVolunteerDetails(BuildContext context) async {
    try {
      String deviceIp = await getDeviceIp();
      final url = Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers');

      // Validate all fields
      if (_nameController.text.isEmpty ||
          _contactController.text.isEmpty ||
          _locationController.text.isEmpty ||
          _messageController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please fill all the fields before proceeding.",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'contact': _contactController.text,
          'message': _messageController.text,
          'ip_address': deviceIp,
        }),
      );

      final responseBody = jsonDecode(response.body);

      if (response.statusCode == 201) {
        if (responseBody['success'] == true && responseBody['_id'] != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                responseBody['message'] ?? "Volunteer saved!",
                style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => WantToHelpScreen2(
                volunteerId: responseBody['_id'],
              ),
            ),
          );
        } else {
          throw Exception("Invalid response format");
        }
      } else if (response.statusCode == 400) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseBody['message'] ?? "This contact already exists!",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.orange,
          ),
        );
      } else {
        throw Exception("Failed with status code: ${response.statusCode}");
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Failed to save details. Please try again.",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
        ),
      );
      debugPrint("Error saving volunteer details: $e");
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
          const HeaderWidget(number: "2"),
          Positioned.fill(
            top: 240,
            child: SingleChildScrollView(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "NAME:",
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        hintText: "Enter your name...",
                        hintStyle: GoogleFonts.poppins(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "CONTACT NUMBER:",
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _contactController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(10),
                      ],
                      decoration: InputDecoration(
                        hintText: "Enter your contact number...",
                        hintStyle: GoogleFonts.poppins(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "LOCATION:",
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _locationController,
                      decoration: InputDecoration(
                        hintText: "Enter your location...",
                        hintStyle: GoogleFonts.poppins(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _getCurrentLocation,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(LucideIcons.mapPin,
                              color: Colors.grey, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            "Track my location",
                            style: GoogleFonts.poppins(
                                fontSize: 14,
                                color: Colors.grey,
                                fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "HOW CAN YOU HELP:",
                      style: GoogleFonts.poppins(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        hintText: "Enter your message...",
                        hintStyle: GoogleFonts.poppins(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 16),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.isEmpty ||
                              _contactController.text.isEmpty ||
                              _locationController.text.isEmpty ||
                              _messageController.text.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please fill all the fields before proceeding.",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
                            // Navigate to the second screen
                            _saveVolunteerDetails(context);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(29),
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                        ),
                        child: Text(
                          "SAVE MY DETAILS",
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
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
