import '../models/student.dart';
import 'database_helper.dart';
import 'package:uuid/uuid.dart';

class StudentService {
  static final DatabaseHelper _dbHelper = DatabaseHelper();
  static final Uuid _uuid = Uuid();

  static Future<List<Student>> getStudents() async {
    return await _dbHelper.getStudents();
  }

  static Future<void> addStudent(Student student) async {
    final id = student.id.isEmpty ? _uuid.v4().substring(0, 8).toUpperCase() : student.id;
    final newStudent = Student(
      id: id,
      firstName: student.firstName,
      lastName: student.lastName,
      major: student.major,
      level: student.level,
      subjects: student.subjects,
      presentDays: student.presentDays,
      totalDays: student.totalDays,
      profilePicture: student.profilePicture,
    );
    await _dbHelper.insertStudent(newStudent);
  }

  static Future<void> updateStudent(Student student) async {
    await _dbHelper.updateStudent(student);
  }

  static Future<void> deleteStudent(String id) async {
    await _dbHelper.deleteStudent(id);
  }

  static Future<Map<String, dynamic>> getStatistics() async {
    final students = await getStudents();

    if (students.isEmpty) {
      return {
        'totalStudents': 0,
        'averageGrade': 0.0,
        'averageAttendance': 0.0,
      };
    }

    final totalStudents = students.length;
    final totalAverage = students.fold<double>(0, (sum, s) => sum + s.averageGrade) / totalStudents;
    final totalAttendance = students.fold<double>(0, (sum, s) => sum + s.attendanceRate) / totalStudents;

    return {
      'totalStudents': totalStudents,
      'averageGrade': totalAverage,
      'averageAttendance': totalAttendance,
    };
  }
}
