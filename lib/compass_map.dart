import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'dart:math' as math;
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../../Widgets/navigation_bar.dart';
import 'package:emergency_app/Widgets/app_drawer.dart';

class CompassMapScreen extends StatefulWidget {
  CompassMapScreen({super.key});

  @override
  _CompassMapScreenState createState() => _CompassMapScreenState();
}

class _CompassMapScreenState extends State<CompassMapScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String selectedButton = "Nearest Hospitals"; // Default selection
  late GoogleMapController _mapController;
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position position = await Geolocator.getCurrentPosition();
    setState(() {
      _currentPosition = LatLng(position.latitude, position.longitude);
    });

    _mapController.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition!, 15));
  }

  String getCardinalDirection(double degrees) {
    if (degrees >= 337.5 || degrees < 22.5) return "N";
    if (degrees >= 22.5 && degrees < 67.5) return "NE";
    if (degrees >= 67.5 && degrees < 112.5) return "E";
    if (degrees >= 112.5 && degrees < 157.5) return "SE";
    if (degrees >= 157.5 && degrees < 202.5) return "S";
    if (degrees >= 202.5 && degrees < 247.5) return "SW";
    if (degrees >= 247.5 && degrees < 292.5) return "W";
    return "NW";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedItem: "Compass"),
      body: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(color: Color(0xFFE5E5E5), thickness: 2, height: 1),
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
              const SizedBox(height: 30),
              Center(
                child: Text(
                  "COMPASS & MAP",
                  style: GoogleFonts.poppins(
                    color: Colors.black,
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Center(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: const Divider(
                    color: Color(0xFFE5E5E5),
                    thickness: 2,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              /// Compass and Buttons Row
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    /// Compass Section
                    StreamBuilder<CompassEvent?>(
                      stream: FlutterCompass.events,
                      builder: (context, snapshot) {
                        if (snapshot.hasError) return const Text("Error loading compass");
                        if (snapshot.connectionState == ConnectionState.waiting || snapshot.data?.heading == null) {
                          return const CircularProgressIndicator();
                        }

                        double direction = snapshot.data!.heading ?? 0;
                        String cardinalDirection = getCardinalDirection(direction);

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Transform.rotate(
                              angle: (direction * (math.pi / 180) * -1),
                              child: CustomPaint(size: const Size(120, 120), painter: CompassPainter()),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              "${direction.toStringAsFixed(1)}° $cardinalDirection",
                              style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                            ),
                          ],
                        );
                      },
                    ),

                    /// Transparent Buttons Section
                    Column(
                      children: [
                        SelectableButton(
                          label: "Nearest Hospitals",
                          isSelected: selectedButton == "Nearest Hospitals",
                          onTap: () => setState(() => selectedButton = "Nearest Hospitals"),
                        ),
                        const SizedBox(height: 10),
                        SelectableButton(
                          label: "Fire Stations",
                          isSelected: selectedButton == "Fire Stations",
                          onTap: () => setState(() => selectedButton = "Fire Stations"),
                        ),
                        const SizedBox(height: 10),
                        SelectableButton(
                          label: "Clean Water Sources",
                          isSelected: selectedButton == "Clean Water Sources",
                          onTap: () => setState(() => selectedButton = "Clean Water Sources"),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          /// Google Map Container
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: MediaQuery.of(context).size.height * 0.45,
              width: double.infinity,
              child: _currentPosition == null
                  ? const Center(child: CircularProgressIndicator())
                  : GoogleMap(
                initialCameraPosition: CameraPosition(target: _currentPosition!, zoom: 15),
                markers: {
                  Marker(
                    markerId: const MarkerId("current_location"),
                    position: _currentPosition!,
                    infoWindow: const InfoWindow(title: "You are here"),
                  ),
                },
                onMapCreated: (controller) => _mapController = controller,
                myLocationEnabled: true,
                zoomControlsEnabled: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


/// Selectable Button Widget
class SelectableButton extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const SelectableButton({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 147,
      height: 40,
      decoration: BoxDecoration(
        color: isSelected ? Colors.black : Colors.transparent,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextButton(
        onPressed: onTap,
        style: TextButton.styleFrom(
          backgroundColor: Colors.transparent,
          padding: EdgeInsets.zero,
        ),
        child: Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }
}

/// Compass Painter
class CompassPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    final circlePaint = Paint()
      ..color = Colors.grey.shade200
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius, circlePaint);

    final borderPaint = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawCircle(center, radius, borderPaint);

    const labels = ["N", "E", "S", "W"];
    const labelOffsets = [Offset(0, -1), Offset(1, 0), Offset(0, 1), Offset(-1, 0)];

    for (int i = 0; i < labels.length; i++) {
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      final offset = center + labelOffsets[i] * (radius - 20);
      textPainter.paint(canvas, offset - Offset(textPainter.width / 2, textPainter.height / 2));
    }

    final needlePaint = Paint()
      ..color = Colors.red
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx, center.dy - radius + 15), needlePaint);

    final greyNeedlePaint = Paint()
      ..color = Colors.grey
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(center, Offset(center.dx, center.dy + radius - 15), greyNeedlePaint);

    final centerCirclePaint = Paint()..color = Colors.black;
    canvas.drawCircle(center, 5, centerCirclePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}