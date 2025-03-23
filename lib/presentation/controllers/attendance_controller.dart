import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';

import '../../../data/database/general_db/db_helper.dart';
import '../../core/widgets/custom_snackbar.dart';
import 'package:permission_handler/permission_handler.dart';

class AttendanceController extends ChangeNotifier {
  bool _isLoading = false;
  List<Map<String, dynamic>> _students = [];

  AttendanceController() {
    _initialize();
  }

  // Public Getters
  bool get isLoading => _isLoading;
  List<Map<String, dynamic>> get students => _students;

  void _initialize() {
    loadStudents();
  }

  Future<void> loadStudents() async {
    final database = await DBHelper().database;
    final students = await database.rawQuery('SELECT * FROM students');

    _students = students.toList();
    notifyListeners();
  }

  void refreshPage() async {
    await loadStudents();
    _isLoading = true;
    notifyListeners();
    Future.delayed(Duration(seconds: 1), () {
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> generatePDF(BuildContext context) async {
    try {
      final pdf = pw.Document();

      final List<Map<String, dynamic>> filteredStudents =
          _students.where((student) => student['status'] == 1).toList();

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          build: (pw.Context context) {
            return pw.TableHelper.fromTextArray(
              context: context,
              data: [
                ['Name', 'Level', 'Department'],
                ...filteredStudents.map((student) => [
                      '${student['surname']?.toString().trim() ?? ''} ${student['firstname']}',
                      student['presentLevel'],
                      student['department'],
                    ]),
              ],
            );
          },
        ),
      );

      String? outputPath;
      try {
        outputPath = await FilePicker.platform.getDirectoryPath();
      } catch (e) {
        print('FilePicker error: $e');
      }

      if (outputPath == null) {
        if (Platform.isAndroid) {
          var status = await Permission.storage.request();
          if (!status.isGranted) {
            CustomSnackbar.show(
              context,
              'Storage permission required to save PDF.',
            );

            return;
          }
          final directory = Directory('/storage/emulated/0/Download');
          outputPath = directory.path;
        } else {
          final directory = await getApplicationDocumentsDirectory();
          outputPath = directory.path;
        }
      }

      final file = File('$outputPath/attendance.pdf');
      await file.writeAsBytes(await pdf.save());

      if (await file.exists()) {
        CustomSnackbar.show(
          context,
          'PDF saved at $outputPath/attendance.pdf',
        );
      } else {
        CustomSnackbar.show(context, 'Failed to save PDF.', isError: true);
      }
    } catch (e) {
      print('Error generating PDF: $e');
      CustomSnackbar.show(context, 'Error generating PDF: $e', isError: true);
    }
  }

  void notifyListenersCall() {
    notifyListeners();
  }
}
