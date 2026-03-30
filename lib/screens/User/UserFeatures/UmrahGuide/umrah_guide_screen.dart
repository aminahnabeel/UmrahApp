// lib/screens/user/umrah_guide_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/dua_tab.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/text_guide.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/vedio_tab.dart';

class UmrahGuideScreen extends StatelessWidget {
  const UmrahGuideScreen({super.key});

  // --- DASHBOARD THEME COLORS ---
  static const Color primaryBlue = Color(0xFF0D47A1); 
  static const Color scaffoldBgColor = Color(0xFFF4F7FA); // Light Greyish-White

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3, // Text, Videos, Duas
      child: Scaffold(
        backgroundColor: scaffoldBgColor, // Body background ab light hoga
        appBar: AppBar(
          backgroundColor: primaryBlue, // Top bar solid blue
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "Umrah Guide",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          bottom: const TabBar(
            indicatorColor: Colors.white, // Active tab line white hogi
            indicatorWeight: 3,
            labelColor: Colors.white, // Selected text white
            unselectedLabelColor: Colors.white70, // Unselected text thora faint
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            tabs: [
              Tab(icon: Icon(Icons.menu_book_rounded), text: "Text"),
              Tab(icon: Icon(Icons.play_circle_fill_rounded), text: "Videos"),
              Tab(icon: Icon(Icons.favorite_rounded), text: "Duas"),
            ],
          ),
        ),
        // Body automatically TabBarView k mutabiq content change kregi
        body: const TabBarView(
          children: [
            TextGuideTab(), 
            VideosTab(), 
            DuasTab(),
          ],
        ),
      ),
    );
  }
}