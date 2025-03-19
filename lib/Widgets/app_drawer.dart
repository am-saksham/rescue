import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppDrawer extends StatelessWidget {
  final String selectedItem; // Stores the selected screen

  const AppDrawer({super.key, required this.selectedItem});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.black, // Full black background
        padding: const EdgeInsets.symmetric(horizontal: 32), // Add horizontal padding
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start, // Align text to the left
          children: [
            const SizedBox(height: 50), // Space from the top
            Text(
              "RESCUE",
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12), // Space below title
            Container(
              height: 1, // Thickness of the line
              color: Colors.grey, // Gray line
              width: double.infinity, // Full width line
            ),
            const SizedBox(height: 50), // Space below the line
            // Drawer options with dynamic arrow
            DrawerItem(title: "Help me!", isSelected: selectedItem == "Help me!"),
            DrawerItem(title: "I Want to Help", isSelected: selectedItem == "I Want to Help"),
            DrawerItem(title: "Safety Guides", isSelected: selectedItem == "Safety Guides"),
            DrawerItem(title: "Compass", isSelected: selectedItem == "Compass"),
            DrawerItem(title: "Map", isSelected: selectedItem == "Map"),
            DrawerItem(title: "News and Alert", isSelected: selectedItem == "News and Alert"),
            DrawerItem(title: "Helpline", isSelected: selectedItem == "Helpline"),
            DrawerItem(title: "Edit Profile", isSelected: selectedItem == "Edit Profile"),
          ],
        ),
      ),
    );
  }
}

// Custom widget for drawer items
class DrawerItem extends StatelessWidget {
  final String title;
  final bool isSelected;

  const DrawerItem({super.key, required this.title, this.isSelected = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context); // Close drawer before navigating

        String route = ''; // Determine the route based on the title
        switch (title) {
          case "Help me!":
            route = '/help_me';
            break;
          case "I Want to Help":
            route = '/i_want_to_help';
            break;
          case "Safety Guides":
            route = '/safety_guides';
            break;
          case "Compass":
            route = '/compass';
            break;
          case "Map":
            route = '/map';
            break;
          case "News and Alert":
            route = '/news_alert';
            break;
          case "Helpline":
            route = '/helpline';
            break;
          case "Edit Profile":
            route = '/edit_profile';
            break;
        }

        if (route.isNotEmpty) {
          Navigator.pushReplacementNamed(context, route);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            if (isSelected)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Text(
                  "▶", // Triangular arrow
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            Text(
              title,
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}