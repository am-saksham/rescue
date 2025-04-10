import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../Widgets/navigation_bar.dart';
import '../../Widgets/app_drawer.dart';

class HelpMeScreen5 extends StatefulWidget {
  HelpMeScreen5({super.key});

  @override
  State<HelpMeScreen5> createState() => _HelpMeScreen5State();
}

class _HelpMeScreen5State extends State<HelpMeScreen5> {
  GoogleMapController? _mapController;
  LatLng _currentPosition = const LatLng(20.5937, 78.9629); // Default: India
  LatLng _destination = const LatLng(23.0775, 76.8513); // Your destination coordinates
  bool _isLoading = true;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  String _distance = "...";
  String _duration = "...";
  Timer?_updateTimer;

  @override
  void initState() {
    super.initState();
    _checkGoogleServices();
    _checkPermissionsAndGetLocation();
    _startAutoRefresh();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    super.dispose();
  }

  void _startAutoRefresh() {

    _updateTimer?.cancel();


    _updateTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isLoading) {
        try {
          await _getCurrentLocation();
        } catch (e) {
          print("Error during auto-refresh: $e");
          // Optionally show error to user or retry sooner
        }
      }
    });
  }

  Future<void> _checkGoogleServices() async {
    GooglePlayServicesAvailability availability =
    await GoogleApiAvailability.instance.checkGooglePlayServicesAvailability();

    if (availability != GooglePlayServicesAvailability.success) {
      print("Google Play Services are not available. Maps may not work properly.");
    }
  }

  Future<void> _checkPermissionsAndGetLocation() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showPermissionDialog();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showPermissionDialog();
      return;
    }

    setState(() {
      _isLoading = false;
    });

    _getCurrentLocation();
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Location Permission Required"),
        content: const Text("Please enable location permissions in settings."),
        actions: [
          TextButton(
            onPressed: () async {
              await openAppSettings();
              Navigator.pop(context);
            },
            child: const Text("Open Settings"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
        ],
      ),
    );
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _addMarkers();
      _getRoute();

      _mapController?.animateCamera(CameraUpdate.newLatLngZoom(_currentPosition, 15));
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _addMarkers() {
    _markers.clear();
    _markers.add(
      Marker(
        markerId: const MarkerId("currentLocation"),
        position: _currentPosition,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId("destination"),
        position: _destination,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    );
  }

  Future<void> _getRoute() async {
    // Replace with your Google Maps API key
    const apiKey = "AIzaSyDNJdTUIO4ztOVUZDD7QfSVPMxy3RDFirE";
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
          'origin=${_currentPosition.latitude},${_currentPosition.longitude}&'
          'destination=${_destination.latitude},${_destination.longitude}&'
          'key=$apiKey',
    );

    try {
      final response = await http.get(url);
      final data = json.decode(response.body);

      if (data['status'] == 'OK') {
        // Update distance and duration
        final distanceText = data['routes'][0]['legs'][0]['distance']['text'];
        final durationText = data['routes'][0]['legs'][0]['duration']['text'];

        setState(() {
          _distance = distanceText;
          _duration = durationText;
        });

        // Decode the polyline points
        final points = data['routes'][0]['overview_polyline']['points'];
        List<LatLng> routeCoordinates = _decodePoly(points);

        setState(() {
          _polylines.add(
            Polyline(
              polylineId: const PolylineId("route"),
              points: routeCoordinates,
              color: Colors.blue,
              width: 5,
            ),
          );
        });

        // Adjust camera to show both points
        LatLngBounds bounds = _boundsFromLatLngList(
          [_currentPosition, _destination],
        );
        _mapController?.animateCamera(
          CameraUpdate.newLatLngBounds(bounds, 100),
        );
      }
    } catch (e) {
      print("Error getting route: $e");
    }
  }

  // Helper function to decode polyline points
  List<LatLng> _decodePoly(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      LatLng p = LatLng(lat / 1E5, lng / 1E5);
      poly.add(p);
    }
    return poly;
  }

  // Helper function to calculate bounds from a list of LatLng points
  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double? x0, x1, y0, y1;
    for (LatLng latLng in list) {
      if (x0 == null) {
        x0 = x1 = latLng.latitude;
        y0 = y1 = latLng.longitude;
      } else {
        if (latLng.latitude > x1!) x1 = latLng.latitude;
        if (latLng.latitude < x0) x0 = latLng.latitude;
        if (latLng.longitude > y1!) y1 = latLng.longitude;
        if (latLng.longitude < y0!) y0 = latLng.longitude;
      }
    }
    return LatLngBounds(
      northeast: LatLng(x1!, y1!),
      southwest: LatLng(x0!, y0!),
    );
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: NavigationBarWidget(scaffoldKey: _scaffoldKey),
      drawer: AppDrawer(selectedItem: 'Help me!'),
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _currentPosition,
              zoom: 15,
            ),
            onMapCreated: (GoogleMapController controller) {
              _mapController = controller;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            markers: _markers,
            polylines: _polylines,
          ),

          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),

          Positioned(
            top: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              onPressed: () {
                _getCurrentLocation();
                _getRoute();
              },
              child: const Icon(Icons.my_location, color: Colors.red),
            ),
          ),

          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: MediaQuery.of(context).size.height * 0.30,
              decoration: const BoxDecoration(
                color: Colors.white,
              ),
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Positioned(
                    bottom: MediaQuery.of(context).size.height * 0.30 - (113 / 2),
                    left: MediaQuery.of(context).size.width / 2 - (113 / 2),
                    child: Container(
                      width: 113,
                      height: 113,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black, width: 3),
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          'assets/images/profile-pic1.jpg',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 56,
                    left: 16,
                    right: 16,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          "Saksham Gupta",
                          style: GoogleFonts.poppins(
                              fontSize: 24, fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 2),
                        Container(
                          width: 100,
                          height: 2,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 10),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              width: 90,
                              height: 60,
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.black, width: 2),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.4),
                                    offset: const Offset(4, 4),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    _duration,
                                    style: GoogleFonts.poppins(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  Text(
                                    _distance,
                                    style: GoogleFonts.poppins(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 30),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  "ID: AG957123",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.normal),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "MOB: 8770119732",
                                  style: GoogleFonts.poppins(
                                      fontSize: 16, fontWeight: FontWeight.normal),
                                ),
                              ],
                            ),
                          ],
                        ),

                        const SizedBox(height: 13),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 162,
                              height: 42,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(13),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: Text(
                                  "Cancel Request",
                                  style: GoogleFonts.poppins(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                            Row(
                              children: [
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.phone, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 17),
                                Container(
                                  width: 50,
                                  height: 50,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Colors.black,
                                  ),
                                  child: IconButton(
                                    icon: const Icon(Icons.message, color: Colors.white),
                                    onPressed: () {},
                                  ),
                                ),
                                const SizedBox(width: 32),
                              ],
                            ),
                          ],
                        ),
                      ],
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
}