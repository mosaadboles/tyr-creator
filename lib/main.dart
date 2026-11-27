import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const TyrCreatorApp());
}

class TyrCreatorApp extends StatelessWidget {
  const TyrCreatorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق تيار - صانع المحتوى',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar', 'AE'),
      supportedLocales: const [
        Locale('ar', 'AE'),
        Locale('en', 'US'),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6B1D2F),
      ),
      home: const HomeScreen(),
    );
  }
}
