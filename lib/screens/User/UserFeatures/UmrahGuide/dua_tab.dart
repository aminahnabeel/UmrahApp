import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DuasTab extends StatefulWidget {
  const DuasTab({super.key});

  @override
  State<DuasTab> createState() => _DuasTabState();
}

class _DuasTabState extends State<DuasTab> {
  // --- DASHBOARD THEME COLORS ---
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color cardBackgroundColor = Colors.white;
  static const Color textColorPrimary = Color(0xFF0D47A1);
  static const Color textColorSecondary = Colors.black54;
  static const Color accentColor = Color(0xFF1976D2);

  final List<Map<String, String>> duas = const [
    {
      "title": "Dua for Intention (Niyyah)",
      "arabic": "لَبَّيْكَ اللَّهُمَّ عُمْرَةً",
      "transliteration": "Labbayka Allahumma ‘Umratan",
      "translation": "Here I am, O Allah, for ‘Umrah.",
      "audio": "dua_niyyah.mp3",
    },
    {
      "title": "Dua at Miqat (Talbiyah)",
      "arabic": "لَبَّيْكَ اللّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
      "transliteration": "Labbayka Allahumma labbayk, labbayka laa shareeka laka labbayk, inna al-hamda wan-ni‘mata laka wal-mulk, laa shareeka lak.",
      "translation": "Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Surely all praise, blessings, and sovereignty belong to You. You have no partner.",
      "audio": "dua_talbiyah.mp3",
    },
    {
      "title": "Entering Masjid al-Haram",
      "arabic": "اللّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
      "transliteration": "Allahumma aftah li abwaba rahmatika.",
      "translation": "O Allah, open for me the doors of Your mercy.",
      "audio": "dua_entering_masjid.mp3",
    },
    {
      "title": "Upon seeing the Kaaba",
      "arabic": "اللّهُمَّ زِدْ هَذَا الْبَيْتَ تَشْرِيفًا وَتَعْظِيمًا",
      "transliteration": "Allahumma zid hadha al-bayta tashreefan wa ta‘theeman.",
      "translation": "O Allah, increase this House in honor, greatness, and reverence.",
      "audio": "dua_seeing_kaaba.mp3",
    },
    {
      "title": "At the Black Stone",
      "arabic": "بِسْمِ اللّهِ وَاللّهُ أَكْبَرُ",
      "transliteration": "Bismillahi wallahu akbar.",
      "translation": "In the name of Allah, Allah is the Greatest.",
      "audio": "dua_black_stone.mp3",
    },
    {
      "title": "Between the Corners",
      "arabic": "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      "transliteration": "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina ‘adhaban-nar.",
      "translation": "Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire.",
      "audio": "dua_between_rukn_yamani_hajr_aswad.mp3",
    },
    {
      "title": "Dua at Multazam",
      "arabic": "اللّهُمَّ يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
      "transliteration": "Allahumma ya muqallibal-quloob thabbit qalbi ‘ala deenik.",
      "translation": "O Allah, Controller of hearts, make my heart firm upon Your religion.",
      "audio": "dua_multazam.mp3",
    },
    {
      "title": "Dua at Maqam Ibrahim",
      "arabic": "وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى",
      "transliteration": "Wattakhidhu min Maqami Ibrahima musalla.",
      "translation": "And take the standing place of Ibrahim as a place of prayer.",
      "audio": "dua_maqam_ibrahim.mp3",
    },
    {
      "title": "While drinking Zamzam",
      "arabic": "اللّهُمَّ اجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ وَارْزُقْنِي رِزْقًا وَاسِعًا",
      "transliteration": "Allahumma aj‘alni min al-mutatahhirin warzuqni rizqan wasi‘an.",
      "translation": "O Allah, make me among those who purify themselves and grant me abundant provision.",
      "audio": "dua_drinking_zamzam.mp3",
    },
    {
      "title": "At Safa (Beginning Sa’i)",
      "arabic": "إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللّهِ... أَبْدَأُ بِمَا بَدَأَ اللّهُ بِهِ",
      "transliteration": "Inna as-Safa wal-Marwata min sha‘a’irillah… Abda’u bima bada’a Allahu bihi.",
      "translation": "Indeed, Safa and Marwah are among the symbols of Allah… I begin with what Allah began with.",
      "audio": "dua_safa.mp3",
    },
    {
      "title": "Dua during Sa’i",
      "arabic": "رَبِّ اغْفِرْ وَارْحَمْ إِنَّكَ أَنتَ الأَعَزُّ الأَكْرَمُ",
      "transliteration": "Rabbi ighfir warham innaka anta al-‘azzu al-akram.",
      "translation": "My Lord, forgive and have mercy, indeed You are the Mighty, the Most Generous.",
      "audio": "dua_during_sai.mp3",
    },
    {
      "title": "Completion of Umrah",
      "arabic": "الْحَمْدُ لِلّهِ عَلَى تَمَامِ الْعُمْرَةِ",
      "transliteration": "Alhamdulillahi ‘ala tamaam al-‘Umrah.",
      "translation": "All praise is for Allah for the completion of ‘Umrah.",
      "audio": "dua_after_umrah.mp3",
    },
  ];

  String searchQuery = "";
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredDuas = duas.where((dua) {
      final query = searchQuery.toLowerCase();
      return dua["title"]!.toLowerCase().contains(query) ||
          dua["transliteration"]!.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // 🔎 Modern Search Bar
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              style: const TextStyle(color: Colors.black87),
              decoration: InputDecoration(
                hintText: "Search Duas...",
                hintStyle: const TextStyle(color: Colors.grey),
                prefixIcon: const Icon(Icons.search_rounded, color: primaryBlue),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(vertical: 0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
              ),
              onChanged: (value) => setState(() => searchQuery = value),
            ),
          ),
        ),

        // 📖 Dua List
        Expanded(
          child: filteredDuas.isEmpty
              ? const Center(child: Text("No duas found.", style: TextStyle(color: textColorSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDuas.length,
                  itemBuilder: (context, index) {
                    final dua = filteredDuas[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: cardBackgroundColor,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Theme(
                        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
                        child: ExpansionTile(
                          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: primaryBlue.withOpacity(0.1),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.menu_book_rounded, color: primaryBlue, size: 20),
                          ),
                          title: Text(
                            dua["title"]!,
                            style: const TextStyle(
                              color: textColorPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.play_circle_fill_rounded, color: primaryBlue, size: 30),
                            onPressed: () async {
                              final audioPath = dua["audio"];
                              if (audioPath != null) {
                                await _audioPlayer.stop();
                                await _audioPlayer.play(AssetSource(audioPath));
                              }
                            },
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  const Divider(height: 1, color: Color(0xFFEEEEEE)),
                                  const SizedBox(height: 15),
                                  Text(
                                    dua["arabic"]!,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: primaryBlue,
                                      fontFamily: 'Arabic', // Agar apke pas custom font hai
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  _buildInfoRow("Transliteration", dua["transliteration"]!),
                                  const SizedBox(height: 10),
                                  _buildInfoRow("Translation", dua["translation"]!),
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
    );
  }

  Widget _buildInfoRow(String label, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: primaryBlue)),
        const SizedBox(height: 2),
        Text(content, style: const TextStyle(fontSize: 14, color: textColorSecondary, height: 1.4)),
      ],
    );
  }
}