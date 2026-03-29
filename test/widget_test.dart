// main.dart

import 'package:flutter/material.dart';
import 'package:smart_umrah_app/screens/landing_screen.dart'; // Make sure this path is correct based on your previous fix

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  // Make sure your constructor matches this exactly:
  const MyApp({
    super.key,
  }); // <--- THIS LINE IS CRUCIAL FOR `const MyApp()` TO WORK

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Umrah App',
      debugShowCheckedModeBanner: false, // Optional: remove debug banner
      theme: ThemeData(
        // Set your app-wide dark theme here
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(
          0xFF1E2A38,
        ), // Primary dark background
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E2A38), // Dark background for app bar
          foregroundColor: Colors.white, // White text/icons
          elevation: 0,
        ),
        // Define text theme for consistency
        textTheme: const TextTheme(
          displayLarge: TextStyle(color: Colors.white),
          displayMedium: TextStyle(color: Colors.white),
          displaySmall: TextStyle(color: Colors.white),
          headlineLarge: TextStyle(color: Colors.white),
          headlineMedium: TextStyle(color: Colors.white),
          headlineSmall: TextStyle(color: Colors.white),
          titleLarge: TextStyle(color: Colors.white),
          titleMedium: TextStyle(color: Colors.white),
          titleSmall: TextStyle(color: Colors.white),
          bodyLarge: TextStyle(color: Colors.white70),
          bodyMedium: TextStyle(color: Colors.white70),
          bodySmall: TextStyle(color: Colors.white70),
          labelLarge: TextStyle(color: Colors.white),
          labelMedium: TextStyle(color: Colors.white),
          labelSmall: TextStyle(color: Colors.white),
        ),
        // ElevatedButton theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF3B82F6), // Accent color
            foregroundColor: Colors.white, // Text color for button
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        // OutlinedButton theme
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.white,
            side: const BorderSide(
              color: Color(0xFF283645),
              width: 2,
            ), // Card background as border
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            textStyle: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        // Input decoration theme for consistent text fields
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF283645), // Card background
          hintStyle: const TextStyle(color: Colors.white70),
          prefixIconColor: Colors.white,
          suffixIconColor: Colors.white70,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
              color: Color(0xFF3B82F6),
              width: 2,
            ), // Accent on focus
          ),
          contentPadding: const EdgeInsets.symmetric(
            vertical: 16,
            horizontal: 16,
          ),
        ),
        // Dropdown theme
        dropdownMenuTheme: DropdownMenuThemeData(
          menuStyle: MenuStyle(
            backgroundColor: WidgetStateProperty.all(
              const Color(0xFF283645),
            ), // Dropdown background
          ),
          textStyle: const TextStyle(
            color: Colors.white,
          ), // Dropdown text color
        ),
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const LandingScreen(),
        // Make sure you have routes for other screens if they are used
        // e.g., '/user-login': (context) => const UserLoginScreen(),
        // '/signup': (context) => const SignUpScreen(),
      },
    );
  }
}

// Ensure you have these imports and classes if they are used in your routes:
// import 'package:smart_umrah_app/screens/user_login_screen.dart';
// import 'package:smart_umrah_app/screens/signup_screen.dart';
