import 'package:flutter/material.dart';
import '../models/grade.dart';
import '../services/grade_service.dart';

class GradeManagementScreen extends StatefulWidget {
  const GradeManagementScreen({Key? key}) : super(key: key);

  @override
  State<GradeManagementScreen> createState() => _GradeManagementScreenState();
}

class _GradeManagementScreenState extends State<GradeManagementScreen> {
  String? _selectedStudentId;
  String? _selectedSubjectId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des notes'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Saisir les notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            _buildForm(),
            const SizedBox(height: 24),
            Text('Historique des notes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Expanded(child: _buildGradesList()),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddGradeDialog,
        label: const Text('Ajouter note'),
        icon: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Ajouter une nouvelle note', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: _showAddGradeDialog,
              icon: const Icon(Icons.add_circle),
              label: const Text('Nouvelle note'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradesList() {
    final grades = GradeService.grades;
    return ListView.separated(
      itemCount: grades.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final grade = grades[index];
        return Card(
          child: ListTile(
            title: Text('Étudiant #${grade.studentId}'),
            subtitle: Text('Matière #${grade.subjectId} - ${grade.value.toStringAsFixed(1)}/20'),
            trailing: IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: () {
                GradeService.deleteGrade(grade.id);
                setState(() {});
              },
            ),
          ),
        );
      },
    );
  }

  void _showAddGradeDialog() {
    final gradeController = TextEditingController();
    final semesterController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ajouter une note'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _selectedStudentId,
                  hint: const Text('Sélectionner un étudiant'),
                  items: [
                    const DropdownMenuItem(value: 'STU001', child: Text('Amine Khadir')),
                    const DropdownMenuItem(value: 'STU002', child: Text('Sara Benaissa')),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedStudentId = value);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedSubjectId,
                  hint: const Text('Sélectionner une matière'),
                  items: GradeService.subjects
                      .map((s) => DropdownMenuItem(value: s.id, child: Text(s.name)))
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedSubjectId = value);
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: gradeController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: const InputDecoration(labelText: 'Note (0-20)', prefixIcon: Icon(Icons.grade)),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: semesterController,
                  decoration: const InputDecoration(labelText: 'Semestre (S1, S2, etc.)', prefixIcon: Icon(Icons.calendar_today)),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                if (_selectedStudentId != null && _selectedSubjectId != null && gradeController.text.isNotEmpty) {
                  final grade = Grade(
                    id: 'GRD${DateTime.now().millisecondsSinceEpoch}',
                    studentId: _selectedStudentId!,
                    subjectId: _selectedSubjectId!,
                    value: double.tryParse(gradeController.text) ?? 0,
                    semester: semesterController.text.isEmpty ? 'S1' : semesterController.text,
                    date: DateTime.now(),
                  );
                  GradeService.addGrade(grade);
                  setState(() {});
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        );
      },
    );
  }
}
