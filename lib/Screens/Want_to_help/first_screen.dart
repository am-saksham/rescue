import 'package:flutter/material.dart';

import '../../Widgets/header.dart';
import '../../Widgets/navigation_bar.dart';

class WantToHelpScreen1 extends StatelessWidget {
  const WantToHelpScreen1({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const NavigationBarWidget(),
      body: Stack(
        children: [
          Column(
            children: [
              const Divider(
                color: Color(0xFFE5E5E5), // Gray dividing line
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

          // Reusable Header Widget with "1" inside the circle
          const HeaderWidget(number: "1"),
        ],
      ),
    );
  }
}
