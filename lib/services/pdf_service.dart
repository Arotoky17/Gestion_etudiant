import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../models/student.dart';

class PDFService {
  static Future<void> exportStudentList(List<Student> students) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        build: (context) => [
          pw.Header(level: 0, child: pw.Text('Liste des Étudiants', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold))),
          pw.SizedBox(height: 20),
          pw.TableHelper.fromTextArray(
            headers: ['Nom', 'Filière', 'Niveau', 'Moyenne', 'Présence'],
            data: students.map((s) => [
              s.fullName,
              s.major,
              s.level,
              s.averageGrade.toStringAsFixed(2),
              '${s.attendanceRate.toStringAsFixed(0)}%'
            ]).toList(),
            headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
            headerDecoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFF534AB7)),
            cellHeight: 30,
            cellAlignments: {
              0: pw.Alignment.centerLeft,
              1: pw.Alignment.center,
              2: pw.Alignment.center,
              3: pw.Alignment.center,
              4: pw.Alignment.center,
            },
          ),
        ],
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/liste_etudiants.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Liste des étudiants');
  }

  static Future<void> generateStudentReport(Student student) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('RELEVÉ DE NOTES', style: pw.TextStyle(fontSize: 26, fontWeight: pw.FontWeight.bold, color: const PdfColor.fromInt(0xFF534AB7))),
              pw.Divider(thickness: 2),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      pw.Text('Étudiant: ${student.fullName}', style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
                      pw.Text('Filière: ${student.major}'),
                      pw.Text('Niveau: ${student.level}'),
                    ],
                  ),
                  pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.end,
                    children: [
                      pw.Text('Date: ${DateTime.now().day}/${DateTime.now().month}/${DateTime.now().year}'),
                      pw.Text('Présence: ${student.attendanceRate.toStringAsFixed(1)}%'),
                    ],
                  ),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Text('Détails des notes:', style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.TableHelper.fromTextArray(
                headers: ['Matière', 'Note', 'Coefficient', 'Total'],
                data: student.subjects.map((s) => [
                  s.name,
                  s.grade.toStringAsFixed(2),
                  s.coefficient.toStringAsFixed(1),
                  (s.grade * s.coefficient).toStringAsFixed(2)
                ]).toList(),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
              ),
              pw.SizedBox(height: 20),
              pw.Container(
                alignment: pw.Alignment.centerRight,
                child: pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.end,
                  children: [
                    pw.Divider(),
                    pw.Text('Moyenne Générale: ${student.averageGrade.toStringAsFixed(2)} / 20', 
                      style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold, color: student.averageGrade >= 10 ? const PdfColor.fromInt(0xFF1D9E75) : const PdfColor.fromInt(0xFFE24B4A))),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/bulletin_${student.lastName}.pdf');
    await file.writeAsBytes(await pdf.save());
    await Share.shareXFiles([XFile(file.path)], text: 'Bulletin de ${student.fullName}');
  }
}