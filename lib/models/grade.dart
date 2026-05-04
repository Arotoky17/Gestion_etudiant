class Grade {
  final String id;
  String studentId;
  String subjectId;
  double value;
  String semester;
  DateTime date;

  Grade({
    required this.id,
    required this.studentId,
    required this.subjectId,
    required this.value,
    required this.semester,
    required this.date,
  });
}
