import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';

import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/astra_logo.dart';
import '../../core/widgets/scale_button.dart';
import '../../core/widgets/theme_toggle_button.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _organizationNameController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String? _selectedOrgType;
  bool _termsAccepted = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _organizationNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 1020;

          return Stack(
            children: [
              Positioned.fill(
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [c.bgPrimary, c.bgSecondary, c.bgPrimary],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -100,
                right: -70,
                child: _Blob(
                    color: AppColors.accentAmber
                        .withValues(alpha: c.isDark ? 0.20 : 0.15)),
              ),
              Positioned(
                bottom: -110,
                left: -80,
                child: _Blob(
                  size: 340,
                  color: c.accentBlue.withValues(alpha: c.isDark ? 0.20 : 0.14),
                ),
              ),
              SafeArea(
                child: compact ? _compactBody() : _desktopBody(),
              ),
              const Positioned(
                  top: 8, right: 8, child: ThemeToggleButton(compact: true)),
            ],
          );
        },
      ),
    );
  }

  Widget _desktopBody() {
    return Row(
      children: [
        Expanded(
          flex: 50,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
            child: _MarketingPanel(),
          ),
        ),
        Expanded(
          flex: 50,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(8, 12, 10, 12),
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 8),
              child: _SignupCard(
                organizationNameController: _organizationNameController,
                fullNameController: _fullNameController,
                emailController: _emailController,
                passwordController: _passwordController,
                confirmPasswordController: _confirmPasswordController,
                selectedOrgType: _selectedOrgType,
                termsAccepted: _termsAccepted,
                obscurePassword: _obscurePassword,
                obscureConfirm: _obscureConfirm,
                onTypeChanged: (v) => setState(() => _selectedOrgType = v),
                onTermsChanged: (v) => setState(() => _termsAccepted = v),
                onPasswordToggle: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                onConfirmToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
                onRegister: _register,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _compactBody() {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(10, 50, 10, 16),
      child: Column(
        children: [
          Row(
            children: [
              _HomeChip(),
              const Spacer(),
              const AstraLogo(size: 22),
            ],
          ),
          const SizedBox(height: 16),
          _SignupCard(
            organizationNameController: _organizationNameController,
            fullNameController: _fullNameController,
            emailController: _emailController,
            passwordController: _passwordController,
            confirmPasswordController: _confirmPasswordController,
            selectedOrgType: _selectedOrgType,
            termsAccepted: _termsAccepted,
            obscurePassword: _obscurePassword,
            obscureConfirm: _obscureConfirm,
            onTypeChanged: (v) => setState(() => _selectedOrgType = v),
            onTermsChanged: (v) => setState(() => _termsAccepted = v),
            onPasswordToggle: () =>
                setState(() => _obscurePassword = !_obscurePassword),
            onConfirmToggle: () =>
                setState(() => _obscureConfirm = !_obscureConfirm),
            onRegister: _register,
          ),
        ],
      ),
    );
  }

  Future<void> _register() async {
    final orgName = _organizationNameController.text.trim();
    final fullName = _fullNameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (orgName.isEmpty ||
        fullName.isEmpty ||
        email.isEmpty ||
        password.isEmpty ||
        _selectedOrgType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content:
                Text('Please fill all fields and select organization type')),
      );
      return;
    }

    if (!_termsAccepted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Accept Terms of Service to continue')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final raw =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final suffix = raw.length > 6 ? raw.substring(raw.length - 6) : raw;
    final organizationId = 'ASTRA-$suffix';

    try {
      final credential =
          await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = credential.user;
      if (user != null) {
        await user.updateDisplayName(fullName);
        await FirebaseFirestore.instance
            .collection('organizations')
            .doc(user.uid)
            .set({
          'organizationId': organizationId,
          'organizationName': orgName,
          'organizationType': _selectedOrgType,
          'adminFullName': fullName,
          'adminEmail': email,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      AppRouter.isAuthenticated = true;
      AppRouter.currentOrganizationId = organizationId;
      AppRouter.currentAdminName = fullName;

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Account created. Organization ID: $organizationId')),
      );
      context.go('/dashboard');
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Registration failed')),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Registration failed')),
      );
    }
  }
}

class _Blob extends StatelessWidget {
  final double size;
  final Color color;

  const _Blob({this.size = 300, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color,
            color.withValues(alpha: color.a * 0.45),
            Colors.transparent,
          ],
        ),
      ),
    ).animate().fadeIn(duration: 900.ms);
  }
}

