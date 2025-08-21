import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/modern_button.dart';
import '../../controllers/attendance_controller.dart';

class AttendancePage extends StatefulWidget {
  AttendancePage({super.key});

  @override
  _AttendancePageState createState() => _AttendancePageState();
}

class _AttendancePageState extends State<AttendancePage> {
  @override
  Widget build(BuildContext context) {
    final attendanceController = Provider.of<AttendanceController>(context);
    final List<Map<String, dynamic>> filteredStudents = attendanceController
        .students
        .where((student) => student['status'] == 1)
        .toList();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Attendance'),
        actions: [
          ModernIconButton(
            icon: Icons.picture_as_pdf,
            onPressed: () => attendanceController.generatePDF(context),
            tooltip: 'Generate PDF',
          ),
          const SizedBox(width: 8),
          ModernIconButton(
            icon: Icons.refresh,
            onPressed: attendanceController.refreshPage,
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: attendanceController.isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryColor,
              ),
            )
          : filteredStudents.isEmpty
              ? _buildEmptyState()
              : _buildAttendanceContent(filteredStudents, attendanceController),
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
                Icons.face_outlined,
                size: AppTheme.isDesktop(context) ? 80 : 60,
                color: AppTheme.textTertiary,
              ),
            ),
            SizedBox(height: AppTheme.isDesktop(context) ? 32 : 24),
            Text(
              'No Students Available',
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
              'No verified students found for attendance',
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
              text: 'Register Students',
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

  Widget _buildAttendanceContent(
    List<Map<String, dynamic>> students,
    AttendanceController controller,
  ) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(AppTheme.getResponsivePadding(context)),
      child: Column(
        children: [
          // Header Stats - Redesigned for single stat
          ModernCard(
            margin:
                EdgeInsets.only(bottom: AppTheme.getResponsivePadding(context)),
            child: Container(
              padding:
                  EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.primaryColor.withOpacity(0.1),
                    AppTheme.primaryColor.withOpacity(0.05),
                  ],
                ),
              ),
              child: Row(
                children: [
                  // Icon Container
                  Container(
                    width: AppTheme.isDesktop(context) ? 80 : 60,
                    height: AppTheme.isDesktop(context) ? 80 : 60,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(
                          AppTheme.isDesktop(context) ? 20 : 16),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.primaryColor.withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.people,
                      color: Colors.white,
                      size: AppTheme.isDesktop(context) ? 36 : 28,
                    ),
                  ),
                  SizedBox(width: AppTheme.isDesktop(context) ? 24 : 16),
                  // Stats Info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Total Students',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 16, tablet: 18, desktop: 20),
                            color: AppTheme.textSecondary,
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: AppTheme.isDesktop(context) ? 8 : 4),
                        Text(
                          students.length.toString(),
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 32, tablet: 36, desktop: 40),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                        SizedBox(height: AppTheme.isDesktop(context) ? 8 : 4),
                        Text(
                          'Available for attendance tracking',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 12, tablet: 14, desktop: 16),
                            color: AppTheme.textTertiary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Action Button
                  Container(
                    padding:
                        EdgeInsets.all(AppTheme.isDesktop(context) ? 12 : 8),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryColor.withOpacity(0.2),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.face,
                      color: AppTheme.primaryColor,
                      size: AppTheme.isDesktop(context) ? 24 : 20,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Attendance Table Header
          Padding(
            padding: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context)),
            child: Row(
              children: [
                Text(
                  'Student List',
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context,
                        mobile: 18, tablet: 20, desktop: 24),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter',
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: AppTheme.isDesktop(context) ? 24 : 16),

          // Attendance Table
          Container(
            margin: EdgeInsets.symmetric(
                horizontal: AppTheme.getResponsivePadding(context)),
            decoration: BoxDecoration(
              color: AppTheme.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: AppTheme.borderColor,
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                // Table Header
                Container(
                  padding: EdgeInsets.all(
                      AppTheme.getResponsiveCardPadding(context)),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: Text(
                          'Name',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 14, tablet: 16, desktop: 18),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Level',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 14, tablet: 16, desktop: 18),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Department',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 14, tablet: 16, desktop: 18),
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Table Body
                ...students
                    .map((student) =>
                        _buildStudentRow(student, students.indexOf(student)))
                    .toList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentRow(Map<String, dynamic> student, int index) {
    final fullName =
        '${student['surname']?.toString().trim() ?? ''} ${student['firstname']}';

    return Container(
      padding: EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.dividerColor,
            width: 1,
          ),
        ),
        color:
            index % 2 == 0 ? AppTheme.surfaceColor : AppTheme.backgroundColor,
      ),
      child: Row(
        children: [
          // Student Avatar
          Container(
            width: AppTheme.isDesktop(context) ? 56 : 40,
            height: AppTheme.isDesktop(context) ? 56 : 40,
            decoration: BoxDecoration(
              borderRadius:
                  BorderRadius.circular(AppTheme.isDesktop(context) ? 28 : 20),
              border: Border.all(
                color: AppTheme.primaryColor.withOpacity(0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
                  BorderRadius.circular(AppTheme.isDesktop(context) ? 26 : 18),
              child: _buildStudentImage(student),
            ),
          ),

          SizedBox(width: AppTheme.isDesktop(context) ? 16 : 12),

          // Student Info
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  fullName,
                  style: TextStyle(
                    fontSize: AppTheme.getResponsiveFontSize(context,
                        mobile: 14, tablet: 16, desktop: 18),
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                    fontFamily: 'Inter',
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),

          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.school,
                  size: AppTheme.isDesktop(context) ? 14 : 12,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    student['presentLevel'] ?? '',
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
          ),

          Expanded(
            child: Row(
              children: [
                Icon(
                  Icons.business,
                  size: AppTheme.isDesktop(context) ? 14 : 12,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    student['department'] ?? '',
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
          ),
        ],
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
        size: AppTheme.isDesktop(context) ? 32 : 24,
      ),
    );
  }
}
