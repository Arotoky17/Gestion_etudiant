import 'package:flutter/material.dart';
import '../models/student.dart';
import 'dart:io';

class StudentCard extends StatelessWidget {
  final Student student;
  final VoidCallback onTap;

  const StudentCard({
    Key? key,
    required this.student,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'student-${student.id}',
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                _buildAvatar(),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        student.fullName,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${student.major} • ${student.level}',
                        style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                      ),
                      const SizedBox(height: 4),
                      _buildAttendanceIndicator(),
                    ],
                  ),
                ),
                _buildGradeBadge(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 28,
      backgroundColor: _getAvatarColor(),
      backgroundImage: student.profilePicture != null ? FileImage(File(student.profilePicture!)) : null,
      child: student.profilePicture == null
          ? Text(
              _getInitials(),
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            )
          : null,
    );
  }

  Widget _buildGradeBadge() {
    final grade = student.averageGrade;
    Color color;
    if (grade >= 12) {
      color = const Color(0xFF1D9E75); // Success (Green)
    } else if (grade >= 8) {
      color = const Color(0xFFEF9F27); // Alert (Orange)
    } else {
      color = const Color(0xFFE24B4A); // Danger (Red)
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        grade.toStringAsFixed(1),
        style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 14),
      ),
    );
  }

  Widget _buildAttendanceIndicator() {
    final rate = student.attendanceRate;
    return Row(
      children: [
        Icon(Icons.access_time, size: 14, color: Colors.grey.shade400),
        const SizedBox(width: 4),
        Text(
          '${rate.toStringAsFixed(0)}% présence',
          style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
        ),
      ],
    );
  }

  String _getInitials() {
    if (student.firstName.isEmpty && student.lastName.isEmpty) return '?';
    String f = student.firstName.isNotEmpty ? student.firstName[0] : '';
    String l = student.lastName.isNotEmpty ? student.lastName[0] : '';
    return (f + l).toUpperCase();
  }

  Color _getAvatarColor() {
    final colors = [
      const Color(0xFF534AB7),
      const Color(0xFF7F77DD),
      const Color(0xFF1D9E75),
      const Color(0xFFEF9F27),
      const Color(0xFFE24B4A),
    ];
    return colors[student.fullName.length % colors.length];
  }
}
