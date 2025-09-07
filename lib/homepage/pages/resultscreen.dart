// lib/homepage/pages/results_screen.dart
import 'package:aimy_ai/homepage/pages/semesterdetailscreen.dart';
import 'package:aimy_ai/homepage/pages/sidepage.dart';
import 'package:aimy_ai/models/subject_result.dart';
import 'package:flutter/material.dart';


// --- Dummy Data Source to simulate fetching semester results ---
final Map<String, Map<String, dynamic>> semesterData = {
  'Year 3, Second Semester': {
    'academicYear': '2024/2025 Academic Year',
    'results': [
      SubjectResult(
        courseCode: 'ACF 255',
        courseTitle: 'FINANCIAL ACCOUNTING I',
        grade: 'A',
        score: '98/100',
        description: 'Excellent',
      ),
      SubjectResult(
        courseCode: 'CSM 353',
        courseTitle: 'SURVEY OF PROGRAMMING LANGUAGES',
        grade: 'A',
        score: '85/100',
        description: 'Excellent',
      ),
      SubjectResult(
        courseCode: 'CSM 357',
        courseTitle: 'HUMAN COMPUTER INTERACTION',
        grade: 'A',
        score: '90/100',
        description: 'Excellent',
      ),
    ],
  },
  'Year 3, First Semester': {
    'academicYear': '2024/2025 Academic Year',
    'results': [
      SubjectResult(
        courseCode: 'CS311',
        courseTitle: 'DATA STRUCTURES',
        grade: 'B',
        score: '80/100',
        description: 'Very Good',
      ),
      SubjectResult(
        courseCode: 'CS312',
        courseTitle: 'OPERATING SYSTEMS',
        grade: 'C+',
        score: '75/100',
        description: 'Good',
      ),
    ],
  },
  'Year 2, Second Semester': {
    'academicYear': '2023/2024 Academic Year',
    'results': [
      SubjectResult(
        courseCode: 'CS221',
        courseTitle: 'ALGORITHMS',
        grade: 'A+',
        score: '95/100',
        description: 'Excellent',
      ),
    ],
  },
  'Year 2, First Semester': {
    'academicYear': '2023/2024 Academic Year',
    'results': [
      SubjectResult(
        courseCode: 'CS211',
        courseTitle: 'PROGRAMMING II',
        grade: 'B-',
        score: '78/100',
        description: 'Good',
      ),
    ],
  },
};

// --- Main Results Screen Widget ---
class ResultsScreen extends StatelessWidget {
  const ResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF8B0000),
      appBar: AppBar(
        title: const Text('Results'),
        backgroundColor: const Color(0xFF8B0000),
        foregroundColor: Colors.white,
        titleTextStyle: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        actions: [
          Builder(
            builder: (context) => IconButton(
              icon: const Icon(Icons.menu),
              onPressed: () => Scaffold.of(context).openEndDrawer(),
            ),
          ),
        ],
      ),
      endDrawer: const SidePage(initialIndex: 4),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30.0),
                    topRight: Radius.circular(30.0),
                  ),
                ),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a Semester',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF8B0000),
                        ),
                      ),
                      const SizedBox(height: 16.0),
                      ...semesterData.keys.map((semesterName) {
                        return SemesterCard(
                          year: semesterName,
                          period: semesterData[semesterName]!['academicYear'],
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => SemesterDetailsScreen(
                                  semesterYear: semesterName,
                                  academicYear: semesterData[semesterName]!['academicYear'],
                                  results: List<SubjectResult>.from(semesterData[semesterName]!['results']),
                                ),
                              ),
                            );
                          },
                        );
                      }).toList(),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Semester Card Widget ---
class SemesterCard extends StatelessWidget {
  final String year;
  final String period;
  final VoidCallback onTap;

  const SemesterCard({
    super.key,
    required this.year,
    required this.period,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16.0),
        margin: const EdgeInsets.symmetric(vertical: 8.0),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(15.0),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            Container(
              height: 60,
              width: 8,
              decoration: BoxDecoration(
                color: const Color(0xFF8B0000),
                borderRadius: BorderRadius.circular(4.0),
              ),
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    year,
                    style: const TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4.0),
                  Text(
                    period,
                    style: const TextStyle(
                      fontSize: 14.0,
                      fontWeight: FontWeight.w400,
                      color: Colors.grey,
                    ),
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