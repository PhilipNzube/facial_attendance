import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../../core/widgets/custom_gap.dart';
import '../../../../controllers/manage_students_controller.dart';

void showUploadProgressDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return WillPopScope(
        onWillPop: () async => false, // Prevent back button dismiss
        child: StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Processing...'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(color: Colors.black),
                  const Gap(20),
                  ValueListenableBuilder(
                    valueListenable: Provider.of<ManageStudentController>(
                            context,
                            listen: false)
                        .uploadProgressNotifier,
                    builder: (context, value, child) {
                      return LinearProgressIndicator(
                        value: value / 100,
                        backgroundColor:
                            const Color(0xFFF5F5F5), // Almost white background
                        valueColor:
                            const AlwaysStoppedAnimation<Color>(Colors.blue),
                      );
                    },
                  ),
                  const Gap(20),
                  ValueListenableBuilder(
                    valueListenable: Provider.of<ManageStudentController>(
                            context,
                            listen: false)
                        .uploadTextNotifier,
                    builder: (context, value, child) {
                      return Text(value);
                    },
                  ),
                ],
              ),
            );
          },
        ),
      );
    },
  );
}
