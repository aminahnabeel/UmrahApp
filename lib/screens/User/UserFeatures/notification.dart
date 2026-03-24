import 'package:flutter/material.dart';
import 'package:smart_umrah_app/ColorTheme/color_theme.dart';

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

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
      backgroundColor: ColorTheme.background,
      appBar: AppBar(
        backgroundColor: ColorTheme.background,
        elevation: 4,
        centerTitle: true,
        title: const Text(
          "Notifications",
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.white),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add functionality to mark all as read if needed
            },
            icon: const Icon(Icons.mark_email_read, color: Color(0xFF3B82F6)),
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: notifications.length,
        itemBuilder: (context, index) {
          final notification = notifications[index];
          return Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF283645),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.25),
                  spreadRadius: 1,
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
              leading: CircleAvatar(
                backgroundColor: const Color(0xFF3B82F6).withOpacity(0.2),
                child: const Icon(Icons.notifications, color: Color(0xFF3B82F6)),
              ),
              title: Text(
                notification['title']!,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
              subtitle: Text(
                notification['body']!,
                style: const TextStyle(fontSize: 14, color: Colors.white70),
              ),
              trailing: Text(
                notification['time']!,
                style: const TextStyle(fontSize: 12, color: Colors.white54),
              ),
              onTap: () {
                // Action when notification is tapped
              },
            ),
          );
        },
      ),
    );
  }
}
