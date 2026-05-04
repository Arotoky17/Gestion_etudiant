import '../models/grade.dart';
import '../models/subject.dart';

class GradeService {
  static final List<Grade> _grades = [
    Grade(
      id: 'GRD001',
      studentId: 'STU001',
      subjectId: 'SUB001',
      value: 16.0,
      semester: 'S1',
      date: DateTime.now(),
    ),
    Grade(
      id: 'GRD002',
      studentId: 'STU001',
      subjectId: 'SUB002',
      value: 17.5,
      semester: 'S1',
      date: DateTime.now(),
    ),
    Grade(
      id: 'GRD003',
      studentId: 'STU002',
      subjectId: 'SUB001',
      value: 14.5,
      semester: 'S1',
      date: DateTime.now(),
    ),
  ];

  static final List<Subject> _subjects = [
    Subject(id: 'SUB001', name: 'Mathématiques', coefficient: 3),
    Subject(id: 'SUB002', name: 'Français', coefficient: 2),
    Subject(id: 'SUB003', name: 'Anglais', coefficient: 2),
    Subject(id: 'SUB004', name: 'Histoire', coefficient: 2),
    Subject(id: 'SUB005', name: 'Sciences', coefficient: 3),
  ];

  static List<Grade> get grades => List.unmodifiable(_grades);
  static List<Subject> get subjects => List.unmodifiable(_subjects);

  static void addGrade(Grade grade) {
    _grades.add(grade);
  }

  static void updateGrade(Grade grade) {
    final index = _grades.indexWhere((item) => item.id == grade.id);
    if (index >= 0) {
      _grades[index] = grade;
    }
  }

  static void deleteGrade(String id) {
    _grades.removeWhere((grade) => grade.id == id);
  }

  static List<Grade> getStudentGrades(String studentId) {
    return _grades.where((grade) => grade.studentId == studentId).toList();
  }

  static double getStudentAverageForSubject(String studentId, String subjectId) {
    final studentGrades = _grades
        .where((g) => g.studentId == studentId && g.subjectId == subjectId)
        .toList();
    if (studentGrades.isEmpty) return 0;
    final sum = studentGrades.fold<double>(0, (sum, g) => sum + g.value);
    return sum / studentGrades.length;
  }

  static double getStudentGeneralAverage(String studentId) {
    final studentGrades = _grades.where((g) => g.studentId == studentId).toList();
    if (studentGrades.isEmpty) return 0;
    final sum = studentGrades.fold<double>(0, (sum, g) => sum + g.value);
    return sum / studentGrades.length;
  }

  static void addSubject(Subject subject) {
    _subjects.add(subject);
  }

  static void deleteSubject(String id) {
    _subjects.removeWhere((subject) => subject.id == id);
  }
}
