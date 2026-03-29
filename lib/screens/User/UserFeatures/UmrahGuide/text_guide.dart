import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  // Track checked state for each step
  List<bool> _isCheckedList = List.generate(5, (_) => false);

  Map<String, dynamic> enData = {};
  Map<String, dynamic> urData = {};

  @override
  void initState() {
    super.initState();
    loadJson();
    _loadCheckedState();
  }

  Future<void> _loadCheckedState() async {
    final prefs = await SharedPreferences.getInstance();
    final checked =
        prefs.getStringList('umrah_guide_checked') ??
        List.generate(5, (_) => 'false');
    setState(() {
      _isCheckedList = checked.map((e) => e == 'true').toList();
    });
  }

  Future<void> _saveCheckedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'umrah_guide_checked',
      _isCheckedList.map((e) => e.toString()).toList(),
    );
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
            final isChecked = _isCheckedList[index];
            final data = getCurrentData(index);
            return Card(
              color: isChecked ? Colors.green.shade700 : cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
              margin: const EdgeInsets.only(bottom: 16.0),
              child: ExpansionTile(
                tilePadding: const EdgeInsets.all(16.0),
                title: Row(
                  children: [
                    GestureDetector(
                      onTap: () async {
                        setState(() {
                          _isCheckedList[index] = !_isCheckedList[index];
                        });
                        await _saveCheckedState();
                      },
                      child: Icon(
                        isChecked ? Icons.check_circle : _getIcon(i),
                        color: isChecked ? Colors.white : accentColor,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        data['step${i}_title'] ?? '',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          decoration: isChecked
                              ? TextDecoration.lineThrough
                              : null,
                        ),
                        textDirection: isUrdu
                            ? TextDirection.rtl
                            : TextDirection.ltr,
                      ),
                    ),
                  ],
                ),
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
