import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart'; 

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

  // Constants to tune for stability
  static const double saiDistance = 394.0; // Distance between Safa and Marwa
  static const double minAccuracyMeters = 20.0; // Ignore low-quality signals
  static const double movementThreshold = 3.0; // Ignore jitters less than 3m
  static const double minWalkingSpeed = 0.5; // Ignore drift (standing still)
  static const double maxWalkingSpeed = 3.5; // Ignore "teleporting" GPS jumps

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
    setState(() => statusMessage = "Checking GPS...");

    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => statusMessage = "Please enable GPS.");
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
      setState(() => statusMessage = "Location permission denied.");
      return;
    }

    setState(() {
      statusMessage = "Ready! Start walking.";
      isTracking = true;
    });

    _positionStreamSub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5, // Only notify if moved 5 meters
      ),
    ).listen((Position position) {
      // 1. Filter by Accuracy
      if (position.accuracy > minAccuracyMeters) return;

      if (lastPosition == null) {
        lastPosition = position;
        return;
      }

      // 2. Calculate Distance from last point
      final double distance = Geolocator.distanceBetween(
        lastPosition!.latitude,
        lastPosition!.longitude,
        position.latitude,
        position.longitude,
      );

      // 3. Filter by Speed and Minimum Movement
      // position.speed is automatically provided by Geolocator in m/s
      bool isActuallyMoving = position.speed > minWalkingSpeed && distance > movementThreshold;
      bool isRealistic = position.speed < maxWalkingSpeed;

      if (isActuallyMoving && isRealistic) {
        setState(() {
          totalDistance += distance;
          statusMessage = "Tracking... Round ${saiCount + 1}";

          // Logic for completing a round
          if (totalDistance >= saiDistance) {
            saiCount++;
            totalDistance = 0.0;
            statusMessage = "Round $saiCount completed!";
            
            if (saiCount >= 7) {
              statusMessage = "Sa'i Completed!";
              isTracking = false;
              _positionStreamSub?.pause();
            }
          }
        });
        lastPosition = position;
      } else {
        // If not moving significantly, we still update status but don't add distance
        if (mounted && totalDistance < saiDistance) {
          setState(() => statusMessage = "Stationary or weak signal...");
        }
      }
    });
  }

  void _resetCounter() {
    setState(() {
      saiCount = 0;
      totalDistance = 0.0;
      statusMessage = "Counter reset.";
      lastPosition = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Text(
                    statusMessage,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                const SizedBox(height: 40),
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