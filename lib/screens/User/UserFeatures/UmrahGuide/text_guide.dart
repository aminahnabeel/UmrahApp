import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextGuideTab extends StatefulWidget {
  const TextGuideTab({super.key});

  @override
  State<TextGuideTab> createState() => _TextGuideTabState();
}

class _TextGuideTabState extends State<TextGuideTab> {
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  // Track translation state for each step
  List<bool> _isUrduList = List.generate(5, (_) => false);

  Map<String, dynamic> enData = {};
  Map<String, dynamic> urData = {};

  @override
  void initState() {
    super.initState();
    loadJson();
  }

  Future<void> loadJson() async {
    final en = await rootBundle.loadString('assets/en.json');
    final ur = await rootBundle.loadString('assets/ur.json');

    setState(() {
      enData = json.decode(en);
      urData = json.decode(ur);
    });
  }

  Map<String, dynamic> getCurrentData(int index) =>
      _isUrduList[index] ? urData : enData;

  @override
  Widget build(BuildContext context) {
    if (enData.isEmpty || urData.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

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

          /// 🔁 Generate 5 steps dynamically
          ...List.generate(5, (index) {
            final i = index + 1;
            final isUrdu = _isUrduList[index];
            final data = getCurrentData(index);
            return Card(
              color: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16.0),

                title: Text(
                  data['step${i}_title'] ?? '',
                  style: const TextStyle(
                    color: textColorPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                  textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                ),

                leading: Icon(_getIcon(i), color: accentColor),
                collapsedIconColor: textColorPrimary,
                iconColor: accentColor,

                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            data['step${i}_desc'] ?? '',
                            style: const TextStyle(
                              color: textColorSecondary,
                              fontSize: 15,
                            ),
                            textDirection: isUrdu
                                ? TextDirection.rtl
                                : TextDirection.ltr,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isUrduList[index] = !_isUrduList[index];
                            });
                          },
                          child: Text(
                            isUrdu ? "English" : "Translation",
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  /// Keep your icons logic here
  IconData _getIcon(int step) {
    switch (step) {
      case 1:
        return Icons.lightbulb_outline;
      case 2:
        return Icons.person_outline;
      case 3:
        return Icons.sync;
      case 4:
        return Icons.directions_walk;
      case 5:
        return Icons.content_cut;
      default:
        return Icons.circle;
    }
  }
}
