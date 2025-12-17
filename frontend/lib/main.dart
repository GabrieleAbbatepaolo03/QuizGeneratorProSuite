import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz_generator_pro/l10n/app_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  static void setLocale(BuildContext context, Locale newLocale) {
    _QuizAppState? state = context.findAncestorStateOfType<_QuizAppState>();
    state?.setLocale(newLocale);
  }

  @override
  State<QuizApp> createState() => _QuizAppState();
}

class _QuizAppState extends State<QuizApp> {
  Locale? _locale;

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    // NUOVA PALETTE: VERDE VIVACE
    const Color bgDark = Color(0xFF0A0A0A); 
    const Color surfaceDark = Color(0xFF161616); 
    const Color vividGreen = Color(0xFF00E676); // Verde brillante stile Cyberpunk

    return MaterialApp(
      title: 'Study Buddy AI',
      debugShowCheckedModeBanner: false,
      locale: _locale, 
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: bgDark,
        primaryColor: vividGreen,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          titleTextStyle: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, fontFamily: 'Roboto'),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        cardTheme: CardThemeData(
          color: surfaceDark,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: BorderSide(color: Colors.white.withOpacity(0.05))
          ),
          margin: EdgeInsets.zero,
        ),

        colorScheme: const ColorScheme.dark(
          primary: vividGreen,
          secondary: vividGreen,
          surface: surfaceDark,
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF202020),
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: vividGreen, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: vividGreen,
            foregroundColor: Colors.black, // Testo nero su verde per contrasto
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        
        sliderTheme: SliderThemeData(
          activeTrackColor: vividGreen,
          inactiveTrackColor: Colors.grey[800],
          thumbColor: Colors.white,
          overlayColor: vividGreen.withOpacity(0.2),
        ),
      ),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('it'),
      ],
      home: const HomeScreen(),
    );
  }
}