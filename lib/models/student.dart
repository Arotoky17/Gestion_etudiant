import 'dart:convert';

class Subject {
  String name;
  double grade;
  double coefficient;

  Subject({
    required this.name,
    required this.grade,
    required this.coefficient,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'grade': grade,
      'coefficient': coefficient,
    };
  }

  factory Subject.fromMap(Map<String, dynamic> map) {
    return Subject(
      name: map['name'],
      grade: (map['grade'] as num).toDouble(),
      coefficient: (map['coefficient'] as num).toDouble(),
    );
  }
}

class Student {
  final String id;
  String firstName;
  String lastName;
  String major; // Filière
  String level; // Niveau
  List<Subject> subjects;
  int presentDays;
  int totalDays;
  String? profilePicture;

  Student({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.major,
    required this.level,
    required this.subjects,
    required this.presentDays,
    required this.totalDays,
    this.profilePicture,
  });

  String get fullName => '$firstName $lastName';

  double get averageGrade {
    if (subjects.isEmpty) return 0.0;
    double totalWeightedGrade = 0;
    double totalCoefficients = 0;
    for (var subject in subjects) {
      totalWeightedGrade += subject.grade * subject.coefficient;
      totalCoefficients += subject.coefficient;
    }
    return totalCoefficients == 0 ? 0.0 : totalWeightedGrade / totalCoefficients;
  }

  double get attendanceRate {
    if (totalDays == 0) return 0.0;
    return (presentDays / totalDays) * 100;
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'firstName': firstName,
      'lastName': lastName,
      'major': major,
      'level': level,
      'subjects': jsonEncode(subjects.map((s) => s.toMap()).toList()),
      'presentDays': presentDays,
      'totalDays': totalDays,
      'profilePicture': profilePicture,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    var subjectsList = <Subject>[];
    if (map['subjects'] != null) {
      var decoded = jsonDecode(map['subjects']) as List;
      subjectsList = decoded.map((s) => Subject.fromMap(s)).toList();
    }

    return Student(
      id: map['id'],
      firstName: map['firstName'],
      lastName: map['lastName'],
      major: map['major'],
      level: map['level'],
      subjects: subjectsList,
      presentDays: map['presentDays'],
      totalDays: map['totalDays'],
      profilePicture: map['profilePicture'],
    );
  }
}
