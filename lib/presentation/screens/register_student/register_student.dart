import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'
    show FilteringTextInputFormatter, Uint8List, rootBundle;
import 'package:provider/provider.dart';
import 'package:path/path.dart' as path;
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/modern_button.dart';
import '../../../core/widgets/custom_snackbar.dart';
import '../../../data/models/school_model.dart';
import '../../controllers/register_student_controller.dart';
import 'widget/custom_dropdown.dart';
import 'widget/custom_text_field.dart';
import 'widget/dialogs/passport_dialog.dart';
import 'widget/dialogs/select_lga_dialog.dart';
import 'widget/dialogs/select_school_dialog.dart';
import 'widget/dialogs/select_school_type_dialog.dart';

class RegisterStudent extends StatefulWidget {
  final Function syncingSchools;
  const RegisterStudent({super.key, required this.syncingSchools});

  @override
  State<RegisterStudent> createState() => _RegisterStudentState();
}

class _RegisterStudentState extends State<RegisterStudent> {
  @override
  Widget build(BuildContext context) {
    final registerStudentController =
        Provider.of<RegisterStudentController>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Register Student'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.getResponsivePadding(context)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section
            ModernCard(
              padding:
                  EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: AppTheme.isDesktop(context) ? 72 : 56,
                        height: AppTheme.isDesktop(context) ? 72 : 56,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          Icons.person_add,
                          color: Colors.white,
                          size: AppTheme.isDesktop(context) ? 36 : 28,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Student Registration',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(
                                    context,
                                    mobile: 20,
                                    tablet: 24,
                                    desktop: 28),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary,
                                fontFamily: 'Inter',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Add a new student to the system',
                              style: TextStyle(
                                fontSize: AppTheme.getResponsiveFontSize(
                                    context,
                                    mobile: 14,
                                    tablet: 16,
                                    desktop: 18),
                                color: AppTheme.textSecondary,
                                fontFamily: 'Inter',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            SizedBox(height: AppTheme.isDesktop(context) ? 32 : 24),

            // Registration Form
            Form(
              key: registerStudentController.formKey,
              child: Column(
                children: [
                  // Personal Information Section
                  _buildSectionHeader('Personal Information'),

                  ModernCard(
                    child: Column(
                      children: [
                        CustomTextField(
                          controller:
                              registerStudentController.surnameController,
                          label: 'Surname',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter surname' : null,
                        ),
                        SizedBox(height: AppTheme.isDesktop(context) ? 24 : 16),
                        CustomTextField(
                          controller:
                              registerStudentController.firstNameController,
                          label: 'First Name',
                          validator: (value) =>
                              value!.isEmpty ? 'Please enter first name' : null,
                        ),
                        SizedBox(height: AppTheme.isDesktop(context) ? 24 : 16),
                        CustomTextField(
                          controller:
                              registerStudentController.middleNameController,
                          label: 'Middle Name (Optional)',
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.isDesktop(context) ? 32 : 24),

                  // Academic Information Section
                  _buildSectionHeader('Academic Information'),

                  ModernCard(
                    child: Column(
                      children: [
                        CustomDropdown<String>(
                          value: registerStudentController.selectedPresentLevel,
                          label: 'Present Level',
                          items: const [
                            '100 Level',
                            '200 Level',
                            '300 Level',
                            '400 Level'
                          ],
                          onChanged: (value) {
                            registerStudentController
                                .setSelectedPresentLevel(value!);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a present level';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: AppTheme.isDesktop(context) ? 24 : 16),
                        CustomDropdown<String>(
                          value: registerStudentController.selectedDepartment,
                          label: 'Department',
                          items: const [
                            'Computer Science',
                            'Mathematics',
                            'Statistics',
                            'Physics'
                          ],
                          onChanged: (value) {
                            registerStudentController
                                .setSelectedDepartment(value!);
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Please select a department';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: AppTheme.isDesktop(context) ? 32 : 24),

                  // Passport Photo Section
                  _buildSectionHeader('Passport Photo'),

                  ModernCard(
                    child: GestureDetector(
                      onTap: () {
                        showPassportDialog(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: AppTheme.isDesktop(context) ? 300 : 200,
                        decoration: BoxDecoration(
                          color: AppTheme.backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: AppTheme.borderColor,
                            width: 2,
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: registerStudentController
                                .passportImage.path.isNotEmpty
                            ? Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(14),
                                    child: Image.file(
                                      registerStudentController.passportImage,
                                      width: double.infinity,
                                      height: double.infinity,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                  Positioned(
                                    top: 8,
                                    right: 8,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: AppTheme.errorColor,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.close,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                        onPressed: () {
                                          registerStudentController
                                              .setPassportImage(File(''));
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.camera_alt_outlined,
                                    size: AppTheme.isDesktop(context) ? 64 : 48,
                                    color: AppTheme.textTertiary,
                                  ),
                                  SizedBox(
                                      height: AppTheme.isDesktop(context)
                                          ? 16
                                          : 12),
                                  Text(
                                    'Upload Passport Photo',
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(
                                          context,
                                          mobile: 16,
                                          tablet: 18,
                                          desktop: 20),
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.textPrimary,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to select photo',
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(
                                          context,
                                          mobile: 14,
                                          tablet: 16,
                                          desktop: 18),
                                      color: AppTheme.textSecondary,
                                      fontFamily: 'Inter',
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ),

                  SizedBox(height: AppTheme.isDesktop(context) ? 40 : 32),

                  // Submit Button
                  SizedBox(
                    width: double.infinity,
                    child: ModernButton(
                      text: 'Register Student',
                      onPressed: registerStudentController.isLoading
                          ? null
                          : () {
                              if (registerStudentController
                                  .passportImage.path.isEmpty) {
                                CustomSnackbar.show(
                                  context,
                                  'Please upload a passport photo',
                                  isError: true,
                                );
                                return;
                              }

                              if (registerStudentController
                                  .formKey.currentState!
                                  .validate()) {
                                registerStudentController.insertData(context);
                              }
                            },
                      isLoading: registerStudentController.isLoading,
                      icon: Icons.person_add,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.isDesktop(context) ? 16 : 12),
      child: Text(
        title,
        style: TextStyle(
          fontSize: AppTheme.getResponsiveFontSize(context,
              mobile: 18, tablet: 20, desktop: 24),
          fontWeight: FontWeight.bold,
          color: AppTheme.textPrimary,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}
