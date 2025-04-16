import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
      ),
      body: Container(
        color: const Color(0xFFF5F5F5),
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome to your Dashboard!',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 20),
            DashboardCard(
              title: 'My Profile',
              icon: Icons.person_outline,
              onTap: () {
                // Navigate to profile screen
              },
            ),
            DashboardCard(
              title: 'My Locations',
              icon: Icons.location_on_outlined,
              onTap: () {
                // Navigate to locations screen
              },
            ),
            DashboardCard(
              title: 'Log Out',
              icon: Icons.logout,
              onTap: () {
                // Add logout logic
              },
            ),
          ],
        ),
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const DashboardCard({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.black),
        title: Text(
          title,
          style: GoogleFonts.poppins(fontSize: 18),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }
}