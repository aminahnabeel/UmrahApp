// lib/screens/user/umrah_guide_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_umrah_app/DataLayer/User/userUmrahGuide/umrah_guide.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/dua_tab.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/text_guide.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/vedio_tab.dart';

class UmrahGuideScreen extends StatelessWidget {
  UmrahGuideScreen({super.key});

  // Theme colors
  static const Color primaryBackgroundColor = Color(0xFF1E2A38);
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Text, Videos, Duas
      child: Scaffold(
        backgroundColor: primaryBackgroundColor,
        appBar: AppBar(
          backgroundColor: primaryBackgroundColor,
          elevation: 0,
          title: const Text(
            "Umrah Guide",
            style: TextStyle(
              color: textColorPrimary,
              fontWeight: FontWeight.bold,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: textColorPrimary),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            indicatorColor: accentColor,
            labelColor: accentColor,
            unselectedLabelColor: textColorSecondary,
            tabs: [
              Tab(icon: Icon(Icons.menu_book), text: "Text"),
              Tab(icon: Icon(Icons.video_collection), text: "Videos"),
              Tab(icon: Icon(Icons.favorite), text: "Duas"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [TextGuideTab(), VideosTab(), DuasTab()],
        ),
      ),
    );
  }
}
