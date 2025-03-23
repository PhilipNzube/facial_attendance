import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../controllers/register_student_controller.dart';

void showPassportDialog(BuildContext context) async {
  final action = await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Upload Passport Photo'),
      content: const Text('Please select an option'),
      actions: [
        TextButton(
          onPressed: () {
            Provider.of<RegisterStudentController>(context, listen: false)
                .pickImgFromGallary(context);
          },
          child: const Text('Select from Gallery'),
        ),
        TextButton(
          onPressed: () {
            Provider.of<RegisterStudentController>(context, listen: false)
                .takeNewPhoto(context);
          },
          child: const Text('Take a New Photo'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
      ],
    ),
  );
}
