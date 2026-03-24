import 'package:flutter/material.dart';
import 'package:smart_umrah_app/DataLayer/User/userUmrahGuide/umrah_guide.dart';

class TextGuideTab extends StatelessWidget {
  const TextGuideTab();

  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Text(
            "A step-by-step guide for your sacred journey.",
            style: const TextStyle(fontSize: 16, color: textColorSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          ...umrahSteps.map(
            (step) => Card(
              color: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16.0),
                title: Text(
                  step['title'],
                  style: const TextStyle(
                    color: textColorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                leading: Icon(step['icon'], color: accentColor),
                collapsedIconColor: textColorPrimary,
                iconColor: accentColor,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Text(
                      step['content'],
                      style: const TextStyle(
                        color: textColorSecondary,
                        fontSize: 15,
                      ),
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
