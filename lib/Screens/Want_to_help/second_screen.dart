import 'dart:async';
import 'dart:convert';
import 'dart:io';
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

class WantToHelpScreen1 extends StatefulWidget {
  const WantToHelpScreen1({super.key});

  @override
  State<WantToHelpScreen1> createState() => _WantToHelpScreen1State();
}

class _WantToHelpScreen1State extends State<WantToHelpScreen1> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();

  StreamSubscription<Position>? _positionStream;
  String? _volunteerId;
  bool _isTracking = false;
  Timer? _locationUpdateTimer;

  @override
  void dispose() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    _nameController.dispose();
    _emailController.dispose();
    _locationController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<String> getDeviceIp() async {
    try {
      final response = await http.get(Uri.parse('https://api.ipify.org'));
      if (response.statusCode == 200) {
        return response.body;
      } else {
        return "unknown";
      }
    } catch (e) {
      debugPrint("Error getting IP address: $e");
      return "unknown";
    }
  }

  // Helper function to normalize email (preserve dots, only lowercase)
  String normalizeEmail(String email) {
    return email.trim().toLowerCase();
  }

  // Email validation function
  bool isValidEmail(String email) {
    return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
  }

  Future<void> _toggleLocationTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location services are disabled.')),
      );
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permissions are denied')),
        );
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location permissions are permanently denied')),
      );
      return;
    }

    if (_isTracking) {
      _stopLocationTracking();
    } else {
      _startLocationTracking();
    }
  }

  void _startLocationTracking() {
    setState(() {
      _isTracking = true;
    });

    // Get initial position
    Geolocator.getCurrentPosition().then((position) {
      _updateLocationUI(position);
      if (_volunteerId != null) {
        _updateVolunteerLocation(position);
      }
    });

    // Start periodic updates
    _positionStream = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 0, // Get all updates
      ),
    ).listen((Position position) {
      _updateLocationUI(position);
      if (_volunteerId != null) {
        _updateVolunteerLocation(position);
      }
    });

    // Setup timer for periodic updates (every second)
    _locationUpdateTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isTracking) {
        Geolocator.getLastKnownPosition().then((position) {
          if (position != null) {
            _updateLocationUI(position);
            if (_volunteerId != null) {
              _updateVolunteerLocation(position);
            }
          }
        });
      }
    });
  }

  void _stopLocationTracking() {
    _positionStream?.cancel();
    _locationUpdateTimer?.cancel();
    setState(() {
      _isTracking = false;
    });
  }

  void _updateLocationUI(Position position) {
    setState(() {
      _locationController.text = "${position.latitude}, ${position.longitude}";
    });
  }

  Future<void> _updateVolunteerLocation(Position position) async {
    try {
      final url = Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/location');

      final response = await http.put(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': normalizeEmail(_emailController.text),
          'latitude': position.latitude,
          'longitude': position.longitude,
        }),
      );

      if (response.statusCode != 200) {
        debugPrint('Failed to update location: ${response.body}');
      }
    } catch (e) {
      debugPrint('Error updating location: $e');
    }
  }

  void _saveVolunteerDetails(BuildContext context) async {
    try {
      // Validate fields first
      if (_nameController.text.isEmpty ||
          _emailController.text.isEmpty ||
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

      // Validate email format
      if (!isValidEmail(_emailController.text)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Please enter a valid email address",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      String deviceIp = await getDeviceIp();
      final url = Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'name': _nameController.text,
          'email': normalizeEmail(_emailController.text),
          'message': _messageController.text,
          'ip_address': deviceIp,
        }),
      );

      final responseBody = jsonDecode(response.body);

      // Updated response handling
      if (response.statusCode == 201) {
        // Check for both possible response formats (old and new)
        final volunteerId = responseBody['_id'] ?? responseBody['data']?['_id'];

        if (volunteerId == null) {
          throw FormatException("Missing volunteer ID in response");
        }

        setState(() => _volunteerId = volunteerId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              responseBody['message'] ?? "Registration successful!",
              style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            backgroundColor: Colors.green,
          ),
        );

        _startLocationTracking();

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WantToHelpScreen2(volunteerId: volunteerId),
          ),
        );
      } else if (response.statusCode == 400) {
        final errorMsg = responseBody['message'] ?? "This email is already registered";
        throw Exception(errorMsg);
      } else {
        throw Exception("Request failed with status ${response.statusCode}");
      }
    } on FormatException catch (e) {
      debugPrint("Response format error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            "Server response format error. Please try again.",
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
        ),
      );
    } catch (e) {
      debugPrint("Registration error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceAll("Exception: ", ""),
            style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          backgroundColor: Colors.red,
        ),
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
          const HeaderWidget(number: "2"),
          Positioned.fill(
            top: 240,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
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
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      "EMAIL ID:",
                      style: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: "Enter your email ID...",
                        hintStyle: GoogleFonts.poppins(color: Colors.black),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 20, horizontal: 16),
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
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(29),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _toggleLocationTracking,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            _isTracking ? LucideIcons.mapPinOff : LucideIcons.mapPin,
                            color: _isTracking ? Colors.green : Colors.grey,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            _isTracking ? "Stop Tracking" : "Track my location",
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              color: _isTracking ? Colors.green : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
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
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: const BorderSide(color: Colors.black, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (_nameController.text.isEmpty ||
                              _emailController.text.isEmpty ||
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
                          } else if (!isValidEmail(_emailController.text)) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  "Please enter a valid email address",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500),
                                ),
                                backgroundColor: Colors.red,
                              ),
                            );
                          } else {
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