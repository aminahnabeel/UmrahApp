import 'package:flutter/material.dart';
import 'package:smart_umrah_app/widgets/play_audio_icon.dart';

class DuasTab extends StatefulWidget {
  const DuasTab({super.key});

  @override
  State<DuasTab> createState() => _DuasTabState();
}

class _DuasTabState extends State<DuasTab> {
  // --- Smart Umrah Theme Setup ---
  static const Color backgroundColor = Color(0xFFF5F7FB); // Light Grey/Blue Background
  static const Color cardBackgroundColor = Colors.white; 
  static const Color textColorPrimary = Color(0xFF0D47A1); // Deep Blue
  static const Color textColorSecondary = Color(0xFF64748B); // Slate Grey
  static const Color accentColor = Color(0xFF1976D2); // Standard Blue

  final List<Map<String, String>> duas = const [
    {
      "title": "Dua for Niyyah (Ummrah)",
      "arabic": "اللَّهُمَّ إِنِّي أُرِيدُ العُمْرَةَ فَيَسِّرْهَا لِي وَتَقَبَّلْهَا مِنِّي",
      "transliteration": "Allahumma innī urīdu al-umrata fayassirhā lī wataqabbalhā minnī",
      "translation": "O Allah, I intend to perform Umrah, so make it easy for me and accept it from me.",
      "audio": "assets/dua_niyyah.mp3",
    },
    {
      "title": "Dua when entering Masjid al-Haram",
      "arabic": "اللّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
      "transliteration": "Allahumma aftah li abwaba rahmatika.",
      "translation": "O Allah, open for me the doors of Your mercy.",
      "audio": "assets/dua_entering_masjid.mp3",
    },
    {
      "title": "First sight of the Kaaba",
      "arabic": "اللَّهُمَّ زِدْ هَذَا البَيْتَ تَشْرِيفًا وَتَعْظِيمًا وَتَكْرِيمًا وَمَهَابَةً، وَزِدْ مَنْ شَرَّفَهُ وَكَرَّمَهُ مِمَّنْ حَجَّهُ أَوِ اعْتَمَرَهُ تَشْرِيفًا وَتَعْظِيمًا وَتَكْرِيمًا وَبِرًا",
      "transliteration": "Allāhumma zid hādhā al-bayta tashrīfan wa ta zīman wa takrīman wa mahābatan, wa zid man sharrafahu wa karramahu mimman hajjahu awi tamarahu tashrīfan wa ta zīman wa takrīman wa birran.",
      "translation": "O Allah, increase this House in honor, reverence, nobility, and awe. And increase in honor, reverence, nobility, and righteousness those who honor it and perform Hajj or 'Umrah at it.",
      "audio": "assets/dua_seeing_kaaba.mp3",
    },
    {
      "title": "Dua between Yemeni Corner and Hajr al-Aswad",
      "arabic": "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      "transliteration": "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina ‘adhaban-nar.",
      "translation": "Our Lord, grant us good in this world and good in the Hereafter, and potect us from the punishment of the Fire.",
      "audio": "assets/dua_between_rukn_yamani_hajr_aswad.mp3",
    },
    {
      "title": "Dua at Maqam Ibrahim",
      "arabic": "وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى",
      "transliteration": "Wattakhidhu min Maqami Ibrahima musalla.",
      "translation": "And take the standing place of Ibrahim as a place of prayer.",
      "audio": "assets/dua_maqam_ibrahim.mp3",
    },
    {
      "title": "Dua for drinking Zamzam",
      "arabic": "اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا، وَرِزْقًا وَاسِعًا، وَشِفَاءً مِنْ كُلِّ دَاءٍ",
      "transliteration": "Allahumma innī as 'aluka ilman nāfi'an, wa rizqan wāsi'an, wa shifā 'an min kulli dā in.",
      "translation": "O Allah, I ask You for beneficial knowledge, abundant provision, and healing from every disease.",
      "audio": "assets/dua_drinking_zamzam.mp3",
    },
    {
      "title": "Dua for Sa’i (between Safa and Marwah)",
      "arabic": "إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللَّهِ فَمَنْ حَجَّ الْبَيْتَ أَوِ اعْتَمَرَ فَلَا جُنَاحَ عَلَيْهِ أَن يَطَّوَّفَ بِهِمَا وَمَن تَطَوَّعَ خَيْرًا فَإِنَّ اللَّهَ شَاكِرٌ عَلِيمٌ",
      "transliteration": "Innaş-Şafa wal-Marwata min sha'a iril-lāh. Faman hajja al-bayta awitamara fa lā junāņa 'alayhi an yattawwafa bihimā. Wa man tatawwa'a khayran fa inna Allāha shākirun 'alīm.",
      "translation": "Indeed, as-Safa and al-Marwah are among the symbols of Allah. So whoever makes Hajj to the House or performs 'umrah - there is no blame upon him for walking between them. And whoever volunteers good - then indeed, Allah is appreciative and Knowing",
      "audio": "assets/dua_for_sai.mp3",
    },
    {
      "title": "Dua for visiting the Rawdah",
      "arabic": "اللَّهُمَّ ارْزُقْنِي زِيَارَةَ هَذَا الْمَكَانِ الْمُبَارَكِ مِرَارًا، وَارْزُقْنِي الْجَنَّةَ فِي جِوَارِ نَبِيِّكَ الْكَرِيمِ",
      "transliteration": "Allāhumma urzuqnī ziyārata hādhā al-makāni al-mubāraki mirāran, wa urzuqnī al-jannata fi jiwāri nabiyyika al-karīm.",
      "translation": "O Allah, grant me the opportunity to visit this blessed place repeatedly, and grant me Paradise in the company of Your noble Prophet.",
      "audio": "assets/dua_for_visiting_rawdah.mp3",
    },
  ];

