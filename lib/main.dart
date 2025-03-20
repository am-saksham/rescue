import 'package:emergency_app/Screens/Help_me/first_screen.dart';
import 'package:emergency_app/Screens/Want_to_help/first_screen.dart';
import 'package:emergency_app/Screens/home_screen.dart';
import 'package:emergency_app/Screens/safety_guide.dart';
import 'package:emergency_app/compass_map.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: HomeScreen(),
      debugShowCheckedModeBanner: false,
      initialRoute: '/home', // Default screen
      routes: {
        '/home': (context) => HomeScreen(),
        '/help_me': (context) => HelpMeScreen1(),
        '/i_want_to_help': (context) => WantToHelpScreen1(),
        '/safety_guides': (context) => SafetyGuideScreen(),
        '/compass': (context) => CompassMapScreen(),
        '/map': (context) => CompassMapScreen(),
      },
    );
  }
}

