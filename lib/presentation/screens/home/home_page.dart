import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/themes/app_theme.dart';
import '../../../core/widgets/modern_card.dart';
import '../../../core/widgets/modern_button.dart';
import '../../../core/widgets/logout_dialog.dart';
import '../../controllers/home_controller.dart';
import '../../controllers/navigation_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Provider.of<HomeController>(context);
    final navController =
        Provider.of<NavigationController>(context, listen: false);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          ModernIconButton(
            icon: Icons.logout,
            onPressed: () => showLogoutDialog(context, homeController.logout),
            tooltip: 'Logout',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: homeController.refreshData,
        child: SingleChildScrollView(
          padding: EdgeInsets.all(AppTheme.getResponsivePadding(context)),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome Section
              ModernCard(
                padding:
                    EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: AppTheme.isDesktop(context) ? 80 : 60,
                          height: AppTheme.isDesktop(context) ? 80 : 60,
                          decoration: BoxDecoration(
                            gradient: AppTheme.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Icon(
                            Icons.dashboard,
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
                                'Welcome to',
                                style: TextStyle(
                                  fontSize: AppTheme.getResponsiveFontSize(
                                      context,
                                      mobile: 16,
                                      tablet: 18,
                                      desktop: 20),
                                  color: AppTheme.textSecondary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                              Text(
                                'Facial Attendance',
                                style: TextStyle(
                                  fontSize: AppTheme.getResponsiveFontSize(
                                      context,
                                      mobile: 24,
                                      tablet: 28,
                                      desktop: 32),
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary,
                                  fontFamily: 'Inter',
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Manage your student attendance efficiently with facial recognition technology.',
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context,
                            mobile: 14, tablet: 16, desktop: 18),
                        color: AppTheme.textSecondary,
                        fontFamily: 'Inter',
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: AppTheme.isDesktop(context) ? 32 : 24),

              // Quick Actions
              Text(
                'Quick Actions',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context,
                      mobile: 20, tablet: 24, desktop: 28),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: AppTheme.isDesktop(context) ? 24 : 16),

              // Action Cards Grid
              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount:
                    AppTheme.getResponsiveGridCrossAxisCount(context),
                crossAxisSpacing: AppTheme.isDesktop(context) ? 24 : 16,
                mainAxisSpacing: AppTheme.isDesktop(context) ? 24 : 16,
                childAspectRatio: AppTheme.isDesktop(context) ? 1.2 : 1.0,
                children: [
                  _buildActionCard(
                    context,
                    icon: Icons.person_add,
                    title: 'Register Student',
                    subtitle: 'Add new student',
                    color: AppTheme.primaryColor,
                    onTap: () {
                      navController.changeTab(1); // Register Student
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.people,
                    title: 'Manage Students',
                    subtitle: 'View & edit students',
                    color: AppTheme.secondaryColor,
                    onTap: () {
                      navController.changeTab(2); // Manage Students
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.face,
                    title: 'Take Attendance',
                    subtitle: 'Start attendance session',
                    color: AppTheme.accentColor,
                    onTap: () {
                      navController.changeTab(3); // Attendance
                    },
                  ),
                  _buildActionCard(
                    context,
                    icon: Icons.assessment,
                    title: 'View Reports',
                    subtitle: 'Attendance reports',
                    color: AppTheme.warningColor,
                    onTap: () {
                      // TODO: Navigate to reports page when implemented
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Reports feature coming soon!'),
                          backgroundColor: AppTheme.warningColor,
                        ),
                      );
                    },
                  ),
                ],
              ),

              SizedBox(height: AppTheme.isDesktop(context) ? 40 : 32),

              // Statistics Section
              Text(
                'Statistics',
                style: TextStyle(
                  fontSize: AppTheme.getResponsiveFontSize(context,
                      mobile: 20, tablet: 24, desktop: 28),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: AppTheme.isDesktop(context) ? 24 : 16),

              // Stats Cards - Responsive Layout
              if (AppTheme.isDesktop(context))
                // Desktop: 2x2 Grid
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                  childAspectRatio: 3,
                  children: homeController.studentStats.entries
                      .map((entry) => _buildStatCard(entry.key, entry.value))
                      .toList(),
                )
              else
                // Mobile/Tablet: Single Column
                ...homeController.studentStats.entries
                    .map((entry) => _buildStatCard(entry.key, entry.value)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ModernCard(
      onTap: onTap,
      padding: EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: AppTheme.isDesktop(context) ? 72 : 56,
            height: AppTheme.isDesktop(context) ? 72 : 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: AppTheme.isDesktop(context) ? 36 : 28,
            ),
          ),
          SizedBox(height: AppTheme.isDesktop(context) ? 6 : 2),
          Flexible(
            child: Text(
              title,
              style: TextStyle(
                fontSize: AppTheme.getResponsiveFontSize(context,
                    mobile: 16, tablet: 18, desktop: 20),
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
                fontFamily: 'Inter',
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
              subtitle,
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
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, Future<int> futureValue) {
    return Builder(
      builder: (context) => ModernCard(
        margin: EdgeInsets.only(bottom: AppTheme.isDesktop(context) ? 0 : 12),
        child: Padding(
          padding: EdgeInsets.all(AppTheme.getResponsiveCardPadding(context)),
          child: Row(
            children: [
              Container(
                width: AppTheme.isDesktop(context) ? 64 : 48,
                height: AppTheme.isDesktop(context) ? 64 : 48,
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.analytics,
                  color: Colors.white,
                  size: AppTheme.isDesktop(context) ? 32 : 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: AppTheme.getResponsiveFontSize(context,
                            mobile: 14, tablet: 16, desktop: 18),
                        color: AppTheme.textSecondary,
                        fontFamily: 'Inter',
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                    const SizedBox(height: 4),
                    FutureBuilder<int>(
                      future: futureValue,
                      builder: (context, snapshot) {
                        return Text(
                          '${snapshot.data ?? 0}',
                          style: TextStyle(
                            fontSize: AppTheme.getResponsiveFontSize(context,
                                mobile: 24, tablet: 28, desktop: 32),
                            fontWeight: FontWeight.bold,
                            color: AppTheme.textPrimary,
                            fontFamily: 'Inter',
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