class _MarketingPanel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return _GlassPanel(
      radius: 30,
      padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const AstraLogo(size: 24).animate().fadeIn(),
              const Spacer(),
              _HomeChip(),
            ],
          ),
          const SizedBox(height: 34),
          Text(
            'Create Your\nSecurity\nWorkspace',
            style: AppTextStyles.display(
              size: 56,
              weight: FontWeight.w900,
              height: 0.93,
              letterSpacing: -1.2,
              color: c.textPrimary,
            ),
          ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06, end: 0),
          const SizedBox(height: 14),
          Text(
            'Register your organization and establish your protected media command center in under two minutes.',
            style: AppTextStyles.body(
              size: 16,
              height: 1.55,
              color: c.textSecondary,
            ),
          ).animate().fadeIn(delay: 240.ms),
          const SizedBox(height: 24),
          const _InfoRow(
              icon: PhosphorIcons.shieldCheck,
              title: 'Organization-verified onboarding'),
          const SizedBox(height: 12),
          const _InfoRow(
              icon: PhosphorIcons.fingerprint,
              title: 'Strong identity and session controls'),
          const SizedBox(height: 12),
          const _InfoRow(
              icon: PhosphorIcons.database,
              title: 'Auditable registration records'),
          const Spacer(),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.bgSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: c.borderDefault),
            ),
            child: Text(
              'Tip: Keep your generated organization ID safe. It is required for all sign-ins.',
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignupCard extends StatelessWidget {
  final TextEditingController organizationNameController;
  final TextEditingController fullNameController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final String? selectedOrgType;
  final bool termsAccepted;
  final bool obscurePassword;
  final bool obscureConfirm;
  final ValueChanged<String?> onTypeChanged;
  final ValueChanged<bool> onTermsChanged;
  final VoidCallback onPasswordToggle;
  final VoidCallback onConfirmToggle;
  final Future<void> Function() onRegister;

  const _SignupCard({
    required this.organizationNameController,
    required this.fullNameController,
    required this.emailController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedOrgType,
    required this.termsAccepted,
    required this.obscurePassword,
    required this.obscureConfirm,
    required this.onTypeChanged,
    required this.onTermsChanged,
    required this.onPasswordToggle,
    required this.onConfirmToggle,
    required this.onRegister,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return _GlassPanel(
      radius: 28,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Sign Up',
            style: AppTextStyles.display(
              size: 32,
              weight: FontWeight.w800,
              letterSpacing: -0.7,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Create your ASTRA organization account',
            style: AppTextStyles.body(size: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 14),
          const _SecurityStatusBar(),
          const SizedBox(height: 18),
          const _FieldLabel(label: 'Organization Name'),
          const SizedBox(height: 7),
          _InputField(
              hint: 'Your organization',
              controller: organizationNameController),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Organization Type'),
          const SizedBox(height: 7),
          DropdownButtonFormField<String>(
            value: selectedOrgType,
            dropdownColor: c.bgSecondary,
            style: AppTextStyles.body(color: c.textPrimary, size: 14),
            decoration: _fieldDecoration(context, 'Select organization type'),
            items: const [
              'Cricket Board',
              'Football League',
              'Esports Org',
              'Basketball League',
              'Other'
            ]
                .map((e) => DropdownMenuItem<String>(value: e, child: Text(e)))
                .toList(),
            onChanged: onTypeChanged,
          ),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Full Name'),
          const SizedBox(height: 7),
          _InputField(hint: 'John Doe', controller: fullNameController),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Email Address'),
          const SizedBox(height: 7),
          _InputField(
              hint: 'admin@organization.com', controller: emailController),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Password'),
          const SizedBox(height: 7),
          _InputField(
            hint: 'Create a strong password',
            controller: passwordController,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: onPasswordToggle,
              icon: Icon(
                obscurePassword
                    ? PhosphorIcons.eyeClosed()
                    : PhosphorIcons.eye(),
                size: 18,
                color: c.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Confirm Password'),
          const SizedBox(height: 7),
          _InputField(
            hint: 'Repeat password',
            controller: confirmPasswordController,
            obscureText: obscureConfirm,
            suffixIcon: IconButton(
              onPressed: onConfirmToggle,
              icon: Icon(
                obscureConfirm
                    ? PhosphorIcons.eyeClosed()
                    : PhosphorIcons.eye(),
                size: 18,
                color: c.textMuted,
              ),
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => onTermsChanged(!termsAccepted),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Checkbox(
                  value: termsAccepted,
                  onChanged: (v) => onTermsChanged(v ?? false),
                  activeColor: AppColors.accentAmber,
                  checkColor: AppColors.textOnAmber,
                  side: BorderSide(color: c.borderDefault),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      'I agree to the Terms of Service and Privacy Policy',
                      style:
                          AppTextStyles.body(size: 12, color: c.textSecondary),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          _SignupButton(onTap: onRegister),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              spacing: 4,
              children: [
                Text(
                  'Already have an account?',
                  style: AppTextStyles.body(size: 13, color: c.textSecondary),
                ),
                InkWell(
                  onTap: () => context.go('/login'),
                  child: Text(
                    'Sign in',
                    style: AppTextStyles.body(
                      size: 13,
                      weight: FontWeight.w700,
                      color: AppColors.accentAmber,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 420.ms).slideY(begin: 0.05, end: 0);
  }

  InputDecoration _fieldDecoration(BuildContext context, String hint) {
    final c = context.colors;
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: c.bgSurface.withValues(alpha: c.isDark ? 0.8 : 0.95),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.borderDefault),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: c.borderDefault),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.accentAmber, width: 1.4),
      ),
    );
  }
}

class _InputField extends StatelessWidget {
  final String hint;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? suffixIcon;

  const _InputField({
    required this.hint,
    required this.controller,
    this.obscureText = false,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: AppTextStyles.body(size: 14, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: c.bgSurface.withValues(alpha: c.isDark ? 0.8 : 0.95),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.borderDefault),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: c.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide:
              const BorderSide(color: AppColors.accentAmber, width: 1.4),
        ),
      ),
    );
  }
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: AppTextStyles.display(
        size: 12,
        weight: FontWeight.w700,
        color: AppColors.accentAmber,
        letterSpacing: 0.8,
      ),
    );
  }
}

class _SignupButton extends StatefulWidget {
  final Future<void> Function() onTap;
  const _SignupButton({required this.onTap});

  @override
  State<_SignupButton> createState() => _SignupButtonState();
}

class _SignupButtonState extends State<_SignupButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: ScaleButton(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: 220.ms,
          height: 52,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _isHovering
                    ? AppColors.accentAmber
                    : AppColors.accentAmber.withValues(alpha: 0.92),
                _isHovering
                    ? AppColors.accentAmber.withValues(alpha: 0.85)
                    : AppColors.accentAmber.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppColors.accentAmber
                    .withValues(alpha: _isHovering ? 0.3 : 0.18),
                blurRadius: _isHovering ? 22 : 16,
                offset: const Offset(0, 9),
              ),
            ],
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Create Account',
                  style: AppTextStyles.display(
                    size: 14,
                    weight: FontWeight.w800,
                    color: AppColors.textOnAmber,
                  ),
                ),
                const SizedBox(width: 10),
                Icon(PhosphorIcons.arrowRight(),
                    size: 18, color: AppColors.textOnAmber),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _HomeChip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return InkWell(
      onTap: () => context.go('/'),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 8),
        decoration: BoxDecoration(
          color: c.bgSurface,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: c.borderDefault),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(PhosphorIcons.arrowLeft(), size: 14, color: c.textSecondary),
            const SizedBox(width: 6),
            Text(
              'Home',
              style: AppTextStyles.body(
                  size: 12, weight: FontWeight.w600, color: c.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final PhosphorIconData Function([PhosphorIconsStyle]) icon;
  final String title;

  const _InfoRow({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon(), size: 15, color: AppColors.accentAmber),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: AppTextStyles.body(
              size: 13,
              weight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityStatusBar extends StatelessWidget {
  const _SecurityStatusBar();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: c.isDark ? 0.08 : 0.1),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: AppColors.accentGreen.withValues(alpha: 0.36)),
      ),
      child: Row(
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: const BoxDecoration(
              color: AppColors.accentGreen,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Secure registration channel active',
              style: AppTextStyles.body(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.accentGreen,
              ),
            ),
          ),
          Icon(PhosphorIcons.lockSimple(),
              size: 14, color: AppColors.accentGreen),
        ],
      ),
    );
  }
}

class _GlassPanel extends StatelessWidget {
  final Widget child;
  final double radius;
  final EdgeInsetsGeometry padding;

  const _GlassPanel({
    required this.child,
    this.radius = 24,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            color: c.bgSecondary.withValues(alpha: c.isDark ? 0.46 : 0.72),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: c.borderDefault.withValues(alpha: 0.75)),
            boxShadow: c.isDark
                ? [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.24),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.white.withValues(alpha: 0.95),
                      blurRadius: 10,
                      offset: const Offset(-2, -2),
                    ),
                    BoxShadow(
                      color: const Color(0xFF64748B).withValues(alpha: 0.16),
                      blurRadius: 20,
                      offset: const Offset(8, 10),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );
  }
}
