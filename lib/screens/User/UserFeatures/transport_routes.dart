import 'package:flutter/material.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart'; 

class TransportRoutes extends StatelessWidget {
  TransportRoutes({super.key});

  // Theme Colors
  static const Color topGradientColor = Color(0xFF0D47A1); 
  static const Color bottomGradientColor = Color(0xFF1976D2); 

  // Sample Data: Is list ki wajah se error aa raha tha
  final List<Map<String, dynamic>> routes = [
    {
      "transport": "Bus / Metro",
      "from": "Masjid al-Haram",
      "to": "Mina",
      "distance": "8 km",
      "time": "15-20 mins",
      "icon": Icons.directions_bus,
    },
    {
      "transport": "Bus / Metro",
      "from": "Mina",
      "to": "Arafat",
      "distance": "12 km",
      "time": "20-30 mins",
      "icon": Icons.train,
    },
    {
      "transport": "Bus / Walking",
      "from": "Arafat",
      "to": "Muzdalifah",
      "distance": "9 km",
      "time": "Walking: 2 hrs",
      "icon": Icons.directions_walk,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true, 
      appBar: const CustomAppBar(
        title: "Transport Routes",
        showBackButton: true,
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [topGradientColor, bottomGradientColor],
          ),
        ),
        child: SafeArea(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: routes.length, // Now defined
            itemBuilder: (context, index) {
              final route = routes[index]; // Now defined
              return _buildRouteCard(route);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 4,
      color: Colors.white, // Card color from reference
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.teal.shade50,
                  child: Icon(route["icon"], color: Colors.teal, size: 28),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    route["transport"],
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 25, thickness: 0.8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLocation(route["from"], isFrom: true),
                Column(
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.grey.shade400, size: 20),
                    const SizedBox(height: 4),
                    Text(
                      route["distance"],
                      style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.black54),
                    ),
                  ],
                ),
                _buildLocation(route["to"], isFrom: false),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Icon(Icons.access_time_filled, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                Text(
                  "Approx. Time: ${route["time"]}",
                  style: const TextStyle(fontSize: 13, color: Colors.black87),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation(String name, {required bool isFrom}) {
    return SizedBox(
      width: 100,
      child: Column(
        children: [
          Icon(
            isFrom ? Icons.location_on : Icons.flag_rounded,
            color: isFrom ? Colors.green.shade600 : Colors.red.shade600,
            size: 24,
          ),
          const SizedBox(height: 6),
          Text(
            name,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}