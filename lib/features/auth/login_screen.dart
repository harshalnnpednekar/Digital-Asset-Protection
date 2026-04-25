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

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
  bool _rememberMe = true;

  final TextEditingController _organizationIdController =
      TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _organizationIdController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final compact = constraints.maxWidth < 980;

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
                top: -90,
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
                child: compact
                    ? _MobileBody(
                        obscurePassword: _obscurePassword,
                        rememberMe: _rememberMe,
                        organizationIdController: _organizationIdController,
                        emailController: _emailController,
                        passwordController: _passwordController,
                        onToggleRemember: () =>
                            setState(() => _rememberMe = !_rememberMe),
                        onToggleObscure: () => setState(
                            () => _obscurePassword = !_obscurePassword),
                      )
                    : Row(
                        children: [
                          Expanded(
                            flex: 53,
                            child: _MarketingPanel(),
                          ),
                          Expanded(
                            flex: 47,
                            child: _FormPanel(
                              obscurePassword: _obscurePassword,
                              rememberMe: _rememberMe,
                              organizationIdController:
                                  _organizationIdController,
                              emailController: _emailController,
                              passwordController: _passwordController,
                              onToggleRemember: () =>
                                  setState(() => _rememberMe = !_rememberMe),
                              onToggleObscure: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                          ),
                        ],
                      ),
              ),
              const Positioned(
                  top: 8, right: 8, child: ThemeToggleButton(compact: true)),
            ],
          );
        },
      ),
    );
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

    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 8, 12),
      child: _GlassPanel(
        radius: 30,
        padding: const EdgeInsets.fromLTRB(28, 24, 28, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const AstraLogo(size: 24).animate().fadeIn(duration: 350.ms),
                const Spacer(),
                _HomeChip(),
              ],
            ),
            const SizedBox(height: 34),
            Text(
              'Enterprise Asset\nProtection\nMade Simple',
              style: AppTextStyles.display(
                size: 58,
                weight: FontWeight.w900,
                height: 0.93,
                letterSpacing: -1.2,
                color: c.textPrimary,
              ),
            ).animate().fadeIn(delay: 120.ms).slideY(begin: 0.06, end: 0),
            const SizedBox(height: 14),
            Text(
              'Secure digital media with cryptographic custody, immutable records, and AI-assisted detection designed for production-grade teams.',
              style: AppTextStyles.body(
                size: 16,
                height: 1.55,
                color: c.textSecondary,
              ),
            ).animate().fadeIn(delay: 240.ms),
            const SizedBox(height: 24),
            const _BenefitRow(
              icon: PhosphorIcons.lockKey,
              title: 'Zero-Knowledge Architecture',
              subtitle: 'Protected key boundaries and strict access controls',
            ),
            const SizedBox(height: 14),
            const _BenefitRow(
              icon: PhosphorIcons.clockCountdown,
              title: '24/7 Monitoring',
              subtitle: 'Continuous anomaly detection and alerting',
            ),
            const SizedBox(height: 14),
            const _BenefitRow(
              icon: PhosphorIcons.linkSimple,
              title: 'Immutable Audit Trails',
              subtitle: 'Verifiable chain-of-custody for compliance workflows',
            ),
            const Spacer(),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: c.bgSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.borderSubtle),
                boxShadow: c.isDark
                    ? []
                    : [
                        BoxShadow(
                          color: Colors.white.withValues(alpha: 0.85),
                          blurRadius: 8,
                          offset: const Offset(-2, -2),
                        ),
                        BoxShadow(
                          color:
                              const Color(0xFF64748B).withValues(alpha: 0.16),
                          blurRadius: 12,
                          offset: const Offset(5, 6),
                        ),
                      ],
              ),
              child: Row(
                children: [
                  Icon(PhosphorIcons.pulse(), color: c.accentBlue, size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Live threat feed synchronized. Security baseline healthy.',
                      style: AppTextStyles.body(
                        size: 12,
                        weight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(delay: 340.ms),
          ],
        ),
      ),
    );
  }
}

class _FormPanel extends StatelessWidget {
  final bool obscurePassword;
  final bool rememberMe;
  final TextEditingController organizationIdController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleRemember;
  final VoidCallback onToggleObscure;

  const _FormPanel({
    required this.obscurePassword,
    required this.rememberMe,
    required this.organizationIdController,
    required this.emailController,
    required this.passwordController,
    required this.onToggleRemember,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 12, 10, 12),
      child: _AuthCard(
        obscurePassword: obscurePassword,
        rememberMe: rememberMe,
        organizationIdController: organizationIdController,
        emailController: emailController,
        passwordController: passwordController,
        onToggleRemember: onToggleRemember,
        onToggleObscure: onToggleObscure,
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  final bool obscurePassword;
  final bool rememberMe;
  final TextEditingController organizationIdController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleRemember;
  final VoidCallback onToggleObscure;

  const _MobileBody({
    required this.obscurePassword,
    required this.rememberMe,
    required this.organizationIdController,
    required this.emailController,
    required this.passwordController,
    required this.onToggleRemember,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
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
          _AuthCard(
            obscurePassword: obscurePassword,
            rememberMe: rememberMe,
            organizationIdController: organizationIdController,
            emailController: emailController,
            passwordController: passwordController,
            onToggleRemember: onToggleRemember,
            onToggleObscure: onToggleObscure,
          ),
        ],
      ),
    );
  }
}

class _AuthCard extends StatelessWidget {
  final bool obscurePassword;
  final bool rememberMe;
  final TextEditingController organizationIdController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleRemember;
  final VoidCallback onToggleObscure;

