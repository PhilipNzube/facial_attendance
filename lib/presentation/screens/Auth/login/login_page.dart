import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/themes/app_theme.dart';
import '../../../../core/widgets/modern_button.dart';
import '../../../../core/widgets/modern_card.dart';
import '../../../controllers/auth_controller.dart';
import 'widgets/login_form.dart';

class LoginPage extends StatelessWidget {
  LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Provider.of<AuthController>(context);
    final size = MediaQuery.of(context).size;
    final isLandscape = AppTheme.isLandscape(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF667eea), // Purple Blue
                Color(0xFF764ba2), // Purple
                Color(0xFFf093fb), // Pink
                Color(0xFFf5576c), // Red Pink
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              stops: [0.0, 0.3, 0.7, 1.0],
            ),
          ),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height -
                    MediaQuery.of(context).padding.top -
                    MediaQuery.of(context).padding.bottom,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    // Header Section
                    Container(
                      padding: EdgeInsets.all(
                          AppTheme.getResponsivePadding(context)),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App Logo
                          Container(
                            width: AppTheme.isDesktop(context) ? 130 : 90,
                            height: AppTheme.isDesktop(context) ? 130 : 90,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(
                                  AppTheme.isDesktop(context) ? 32 : 24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius:
                                      AppTheme.isDesktop(context) ? 30 : 20,
                                  offset: const Offset(0, 10),
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(
                                  AppTheme.isDesktop(context) ? 32 : 24),
                              child: Image.asset(
                                "images/portal-landing-logo.png",
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.face,
                                    size: AppTheme.isDesktop(context) ? 80 : 60,
                                    color: AppTheme.primaryColor,
                                  );
                                },
                              ),
                            ),
                          ),
                          SizedBox(
                              height: AppTheme.isDesktop(context) ? 24 : 16),
                          // Welcome Text
                          Text(
                            'Welcome Back',
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFontSize(context,
                                  mobile: 28, tablet: 32, desktop: 36),
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: 'Inter',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.3),
                                  offset: const Offset(0, 2),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: AppTheme.isDesktop(context) ? 8 : 4),
                          Text(
                            'Sign in to your account to continue',
                            style: TextStyle(
                              fontSize: AppTheme.getResponsiveFontSize(context,
                                  mobile: 16, tablet: 18, desktop: 20),
                              color: Colors.white.withOpacity(0.9),
                              fontFamily: 'Inter',
                              shadows: [
                                Shadow(
                                  color: Colors.black.withOpacity(0.2),
                                  offset: const Offset(0, 1),
                                  blurRadius: 2,
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // Login Form Section
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(
                          AppTheme.getResponsivePadding(context)),
                      child: Column(
                        children: [
                          // Login Form Card
                          ModernCard(
                            margin: EdgeInsets.symmetric(
                              horizontal: AppTheme.isDesktop(context) ? 0 : 0,
                            ),
                            child: Container(
                              padding: EdgeInsets.all(
                                  AppTheme.getResponsiveCardPadding(context)),
                              decoration: BoxDecoration(
                                color: AppTheme.surfaceColor,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: Column(
                                children: [
                                  // Form Icon
                                  Container(
                                    width:
                                        AppTheme.isDesktop(context) ? 80 : 60,
                                    height:
                                        AppTheme.isDesktop(context) ? 80 : 60,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.primaryGradient,
                                      borderRadius: BorderRadius.circular(
                                          AppTheme.isDesktop(context)
                                              ? 40
                                              : 30),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppTheme.primaryColor
                                              .withOpacity(0.3),
                                          blurRadius: 12,
                                          offset: const Offset(0, 4),
                                        ),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.lock_outline,
                                      color: Colors.white,
                                      size:
                                          AppTheme.isDesktop(context) ? 36 : 28,
                                    ),
                                  ),
                                  SizedBox(
                                      height: AppTheme.isDesktop(context)
                                          ? 24
                                          : 16),

                                  // Form Title
                                  Text(
                                    'Sign In',
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
                                  SizedBox(
                                      height:
                                          AppTheme.isDesktop(context) ? 8 : 4),
                                  Text(
                                    'Enter your credentials to continue',
                                    style: TextStyle(
                                      fontSize: AppTheme.getResponsiveFontSize(
                                          context,
                                          mobile: 14,
                                          tablet: 16,
                                          desktop: 18),
                                      color: AppTheme.textSecondary,
                                      fontFamily: 'Inter',
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  SizedBox(
                                      height: AppTheme.isDesktop(context)
                                          ? 32
                                          : 24),

                                  // Login Form
                                  LoginForm(
                                    emailController:
                                        authController.emailController,
                                    passcodeController:
                                        authController.passcodeController,
                                    emailFocusNode:
                                        authController.emailFocusNode,
                                    isLoading: authController.isLoading,
                                    showFingerprint: true,
                                    onSubmit: () => authController.login(
                                      authController.emailController.text
                                          .trim(),
                                      authController.passcodeController.text
                                          .trim(),
                                      context,
                                    ),
                                    onFingerprintLogin: () =>
                                        authController.biometricLogin(context),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          // Footer
                          SizedBox(
                              height: AppTheme.isDesktop(context) ? 32 : 24),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppTheme.isDesktop(context) ? 40 : 20,
                              vertical: AppTheme.isDesktop(context) ? 16 : 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.security,
                                  color: Colors.white.withOpacity(0.8),
                                  size: AppTheme.isDesktop(context) ? 20 : 16,
                                ),
                                SizedBox(
                                    width:
                                        AppTheme.isDesktop(context) ? 12 : 8),
                                Text(
                                  '© 2025 Facial Attendance System',
                                  style: TextStyle(
                                    fontSize: AppTheme.getResponsiveFontSize(
                                        context,
                                        mobile: 12,
                                        tablet: 14,
                                        desktop: 16),
                                    color: Colors.white.withOpacity(0.8),
                                    fontFamily: 'Inter',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
