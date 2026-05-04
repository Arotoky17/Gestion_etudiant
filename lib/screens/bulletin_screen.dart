import 'package:flutter/material.dart';
import '../models/student.dart';

class BulletinScreen extends StatelessWidget {
  final Student student;

  const BulletinScreen({Key? key, required this.student}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final average = student.averageGrade;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bulletin de Notes'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, 10)),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(
                    child: Text(
                      'RÉSULTATS ACADÉMIQUES',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                    ),
                  ),
                  const Divider(height: 40),
                  _buildField('Nom', student.fullName),
                  _buildField('Filière', student.major),
                  _buildField('Niveau', student.level),
                  const SizedBox(height: 24),
                  const Text('Détail des notes', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...student.subjects.map((s) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(s.name),
                        Text('${s.grade}/20 (x${s.coefficient})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  )).toList(),
                  const Divider(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Moyenne Générale', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      Text(
                        '${average.toStringAsFixed(2)}/20',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: average >= 12 ? Colors.green : (average >= 8 ? Colors.orange : Colors.red),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Appréciation'),
                      Text(
                        _getAppreciation(average),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  String _getAppreciation(double average) {
    if (average >= 16) return 'Excellent';
    if (average >= 14) return 'Très bien';
    if (average >= 12) return 'Bien';
    if (average >= 10) return 'Passable';
    return 'Insuffisant';
  }
}