  String searchQuery = "";

  @override
  Widget build(BuildContext context) {
    final filteredDuas = duas.where((dua) {
      final query = searchQuery.toLowerCase();
      return dua["title"]!.toLowerCase().contains(query) ||
          dua["arabic"]!.contains(query) ||
          dua["transliteration"]!.toLowerCase().contains(query);
    }).toList();

    return Container(
      color: backgroundColor, // Apply light background to the whole tab
      child: Column(
        children: [
          // 🔎 Search Bar
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              style: const TextStyle(color: Color(0xFF2D3142)),
              decoration: InputDecoration(
                hintText: "Search Duas...",
                hintStyle: const TextStyle(color: textColorSecondary),
                prefixIcon: const Icon(Icons.search, color: accentColor),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.blue.shade50),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
            ),
          ),

          // 📖 Dua List
          Expanded(
            child: filteredDuas.isEmpty
                ? const Center(
                    child: Text(
                      "No duas found.",
                      style: TextStyle(color: textColorSecondary),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    itemCount: filteredDuas.length,
                    itemBuilder: (context, index) {
                      final dua = filteredDuas[index];
                      return Container(
                        margin: const EdgeInsets.only(bottom: 16.0),
                        decoration: BoxDecoration(
                          color: cardBackgroundColor,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Theme(
                          // Removing the default border and highlight of ExpansionTile
                          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                          child: ExpansionTile(
                            tilePadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4),
                            title: Text(
                              dua["title"]!,
                              style: const TextStyle(
                                color: Color(0xFF2D3142), // Dark Slate
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            leading: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: accentColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: accentColor, size: 20),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (dua["audio"] != null)
                                  PlayAudioIcon(assetPath: dua["audio"]!),
                                const SizedBox(width: 8),
                                const Icon(Icons.expand_more, color: textColorSecondary),
                              ],
                            ),
                            children: [
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.stretch,
                                  children: [
                                    const Divider(height: 1, thickness: 0.5),
                                    const SizedBox(height: 12),
                                    Text(
                                      dua["arabic"]!,
                                      textDirection: TextDirection.rtl,
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: textColorPrimary,
                                        height: 1.8,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                    const SizedBox(height: 16),
                                    _buildTextSection("Transliteration", dua["transliteration"]!),
                                    const SizedBox(height: 8),
                                    _buildTextSection("Translation", dua["translation"]!),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // Helper widget to keep the layout clean
  Widget _buildTextSection(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
            color: textColorSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          content,
          style: const TextStyle(
            fontSize: 14,
            color: Color(0xFF2D3142),
            height: 1.4,
          ),
        ),
      ],
    );
  }
}