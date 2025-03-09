import 'package:flutter/material.dart';
import 'package:project_grad/splash/splash_screen.dart';
import 'AboutUs/AboutUsPage.dart';
import 'Diseases/Diabetes/diabetes_symptoms_screen.dart'
    show DiabetesSymptomsScreen;
import 'Diseases/Heart/heart_diseases_test_page.dart';
import 'Diseases/Hypertention/hypertension_test_page.dart';
import 'Home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Health Guardian',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6C63FF),
        ),
        useMaterial3: true,
        fontFamily: 'Nunito',
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          titleTextStyle: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w700,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF6C63FF),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 2,
          ),
        ),
        scaffoldBackgroundColor: Colors.transparent,
      ),
      home: SplashScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
