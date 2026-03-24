import 'package:flutter/material.dart';
import 'package:smart_umrah_app/ColorTheme/color_theme.dart';
import 'package:smart_umrah_app/DataLayer/User/ZiaratRoutes/ziarat_routes.dart';

class TransportRoutes extends StatelessWidget {
  const TransportRoutes({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Transport Routes",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal),
        ),
        centerTitle: true,
        backgroundColor: ColorTheme.background,
        elevation: 6,
      ),
      body: Container(
        color: ColorTheme.background,

        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: routes.length,
          itemBuilder: (context, index) {
            final route = routes[index];
            return _buildRouteCard(route);
          },
        ),
      ),
    );
  }

  Widget _buildRouteCard(Map<String, dynamic> route) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 12),
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Header with transport type
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: Colors.teal.shade100,
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
            const Divider(height: 25, thickness: 1),

            // Route info
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLocation(route["from"], isFrom: true),
                Column(
                  children: [
                    Icon(Icons.arrow_forward, color: Colors.grey.shade600),
                    const SizedBox(height: 4),
                    Text(
                      route["distance"],
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
                _buildLocation(route["to"], isFrom: false),
              ],
            ),

            const SizedBox(height: 14),

            // Time info
            Row(
              children: [
                const Icon(Icons.schedule, color: Colors.grey, size: 20),
                const SizedBox(width: 6),
                Text(
                  "Approx. Time: ${route["time"]}",
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocation(String name, {required bool isFrom}) {
    return Column(
      children: [
        Icon(
          isFrom ? Icons.location_on : Icons.flag,
          color: isFrom ? Colors.green : Colors.red,
          size: 26,
        ),
        const SizedBox(height: 6),
        Text(
          name,
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
