import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../models/student.dart';
import '../services/student_service.dart';

class StudentFormScreen extends StatefulWidget {
  final Student? student;

  const StudentFormScreen({Key? key, this.student}) : super(key: key);

  @override
  State<StudentFormScreen> createState() => _StudentFormScreenState();
}

class _StudentFormScreenState extends State<StudentFormScreen> {
  int _currentStep = 0;
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();

  // Step 1 data
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  String? _selectedMajor;
  String? _selectedLevel;
  String? _imagePath;

  // Step 2 data
  List<Subject> _subjects = [];
  final _subjectNameController = TextEditingController();
  final _gradeController = TextEditingController();
  final _coeffController = TextEditingController();

  // Step 3 data
  late TextEditingController _presentDaysController;
  late TextEditingController _totalDaysController;

  @override
  void initState() {
    super.initState();
    final s = widget.student;
    _firstNameController = TextEditingController(text: s?.firstName ?? '');
    _lastNameController = TextEditingController(text: s?.lastName ?? '');
    _selectedMajor = s?.major;
    _selectedLevel = s?.level;
    _imagePath = s?.profilePicture;
    _subjects = s?.subjects != null ? List.from(s!.subjects) : [];
    _presentDaysController = TextEditingController(text: s?.presentDays.toString() ?? '0');
    _totalDaysController = TextEditingController(text: s?.totalDays.toString() ?? '200');
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _subjectNameController.dispose();
    _gradeController.dispose();
    _coeffController.dispose();
    _presentDaysController.dispose();
    _totalDaysController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imagePath = pickedFile.path;
      });
    }
  }

  void _addSubject() {
    if (_subjectNameController.text.isNotEmpty &&
        _gradeController.text.isNotEmpty &&
        _coeffController.text.isNotEmpty) {
      setState(() {
        _subjects.add(Subject(
          name: _subjectNameController.text,
          grade: double.tryParse(_gradeController.text) ?? 0.0,
          coefficient: double.tryParse(_coeffController.text) ?? 1.0,
        ));
        _subjectNameController.clear();
        _gradeController.clear();
        _coeffController.clear();
      });
    }
  }

  void _removeSubject(int index) {
    setState(() {
      _subjects.removeAt(index);
    });
  }

  void _saveStudent() async {
    final s = widget.student;
    final student = Student(
      id: s?.id ?? '',
      firstName: _firstNameController.text,
      lastName: _lastNameController.text,
      major: _selectedMajor ?? 'Inconnu',
      level: _selectedLevel ?? 'N/A',
      subjects: _subjects,
      presentDays: int.tryParse(_presentDaysController.text) ?? 0,
      totalDays: int.tryParse(_totalDaysController.text) ?? 200,
      profilePicture: _imagePath,
    );

    if (s == null) {
      await StudentService.addStudent(student);
    } else {
      await StudentService.updateStudent(student);
    }

    if (mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student == null ? 'Nouvel Étudiant' : 'Modifier Étudiant'),
      ),
      body: Stepper(
        type: StepperType.horizontal,
        currentStep: _currentStep,
        onStepContinue: () {
          if (_currentStep < 2) {
            setState(() => _currentStep += 1);
          } else {
            _saveStudent();
          }
        },
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() => _currentStep -= 1);
          } else {
            Navigator.pop(context);
          }
        },
        steps: [
          _buildStep1(),
          _buildStep2(),
          _buildStep3(),
        ],
      ),
    );
  }

  Step _buildStep1() {
    return Step(
      title: const Text('Infos'),
      isActive: _currentStep >= 0,
      content: Form(
        key: _formKey1,
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                child: _imagePath == null
                    ? Icon(Icons.add_a_photo, size: 40, color: Theme.of(context).colorScheme.primary)
                    : null,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _firstNameController,
              decoration: const InputDecoration(labelText: 'Prénom', prefixIcon: Icon(Icons.person_outline)),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _lastNameController,
              decoration: const InputDecoration(labelText: 'Nom', prefixIcon: Icon(Icons.person)),
              validator: (v) => v!.isEmpty ? 'Requis' : null,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedMajor,
              decoration: const InputDecoration(labelText: 'Filière', prefixIcon: Icon(Icons.school)),
              items: ['Informatique', 'Gestion', 'Droit', 'Médecine']
                  .map((m) => DropdownMenuItem(value: m, child: Text(m)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedMajor = v),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedLevel,
              decoration: const InputDecoration(labelText: 'Niveau', prefixIcon: Icon(Icons.layers)),
              items: ['L1', 'L2', 'L3', 'M1', 'M2']
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _selectedLevel = v),
            ),
          ],
        ),
      ),
    );
  }

  Step _buildStep2() {
    double avg = 0;
    if (_subjects.isNotEmpty) {
      double totalWeighted = _subjects.fold(0, (sum, s) => sum + (s.grade * s.coefficient));
      double totalCoeff = _subjects.fold(0, (sum, s) => sum + s.coefficient);
      avg = totalCoeff > 0 ? totalWeighted / totalCoeff : 0;
    }

    return Step(
      title: const Text('Notes'),
      isActive: _currentStep >= 1,
      content: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Moyenne Pondérée:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text(
                  avg.toStringAsFixed(2),
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(flex: 3, child: TextField(controller: _subjectNameController, decoration: const InputDecoration(hintText: 'Matière'))),
              const SizedBox(width: 8),
              Expanded(flex: 2, child: TextField(controller: _gradeController, decoration: const InputDecoration(hintText: 'Note'), keyboardType: TextInputType.number)),
              const SizedBox(width: 8),
              Expanded(flex: 1, child: TextField(controller: _coeffController, decoration: const InputDecoration(hintText: 'Coef'), keyboardType: TextInputType.number)),
              IconButton(onPressed: _addSubject, icon: const Icon(Icons.add_circle, color: Colors.green)),
            ],
          ),
          const Divider(height: 32),
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _subjects.length,
            itemBuilder: (context, index) {
              final s = _subjects[index];
              return ListTile(
                title: Text(s.name),
                subtitle: Text('Note: ${s.grade} | Coeff: ${s.coefficient}'),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, color: Colors.red), onPressed: () => _removeSubject(index)),
              );
            },
          ),
        ],
      ),
    );
  }

  Step _buildStep3() {
    return Step(
      title: const Text('Présence'),
      isActive: _currentStep >= 2,
      content: Form(
        key: _formKey3,
        child: Column(
          children: [
            const Text('Indiquez le taux de présence de l\'étudiant sur l\'année.'),
            const SizedBox(height: 24),
            TextFormField(
              controller: _presentDaysController,
              decoration: const InputDecoration(labelText: 'Jours Présents', prefixIcon: Icon(Icons.check_circle_outline)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _totalDaysController,
              decoration: const InputDecoration(labelText: 'Total Jours', prefixIcon: Icon(Icons.calendar_month_outlined)),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            Builder(builder: (context) {
              int present = int.tryParse(_presentDaysController.text) ?? 0;
              int total = int.tryParse(_totalDaysController.text) ?? 1;
              double rate = (present / total) * 100;
              return Column(
                children: [
                  Text('${rate.toStringAsFixed(1)}% de présence', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: rate / 100,
                    minHeight: 10,
                    borderRadius: BorderRadius.circular(5),
                    backgroundColor: Colors.grey.shade200,
                    color: rate >= 75 ? Colors.green : (rate >= 50 ? Colors.orange : Colors.red),
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
