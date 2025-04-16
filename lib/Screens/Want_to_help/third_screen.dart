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

  Future<void> _pickImage() async {
    var status = await Permission.photos.request();
    if (status.isGranted) {
      final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

      if (pickedFile != null) {
        setState(() {
          _imageFile = File(pickedFile.path);
        });

        await uploadImage(_imageFile!);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Permission denied. Cannot pick image.")),
      );
    }
  }

  Future<void> uploadImage(File imageFile) async {
    setState(() {
      _isUploading = true;
    });

    final uri = Uri.parse('https://rescue-api-zwxb.onrender.com/api/volunteers/${widget.volunteerId}/photo');

    final request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('image', imageFile.path));
    print("Uploading to: ${uri.toString()}");

    try {
      final response = await request.send();
      final responseBody = await response.stream.bytesToString();

      print("Status code: ${response.statusCode}");
      print("Response body: $responseBody");

      setState(() {
        _isUploading = false;
      });

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Image uploaded successfully!")),
        );
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final Map<String, dynamic> jsonResponse = jsonDecode(responseBody);
        final message = jsonResponse['message'] ?? 'Failed to upload image. Try again.';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      setState(() {
        _isUploading = false;
      });
      print("Upload error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error occurred: $e")),
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
          const HeaderWidget(number: "3"),
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
      ),
    );
  }
}