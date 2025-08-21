import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/modern_button.dart';
import '../../controllers/manage_students_controller.dart';
import 'widgets/dialogs/confirm_upload_data_dialog.dart';
import 'widgets/dialogs/confirm_view_data_dialog.dart';
import 'widgets/dialogs/delete_student_dialog.dart';
import 'widgets/dialogs/edit_dialog.dart';

class ManageStudents extends StatefulWidget {
  const ManageStudents({super.key});

  @override
  State<ManageStudents> createState() => _ManageStudentsState();
}

class _ManageStudentsState extends State<ManageStudents> {
  @override
  Widget build(BuildContext context) {
    final manageStudentController =
        Provider.of<ManageStudentController>(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Manage Students'),
        actions: [
          ModernIconButton(
            icon: Icons.refresh,
            onPressed: manageStudentController.loadStudents,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: manageStudentController.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : manageStudentController.students.isEmpty
              ? _buildEmptyState()
              : _buildStudentList(manageStudentController),
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context)),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: MediaQuery.of(context).size.height * 0.1),
            Container(
              width: AppTheme.isDesktop(context) ? 160 : 120,
              height: AppTheme.isDesktop(context) ? 160 : 120,
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(
                    AppTheme.isDesktop(context) ? 80 : 60),
                border: Border.all(
                  color: AppTheme.borderColor,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.people_outline,
                size: AppTheme.isDesktop(context) ? 80 : 60,
                color: AppTheme.textTertiary,
              ),
            ),
            SizedBox(height: AppTheme.isDesktop(context) ? 32 : 24),
            Text(
              'No Students Found',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context,
                    mobile: 24, tablet: 28, desktop: 32),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
                fontFamily: 'Inter',
              ),
            ),
            SizedBox(height: AppTheme.isDesktop(context) ? 12 : 8),
            Text(
              'Start by registering new students',
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18, desktop: 20),
                color: AppTheme.textSecondary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppTheme.isDesktop(context) ? 40 : 32),
            ModernButton(
              text: 'Register Student',
              onPressed: () {
                // Navigate to register student
              },
              icon: Icons.person_add,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentList(ManageStudentController controller) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context)),
      child: Column(
        children: [
          // Header Stats
          ModernCard(
            margin:
                EdgeInsets.only(bottom: AppTheme.getResponsivePadding(context)),
            child: Padding(
              padding:
                  EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
              child: Row(
                children: [
                  Expanded(
                    child: _buildStatItem(
                      'Total Students',
                      controller.students.length.toString(),
                      Icons.people,
                      AppTheme.primaryColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: AppTheme.isDesktop(context) ? 60 : 40,
                    color: AppTheme.dividerColor,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Verified',
                      controller.students
                          .where((s) => s['status'] == 1)
                          .length
                          .toString(),
                      Icons.verified,
                      AppTheme.successColor,
                    ),
                  ),
                  Container(
                    width: 1,
                    height: AppTheme.isDesktop(context) ? 60 : 40,
                    color: AppTheme.dividerColor,
                  ),
                  Expanded(
                    child: _buildStatItem(
                      'Pending',
                      controller.students
                          .where((s) => s['status'] == 0)
                          .length
                          .toString(),
                      Icons.pending,
                      AppTheme.warningColor,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Student List
          ...controller.students
              .map((student) => _buildStudentCard(
                  student, controller.students.indexOf(student), controller))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String label, String value, IconData icon, Color color) {
    return Column(
      children: [
        Icon(
          icon,
          color: color,
          size: AppTheme.isDesktop(context) ? 32 : 24,
        ),
        SizedBox(height: AppTheme.isDesktop(context) ? 12 : 8),
        Text(
          value,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context,
                mobile: 20, tablet: 24, desktop: 28),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            fontFamily: 'Inter',
          ),
        ),
        SizedBox(height: AppTheme.isDesktop(context) ? 6 : 4),
        Text(
          label,
          style: TextStyle(
            fontSize: AppTheme.getResponsiveFontSize(context,
                mobile: 12, tablet: 14, desktop: 16),
            color: AppTheme.textSecondary,
            fontFamily: 'Inter',
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ],
    );
  }

  Widget _buildStudentCard(Map<String, dynamic> student, int index,
      ManageStudentController controller) {
    final isVerified = student['status'] == 1;
    final fullName =
        '${student['surname']?.toString().trim() ?? ''} ${student['firstname']}';

    return ModernCard(
      margin: EdgeInsets.only(bottom: AppTheme.getResponsivePadding(context)),
      onTap: () => confirmViewData(context, index),
      child: Container(
        padding: EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppTheme.surfaceColor,
              AppTheme.surfaceColor.withOpacity(0.8),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Student Avatar with Status Indicator
            Stack(
              children: [
                Container(
                  width: AppTheme.isDesktop(context) ? 80 : 60,
                  height: AppTheme.isDesktop(context) ? 80 : 60,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(
                        AppTheme.isDesktop(context) ? 40 : 30),
                    border: Border.all(
                      color: isVerified
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      width: 3,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (isVerified
                                ? AppTheme.successColor
                                : AppTheme.warningColor)
                            .withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        AppTheme.isDesktop(context) ? 37 : 27),
                    child: _buildStudentImage(student),
                  ),
                ),
                // Status Badge
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? AppTheme.successColor
                          : AppTheme.warningColor,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.surfaceColor,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      isVerified ? Icons.check : Icons.schedule,
                      color: Colors.white,
                      size: AppTheme.isDesktop(context) ? 16 : 12,
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(width: AppTheme.isDesktop(context) ? 24 : 16),

            // Student Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fullName,
                    style: TextStyle(
                      fontSize: AppTheme.getResponsiveFontSize(context,
                          mobile: 16, tablet: 18, desktop: 20),
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                      fontFamily: 'Inter',
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  SizedBox(height: AppTheme.isDesktop(context) ? 6 : 4),
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        size: AppTheme.isDesktop(context) ? 16 : 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Level: ${student['presentLevel']}',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 14, tablet: 16, desktop: 18),
                            color: AppTheme.textSecondary,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.isDesktop(context) ? 4 : 2),
                  Row(
                    children: [
                      Icon(
                        Icons.business,
                        size: AppTheme.isDesktop(context) ? 16 : 14,
                        color: AppTheme.textSecondary,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          'Dept: ${student['department'] ?? 'N/A'}',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 14, tablet: 16, desktop: 18),
                            color: AppTheme.textSecondary,
                            fontFamily: 'Inter',
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppTheme.isDesktop(context) ? 8 : 6),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: AppTheme.isDesktop(context) ? 12 : 8,
                      vertical: AppTheme.isDesktop(context) ? 6 : 4,
                    ),
                    decoration: BoxDecoration(
                      color: isVerified
                          ? AppTheme.successColor.withOpacity(0.1)
                          : AppTheme.warningColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: isVerified
                            ? AppTheme.successColor.withOpacity(0.3)
                            : AppTheme.warningColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          isVerified ? Icons.verified : Icons.schedule,
                          size: AppTheme.isDesktop(context) ? 14 : 12,
                          color: isVerified
                              ? AppTheme.successColor
                              : AppTheme.warningColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isVerified ? 'Verified' : 'Pending',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 12, tablet: 14, desktop: 16),
                            fontWeight: FontWeight.w500,
                            color: isVerified
                                ? AppTheme.successColor
                                : AppTheme.warningColor,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Action Buttons
            Column(
              children: [
                ModernIconButton(
                  icon: Icons.edit,
                  onPressed: () => editStudentDialog(index, context),
                  backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  iconColor: AppTheme.primaryColor,
                  size: AppTheme.isDesktop(context) ? 24 : 20,
                ),
                SizedBox(height: AppTheme.isDesktop(context) ? 12 : 8),
                ModernIconButton(
                  icon: Icons.delete,
                  onPressed: () => deleteStudent(index, context),
                  backgroundColor: AppTheme.errorColor.withOpacity(0.1),
                  iconColor: AppTheme.errorColor,
                  size: AppTheme.isDesktop(context) ? 24 : 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStudentImage(Map<String, dynamic> student) {
    final passport = student['passport'];

    if (passport != null && passport.toString().isNotEmpty) {
      if (passport.toString().startsWith('http')) {
        return Image.network(
          passport as String,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      } else {
        return Image.file(
          File(passport as String),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildDefaultAvatar();
          },
        );
      }
    }

    return _buildDefaultAvatar();
  }

  Widget _buildDefaultAvatar() {
    return Container(
      color: AppTheme.backgroundColor,
      child: Icon(
        Icons.person,
        color: AppTheme.textTertiary,
        size: AppTheme.isDesktop(context) ? 40 : 32,
      ),
    );
  }
}
