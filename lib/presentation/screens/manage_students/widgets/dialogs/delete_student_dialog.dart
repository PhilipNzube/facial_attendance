import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../data/database/general_db/db_helper.dart';
import '../../../../controllers/manage_students_controller.dart';

void deleteStudent(int index, BuildContext context) async {
  final student = Provider.of<ManageStudentController>(context, listen: false)
      .students[index];
  final database = await DBHelper().database;

  await showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('Delete Student'),
      content: Text('Are you sure you want to delete ${student['surname']}?'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            await database.delete(
              'students',
              where: 'randomId = ?',
              whereArgs: [student['randomId']],
            );
            await Provider.of<ManageStudentController>(context, listen: false)
                .loadStudents();
            Navigator.of(context).pop();
          },
          child: Text('Delete'),
        ),
      ],
    ),
  );
}
