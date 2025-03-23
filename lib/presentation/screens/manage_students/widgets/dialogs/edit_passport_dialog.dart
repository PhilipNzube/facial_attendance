import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../../../../data/database/general_db/db_helper.dart';
import '../../../../controllers/manage_students_controller.dart';

void editPassport(int index, BuildContext context) async {
  final student = Provider.of<ManageStudentController>(context, listen: false)
      .students[index];
  String? originalPassport = student['passport'] as String?;
  File _passportImage = File('');

  showDialog(
    context: context,
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return AlertDialog(
          title: Text('Edit Passport for ${student['surname']}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                height: 200,
                margin: const EdgeInsets.symmetric(vertical: 10),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_passportImage.path.isNotEmpty)
                      Image.file(_passportImage)
                    else if (student['passport'] != null &&
                        student['passport'] != '')
                      Image.file(File(student['passport'] as String))
                    else
                      Icon(Icons.person),
                    if (_passportImage.path.isNotEmpty)
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _passportImage = File('');
                          });
                        },
                        child: Text('Delete Passport'),
                      ),
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().getImage(
                          source: ImageSource.gallery,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            _passportImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Text('Select from Gallery'),
                    ),
                    TextButton(
                      onPressed: () async {
                        final pickedFile = await ImagePicker().getImage(
                          source: ImageSource.camera,
                        );
                        if (pickedFile != null) {
                          setState(() {
                            _passportImage = File(pickedFile.path);
                          });
                        }
                      },
                      child: Text('Take a New Photo'),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () async {
                final database = await DBHelper().database;

                String? newPassportUrl;
                if (student['passport'] != originalPassport) {
                  if (await Provider.of<ManageStudentController>(context,
                          listen: false)
                      .hasInternet()) {
                    newPassportUrl = await Provider.of<ManageStudentController>(
                            context,
                            listen: false)
                        .uploadImage(
                            _passportImage, student['randomId'] as String);
                    student['cloudinaryUrl'] =
                        newPassportUrl; // Update Cloudinary URL
                  } else {
                    // Handle offline case
                    print(
                        'No internet connection. Image will be uploaded later.');
                  }
                }

                await database.update(
                  'students',
                  {
                    'passport': _passportImage.path,
                    'cloudinaryUrl':
                        student['cloudinaryUrl'], // Save updated Cloudinary URL
                  },
                  where: 'schoolId = ?',
                  whereArgs: [student['schoolId']],
                );
                await Provider.of<ManageStudentController>(context,
                        listen: false)
                    .loadStudents(); // Refresh the list
                Navigator.of(context).pop();
              },
              child: const Text('Save'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    ),
  );
}
