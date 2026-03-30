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
  // --- MODERN THEME COLORS ---
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColorPrimary = Color(0xFF0D47A1); 
  static const Color textColorSecondary = Colors.black54; 
  static const Color accentColor = Color(0xFF1976D2);
  static const Color successGreen = Color(0xFF2E7D32); // Modern Green

  List<bool> _isUrduList = List.generate(5, (_) => false);
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
    final checked = prefs.getStringList('umrah_guide_checked') ?? List.generate(5, (_) => 'false');
    setState(() {
      _isCheckedList = checked.map((e) => e == 'true').toList();
    });
  }

  Future<void> _saveCheckedState() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('umrah_guide_checked', _isCheckedList.map((e) => e.toString()).toList());
  }

  Future<void> loadJson() async {
    final en = await rootBundle.loadString('assets/en.json');
    final ur = await rootBundle.loadString('assets/ur.json');
    setState(() {
      enData = json.decode(en);
      urData = json.decode(ur);
    });
  }

  Map<String, dynamic> getCurrentData(int index) => _isUrduList[index] ? urData : enData;

  @override
  Widget build(BuildContext context) {
    if (enData.isEmpty || urData.isEmpty) {
      return const Center(child: CircularProgressIndicator(color: primaryBlue));
    }

    return SingleChildScrollView(
      // Padding matches your dashboard grid padding
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 100), 
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Umrah Step-by-Step",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: primaryBlue),
          ),
          const Text(
            "Follow these steps for your sacred journey.",
            style: TextStyle(fontSize: 14, color: textColorSecondary),
          ),
          const SizedBox(height: 25),

          ...List.generate(5, (index) {
            final i = index + 1;
            final isUrdu = _isUrduList[index];
            final isChecked = _isCheckedList[index];
            final data = getCurrentData(index);

            return Container(
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: isChecked ? Colors.green.withOpacity(0.05) : cardBackgroundColor,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isChecked ? successGreen.withOpacity(0.3) : Colors.transparent,
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Theme(
                // Removes the default divider lines from ExpansionTile
                data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: GestureDetector(
                    onTap: () async {
                      setState(() {
                        _isCheckedList[index] = !_isCheckedList[index];
                      });
                      await _saveCheckedState();
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: isChecked ? successGreen : accentColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isChecked ? Icons.check_rounded : _getIcon(i),
                        color: isChecked ? Colors.white : accentColor,
                        size: 22,
                      ),
                    ),
                  ),
                  title: Text(
                    data['step${i}_title'] ?? '',
                    style: TextStyle(
                      color: isChecked ? successGreen : textColorPrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      decoration: isChecked ? TextDecoration.lineThrough : null,
                    ),
                    textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                  ),
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                          const SizedBox(height: 15),
                          Text(
                            data['step${i}_desc'] ?? '',
                            style: const TextStyle(color: textColorSecondary, fontSize: 14, height: 1.5),
                            textDirection: isUrdu ? TextDirection.rtl : TextDirection.ltr,
                          ),
                          const SizedBox(height: 10),
                          TextButton.icon(
                            onPressed: () {
                              setState(() => _isUrduList[index] = !_isUrduList[index]);
                            },
                            icon: const Icon(Icons.translate_rounded, size: 16),
                            label: Text(isUrdu ? "Switch to English" : "Urdu Translation"),
                            style: TextButton.styleFrom(
                              foregroundColor: accentColor,
                              textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  IconData _getIcon(int step) {
    switch (step) {
      case 1: return Icons.auto_awesome_rounded;
      case 2: return Icons.person_pin_rounded;
      case 3: return Icons.sync_problem_rounded;
      case 4: return Icons.directions_run_rounded;
      case 5: return Icons.content_cut_rounded;
      default: return Icons.circle;
    }
  }
}