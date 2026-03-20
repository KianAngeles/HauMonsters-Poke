import 'package:flutter/material.dart';
import 'package:pokemap/pages/dashboard_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    const pokemonRed = Color(0xFFD63A32);
    const pokemonBlue = Color(0xFF2A75BB);
    const pokemonYellow = Color(0xFFFFCB05);
    const creamBackground = Color(0xFFF8F2E7);
    const pokemonInk = Color(0xFF202632);
    final baseTextTheme = ThemeData.light(useMaterial3: true).textTheme;

    return MaterialApp(
      title: 'HAUMonsters',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: const ColorScheme.light(
          primary: pokemonRed,
          onPrimary: Colors.white,
          secondary: pokemonYellow,
          onSecondary: Colors.black,
          tertiary: pokemonBlue,
          onTertiary: Colors.white,
          surface: Colors.white,
          onSurface: pokemonInk,
          error: pokemonRed,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: creamBackground,
        textTheme: baseTextTheme.apply(
          bodyColor: pokemonInk,
          displayColor: pokemonInk,
        ),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: pokemonRed,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        cardTheme: CardThemeData(
          color: Colors.white.withValues(alpha: 0.95),
          elevation: 3,
          shadowColor: Colors.black.withValues(alpha: 0.08),
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        drawerTheme: const DrawerThemeData(backgroundColor: Color(0xFFFFFBF2)),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 16,
          ),
          labelStyle: const TextStyle(
            color: pokemonBlue,
            fontWeight: FontWeight.w600,
          ),
          prefixIconColor: pokemonBlue,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: pokemonBlue.withValues(alpha: 0.18)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: pokemonBlue.withValues(alpha: 0.18)),
          ),
          focusedBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: pokemonBlue, width: 2),
          ),
          errorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: pokemonRed),
          ),
          focusedErrorBorder: const OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(16)),
            borderSide: BorderSide(color: pokemonRed, width: 2),
          ),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: pokemonRed,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: pokemonBlue,
            side: BorderSide(color: pokemonBlue.withValues(alpha: 0.35)),
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: pokemonYellow,
          foregroundColor: Colors.black,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: pokemonBlue,
          contentTextStyle: TextStyle(color: Colors.white),
        ),
      ),
      home: const DashboardPage(),
    );
  }
}
