import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class NusukInfoScreen extends StatelessWidget {
  const NusukInfoScreen({super.key});

  static final Uri _appUri = Uri.parse('nusuk://');
  static final Uri _playStoreUri = Uri.parse(
    'https://play.google.com/store/apps/details?id=com.moh.nusukapp',
  );

  Future<void> _openNusuk(BuildContext context) async {
    if (await canLaunchUrl(_appUri)) {
      await launchUrl(_appUri);
      return;
    }

    if (!context.mounted) return;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Nusuk App Required'),
        content: const Text(
          'To apply for Umrah or Hajj, please install the official Nusuk app.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await launchUrl(_playStoreUri, mode: LaunchMode.externalApplication);
              if (dialogContext.mounted) {
                Navigator.pop(dialogContext);
              }
            },
            child: const Text('Install'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nusuk App'),
        backgroundColor: const Color(0xFF0D47A1),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'What is Nusuk?',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Nusuk is the official platform by the Ministry of Hajj and Umrah for booking and managing Umrah and Hajj services. Pilgrims can use it to register, apply for permits, and prepare important travel steps before the journey.',
                      style: TextStyle(fontSize: 15, height: 1.45),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'With Nusuk, you can:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF0D47A1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      '- Request Umrah permits\n'
                      '- Manage booking details and appointments\n'
                      '- Access trusted guidance for rituals\n'
                      '- Review important updates related to your pilgrimage',
                      style: TextStyle(fontSize: 14.5, height: 1.5),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openNusuk(context),
                icon: const Icon(Icons.open_in_new_rounded),
                label: const Text('Open Nusuk App'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0D47A1),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
