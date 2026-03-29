import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class DuasTab extends StatefulWidget {
  const DuasTab({super.key});

  @override
  State<DuasTab> createState() => _DuasTabState();
}

class _DuasTabState extends State<DuasTab> {
  static const Color cardBackgroundColor = Color(0xFF283645);
  static const Color textColorPrimary = Colors.white;
  static const Color textColorSecondary = Colors.white70;
  static const Color accentColor = Color(0xFF3B82F6);

  final List<Map<String, String>> duas = const [
    {
      "title": "Dua for Intention (Niyyah)",
      "arabic": "لَبَّيْكَ اللَّهُمَّ عُمْرَةً",
      "transliteration": "Labbayka Allahumma ‘Umratan",
      "translation": "Here I am, O Allah, for ‘Umrah.",
      "audio": "assets/dua_niyyah.mp3",
    },
    {
      "title": "Dua at Miqat (Talbiyah)",
      "arabic":
          "لَبَّيْكَ اللّهُمَّ لَبَّيْكَ، لَبَّيْكَ لَا شَرِيكَ لَكَ لَبَّيْكَ، إِنَّ الْحَمْدَ وَالنِّعْمَةَ لَكَ وَالْمُلْكَ، لَا شَرِيكَ لَكَ",
      "transliteration":
          "Labbayka Allahumma labbayk, labbayka laa shareeka laka labbayk, inna al-hamda wan-ni‘mata laka wal-mulk, laa shareeka lak.",
      "translation":
          "Here I am, O Allah, here I am. Here I am, You have no partner, here I am. Surely all praise, blessings, and sovereignty belong to You. You have no partner.",
      "audio": "assets/dua_talbiyah.mp3",
    },
    {
      "title": "Dua when entering Masjid al-Haram",
      "arabic": "اللّهُمَّ افْتَحْ لِي أَبْوَابَ رَحْمَتِكَ",
      "transliteration": "Allahumma aftah li abwaba rahmatika.",
      "translation": "O Allah, open for me the doors of Your mercy.",
      "audio": "assets/dua_entering_masjid.mp3",
    },
    {
      "title": "Dua upon seeing the Kaaba",
      "arabic": "اللّهُمَّ زِدْ هَذَا الْبَيْتَ تَشْرِيفًا وَتَعْظِيمًا",
      "transliteration":
          "Allahumma zid hadha al-bayta tashreefan wa ta‘theeman.",
      "translation":
          "O Allah, increase this House in honor, greatness, and reverence.",
      "audio": "assets/dua_seeing_kaaba.mp3",
    },
    {
      "title": "Dua at the Black Stone (Hajr al-Aswad)",
      "arabic": "بِسْمِ اللّهِ وَاللّهُ أَكْبَرُ",
      "transliteration": "Bismillahi wallahu akbar.",
      "translation": "In the name of Allah, Allah is the Greatest.",
      "audio": "assets/dua_black_stone.mp3",
    },
    {
      "title": "Dua between Rukn al-Yamani and Hajr al-Aswad",
      "arabic":
          "رَبَّنَا آتِنَا فِي الدُّنْيَا حَسَنَةً وَفِي الآخِرَةِ حَسَنَةً وَقِنَا عَذَابَ النَّارِ",
      "transliteration":
          "Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina ‘adhaban-nar.",
      "translation":
          "Our Lord, give us good in this world and good in the Hereafter, and save us from the punishment of the Fire.",
      "audio": "assets/dua_between_rukn_yamani_hajr_aswad.mp3",
    },
    {
      "title": "Dua at Multazam (between Hajr al-Aswad and Kaaba door)",
      "arabic":
          "اللّهُمَّ يَا مُقَلِّبَ الْقُلُوبِ ثَبِّتْ قَلْبِي عَلَى دِينِكَ",
      "transliteration":
          "Allahumma ya muqallibal-quloob thabbit qalbi ‘ala deenik.",
      "translation":
          "O Allah, Controller of hearts, make my heart firm upon Your religion.",
      "audio": "assets/dua_multazam.mp3",
    },
    {
      "title": "Dua at Maqam Ibrahim",
      "arabic": "وَاتَّخِذُوا مِن مَّقَامِ إِبْرَاهِيمَ مُصَلًّى",
      "transliteration": "Wattakhidhu min Maqami Ibrahima musalla.",
      "translation":
          "And take the standing place of Ibrahim as a place of prayer.",
      "audio": "assets/dua_maqam_ibrahim.mp3",
    },
    {
      "title": "Dua while drinking Zamzam",
      "arabic":
          "اللّهُمَّ اجْعَلْنِي مِنَ الْمُتَطَهِّرِينَ وَارْزُقْنِي رِزْقًا وَاسِعًا",
      "transliteration":
          "Allahumma aj‘alni min al-mutatahhirin warzuqni rizqan wasi‘an.",
      "translation":
          "O Allah, make me among those who purify themselves and grant me abundant provision.",
      "audio": "assets/dua_drinking_zamzam.mp3",
    },
    {
      "title": "Dua at Safa (beginning Sa’i)",
      "arabic":
          "إِنَّ الصَّفَا وَالْمَرْوَةَ مِن شَعَائِرِ اللّهِ... أَبْدَأُ بِمَا بَدَأَ اللّهُ بِهِ",
      "transliteration":
          "Inna as-Safa wal-Marwata min sha‘a’irillah… Abda’u bima bada’a Allahu bihi.",
      "translation":
          "Indeed, Safa and Marwah are among the symbols of Allah… I begin with what Allah began with.",
      "audio": "assets/dua_safa.mp3",
    },
    {
      "title": "Dua during Sa’i (between Safa and Marwah)",
      "arabic": "رَبِّ اغْفِرْ وَارْحَمْ إِنَّكَ أَنتَ الأَعَزُّ الأَكْرَمُ",
      "transliteration": "Rabbi ighfir warham innaka anta al-‘azzu al-akram.",
      "translation":
          "My Lord, forgive and have mercy, indeed You are the Mighty, the Most Generous.",
      "audio": "assets/dua_during_sai.mp3",
    },
    {
      "title": "Dua after completing Umrah",
      "arabic": "الْحَمْدُ لِلّهِ عَلَى تَمَامِ الْعُمْرَةِ",
      "transliteration": "Alhamdulillahi ‘ala tamaam al-‘Umrah.",
      "translation": "All praise is for Allah for the completion of ‘Umrah.",
      "audio": "assets/dua_after_umrah.mp3",
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
          dua["arabic"]!.contains(query) ||
          dua["transliteration"]!.toLowerCase().contains(query);
    }).toList();

