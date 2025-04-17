import 'package:emergency_app/Screens/Want_to_help/first_screen.dart';
import 'package:flutter/material.dart';
import 'package:emergency_app/Screens/Want_to_help/dashboard_screen.dart';
import 'auth_service.dart';

class AuthChecker extends StatelessWidget {
  const AuthChecker({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: AuthService.getUserData(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final userData = snapshot.data ?? {};
        final isLoggedIn = userData['isLoggedIn'] == true;

        // For "I Want to Help" flow
        return isLoggedIn
            ? DashboardScreen(
          userEmail: userData['email'],
          userName: userData['name'],
          userProfilePic: userData['profilePic'],
        )
            : WantToHelpScreen0();
      },
    );
  }
}