  const _AuthCard({
    required this.obscurePassword,
    required this.rememberMe,
    required this.organizationIdController,
    required this.emailController,
    required this.passwordController,
    required this.onToggleRemember,
    required this.onToggleObscure,
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
            'Sign In',
            style: AppTextStyles.display(
              size: 32,
              weight: FontWeight.w800,
              letterSpacing: -0.7,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Access your protected asset dashboard',
            style: AppTextStyles.body(size: 14, color: c.textSecondary),
          ),
          const SizedBox(height: 14),
          const _SecurityStatusBar(),
          const SizedBox(height: 18),
          const _FieldLabel(label: 'Organization ID'),
          const SizedBox(height: 7),
          _InputField(
              hint: 'e.g. ASTRA-7XK29P', controller: organizationIdController),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Email Address'),
          const SizedBox(height: 7),
          _InputField(
              hint: 'admin@organization.com', controller: emailController),
          const SizedBox(height: 14),
          const _FieldLabel(label: 'Password'),
          const SizedBox(height: 7),
          _InputField(
            hint: '••••••••••••',
            controller: passwordController,
            obscureText: obscurePassword,
            suffixIcon: IconButton(
              onPressed: onToggleObscure,
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
          Row(
            children: [
              InkWell(
                onTap: onToggleRemember,
                borderRadius: BorderRadius.circular(8),
                child: Row(
                  children: [
                    Checkbox(
                      value: rememberMe,
                      onChanged: (_) => onToggleRemember(),
                      activeColor: AppColors.accentAmber,
                      checkColor: AppColors.textOnAmber,
                      side: BorderSide(color: c.borderDefault),
                    ),
                    Text(
                      'Remember me',
                      style: AppTextStyles.body(
                        size: 13,
                        weight: FontWeight.w600,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              TextButton(
                onPressed: () =>
                    _requestPasswordReset(context, emailController.text.trim()),
                child: Text(
                  'Forgot Password?',
                  style: AppTextStyles.body(
                    size: 13,
                    weight: FontWeight.w700,
                    color: AppColors.accentAmber,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _AuthButton(
            organizationIdController: organizationIdController,
            emailController: emailController,
            passwordController: passwordController,
          ),
          const SizedBox(height: 16),
          Center(
            child: Wrap(
              spacing: 4,
              children: [
                Text(
                  'No account yet?',
                  style: AppTextStyles.body(size: 13, color: c.textSecondary),
                ),
                InkWell(
                  onTap: () => context.go('/signup'),
                  child: Text(
                    'Create one',
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
}

class _BenefitRow extends StatelessWidget {
  final PhosphorIconData Function([PhosphorIconsStyle]) icon;
  final String title;
  final String subtitle;

  const _BenefitRow(
      {required this.icon, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: AppColors.accentAmber.withValues(alpha: 0.14),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon(), size: 16, color: AppColors.accentAmber),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTextStyles.display(
                  size: 15,
                  weight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTextStyles.body(size: 13, color: c.textSecondary),
              ),
            ],
          ),
        ),
      ],
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

class _AuthButton extends StatefulWidget {
  final TextEditingController organizationIdController;
  final TextEditingController emailController;
  final TextEditingController passwordController;

  const _AuthButton({
    required this.organizationIdController,
    required this.emailController,
    required this.passwordController,
  });

  @override
  State<_AuthButton> createState() => _AuthButtonState();
}

class _AuthButtonState extends State<_AuthButton> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: ScaleButton(
        onTap: () async {
          final organizationId =
              widget.organizationIdController.text.trim().toUpperCase();
          final email = widget.emailController.text.trim();
          final password = widget.passwordController.text;

          if (organizationId.isEmpty || email.isEmpty || password.isEmpty) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Enter organization ID, email and password')),
            );
            return;
          }

          try {
            final credential =
                await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            final user = credential.user;
            if (user == null) {
              AppRouter.isAuthenticated = false;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Authentication failed')),
              );
              return;
            }

            final orgDoc = await FirebaseFirestore.instance
                .collection('organizations')
                .doc(user.uid)
                .get();

            final storedOrgId = (orgDoc.data()?['organizationId'] ?? '')
                .toString()
                .trim()
                .toUpperCase();
            final storedAdminName =
                (orgDoc.data()?['adminFullName'] ?? '').toString().trim();

            if (storedOrgId.isEmpty || storedOrgId != organizationId) {
              await FirebaseAuth.instance.signOut();
              AppRouter.isAuthenticated = false;
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Invalid organization ID')),
              );
              return;
            }

            AppRouter.isAuthenticated = true;
            AppRouter.currentOrganizationId = storedOrgId;
            AppRouter.currentAdminName = storedAdminName.isEmpty
                ? (user.displayName ?? 'Admin User')
                : storedAdminName;

            if (context.mounted) {
              await Future<void>.delayed(Duration.zero);
              AppRouter.router.go('/dashboard');
            }
          } on FirebaseAuthException catch (e) {
            AppRouter.isAuthenticated = false;
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.message ?? 'Authentication failed')),
            );
          } catch (_) {
            AppRouter.isAuthenticated = false;
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Authentication failed')),
            );
          }
        },
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
                  'Authenticate Access',
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
              'Secure connection established',
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

Future<void> _requestPasswordReset(BuildContext context, String email) async {
  if (email.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Enter your email address first')),
    );
    return;
  }

  try {
    await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset email sent')),
    );
  } on FirebaseAuthException catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(e.message ?? 'Unable to send reset email')),
    );
  } catch (_) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Unable to send reset email')),
    );
  }
}
