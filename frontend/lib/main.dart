import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:quiz_generator_pro/l10n/app_localizations.dart';
import 'screens/home_screen.dart';

//********************* */ START SERVER COMMAND */***************************//
//*             uvicorn src.main:app --reload --port 8001                   *//  
//*********************   END SERVER COMMAND  *******************************//

void main() {
  runApp(const QuizApp());
}

class QuizApp extends StatefulWidget {
  const QuizApp({super.key});

  // Metodo statico per cambiare lingua da qualsiasi punto dell'app
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
    const Color bgDark = Color(0xFF0A0A0A); 
    const Color surfaceDark = Color(0xFF161616); 
    const Color vividGreen = Color(0xFF00E676); 

    return MaterialApp(
      title: 'Quiz Generator Pro', // App name fixed globally
      debugShowCheckedModeBanner: false,
      locale: _locale, 
      
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        scaffoldBackgroundColor: bgDark,
        primaryColor: vividGreen,
        
        appBarTheme: const AppBarTheme(
          backgroundColor: bgDark,
          elevation: 0,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          iconTheme: IconThemeData(color: Colors.white),
        ),

        colorScheme: const ColorScheme.dark(
          primary: vividGreen,
          secondary: vividGreen,
          surface: surfaceDark,
          onSurface: Colors.white,
          background: bgDark,
        ),

        textTheme: const TextTheme(
          bodyMedium: TextStyle(color: Colors.white),
        ),

        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF2C2C2C),
          labelStyle: TextStyle(color: Colors.grey[400]),
          hintStyle: TextStyle(color: Colors.grey[600]),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: vividGreen, width: 2)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        ),

        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: vividGreen,
            foregroundColor: Colors.black, 
            elevation: 0,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
        ),
        
        sliderTheme: SliderThemeData(
          activeTrackColor: vividGreen,
          inactiveTrackColor: Colors.grey[800], // FIXED: Gray background instead of dark/black
          thumbColor: Colors.white,
          overlayColor: vividGreen.withOpacity(0.2),
          trackHeight: 4.0, 
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
        Locale('es'),
        Locale('zh'),
        Locale('am'),
      ],
      home: const HomeScreen(),
    );
  }
}