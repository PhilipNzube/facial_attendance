import 'package:flutter/material.dart';
import '../../../../../core/themes/app_theme.dart';
import '../../../../../core/widgets/modern_button.dart';

class LoginForm extends StatefulWidget {
  final TextEditingController emailController;
  final TextEditingController passcodeController;
  final FocusNode emailFocusNode;
  final VoidCallback onSubmit;
  final bool isLoading;
  final bool showFingerprint;
  final VoidCallback onFingerprintLogin;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passcodeController,
    required this.emailFocusNode,
    required this.onSubmit,
    required this.isLoading,
    required this.showFingerprint,
    required this.onFingerprintLogin,
  });

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  bool _obscurePassword = true;
  final FocusNode _passwordFocusNode = FocusNode();

  @override
  void dispose() {
    _passwordFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Email Field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.emailFocusNode.hasFocus
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              width: widget.emailFocusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.emailController,
            focusNode: widget.emailFocusNode,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontFamily: 'Inter',
            ),
            decoration: const InputDecoration(
              labelText: 'Email Address',
              labelStyle: TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding:
                  EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              prefixIcon: Icon(
                Icons.email_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
            ),
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            onFieldSubmitted: (_) {
              FocusScope.of(context).requestFocus(_passwordFocusNode);
            },
          ),
        ),

        const SizedBox(height: 20),

        // Password Field
        Container(
          decoration: BoxDecoration(
            color: AppTheme.backgroundColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _passwordFocusNode.hasFocus
                  ? AppTheme.primaryColor
                  : AppTheme.borderColor,
              width: _passwordFocusNode.hasFocus ? 2 : 1,
            ),
          ),
          child: TextFormField(
            controller: widget.passcodeController,
            focusNode: _passwordFocusNode,
            obscureText: _obscurePassword,
            style: const TextStyle(
              fontSize: 16,
              color: AppTheme.textPrimary,
              fontFamily: 'Inter',
            ),
            decoration: InputDecoration(
              labelText: 'Password',
              labelStyle: const TextStyle(
                color: AppTheme.textSecondary,
                fontFamily: 'Inter',
                fontSize: 14,
              ),
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              prefixIcon: const Icon(
                Icons.lock_outlined,
                color: AppTheme.textSecondary,
                size: 20,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
            ),
            keyboardType: TextInputType.number,
            maxLength: 6,
            textInputAction: TextInputAction.done,
            onFieldSubmitted: (_) => widget.onSubmit(),
          ),
        ),

        const SizedBox(height: 32),

        // Buttons Row
        Row(
          children: [
            // Sign In Button
            Expanded(
              flex: 2,
              child: ModernButton(
                text: 'Sign In',
                onPressed: widget.onSubmit,
                isLoading: widget.isLoading,
                icon: Icons.login,
              ),
            ),

            const SizedBox(width: 16),

            // Fingerprint Button
            if (widget.showFingerprint)
              Expanded(
                child: Container(
                  height: 56,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.accentColor.withOpacity(0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: widget.onFingerprintLogin,
                      borderRadius: BorderRadius.circular(16),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.fingerprint,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
