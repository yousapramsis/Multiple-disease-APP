// heart_diseases_test_page.dart
import 'package:flutter/material.dart';

class HeartDiseasesTestPage extends StatelessWidget {
  const HeartDiseasesTestPage({Key? key}) : super(key: key);

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
        title: const Text('Heart Diseases Test',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: Colors.white)),
        centerTitle: true,
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
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                Text(
                  'Heart Disease Risk Factors',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: const Color(
                            0xFF2D2D3A), // Match main page text color
                      ),
                ),
                const SizedBox(height: 16),
                const HeartParameterCard(
                  title: 'Cholesterol Levels',
                  description: 'HDL, LDL, Total Cholesterol',
                  icon: Icons.water_drop,
                ),
                const SizedBox(height: 12),
                const HeartParameterCard(
                  title: 'Blood Pressure',
                  description: 'Systolic and Diastolic readings',
                  icon: Icons.favorite,
                ),
                const SizedBox(height: 12),
                const HeartParameterCard(
                  title: 'Smoking History',
                  description: 'Current or past smoker',
                  icon: Icons.smoking_rooms,
                ),
                // Add more parameters as needed
              ],
            ),
          ),
        ),
      ),
    );
  }
}


class HeartParameterCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;

  const HeartParameterCard({
    Key? key,
    required this.title,
    required this.description,
    required this.icon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}