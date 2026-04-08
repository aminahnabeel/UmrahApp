import 'dart:convert';
import 'dart:developer' as dev;

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class ChatbotScreen extends StatefulWidget {
  const ChatbotScreen({super.key});

  @override
  State<ChatbotScreen> createState() => _ChatbotScreenState();
}

class _GlassIdentityChip extends StatelessWidget {
  const _GlassIdentityChip({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.08)),
      ),
      child: child,
    );
  }
}

class _OnlineDot extends StatefulWidget {
  const _OnlineDot();

  @override
  State<_OnlineDot> createState() => _OnlineDotState();
}

class _OnlineDotState extends State<_OnlineDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        final scale = 0.9 + 0.2 * mathSin(t * 2 * 3.14159);
        final opacity = 0.6 + 0.4 * mathSin(t * 2 * 3.14159);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: Colors.greenAccent.withOpacity(opacity.clamp(0.0, 1.0)),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.greenAccent.withOpacity(0.6),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ChatbotScreenState extends State<ChatbotScreen>
    with TickerProviderStateMixin {
  static const Color _primaryBlue = Color(0xFF1D4FA3);
  static const Color _borderBlue = Color(0xFFC7D7F6);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late AnimationController _fadeController;
  late AnimationController _typingController;

  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  bool _isLoading = true;
  bool _isTyping = false;

  static const String _apiKey = String.fromEnvironment(
    'GEMINI_API_KEY',
    defaultValue: 'AIzaSyDeMgpSnR4tsBByq74TPKds9B_87fnawnc',
  );
  static const String _apiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent';

  String _language = 'en';

  static const Map<String, String> _languageInstructions = {
    'en': 'Respond in English.',
    'ar': 'الرد باللغة العربية (Respond in Arabic).',
    'ur': 'اردو میں جواب دیں (Respond in Urdu).',
    'id': 'Jawab dalam Bahasa Indonesia (Respond in Indonesian).',
  };

  static const Map<String, List<String>> _topicKeywords = {
    'ihram': [
      'ihram',
      'ihraam',
      'miqat',
      'meeqat',
      'talbiyah',
      'labbayk',
      'niyyah',
      'intention',
      'perfume',
      'scented',
      'hair',
      'nails',
      'ghusl',
      'wudu',
    ],
    'tawaf': [
      'tawaf',
      'tawaaf',
      'kaaba',
      'kaba',
      'hajar al aswad',
      'black stone',
      'idtiba',
      'ramal',
      'maqam ibrahim',
      'hijr ismail',
      'rukn yamani',
    ],
    'zamzam': [
      'zamzam',
      'zam zam',
      'zam zam water',
      'zamzam water',
      'zam zam well',
      'drink zamzam',
      'how to drink zamzam',
      'how to drink zam zam water',
      'water of zamzam',
    ],
    'sai': [
      'sai',
      'sa i',
      'sa\'i',
      'safa',
      'marwah',
      'marwa',
      'green lights',
      'green markers',
      'jog',
      'run',
    ],
    'halq': [
      'halq',
      'taqsir',
      'tasqir',
      'shave',
      'shaving',
      'trim',
      'haircut',
      'clip',
      'finish umrah',
      'exit ihram',
    ],
    'travel': [
      'visa',
      'passport',
      'hotel',
      'accommodation',
      'flight',
      'airport',
      'bag',
      'packing',
      'vaccination',
      'medicine',
      'hydration',
      'transport',
    ],
    'women': [
      'women',
      'woman',
      'female',
      'menstruation',
      'period',
      'niqab',
      'gloves',
      'hijab',
      'socks',
      'modest clothing',
    ],
    'mistakes': [
      'mistake',
      'error',
      'what if',
      'forgot',
      'invalid',
      'penalty',
      'dam',
      'charity',
      'sacrifice',
      'crowd',
      'stuck',
    ],
    'general': [
      'umrah',
      'hajj',
      'dua',
      'prayer',
      'salah',
      'zamzam',
      'kaaba',
      'haram',
      'pilgrim',
    ],
  };

  static const Map<String, String> _topicGuidance = {
    'ihram':
        'If the user is asking about Ihram, explain the intention, Talbiyah, miqat, clothing rules, and what is prohibited or permitted. Mention that accidental mistakes should be checked with a qualified scholar if the ruling depends on details.',
    'tawaf':
        'If the user is asking about Tawaf, give the 7-circuit order, Black Stone start, Kaaba on the left, wudu requirement, Hijr Ismail boundary, and what to do if the crowd is dense.',
    'sai':
        'If the user is asking about Sai, explain the 7 trips between Safa and Marwah, the green markers for men, the starting and ending points, and that breaks are allowed when needed.',
    'halq':
        'If the user is asking about Halq or Taqsir, explain how men and women finish Umrah, what length is required for trimming, and that this step ends Ihram restrictions.',
    'zamzam':
      'If the user is asking about Zamzam, explain that it is blessed water from Makkah. Give practical guidance on how to drink it respectfully, make dua, and mention that it is commonly drunk after Tawaf or in the Haram.',
    'travel':
        'If the user is asking about travel, focus on visa, passport, packing, health, hydration, prayer planning, and practical readiness for pilgrims.',
    'women':
        'If the user is asking about women-specific rulings, answer respectfully and carefully, especially for clothing, menstruation, niqab, gloves, and practical worship guidance.',
    'mistakes':
        'If the user is asking about a mistake or problem, explain the correction first, then note whether charity, sacrifice, or scholarly guidance may be needed depending on the exact case.',
    'general':
        'If the user is asking a broad Umrah question, answer directly, then connect it to the correct ritual step with a practical next action.',
  };

  static const String _umrahKnowledgeBase = '''
You are an expert Umrah guide assistant with comprehensive knowledge about Islamic pilgrimage rituals, travel guidance, and pilgrim support. You provide accurate, respectful guidance acknowledging different schools of Islamic jurisprudence (Hanafi, Maliki, Shafi'i, Hanbali) when relevant.

Core Umrah Rituals:

1. IHRAM (الإحرام / احرام / Ihram)
Definition: State of spiritual consecration and purity required for performing Umrah or Hajj.

Miqat Stations (Entry Points):
- Dhul-Hulayfah (for those from Madinah direction) - 450km from Makkah
- Al-Juhfah (for those from Syria, Egypt, North Africa)
- Qarn al-Manazil (for those from Najd, Riyadh)
- Yalamlam (for those from Yemen)
- Dhat Irq (for those from Iraq)
Note: Air travelers enter Ihram when airplane reaches Miqat boundary

Preparation Before Ihram:
1. Perform Ghusl (ritual bath) or Wudu (ablution)
2. Trim nails, remove unwanted hair (mustache, armpit, pubic)
3. Men: Wear two unstitched white cloths (Izar for lower body, Rida for upper body)
4. Women: Wear modest clothing (any color), covering all except face and hands
5. Apply non-scented soap/deodorant (NO perfume after Ihram)
6. Pray 2 Rakahs Sunnah (recommended but not obligatory)

Entering Ihram - The Intention (Niyyah):
Make clear intention in heart and say: Labbayka Umratan (Here I am for Umrah)
Then recite Talbiyah: Labbayk Allahumma labbayk, labbayka la sharika laka labbayk, innal-hamda wan-ni mata laka wal-mulk, la sharika lak
Translation: Here I am at Your service, O Allah, here I am. Here I am, You have no partner, here I am. Verily all praise, grace and sovereignty belong to You. You have no partner.

Ihram Prohibitions (Men and Women):
- NO perfume, scented oils, or scented products (soap, lotion, deodorant)
- NO cutting hair or nails
- NO hunting or harming animals/insects (even mosquitoes - just brush away)
- NO intimate relations or marriage contracts
- NO arguing or fighting
- NO wearing stitched garments that wrap the body (men only)
- NO covering the head with anything that touches it (men only)
- NO covering the face with niqab/veil (women only - though face covering with hand/paper for need is debated)
- NO wearing gloves (women only)
- NO cutting trees or plants in Haram boundary
- NO using henna

Permitted During Ihram:
- Bathing/washing (without scented soap)
- Changing Ihram garments if dirty
- Using unscented umbrella
- Taking prescribed medication
- Scratching gently (if hair falls accidentally, no penalty)
- Women: wearing socks, modest colored clothing

Violations and Penalties:
Minor violations: Give charity to poor in Makkah
Major violations: Sacrifice an animal (consult scholar on-site)

Common Questions:
Q: What if my Ihram cloth falls off?
A: Quickly re-wrap it. Accidental brief exposure has no penalty.

Q: Can I shower during Ihram?
A: Yes, but use unscented products only.

Q: What if I accidentally use perfume/cut nail?
A: Minor mistake - give charity. Intentional - may require sacrifice (consult scholar).

2. TAWAF (الطواف / طواف / Tawaf)
Definition: Circumambulation (walking around) the Holy Kaaba 7 times in counterclockwise direction as an act of worship.

Preparation:
1. Must be in state of Wudu (ablution)
2. Men: Expose right shoulder (Idtiba) - place Rida under right armpit, over left shoulder
3. Face the Black Stone (Hajar al-Aswad) at the corner of Kaaba
4. Make intention: I intend to perform Tawaf of Umrah for the sake of Allah

Starting Position - The Black Stone:
- Eastern corner of Kaaba marked by black stone in silver frame
- If possible, kiss the stone or touch it with right hand then kiss hand
- If crowded, raise both hands toward it and say Bismillah, Allahu Akbar
- DO NOT push or harm others to reach the stone

Performing the 7 Circuits:

First 3 Circuits (for men only):
- Ramal: Walk briskly with small rapid steps, chest out, shoulders moving
- Purpose: Display strength and vigor
- Women: Walk at normal pace all 7 circuits

Last 4 Circuits:
- Walk at normal, comfortable pace
- Men end Ramal, walk normally

Important Tawaf Rules:
1. Kaaba must always be on your LEFT side
2. Complete all 7 circuits without interruption if possible
3. If prayer time comes (Adhan), stop, pray Salah, then resume from where you stopped
4. Stay outside the Hijr Ismail (semi-circular wall area) - must go around it
5. Green lights on floor mark where circuits begin/end from Black Stone
6. Each circuit: Start at Black Stone alignment, end at Black Stone alignment = 1 circuit

What to Recite:
- No specific mandatory duas (personal prayers in any language accepted)
- Recommended between Yemeni Corner and Black Stone: Rabbana atina fid-dunya hasanatan wa fil-akhirati hasanatan wa qina adhaban-nar
- Recite Quran, make dua, remember Allah
- Each person may recite different prayers - focus on devotion

Touching the Yemeni Corner:
- If possible, touch Rukn Yamani (Yemeni corner - southwestern corner) with RIGHT hand
- Do NOT kiss it, just touch
- If crowded, skip and continue (no hand gesture needed)

After Completing 7 Circuits:
1. Cover both shoulders (men)
2. Proceed to Maqam Ibrahim (Station of Abraham) - golden structure
3. Pray 2 Rakahs Salah behind Maqam (or anywhere in Haram if crowded)
4. Drink Zamzam water
5. Return to Black Stone, touch/kiss if possible (not obligatory)

Common Mistakes:
- Counting incorrectly - use fingers or counter
- Starting too far from Black Stone alignment
- Going inside Hijr Ismail area (invalidates that circuit)
- Pushing others aggressively
- Not maintaining Wudu throughout

Wheelchair/Disability Accommodations:
- Upper level wheelchair circuits available
- Same rules apply, helpers may assist
- Intention and effort count if physical completion difficult

3. SAI (السعي / سعی / Sai)
Definition: Walking back and forth between the hills of Safa and Marwah 7 times, commemorating Hajar search for water for baby Ismail (peace be upon them).

Historical Significance:
When Prophet Ibrahim left Hajar and baby Ismail in desert, water ran out. Hajar ran between Safa and Marwah 7 times searching for help. Allah then sent Angel Jibril who struck ground, causing Zamzam water to spring forth.

Preparation:
- Sai can be performed without Wudu (though Wudu is recommended)
- Exit from Bab al-Safa (Safa gate) toward Safa hill
- Sai is performed on multiple floors - ground, first floor, second floor (all valid)

Starting at Safa:
1. Climb Safa until you can see the Kaaba (if possible - crowding may prevent this)
2. Face the Kaaba, raise hands in dua
3. Recite: Inna as-Safa wal-Marwata min sha airillah (Quran 2:158)
4. Say Takbir 3 times
5. Say Tahlil
6. Make personal dua
7. Begin walking toward Marwah - this is circuit 1

The 7 Circuits:
1. Safa to Marwah = Circuit 1
2. Marwah to Safa = Circuit 2
3. Safa to Marwah = Circuit 3
4. Marwah to Safa = Circuit 4
5. Safa to Marwah = Circuit 5
6. Marwah to Safa = Circuit 6
7. Safa to Marwah = Circuit 7 (end at Marwah)

The Green Lights Section (Men Only):
- Between the two green lights/pillars
- Men should jog/run at moderate pace
- Women walk at normal pace throughout entire Sai

Important Rules:
- Must complete all 7 circuits
- Start at Safa, end at Marwah
- Can take breaks for rest, prayer times, or restroom
- Can drink water during Sai

After Completing Sai:
Proceed directly to hair cutting/trimming (Halq or Taqsir)

4. HALQ or TAQSIR (Shaving or Trimming)
Definition: The final ritual of Umrah - cutting hair to exit the state of Ihram.

HALQ (Complete Shaving) - Men Only:
- Shave entire head completely
- More rewarding than trimming

TAQSIR (Trimming/Shortening):
- Cut at least fingertip length from hair
- Acceptable for both men and women
- Must trim from all parts of head, not just one side

For Women:
- ONLY Taqsir (trimming) allowed, not shaving
- Gather hair together and trim fingertip length from ends

For Men:
- Can choose Halq (shaving) or Taqsir (trimming)
- Shaving gives more reward

Where to Get It Done:
- Barbershops around Haram
- Cost usually 10-20 SAR

Important Points:
- Must be done within Haram boundary (Makkah)
- After this step, Umrah is complete
- All Ihram restrictions are lifted

Sequence Importance:
Must follow order: Ihram -> Tawaf -> Sai -> Halq/Taqsir

Travel Guidance:

Before Departure:
- Valid passport (minimum 6 months validity)
- Umrah visa
- Vaccination requirements
- Book accommodation near Haram
- Comfortable walking shoes and modest clothing

Health and Safety:
- Stay hydrated
- Avoid peak sun hours (11 AM - 3 PM)
- Use umbrella for shade
- Carry needed medication
- Emergency number in Saudi Arabia: 911

Prayer Times and Etiquette:
- Perform 5 daily prayers on time
- Respect sacred spaces
- Maintain cleanliness and Wudu
- Be patient and kind to fellow pilgrims

Common Questions:
Q: Can I perform Umrah during menstruation?
A: Women should wait until they are in a state of purity before Tawaf and Sai.

Q: How long does Umrah take?
A: Usually 3-6 hours depending on crowd levels.

Q: What if I make a mistake during rituals?
A: Consult scholars on-site. Minor mistakes may need simple correction; major ones may require sacrifice.

When answering questions:
- Be respectful and supportive
- Provide step-by-step guidance when asked
- Cite Islamic sources when appropriate
- Be sensitive to different schools of thought
- Offer practical advice for first-time pilgrims
- Emphasize spiritual significance alongside physical actions
''';

  final List<ChatMessage> _messages = [
    ChatMessage(
      text:
          'Assalamu Alaikum. I am your Umrah AI guide. I can help with Ihram, Tawaf, Sai, Halq/Taqsir, travel prep, and practical tips for pilgrims. How can I help you today?',
      isBot: true,
      timestamp: DateTime.now(),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startLoadingSequence();
    _messageController.addListener(() {
      setState(() {});
    });
  }

  String _buildSystemPrompt(String userMessage) {
    final languageInstruction =
        _languageInstructions[_detectLanguage(userMessage)] ??
            _languageInstructions['en']!;
    final targetedGuidance = _buildTargetedGuidance(userMessage);

    return '''$_umrahKnowledgeBase

$languageInstruction
$targetedGuidance

Be helpful, compassionate, and provide accurate information.
Keep responses concise but informative (2-4 paragraphs unless detailed steps are requested).
Do not start answers with greetings like Wa Alaikum Assalam unless the user's message is only a greeting.
If a question needs a scholar-specific ruling, mention this clearly and recommend consulting qualified scholars on-site.''';
  }


  String _detectLanguage(String text) {
    if (RegExp(r'[\u0600-\u06FF]').hasMatch(text)) {
      return RegExp(r'[ےںٹڈڑگھ]').hasMatch(text) ? 'ur' : 'ar';
    }

    final lower = _normalizeText(text);
    if (RegExp(r'\b(bahasa|indonesia|indonesian)\b').hasMatch(lower)) {
      return 'id';
    }

    return 'en';
  }

  String _normalizeText(String text) {
    return text.toLowerCase().replaceAll(RegExp(r'[^\w\s\u0600-\u06FF]'), ' ');
  }

  List<String> _matchedTopics(String text) {
    final normalized = _normalizeText(text);
    final matches = <MapEntry<String, int>>[];

    for (final entry in _topicKeywords.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (normalized.contains(_normalizeText(keyword))) {
          score++;
        }
      }
      if (score > 0) {
        matches.add(MapEntry(entry.key, score));
      }
    }

    matches.sort((a, b) => b.value.compareTo(a.value));
    return matches.map((entry) => entry.key).take(2).toList();
  }

  Map<String, int> _topicScores(String text) {
    final normalized = _normalizeText(text);
    final scores = <String, int>{};

    for (final entry in _topicKeywords.entries) {
      var score = 0;
      for (final keyword in entry.value) {
        if (normalized.contains(_normalizeText(keyword))) {
          score++;
        }
      }
      if (score > 0) {
        scores[entry.key] = score;
      }
    }

    return scores;
  }

  String? _directTopicResponse(String userMessage) {
    final scores = _topicScores(userMessage);
    if (scores.isEmpty) {
      return null;
    }

    final sortedTopics = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final topTopic = sortedTopics.first.key;
    final topScore = sortedTopics.first.value;
    final wordCount = _normalizeText(userMessage)
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .length;

    final clearSingleTopic = topScore >= 1 &&
        (sortedTopics.length == 1 || topScore >= sortedTopics[1].value + 1 || wordCount <= 5);
    if (!clearSingleTopic) {
      return null;
    }

    switch (topTopic) {
      case 'ihram':
        return 'Ihram starts with ghusl or wudu, then the intention for Umrah and Talbiyah. After that, avoid perfume, scented products, cutting hair or nails, and other Ihram restrictions until Umrah is complete.';
      case 'tawaf':
        return 'Tawaf is 7 counterclockwise circles around the Kaaba. Start at the Black Stone line, keep the Kaaba on your left, stay in wudu, and go around the Hijr Ismail instead of through it.';
      case 'zamzam':
        return 'Zamzam is blessed water in Makkah. Say Bismillah, drink it respectfully, and make dua. It is commonly drunk after Tawaf or while in the Haram.';
      case 'sai':
        return 'Sai is 7 trips between Safa and Marwah, starting at Safa and ending at Marwah. Men jog between the green markers, women walk normally, and breaks are allowed if needed.';
      case 'halq':
        return 'Halq or Taqsir is the final step of Umrah. Men may shave the whole head or trim, while women trim a small amount from the ends of the hair.';
      case 'travel':
        return 'For travel, check passport validity, visa, vaccination requirements, hotel booking, medicines, and walking comfort. Plan around prayer times and stay hydrated in Makkah.';
      case 'women':
        return 'For women, keep the guidance focused on modest clothing, no perfume after Ihram, no niqab or gloves during Ihram, and the ruling for menstruation if that is the issue.';
      case 'mistakes':
        return 'If a mistake happens during Umrah, the exact correction depends on what happened and when. Some issues need charity, while others need scholarly guidance or sacrifice.';
      default:
        return null;
    }
  }

  bool _isGreetingOnly(String text) {
    final normalized = _normalizeText(text).trim();
    if (normalized.isEmpty) {
      return false;
    }

    final greetings = <String>{
      'hi',
      'hello',
      'hey',
      'salam',
      'assalamualaikum',
      'assalam o alaikum',
      'assalamu alaikum',
      'asalam o alikum',
      'wa alaikum assalam',
      'wa alaikum salam',
      'walaikum assalam',
      'walaikum salam',
    };

    if (greetings.contains(normalized)) {
      return true;
    }

    final arabicGreeting = RegExp(r'^[\u0600-\u06FF\s]+$').hasMatch(normalized) &&
        RegExp(r'السلام|عليكم|سلا[م]+').hasMatch(normalized);
    return arabicGreeting;
  }

  String _greetingResponse() {
    return 'Wa Alaikum Assalam.';
  }

  String _stripGreetingPrefix(String text) {
    final trimmed = text.trimLeft();
    final greetingPatterns = <RegExp>[
      RegExp(r'^(wa\s*alaikum\s*assalam[!.،,:\-\s]*)', caseSensitive: false),
      RegExp(r'^(wa\s*alikum\s*assalam[!.،,:\-\s]*)', caseSensitive: false),
      RegExp(r'^(assalamu\s*alaikum[!.،,:\-\s]*)', caseSensitive: false),
      RegExp(r'^(assalamualaikum[!.،,:\-\s]*)', caseSensitive: false),
      RegExp(r'^(salam[!.،,:\-\s]*)', caseSensitive: false),
    ];

    var cleaned = trimmed;
    for (final pattern in greetingPatterns) {
      cleaned = cleaned.replaceFirst(pattern, '');
    }

    return cleaned.trimLeft();
  }

  String _buildTargetedGuidance(String userMessage) {
    final topics = _matchedTopics(userMessage);
    if (topics.isEmpty) {
      return _topicGuidance['general']!;
    }

    final guidance = topics
        .map((topic) => _topicGuidance[topic])
        .whereType<String>()
        .toList();
    return guidance.join('\n');
  }

  void _initializeAnimations() {
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _typingController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.elasticOut),
    );

    _fadeController.value = 1.0;
  }

  Future<void> _startLoadingSequence() async {
    await Future.delayed(const Duration(seconds: 3));
    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _fadeController.dispose();
    _typingController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> _buildConversationHistory() {
    return _messages
        .map(
          (msg) => {
            'role': msg.isBot ? 'assistant' : 'user',
            'content': msg.text,
          },
        )
        .toList();
  }

  Future<String> _getGeminiResponse(String userMessage) async {
    try {
      if (_apiKey.trim().isEmpty) {
        throw Exception('GEMINI_API_KEY is missing.');
      }

      final directResponse = _directTopicResponse(userMessage);
      if (directResponse != null) {
        return directResponse;
      }

      final systemPrompt = _buildSystemPrompt(userMessage);
      final conversationHistory = _buildConversationHistory();

      final contents = conversationHistory
          .map(
            (msg) => {
              'role': msg['role'] == 'assistant' ? 'model' : 'user',
              'parts': [
                {'text': msg['content']},
              ],
            },
          )
          .toList();

      final body = {
        'systemInstruction': {
          'parts': [
            {'text': systemPrompt},
          ],
        },
        'contents': contents,
        'generationConfig': {
          'temperature': 0.45,
          'topP': 0.9,
          'topK': 40,
          'maxOutputTokens': 1024,
        },
      };

      final response = await http.post(
        Uri.parse('$_apiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(body),
      );

      if (response.statusCode != 200) {
        dev.log(
          'Gemini API Error: ${response.statusCode} - ${response.body}',
          name: 'chatbot_screen',
        );
        return _getFallbackResponse(userMessage);
      }

      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final candidates = data['candidates'] as List<dynamic>?;
      if (candidates == null || candidates.isEmpty) {
        return _getFallbackResponse(userMessage);
      }

      final content = candidates.first['content'] as Map<String, dynamic>?;
      final parts = content?['parts'] as List<dynamic>?;
      final text = parts != null && parts.isNotEmpty
          ? (parts.first['text'] as String? ?? '')
          : '';

      final cleanedText = _isGreetingOnly(userMessage)
          ? text.trim()
          : _stripGreetingPrefix(text);

      final fallbackDirectResponse = _directTopicResponse(userMessage);
      if (cleanedText.trim().isEmpty && fallbackDirectResponse != null) {
        return fallbackDirectResponse;
      }

      if (cleanedText.trim().isEmpty) {
        return _getFallbackResponse(userMessage);
      }

      return cleanedText.trim();
    } catch (e, st) {
      dev.log(
        'Error calling Gemini API',
        name: 'chatbot_screen',
        error: e,
        stackTrace: st,
      );
      return _getFallbackResponse(userMessage);
    }
  }

  String _getFallbackResponse(String userMessage) {
    final topics = _matchedTopics(userMessage);
    final topic = topics.isNotEmpty ? topics.first : 'general';

    switch (topic) {
      case 'ihram':
        return 'Ihram begins with ghusl or wudu, then the intention for Umrah and Talbiyah: Labbayk Allahumma labbayk. From that point, avoid perfume, scented products, cutting hair or nails, and other Ihram restrictions until Umrah is completed. If you want, I can also give you the exact miqat and clothing rules.';
      case 'tawaf':
        return 'Tawaf is 7 counterclockwise circles around the Kaaba. Start at the Black Stone line, keep the Kaaba on your left, stay in wudu, and go around the Hijr Ismail instead of through it. After finishing, pray 2 rakah near Maqam Ibrahim if possible and drink Zamzam.';
      case 'sai':
        return 'Sai is 7 walks between Safa and Marwah, starting at Safa and ending at Marwah. Men jog between the green markers, women walk normally, and breaks are allowed if needed. After Sai, you move to Halq or Taqsir to complete Umrah.';
      case 'halq':
        return 'Halq or Taqsir is the final step of Umrah. Men may shave the whole head or trim, while women trim a small amount from the ends of the hair. After this, Ihram restrictions are lifted and Umrah is complete.';
      case 'zamzam':
        return 'Zamzam is blessed water in Makkah. You can drink it respectfully, preferably while facing the Qiblah if possible, say Bismillah, and make dua. It is often drunk after Tawaf or during a visit to the Haram.';
      case 'travel':
        return 'For travel, check passport validity, visa, vaccination requirements, hotel booking, medicines, and walking comfort. In Makkah, stay hydrated, plan around prayer times, and keep a simple route so you can focus on worship.';
      case 'women':
        return 'For women, Umrah guidance stays focused on modest clothing, no perfume after Ihram, no niqab or gloves during Ihram, and careful handling of menstruation rulings. If you want, I can answer the women-specific ruling for your exact step.';
      case 'mistakes':
        return 'If a mistake happens during Umrah, the correction depends on the exact action and timing. Some issues only need a fix or charity, while others need scholarly guidance or sacrifice. Tell me exactly what happened and I will narrow it down clearly.';
      default:
        return 'I can help with Ihram, Tawaf, Sai, Halq/Taqsir, Miqat, Talbiyah, women-specific rulings, travel prep, and common mistakes. Send me any Umrah word or situation and I will answer with the right step.';
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final userMessage = _messageController.text.trim();

    if (_isGreetingOnly(userMessage)) {
      setState(() {
        _messages.add(
          ChatMessage(
            text: userMessage,
            isBot: false,
            timestamp: DateTime.now(),
          ),
          );
        _messages.add(
          ChatMessage(
            text: _greetingResponse(),
            isBot: true,
            timestamp: DateTime.now(),
          ),
        );
      });

      _messageController.clear();
      _scrollToBottom();
      return;
    }

    setState(() {
      _messages.add(
        ChatMessage(text: userMessage, isBot: false, timestamp: DateTime.now()),
      );
      _isTyping = true;
    });

    _messageController.clear();
    _scrollToBottom();
    _typingController.repeat();

    final botResponse = await _getGeminiResponse(userMessage);

    if (!mounted) return;

    setState(() {
      _isTyping = false;
      _messages.add(
        ChatMessage(text: botResponse, isBot: true, timestamp: DateTime.now()),
      );
    });
    _typingController.stop();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _isLoading ? _primaryBlue : const Color(0xFFF7FAFF),
      body: _isLoading ? _buildLoadingScreen() : _buildChatScreen(),
    );
  }

  Widget _buildLoadingScreen() {
    return Container(
      color: _primaryBlue,
      width: double.infinity,
      height: double.infinity,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final size =
              (screenWidth < screenHeight ? screenWidth : screenHeight) * 0.7;
          return Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: ScaleTransition(
                scale: _scaleAnimation,
                child: SizedBox(
                  width: size,
                  height: size,
                  child: FittedBox(
                    fit: BoxFit.contain,
                    child: SizedBox(
                      width: size,
                      height: size,
                      child: Lottie.asset(
                        'assets/loadinginfinity.json',
                        repeat: true,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatScreen() {
    return SafeArea(
      child: Column(
        children: [
          _buildCustomAppBar(),
          Expanded(
            child: Container(
              color: Colors.white,
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                itemCount: _messages.length + (_isTyping ? 1 : 0),
                itemBuilder: (context, index) {
                  if (_isTyping && index == _messages.length) {
                    return _buildTypingBubble();
                  }
                  final message = _messages[index];
                  return _buildMessageBubble(message, index);
                },
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      decoration: const BoxDecoration(color: _primaryBlue),
      child: SafeArea(
        bottom: false,
        child: SizedBox(
          height: 60,
          child: Stack(
            alignment: Alignment.center,
            children: [
              const Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Divider(
                  height: 0.5,
                  thickness: 0.5,
                  color: Color(0x4DF7FAFF),
                ),
              ),
              Align(
                alignment: Alignment.centerLeft,
                child: Padding(
                  padding: const EdgeInsets.only(left: 2),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    splashRadius: 22,
                    hoverColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    focusColor: Colors.transparent,
                    onPressed: () => Navigator.of(context).maybePop(),
                    tooltip: 'Back',
                  ),
                ),
              ),
              _GlassIdentityChip(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: Color(0xFFEAF1FF),
                      child: Icon(
                        Icons.travel_explore_rounded,
                        color: _primaryBlue,
                        size: 22,
                      ),
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Smart Umrah AI',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.15,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(width: 6),
                    _OnlineDot(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isBot = message.isBot;
    final bubbleColor = isBot ? Colors.white : _primaryBlue;
    final textColor = isBot ? const Color(0xFF24364D) : Colors.white;

    double topGap;
    if (index == 0) {
      topGap = 12;
    } else {
      final prev = _messages[index - 1];
      topGap = prev.isBot == isBot ? 6 : 14;
    }

    final maxWidth = MediaQuery.of(context).size.width * 0.78;
    final bubble = ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxWidth.clamp(280, 420)),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bubbleColor,
          borderRadius: BorderRadius.circular(14),
          border: isBot ? Border.all(color: _borderBlue) : null,
          boxShadow: [
            BoxShadow(
              color: _primaryBlue.withOpacity(0.09),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(color: textColor, fontSize: 15, height: 1.35),
        ),
      ),
    );

    if (isBot) {
      return Padding(
        padding: EdgeInsets.only(top: topGap, bottom: 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const CircleAvatar(
              radius: 14,
              backgroundColor: _primaryBlue,
              child: Icon(
                Icons.travel_explore_rounded,
                size: 16,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 6),
            bubble,
          ],
        ),
      );
    }

    return Padding(
      padding: EdgeInsets.only(top: topGap, bottom: 4),
      child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [bubble]),
    );
  }

  Widget _buildTypingBubble() {
    return Padding(
      padding: const EdgeInsets.only(top: 14, bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CircleAvatar(
            radius: 14,
            backgroundColor: _primaryBlue,
            child: Icon(
              Icons.travel_explore_rounded,
              size: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _borderBlue),
              boxShadow: [
                BoxShadow(
                  color: _primaryBlue.withOpacity(0.09),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const _TypingDotsInline(),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _borderBlue),
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 120),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(color: Color(0xFF24364D)),
                    cursorColor: _primaryBlue,
                    minLines: 1,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      isCollapsed: true,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      hintText: 'Ask your Umrah question...',
                      hintStyle: TextStyle(color: Color(0xFF6B7D99)),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _primaryBlue,
                borderRadius: BorderRadius.circular(14),
              ),
              child: IconButton(
                icon: const Icon(Icons.send_rounded, color: Colors.white),
                hoverColor: Colors.transparent,
                highlightColor: Colors.transparent,
                splashColor: Colors.transparent,
                focusColor: Colors.transparent,
                onPressed: _messageController.text.trim().isEmpty
                    ? null
                    : _sendMessage,
                tooltip: 'Send',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TypingDotsInline extends StatefulWidget {
  const _TypingDotsInline();

  @override
  State<_TypingDotsInline> createState() => _TypingDotsInlineState();
}

class _TypingDotsInlineState extends State<_TypingDotsInline>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final t = _controller.value;
        double opacityFor(int i) {
          return 0.2 +
              0.8 * (0.5 + 0.5 * (mathSin((t * 2 * 3.14159) + (i * 0.6))));
        }

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _inlineDot(Colors.black.withOpacity(opacityFor(0))),
            const SizedBox(width: 4),
            _inlineDot(Colors.black.withOpacity(opacityFor(1))),
            const SizedBox(width: 4),
            _inlineDot(Colors.black.withOpacity(opacityFor(2))),
          ],
        );
      },
    );
  }

  Widget _inlineDot(Color color) {
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class ChatMessage {
  ChatMessage({
    required this.text,
    required this.isBot,
    required this.timestamp,
  });

  final String text;
  final bool isBot;
  final DateTime timestamp;
}

double mathSin(double x) => _sinTaylor(x);

double _sinTaylor(double x) {
  const double pi = 3.1415926535897932;
  while (x > pi) {
    x -= 2 * pi;
  }
  while (x < -pi) {
    x += 2 * pi;
  }

  final x2 = x * x;
  return x * (1 - x2 / 6 + x2 * x2 / 120 - x2 * x2 * x2 / 5040);
}
