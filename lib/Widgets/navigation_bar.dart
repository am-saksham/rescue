import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class NavigationBarWidget extends StatelessWidget implements PreferredSizeWidget {
  const NavigationBarWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white, // White background
      elevation: 0, // Remove shadow
      leading: Padding(
        padding: const EdgeInsets.only(left: 32.0), // Shift hamburger more to the left
        child: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black), // Black hamburger menu
          onPressed: () {
            // TODO: Handle menu action
          },
        ),
      ),
      title: Text(
        "RESCUE",
        style: GoogleFonts.poppins(
          color: Colors.black, // Black text
          fontSize: 22,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true, // Center the title
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}