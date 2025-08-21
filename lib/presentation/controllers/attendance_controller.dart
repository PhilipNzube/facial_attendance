import 'package:flutter/material.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:file_picker/file_picker.dart';
import 'package:share_plus/share_plus.dart';

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

      // Generate PDF bytes
      final pdfBytes = await pdf.save();

      if (Platform.isAndroid) {
        // Show options to user
        final choice = await _showAndroidSaveOptions(context);

        if (choice == 'share') {
          // Share approach - works on all Android versions
          final directory = await getApplicationDocumentsDirectory();
          final file = File('${directory.path}/attendance.pdf');
          await file.writeAsBytes(pdfBytes);

          if (await file.exists()) {
            await Share.shareXFiles(
              [XFile(file.path)],
              text: 'Attendance Report',
              subject: 'Attendance Report PDF',
            );

            CustomSnackbar.show(
              context,
              'PDF generated successfully! You can now share or save it.',
            );
          } else {
            CustomSnackbar.show(context, 'Failed to generate PDF.',
                isError: true);
          }
        } else if (choice == 'downloads') {
          // Try to save to Downloads folder (may not work on Android 10+)
          try {
            final directory = Directory('/storage/emulated/0/Download');
            if (await directory.exists()) {
              final file = File('${directory.path}/attendance.pdf');
              await file.writeAsBytes(pdfBytes);

              if (await file.exists()) {
                CustomSnackbar.show(
                  context,
                  'PDF saved to Downloads folder',
                );
              } else {
                CustomSnackbar.show(context, 'Failed to save PDF.',
                    isError: true);
              }
            } else {
              CustomSnackbar.show(
                context,
                'Downloads folder not accessible. Please use Share option.',
                isError: true,
              );
            }
          } catch (e) {
            CustomSnackbar.show(
              context,
              'Cannot save to Downloads folder on this Android version. Please use Share option.',
              isError: true,
            );
          }
        }
      } else {
        // For other platforms, use the original approach
        String? outputPath;
        try {
          outputPath = await FilePicker.platform.getDirectoryPath();
        } catch (e) {
          print('FilePicker error: $e');
        }

        if (outputPath == null) {
          final directory = await getApplicationDocumentsDirectory();
          outputPath = directory.path;
        }

        final file = File('$outputPath/attendance.pdf');
        await file.writeAsBytes(pdfBytes);

        if (await file.exists()) {
          CustomSnackbar.show(
            context,
            'PDF saved at $outputPath/attendance.pdf',
          );
        } else {
          CustomSnackbar.show(context, 'Failed to save PDF.', isError: true);
        }
      }
    } catch (e) {
      print('Error generating PDF: $e');
      CustomSnackbar.show(context, 'Error generating PDF', isError: true);
    }
  }

  Future<String?> _showAndroidSaveOptions(BuildContext context) async {
    return await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Save PDF'),
          content: const Text(
            'Choose how you want to save the PDF:\n\n'
            '• Share: Works on all Android versions\n'
            '• Downloads: May not work on Android 10+',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop('share'),
              child: const Text('Share'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop('downloads'),
              child: const Text('Downloads'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(null),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  void notifyListenersCall() {
    notifyListeners();
  }
}
