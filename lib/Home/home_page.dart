import 'package:flutter/material.dart';
import 'package:project_grad/Home/widgets/diseases_card.dart';

import '../AboutUs/AboutUsPage.dart';
import '../Diseases/Diabetes/diabetes_symptoms_screen.dart';
import '../Diseases/Heart/heart_diseases_test_page.dart';
import '../Diseases/Hypertention/hypertension_test_page.dart';

class MyHomePage extends StatelessWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF6C63FF), Color(0xFF4A90E2)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () => _showUnderDevelopment(context),
          ),
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AboutUsPage()),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF8F9FF), Color(0xFFE6E9FF)],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/health_icon.png',
                        height: 180,
                      ),
                      const SizedBox(height: 30),
                      const Text(
                        'Early Detection Saves Lives',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D3A),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 15),
                      const Text(
                        'Assess your health risks with our AI-powered predictive models. '
                        'Results are indicative - always consult a healthcare professional.',
                        style: TextStyle(
                          fontSize: 16,
                          color: Color(0xFF5A5A5A),
                          height: 1.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(vertical: 30),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(40)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'Health Assessments',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF4A90E2),
                      ),
                    ),
                    const SizedBox(height: 25),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Row(
                        children: [
                          const SizedBox(width: 20),
                          DiseaseCard(
                            title: 'Diabetes',
                            icon: Icons.bloodtype,
                            color1: const Color.fromARGB(255, 238, 255, 0),
                            color2: const Color.fromARGB(255, 132, 155, 2),
                            route:
                                DiabetesSymptomsScreen(), // Route to symptoms screen first
                          ),
                          const DiseaseCard(
                            title: 'Hypertension',
                            icon: Icons.monitor_heart,
                            color1: Color.fromARGB(255, 71, 85, 209),
                            color2: Color.fromARGB(255, 66, 86, 231),
                            route: HypertensionTestPage(),
                          ),
                          const DiseaseCard(
                            title: 'Heart Health',
                            icon: Icons.favorite,
                            color1:
                                Color(0xFFF44336), // Red Color for Heart Health
                            color2: Color(0xFFE57373), // Lighter Red
                            route: HeartDiseasesTestPage(),
                          ),
                          const SizedBox(width: 20),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUnderDevelopment(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Feature coming soon!'),
        duration: Duration(seconds: 1),
      ),
    );
  }
}
