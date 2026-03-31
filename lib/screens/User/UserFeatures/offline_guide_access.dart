import 'package:flutter/material.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/dua_tab.dart';
import 'package:smart_umrah_app/screens/User/UserFeatures/UmrahGuide/text_guide.dart';

class OfflineGuideAccess extends StatelessWidget {
  const OfflineGuideAccess({super.key});

  // --- Image Match Theme Colors ---
  static const Color headerBlue = Color(0xFF0D47A1); // Solid Dark Blue
  static const Color lightBg = Color(0xFFF5F7FB);
  static const Color tabIndicatorColor = Colors.white;

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2, // Sirf Text aur Duas
      child: Scaffold(
        backgroundColor: lightBg,
        appBar: AppBar(
          backgroundColor: headerBlue,
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
            indicatorColor: tabIndicatorColor,
            indicatorWeight: 4, // Thoda thick indicator jaisa SS mein hai
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold, 
              fontSize: 14,
            ),
            tabs: [
              Tab(
                icon: Icon(Icons.menu_book_rounded, color: Colors.white),
                text: "Text",
              ),
              Tab(
                icon: Icon(Icons.favorite_rounded, color: Colors.white),
                text: "Duas",
              ),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TextGuideTab(),
            DuasTab(),
          ],
        ),
      ),
    );
  }
}