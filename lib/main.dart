import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:smart_umrah_app/routes/routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  runApp(const SmartUmrahApp());
}

class SmartUmrahApp extends StatelessWidget {
  const SmartUmrahApp({super.key});

  // Theme Colors from your dashboard
  static const Color primaryBlue = Color(0xFF0D47A1);
  static const Color secondaryBlue = Color(0xFF1976D2);
  static const Color accentColor = Color(0xFF64B5F6);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Smart Umrah Application',
      debugShowCheckedModeBanner: false,
      defaultTransition: Transition.fadeIn,
      
      // Customized Theme to match your Blue Theme
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: primaryBlue,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryBlue,
          primary: primaryBlue,
          secondary: secondaryBlue,
          surface: Colors.white,
        ),
        
        // Default AppBar Theme
        appBarTheme: const AppBarTheme(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
        ),

        // Default Button Theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // Default Input Decoration (TextFields)
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: primaryBlue, width: 2),
          ),
        ),
      ),
      
      initialRoute: AppRoutes.logo,
      getPages: AppRoutes.getpags, 
    );
  }
}