    return Column(
      children: [
        // 🔎 Search Bar
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: TextField(
            style: const TextStyle(color: textColorPrimary),
            decoration: InputDecoration(
              hintText: "Search Duas...",
              hintStyle: const TextStyle(color: textColorSecondary),
              prefixIcon: const Icon(Icons.search, color: accentColor),
              filled: true,
              fillColor: cardBackgroundColor,
              contentPadding: const EdgeInsets.symmetric(vertical: 0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
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
                  padding: const EdgeInsets.all(16.0),
                  itemCount: filteredDuas.length,
                  itemBuilder: (context, index) {
                    final dua = filteredDuas[index];
                    return Card(
                      color: cardBackgroundColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      margin: const EdgeInsets.only(bottom: 16.0),
                      child: ExpansionTile(
                        tilePadding: const EdgeInsets.all(16.0),
                        title: Text(
                          dua["title"]!,
                          style: const TextStyle(
                            color: textColorPrimary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        leading: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.book, color: accentColor),
                            const SizedBox(width: 8),
                            IconButton(
                              icon: const Icon(
                                Icons.volume_up,
                                color: accentColor,
                              ),
                              tooltip: 'Play Audio',
                              onPressed: () async {
                                final audioPath = dua["audio"];
                                if (audioPath != null) {
                                  await _audioPlayer.stop();
                                  await _audioPlayer.play(
                                    AssetSource(audioPath),
                                  );
                                }
                              },
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  dua["arabic"]!,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColorPrimary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  "Transliteration: ${dua["transliteration"]!}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: textColorSecondary,
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  "Translation: ${dua["translation"]!}",
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: textColorSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
