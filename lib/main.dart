import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Supabase.initialize(
    url: 'https://qnmjmhyxyyhuiyobdebk.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InFubWptaHl4eXlodWl5b2JkZWJrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTUwNzU4NjAsImV4cCI6MjA3MDY1MTg2MH0.YTNoraJyuxGOzhGvcratUWBfgK5sSKMQqmxTD_Hw7FE',
  );
  runApp(const SmartUmrahApp());
}

class SmartUmrahApp extends StatelessWidget {
  const SmartUmrahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Umrah Application',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Color(0XFF263442)),
      ),
      initialRoute: AppRoutes.landingscreen,
      getPages: AppRoutes().getpags,
    );
  }
}
