import 'package:emergency_app/Screens/Help_me/second_screen.dart';
import 'package:emergency_app/Widgets/app_drawer.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/header.dart';
import '../../Widgets/navigation_bar.dart';

class HelpMeScreen1 extends StatelessWidget {
  HelpMeScreen1({super.key});

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  @override
  Widget build(BuildContext context) {
    final List<String> emergencyOptions = [
      "Earthquake",
      "Fire",
      "Floods",
      "Tsunami",
      "Landslide",
      "Stampede",
      "Other",
    ];

    return Scaffold(
      key: _scaffoldKey,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedItem: 'Help me!',),
      body: SizedBox.expand(
        child: Stack(
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
            const HeaderWidget(number: "1"),
            Positioned.fill(
              top: 240,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "WHAT IS THE EMERGENCY?",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 30),
                    Column(
                      children: emergencyOptions.map((option) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 16),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => HelpMeScreen2(emergencyType: option),
                                ),
                              );
                            },
                            borderRadius: BorderRadius.circular(29),
                            child: Container(
                              width: double.infinity,
                              height: 52,
                              decoration: BoxDecoration(
                                color: Colors.black,
                                borderRadius: BorderRadius.circular(29),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                option,
                                style: GoogleFonts.poppins(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 50),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}