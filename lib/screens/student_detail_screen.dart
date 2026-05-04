import 'package:flutter/material.dart';
import '../models/student.dart';
import '../services/pdf_service.dart';
import 'student_form_screen.dart';
import 'dart:io';

class StudentDetailScreen extends StatefulWidget {
  final Student student;

  const StudentDetailScreen({Key? key, required this.student}) : super(key: key);

  @override
  State<StudentDetailScreen> createState() => _StudentDetailScreenState();
}

class _StudentDetailScreenState extends State<StudentDetailScreen> {
  late Student _currentStudent;

  @override
  void initState() {
    super.initState();
    _currentStudent = widget.student;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'étudiant'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(builder: (_) => StudentFormScreen(student: _currentStudent)),
              );
              if (result == true) {
                // Since it's a local app, we might need to reload the student from DB
                // but for now let's just assume the form returns the updated student or we reload the dashboard
                Navigator.pop(context, true); 
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.picture_as_pdf),
            onPressed: () => PDFService.generateStudentReport(_currentStudent),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(context),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsRow(context),
                  const SizedBox(height: 24),
                  const Text('Détails des notes', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  _buildSubjectsList(context),
                  const SizedBox(height: 24),
                  _buildAttendanceSection(context),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 32),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          Hero(
            tag: 'student-${_currentStudent.id}',
            child: CircleAvatar(
              radius: 60,
              backgroundColor: Colors.white,
              backgroundImage: _currentStudent.profilePicture != null ? FileImage(File(_currentStudent.profilePicture!)) : null,
              child: _currentStudent.profilePicture == null
                  ? Text(_currentStudent.firstName[0] + _currentStudent.lastName[0], style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary))
                  : null,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _currentStudent.fullName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          Text(
            '${_currentStudent.major} • ${_currentStudent.level}',
            style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.8)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsRow(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildInfoCard(
            context,
            'Moyenne',
            _currentStudent.averageGrade.toStringAsFixed(2),
            Icons.star,
            _currentStudent.averageGrade >= 12 ? Colors.green : (_currentStudent.averageGrade >= 8 ? Colors.orange : Colors.red),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: _buildInfoCard(
            context,
            'Présence',
            '${_currentStudent.attendanceRate.toStringAsFixed(1)}%',
            Icons.check_circle,
            _currentStudent.attendanceRate >= 75 ? Colors.green : Colors.orange,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
          Text(label, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context) {
    if (_currentStudent.subjects.isEmpty) {
      return const Center(child: Text('Aucune note enregistrée'));
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _currentStudent.subjects.length,
      itemBuilder: (context, index) {
        final s = _currentStudent.subjects[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            title: Text(s.name, style: const TextStyle(fontWeight: FontWeight.w600)),
            subtitle: Text('Coefficient: ${s.coefficient}'),
            trailing: Text(
              '${s.grade}/20',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: s.grade >= 12 ? Colors.green : (s.grade >= 8 ? Colors.orange : Colors.red),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAttendanceSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assiduité', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Jours présents: ${_currentStudent.presentDays}'),
              Text('Total jours: ${_currentStudent.totalDays}'),
            ],
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: _currentStudent.attendanceRate / 100,
            minHeight: 8,
            borderRadius: BorderRadius.circular(4),
            color: Theme.of(context).colorScheme.primary,
            backgroundColor: Colors.grey.shade200,
          ),
        ],
      ),
    );
  }
}
