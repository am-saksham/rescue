import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../Widgets/header.dart';
import '../../Widgets/navigation_bar.dart';
import 'package:http/http.dart' as http;
import 'otp_screen.dart';

class WantToHelpScreen2 extends StatefulWidget {
  final String volunteerId;

  const WantToHelpScreen2({
    super.key,
    required this.volunteerId,
  });

  @override
  State<WantToHelpScreen2> createState() => _WantToHelpScreen2State();
}

class _WantToHelpScreen2State extends State<WantToHelpScreen2> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  File? _imageFile;
  bool _isUploading = false;
  bool _isLoadingEmail = true;
  String? _volunteerEmail;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    fetchVolunteerEmail();
  }

  Future<void> fetchVolunteerEmail() async {
    setState(() {
      _isLoadingEmail = true;
      _errorMessage = null;
    });

    try {
      final uri = Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/${widget.volunteerId}');
      final response = await http.get(uri);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Handle both possible response formats:
        // 1. Direct email field
        // 2. Nested in data object
        final email = data['email'] ?? data['data']?['email'];

        if (email != null) {
          setState(() {
            _volunteerEmail = email.toString();
            _isLoadingEmail = false;
          });
          debugPrint('✅ Fetched email: $_volunteerEmail');
        } else {
          throw Exception('Email not found in response');
        }
      } else {
        throw Exception('Failed to load volunteer data: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('⚠️ Error fetching email: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoadingEmail = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to load volunteer data")),
      );
    }
  }

  Future<void> _pickImage() async {
    if (_volunteerEmail == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please wait while we load your information")),
      );
      return;
    }

    var status = await Permission.photos.request();
    if (!status.isGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Cannot pick image.")),
      );
      return;
    }

    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() => _imageFile = File(pickedFile.path));
      await uploadImage(_imageFile!);
    }
  }

  Future<void> uploadImage(File imageFile) async {
    setState(() => _isUploading = true);

    try {
      final uri = Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/${widget.volunteerId}/photo');
      final request = http.MultipartRequest('POST', uri)
        ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));

      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      setState(() => _isUploading = false);

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(responseBody);
        final emailFromResponse = jsonResponse['email'] ?? _volunteerEmail;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );

        if (emailFromResponse != null) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OtpScreen(to_email: emailFromResponse),
            ),
          );
        }
      } else {
        throw Exception('Upload failed with status ${response.statusCode}');
      }
    } catch (e) {
      setState(() => _isUploading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Upload failed: ${e.toString()}")),
      );
      debugPrint("Upload error: $e");
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
          const HeaderWidget(number: "3"),

          // Loading indicator when fetching email
          if (_isLoadingEmail)
            const Center(child: CircularProgressIndicator()),

          // Error message if email fetch failed
          if (_errorMessage != null)
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Failed to load data",
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  ElevatedButton(
                    onPressed: fetchVolunteerEmail,
                    child: const Text("Retry"),
                  ),
                ],
              ),
            ),

          // Main content when email is loaded
          if (!_isLoadingEmail && _errorMessage == null) ...[
            Positioned(
              top: 280,
              left: MediaQuery.of(context).size.width * 0.5 - 90,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.black,
                    width: 4,
                  ),
                ),
                child: CircleAvatar(
                  radius: 90,
                  backgroundColor: Colors.white,
                  backgroundImage: _imageFile != null ? FileImage(_imageFile!) : null,
                  child: _imageFile == null
                      ? const Icon(
                    Icons.person_outline,
                    size: 90,
                    color: Colors.black,
                  )
                      : null,
                ),
              ),
            ),
            Positioned(
              top: 520,
              left: MediaQuery.of(context).size.width * 0.5 - 130,
              child: ElevatedButton(
                onPressed: _isUploading ? null : _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(29),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                ),
                child: _isUploading
                    ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    strokeWidth: 2.5,
                  ),
                )
                    : Text(
                  'UPLOAD MY PICTURE',
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}