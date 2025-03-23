import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:facial_attendance/presentation/screens/manage_students/widgets/dialogs/select_school_dialog.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

import '../../../../../core/widgets/custom_gap.dart';
import '../../../../../core/widgets/custom_snackbar.dart';
import '../../../../../data/database/general_db/db_helper.dart';
import '../../../../../data/models/school_model.dart';
import '../../../../controllers/manage_students_controller.dart';
import 'package:image/image.dart' as img;

import '../../../register_student/widget/custom_dropdown.dart';
import '../../../register_student/widget/custom_text_field.dart';

void editStudentDialog(int index, BuildContext context) async {
  Provider.of<ManageStudentController>(context, listen: false)
      .setLoadSchoolsFuture(
          Provider.of<ManageStudentController>(context, listen: false)
              .syncAndLoadSchools()
              .then((schools) {
    Provider.of<ManageStudentController>(context, listen: false)
        .setSchools(schools); // Populate _schools
    return schools; // Explicitly return the schools list
  }));
  final student = Map<String, Object?>.from(
      Provider.of<ManageStudentController>(context, listen: false)
          .students[index]);
  String? passportImg = student['passport'] as String?;
  Provider.of<ManageStudentController>(context, listen: false)
      .setSelectedSchool(student['schoolId'] as String?);

  if (passportImg != null && passportImg.isNotEmpty) {
    Provider.of<ManageStudentController>(context, listen: false)
        .setPassportImage(File(passportImg));
  }

  // Fetch the student's current values
  String? currentState = student['stateOfOrigin']?.toString();
  String? currentLga = student['lga']?.toString();
  String? currentLgaOfEnrollment = student['lgaOfEnrollment']?.toString();
  String? currentWard = student['ward']?.toString();

  // Fetch LGAs and wards for the student's state
  if (currentState != null) {
    Provider.of<ManageStudentController>(context, listen: false).getStates();
    Provider.of<ManageStudentController>(context, listen: false)
        .getLgas(currentState);
    Provider.of<ManageStudentController>(context, listen: false)
        .getLgasOfEnrollment(currentState);
    if (currentLgaOfEnrollment != null) {
      Provider.of<ManageStudentController>(context, listen: false)
          .getWardsOfEnrollment(currentLgaOfEnrollment, currentState);
    }
  }
  // Create controllers for each field and initialize them with the current student data
  final TextEditingController surnameController =
      TextEditingController(text: student['surname']?.toString() ?? '');
  final TextEditingController studentNinController =
      TextEditingController(text: student['studentNin']?.toString() ?? '');
  final TextEditingController _wardController =
      TextEditingController(text: currentWard ?? '');
  final TextEditingController _firstNameController =
      TextEditingController(text: student['firstname']?.toString() ?? '');
  final TextEditingController _middleNameController =
      TextEditingController(text: student['middlename']?.toString() ?? '');
  final TextEditingController genderController =
      TextEditingController(text: student['gender']?.toString() ?? '');
  final TextEditingController dobController =
      TextEditingController(text: student['dob']?.toString() ?? '');
  final TextEditingController nationalityController =
      TextEditingController(text: student['nationality']?.toString() ?? '');
  final TextEditingController stateOfOriginController =
      TextEditingController(text: student['stateOfOrigin']?.toString() ?? '');
  final TextEditingController lgaController =
      TextEditingController(text: student['lga']?.toString() ?? '');
  final TextEditingController lgaOfEnrollmentController =
      TextEditingController(text: currentLgaOfEnrollment ?? '');
  final TextEditingController communityNameController =
      TextEditingController(text: student['communityName']?.toString() ?? '');
  final TextEditingController residentialAddressController =
      TextEditingController(
          text: student['residentialAddress']?.toString() ?? '');
  final TextEditingController presentClassController =
      TextEditingController(text: student['presentClass']?.toString() ?? '');
  final TextEditingController yearOfEnrollmentController =
      TextEditingController(
          text: student['yearOfEnrollment']?.toString() ?? '');
  final TextEditingController parentContactController =
      TextEditingController(text: student['parentContact']?.toString() ?? '');
  final TextEditingController parentOccupationController =
      TextEditingController(
          text: student['parentOccupation']?.toString() ?? '');
  final TextEditingController parentPhoneController =
      TextEditingController(text: student['parentPhone']?.toString() ?? '');
  final TextEditingController parentNameController =
      TextEditingController(text: student['parentName']?.toString() ?? '');
  final TextEditingController parentNinController =
      TextEditingController(text: student['parentNin']?.toString() ?? '');
  final TextEditingController parentBvnController = TextEditingController(
      text: student['parentBvn']?.toString() ?? ''); // Parent BVN Controller
  final TextEditingController bankNameController =
      TextEditingController(text: student['bankName']?.toString() ?? '');
  final TextEditingController accountNumberController =
      TextEditingController(text: student['accountNumber']?.toString() ?? '');
  final TextEditingController passportController =
      TextEditingController(text: student['passport']?.toString() ?? '');

  // Dropdown values
  String? _selectedGender = student['gender']?.toString() ?? 'Female';
  String? _selectedNationality =
      student['nationality']?.toString() ?? 'Nigeria';
  String? _selectedState = student['stateOfOrigin']?.toString();
  String? _selectedLga = student['lga']?.toString();
  String? _selectedLgaOfEnrollment = student['lgaOfEnrollment']?.toString();
  String? _selectedPresentLevel = student['presentLevel']?.toString();
  String? _selectedDepartment = student['department']?.toString();
  int? _selectedYearOfEnrollment = student['yearOfEnrollment'] != null
      ? int.tryParse(student['yearOfEnrollment'].toString())
      : null;
  String? _selectedParentOccupation = student['parentOccupation']?.toString();
  String? _selectedBank = student['bankName']?.toString();
  String? _selectedDisabilityStatus =
      student['disabilityStatus']?.toString() ?? 'No';

  print(
      '${lgaOfEnrollmentController.text}, $currentState, $currentLga, $currentLgaOfEnrollment, $currentWard');

  showDialog(
    context: context,
    builder: (context) => FutureBuilder<List<School>>(
        future: Provider.of<ManageStudentController>(context, listen: false)
            .loadSchoolsFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Colors.black));
          } else if (snapshot.hasError) {
            return AlertDialog(
              title: Text('Error'),
              content: Text('Failed to load schools. Please try again later.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          } else {
            return StatefulBuilder(
              builder: (context, setState) {
                String currentSchoolName =
                    Provider.of<ManageStudentController>(context, listen: false)
                        .schools
                        .firstWhere(
                          (school) =>
                              school.id ==
                              Provider.of<ManageStudentController>(context,
                                      listen: false)
                                  .selectedSchool,
                          orElse: () =>
                              School(id: '', schoolName: 'Unknown School'),
                        )
                        .schoolName;

                return AlertDialog(
                  title: Text('Edit ${student['surname']}'),
                  content: SingleChildScrollView(
                    child: Form(
                      key: Provider.of<ManageStudentController>(context,
                              listen: false)
                          .formKey, // Use the GlobalKey here
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CustomTextField(
                            controller: surnameController,
                            label: 'Surname',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter surname';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),
                          CustomTextField(
                            controller: _firstNameController,
                            label: 'Firstname',
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter firstname';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),
                          CustomTextField(
                            controller: _middleNameController,
                            label: 'Middlename',
                          ),
                          const Gap(10),
                          CustomDropdown<String>(
                            value: _selectedPresentLevel,
                            label: 'Present Level',
                            items: const [
                              '100 Level',
                              '200 Level',
                              '300 Level',
                              '400 Level'
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedPresentLevel = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a present class';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),
                          CustomDropdown<String>(
                            value: _selectedDepartment,
                            label: 'Department',
                            items: const [
                              'Computer Science',
                              'Mathematics',
                              'Statistics',
                              'Physics'
                            ],
                            onChanged: (value) {
                              setState(() {
                                _selectedDepartment = value!;
                              });
                            },
                            validator: (value) {
                              if (value == null) {
                                return 'Please select a department';
                              }
                              return null;
                            },
                          ),
                          const Gap(10),
                          GestureDetector(
                            onTap: () async {
                              await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Upload Passport Photo'),
                                  content: Text('Please select an option'),
                                  actions: [
                                    TextButton(
                                      onPressed: () async {
                                        final pickedFile =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.gallery,
                                        );
                                        if (pickedFile != null) {
                                          final originalImage = img.decodeImage(
                                            File(pickedFile.path)
                                                .readAsBytesSync(),
                                          );

                                          if (originalImage != null) {
                                            final croppedImage =
                                                img.copyResizeCropSquare(
                                                    originalImage,
                                                    size: 200);

                                            final randomDigit =
                                                Random().nextInt(10).toString();
                                            final newFileName =
                                                'passport_${randomDigit}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                            final directory =
                                                await getApplicationDocumentsDirectory();
                                            final newFile = File(
                                                '${directory.path}/$newFileName');

                                            await newFile.writeAsBytes(
                                                img.encodeJpg(croppedImage));

                                            setState(() {
                                              Provider.of<ManageStudentController>(
                                                      context,
                                                      listen: false)
                                                  .setPassportImage(newFile);
                                              student['passport'] =
                                                  newFile.path;
                                            });

                                            print(
                                                'Image cropped and saved to: ${newFile.path}');
                                          }
                                        }

                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Select from Gallery'),
                                    ),
                                    TextButton(
                                      onPressed: () async {
                                        final pickedFile =
                                            await ImagePicker().pickImage(
                                          source: ImageSource.camera,
                                        );
                                        if (pickedFile != null) {
                                          final originalImage = img.decodeImage(
                                            File(pickedFile.path)
                                                .readAsBytesSync(),
                                          );

                                          if (originalImage != null) {
                                            final croppedImage =
                                                img.copyResizeCropSquare(
                                                    originalImage,
                                                    size: 200);

                                            final randomDigit =
                                                Random().nextInt(10).toString();
                                            final newFileName =
                                                'passport_${randomDigit}_${DateTime.now().millisecondsSinceEpoch}.jpg';
                                            final directory =
                                                await getApplicationDocumentsDirectory();
                                            final newFile = File(
                                                '${directory.path}/$newFileName');

                                            await newFile.writeAsBytes(
                                                img.encodeJpg(croppedImage));

                                            setState(() {
                                              Provider.of<ManageStudentController>(
                                                      context,
                                                      listen: false)
                                                  .setPassportImage(newFile);
                                              student['passport'] =
                                                  newFile.path;
                                            });

                                            print(
                                                'Image cropped and saved to: ${newFile.path}');
                                          }
                                        }

                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Take a New Photo'),
                                    ),
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            child: Container(
                              width: double.infinity,
                              height: 180,
                              margin: const EdgeInsets.symmetric(vertical: 10),
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  if (Provider.of<ManageStudentController>(
                                          context,
                                          listen: false)
                                      .passportImage
                                      .path
                                      .isEmpty) ...[
                                    const Icon(Icons.photo,
                                        size: 50, color: Colors.grey),
                                    const Gap(10),
                                    const Text(
                                      'Upload Passport Photo',
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                      textAlign: TextAlign.center,
                                    ),
                                  ] else ...[
                                    // Image preview
                                    Container(
                                      width: 80,
                                      height: 80,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(color: Colors.grey),
                                        image: DecorationImage(
                                          image: FileImage(Provider.of<
                                                      ManageStudentController>(
                                                  context,
                                                  listen: false)
                                              .passportImage),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                    const Gap(8),

                                    // Confirmation text
                                    const Text(
                                      'Passport photo uploaded',
                                      style: TextStyle(
                                          fontSize: 14, color: Colors.green),
                                      textAlign: TextAlign.center,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const Gap(6),

                                    // Delete button
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          Provider.of<ManageStudentController>(
                                                  context,
                                                  listen: false)
                                              .setPassportImage(File(''));
                                          student['passport'] = '';
                                        });
                                      },
                                      child: const Text(
                                        'Delete Passport',
                                        style: TextStyle(color: Colors.red),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () async {
                        if (Provider.of<ManageStudentController>(context,
                                listen: false)
                            .formKey
                            .currentState!
                            .validate()) {
                          final database = await DBHelper().database;

                          // final recordExists =
                          //     await Provider.of<ManageStudentController>(
                          //             context,
                          //             listen: false)
                          //         .checkIfRecordExists(
                          //   studentNin: studentNinController.text,
                          //   accountNumber: accountNumberController.text,
                          // );

                          if (Provider.of<ManageStudentController>(context,
                                  listen: false)
                              .passportImage
                              .path
                              .isEmpty) {
                            CustomSnackbar.show(
                              context,
                              'Please upload a passport photo',
                              isError: true,
                            );

                            return;
                          }

                          await database.update(
                            'students',
                            {
                              'surname': surnameController.text,

                              'firstname': _firstNameController.text,
                              'middlename': _middleNameController.text,

                              'presentLevel': _selectedPresentLevel,
                              'department': _selectedDepartment,

                              'passport': student['passport'],
                              'cloudinaryUrl': student[
                                  'cloudinaryUrl'], // Save updated Cloudinary URL
                              'status': 0,
                            },
                            where: 'randomId = ?',
                            whereArgs: [student['randomId']],
                          );
                          await Provider.of<ManageStudentController>(context,
                                  listen: false)
                              .loadStudents(); // Refresh the list
                          Navigator.of(context).pop();
                        }
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
            );
          }
        }),
  );
}
