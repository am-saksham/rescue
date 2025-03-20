import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class HeaderWidget extends StatelessWidget {
  final String number; // Number inside the circle

  const HeaderWidget({super.key, required this.number});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Back Button
        Positioned(
          top: 30,
          left: 32,
          child: IconButton(
            icon: const Icon(Icons.arrow_back_rounded, color: Colors.black, size: 28),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),

        // Centered Column with Circle and Divider
        Positioned(
          top: 60,
          left: 0,
          right: 0,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Black Circle with Number
              Container(
                width: 83,
                height: 83,
                decoration: const BoxDecoration(
                  color: Colors.black,
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Text(
                  number,
                  style: GoogleFonts.poppins(
                    color: Colors.white,
                    fontSize: 38,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 60), // Spacing before the divider

              // Wider Divider Below the Circle
              SizedBox(
                width: MediaQuery.of(context).size.width * 0.8, // 80% of screen width
                child: const Divider(
                  color: Color(0xFFE5E5E5), // Gray divider
                  thickness: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}