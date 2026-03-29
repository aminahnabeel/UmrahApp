import 'package:flutter/material.dart';
import 'package:smart_umrah_app/widgets/custom_app_bar.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Theme Colors
  static const Color topGradientColor = Color(0xFF0D47A1);
  static const Color bottomGradientColor = Color(0xFF1976D2);
  static const Color customBlue = Color(0xFF0D47A1);

  // Sample notifications data
  final List<Map<String, String>> notifications = const [
    {
      "title": "New Update Available",
      "body": "Version 2.0 is now available. Update to enjoy new features.",
      "time": "5 min ago",
    },
    {
      "title": "Reminder",
      "body": "Don't forget to complete your profile setup.",
      "time": "1 hour ago",
    },
    {
      "title": "Promo",
      "body": "Get 20% off on your next subscription!",
      "time": "Yesterday",
    },
    {
      "title": "Maintenance Notice",
      "body": "Server maintenance scheduled at 12:00 AM.",
      "time": "2 days ago",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: CustomAppBar(
        title: "Notifications",
        showBackButton: true,
        actions: [
          IconButton(
            onPressed: () {
              // Mark all as read functionality
            },
            icon: const Icon(Icons.mark_email_read, color: Colors.white),
          ),
        ],
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
          child: notifications.isEmpty
              ? const Center(
                  child: Text(
                    "No new notifications",
                    style: TextStyle(color: Colors.white70, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return Card(
                      color: Colors.white,
                      elevation: 2,
                      margin: const EdgeInsets.only(bottom: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(12),
                        leading: CircleAvatar(
                          backgroundColor: customBlue.withOpacity(0.1),
                          child: const Icon(Icons.notifications_active, color: customBlue),
                        ),
                        title: Text(
                          notification['title']!,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 4),
                            Text(
                              notification['body']!,
                              style: const TextStyle(fontSize: 14, color: Colors.black54),
                            ),
                            const SizedBox(height: 6),
                            Row(
                              children: [
                                const Icon(Icons.access_time, size: 12, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                  notification['time']!,
                                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                                ),
                              ],
                            ),
                          ],
                        ),
                        onTap: () {
                          // Action on tap
                        },
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }
}