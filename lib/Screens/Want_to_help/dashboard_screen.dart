import 'package:emergency_app/Screens/Want_to_help/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../Widgets/app_drawer.dart';
import '../../Widgets/navigation_bar.dart';  // Import the NavigationBarWidget
import '../../auth_service.dart';

class DashboardScreen extends StatelessWidget {
  final String? userEmail;
  final String? userName;
  final String? userProfilePic;

  const DashboardScreen({
    super.key,
    this.userEmail,
    this.userName,
    this.userProfilePic,
  });

  Future<void> _logout(BuildContext context) async {
    await AuthService.logout();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => WantToHelpScreen0()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: _scaffoldKey,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey),  // Use the same NavigationBarWidget
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
          Positioned.fill(
            top: 240,  // Adjust this value to match your header positioning
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 20),
              child: Column(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: userProfilePic != null
                          ? Image.network(
                        userProfilePic!,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            _buildDefaultProfileIcon(),
                      )
                          : _buildDefaultProfileIcon(),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Welcome, ${userName ?? 'User'}!",
                    style: GoogleFonts.poppins(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    userEmail ?? 'No email provided',
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 30),
                  // Add your dashboard content here
                  // For example, you can add action buttons:
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Add dashboard action
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                      child: Text(
                        'View Emergency Requests',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _logout(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(29),
                        ),
                      ),
                      child: Text(
                        'Logout',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDefaultProfileIcon() {
    return Container(
      color: Colors.grey.shade200,
      child: const Icon(
        Icons.person,
        size: 50,
        color: Colors.black54,
      ),
    );
  }
}