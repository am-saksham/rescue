import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import '../../Widgets/navigation_bar.dart';
import '../../Widgets/app_drawer.dart';
import '../../Widgets/header.dart';
import '../../auth_service.dart';
import 'dashboard_screen.dart';

class OtpScreen extends StatefulWidget {
  final String to_email;

  const OtpScreen({super.key, required this.to_email});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<TextEditingController> _otpControllers =
  List.generate(4, (index) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(4, (index) => FocusNode());

  int _remainingSeconds = 60;
  Timer? _timer;
  bool _canResend = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _sendOtpEmail(); // Send OTP email when the screen is initialized
    _startTimer(); // start timer on first load
  }

  // API to send OTP to the email
  Future<void> _sendOtpEmail() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final uri = Uri.parse('https://emailjs-rescue-api.onrender.com/send-otp');
      final response = await http.post(
        uri,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': widget.to_email}),
      ).timeout(const Duration(seconds: 30));

      final responseData = jsonDecode(response.body);

      if (response.statusCode == 200 && responseData['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("OTP sent to your email.")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(responseData['message'] ?? "Failed to send OTP")),
        );
      }
    } on TimeoutException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Request timed out. Please try again.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to send OTP. Please try again.")),
      );
      debugPrint('Error sending OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // API to verify OTP entered by the user
  // API to verify OTP entered by the user
  Future<void> _verifyOtp(String otp) async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Step 1: Verify OTP with your OTP service
      final verifyResponse = await http.post(
        Uri.parse('https://emailjs-rescue-api.onrender.com/verify-otp'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': widget.to_email,
          'code': otp,
        }),
      ).timeout(const Duration(seconds: 30));

      final verifyData = jsonDecode(verifyResponse.body);

      if (verifyResponse.statusCode == 200 && verifyData['success'] == true) {
        // Step 2: Get user details directly from your Volunteer API
        final userResponse = await http.get(
          Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/email/${widget.to_email}'),
        );

        final userData = jsonDecode(userResponse.body);

        if (userResponse.statusCode == 200 && userData['exists'] == true) {
          // Step 3: Get full user details using the ID
          final detailsResponse = await http.get(
            Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/${userData['_id']}'),
          );

          final detailsData = jsonDecode(detailsResponse.body);

          // Save user data for persistent login
          await AuthService.saveUserData(
            email: widget.to_email,
            name: detailsData['data']['name'] ?? 'User',
            profilePic: detailsData['data']['image'] ?? '',
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => DashboardScreen(
                userEmail: widget.to_email,
                userName: detailsData['data']['name'],
                userProfilePic: detailsData['data']['image'],
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("User details not found")),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(verifyData['message'] ?? "Invalid OTP")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Failed to verify OTP. Please try again.")),
      );
      debugPrint('Error verifying OTP: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Timer to manage OTP resend
  void _startTimer() {
    setState(() {
      _remainingSeconds = 60;
      _canResend = false;
    });

    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds == 0) {
        timer.cancel();
        setState(() {
          _canResend = true;
        });
      } else {
        setState(() {
          _remainingSeconds--;
        });
      }
    });
  }

  void _handleSubmit() {
    String otp = _otpControllers.map((c) => c.text).join();
    if (otp.length == 4 && int.tryParse(otp) != null) {
      _verifyOtp(otp);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter a valid 4-digit OTP.")),
      );
    }
  }

  void _handleResend() {
    if (_canResend && !_isLoading) {
      _sendOtpEmail();
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var controller in _otpControllers) {
      controller.dispose();
    }
    for (var node in _focusNodes) {
      node.dispose();
    }
    super.dispose();
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
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  Text(
                    "Enter OTP",
                    style: GoogleFonts.poppins(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(4, (index) {
                      return SizedBox(
                        width: 60,
                        child: TextField(
                          controller: _otpControllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: GoogleFonts.poppins(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                          decoration: InputDecoration(
                            counterText: '',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(color: Colors.black, width: 2),
                            ),
                          ),
                          onChanged: (value) {
                            if (value.length == 1 && index < 3) {
                              _focusNodes[index + 1].requestFocus();
                            } else if (value.isEmpty && index > 0) {
                              _focusNodes[index - 1].requestFocus();
                            }
                          },
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _handleSubmit,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : Text(
                        'Submit',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _canResend
                      ? TextButton(
                    onPressed: _isLoading ? null : _handleResend,
                    child: Text(
                      'Resend OTP',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  )
                      : Text(
                    'Resend available in 00:${_remainingSeconds.toString().padLeft(2, '0')}',
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}