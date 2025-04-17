import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../Widgets/navigation_bar.dart';

class SafetyGuideScreen extends StatelessWidget {
  SafetyGuideScreen({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  // Map of guide items to their respective URLs
  final Map<String, String> guideUrls = {
    "Earthquake\nSafety Guide": "https://www.ready.gov/earthquakes",
    "Fire\nSafety Guide": "https://firetechglobal.com/fire-safety-and-prevention-tips-and-guidelines/",
    "Floods\nSafety Guide": "https://www.mass.gov/info-details/flood-safety-tips",
    "How to prepare a\nFirst Aid Kit": "https://www.redcross.org/get-help/how-to-prepare-for-emergencies/anatomy-of-a-first-aid-kit.html",
  };

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedItem: 'Safety Guides'),
      body: Center(
        child: SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height,
          child: Column(
            children: [
              const Divider(
                color: Color(0xFFE5E5E5),
                thickness: 2,
                height: 1,
              ),

              // Back Button
              Padding(
                padding: const EdgeInsets.only(top: 30, left: 20),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 28),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                ),
              ),

              // Title
              const SizedBox(height: 30),
              Text(
                "SAFETY GUIDES",
                style: GoogleFonts.poppins(
                  color: Colors.black,
                  fontSize: 24,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 15),

              // Divider Below Title
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8,
                child: const Divider(
                  color: Color(0xFFE5E5E5),
                  thickness: 2,
                ),
              ),

              const SizedBox(height: 20),

              // Safety Guide Items (Centered)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _safetyGuideItem(Icons.landslide, "Earthquake\nSafety Guide"),
                  _safetyGuideItem(Icons.local_fire_department, "Fire\nSafety Guide"),
                  _safetyGuideItem(Icons.waves, "Floods\nSafety Guide"),
                  _safetyGuideItem(Icons.medical_services, "How to prepare a\nFirst Aid Kit"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _safetyGuideItem(IconData icon, String title) {
    return GestureDetector(
      onTap: () => _launchUrl(guideUrls[title]!),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 77,
              height: 77,
              decoration: const BoxDecoration(
                color: Colors.black,
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Icon(icon, color: Colors.white, size: 45),
            ),
            const SizedBox(width: 15),
            SizedBox(
              width: 180,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.poppins(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    "Read Now",
                    style: GoogleFonts.poppins(
                      color: Color(0xFF939393),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}