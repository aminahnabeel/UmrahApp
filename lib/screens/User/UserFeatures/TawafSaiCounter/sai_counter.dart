import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart'; // Import CustomAppBar

class SaiCounter extends StatefulWidget {
  const SaiCounter({super.key});

  @override
  State<SaiCounter> createState() => _SaiCounterState();
}

class _SaiCounterState extends State<SaiCounter> {
  int saiCount = 0;
  double totalDistance = 0.0;
  Position? lastPosition;
  StreamSubscription<Position>? _positionStreamSub;

  static const double saiDistance = 394; // Safa <-> Marwa distance
  static const double minAccuracyMeters = 25.0;
  static const double minMovementMeters = 2.5;
  static const double maxWalkingSpeedMps = 3.5;
  String statusMessage = "Initializing location...";
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    super.dispose();
  }

  Future<void> _startLocationTracking() async {
    setState(() => statusMessage = "Checking location...");

    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => statusMessage = "GPS is disabled.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() => statusMessage = "Permission denied.");
      return;
    }

    setState(() {
      statusMessage = "Tracking... Start walking";
      isTracking = true;
    });

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2,
      ),
    ).listen((Position position) {
      // Ignore low-quality GPS fixes that can drift while standing still.
      if (position.accuracy > minAccuracyMeters) {
        return;
      }

      if (lastPosition == null) {
        lastPosition = position;
        return;
      }

      final double distance = Geolocator.distanceBetween(
        lastPosition!.latitude,
        lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      final DateTime? lastTime = lastPosition!.timestamp;
      final DateTime? currentTime = position.timestamp;
      final double seconds = (lastTime != null && currentTime != null)
          ? currentTime.difference(lastTime).inMilliseconds / 1000.0
          : 0.0;
      final double computedSpeed = seconds > 0 ? distance / seconds : 0.0;

      // Reject jitter and unrealistic GPS jumps.
      if (distance < minMovementMeters || computedSpeed > maxWalkingSpeedMps) {
        lastPosition = position;
        return;
      }

      setState(() {
        totalDistance += distance;
        statusMessage = "Tracking... Keep walking";
        if (totalDistance >= saiDistance) {
          saiCount++;
          totalDistance = 0.0;
          statusMessage = "Round $saiCount completed!";
        }
      });

      lastPosition = position;
    });
  }

  void _resetCounter() {
    setState(() {
      saiCount = 0;
      totalDistance = 0.0;
      statusMessage = "Counter reset.";
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 1. Same CustomAppBar
      appBar: const CustomAppBar(
        title: "Sa’i Auto Counter",
        showBackButton: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E3A8A), Color(0xFF3B82F6)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                
                // Icon for Sa'i
                const Icon(Icons.directions_run, size: 80, color: Colors.white),
                
                const SizedBox(height: 20),

                Text(
                  "$saiCount / 7 Rounds",
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                
                const SizedBox(height: 30),

                // Distance Card (Matching Tawaf Style)
                Card(
                  color: Colors.white.withOpacity(0.15),
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      border: Border.all(color: Colors.white.withOpacity(0.4), width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "${totalDistance.toStringAsFixed(1)} m",
                          style: const TextStyle(
                            fontSize: 50,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const Text(
                          "Current Leg Progress",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 40),

                // Status Message
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white70, fontSize: 15),
                  ),
                ),

                const SizedBox(height: 40),

                // Reset Button (Same as Tawaf)
                ElevatedButton.icon(
                  onPressed: _resetCounter,
                  icon: const Icon(Icons.refresh),
                  label: const Text("Reset Tracking"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF1E3A8A),
                    padding: const EdgeInsets.symmetric(horizontal: 45, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 6,
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}