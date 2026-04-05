import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_text_styles.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/widgets/astra_logo.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/theme_toggle_button.dart';
import '../../core/widgets/scale_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;
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
      body: LayoutBuilder(builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 1000;
        final availableHeight = constraints.maxHeight;

        return Stack(
          children: [
            // LAYER 1: BASE
            Positioned.fill(
                child: AnimatedContainer(duration: 300.ms, color: c.bgPrimary)),

            // LAYER 2: CLEAN BACKGROUND
            Positioned.fill(
              child: Container(color: c.bgPrimary),
            ),

            // LAYER 3: CONTENT
            Positioned.fill(
              child: isMobile
                  ? _MobileView(
                      obscurePassword: _obscurePassword,
                      organizationIdController: _organizationIdController,
                      emailController: _emailController,
                      passwordController: _passwordController,
                      onToggleObscure: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    )
                  : Row(
                      children: [
                        // LEFT PANEL: 55%
                        Expanded(
                          flex: 55,
                          child: _LeftPanel(availableHeight: availableHeight),
                        ),

                        // DIVIDER
                        AnimatedContainer(
                          duration: 300.ms,
                          width: 1,
                          color: c.borderDefault.withValues(alpha: 0.5),
                        ),

                        // RIGHT PANEL: 45%
                        Expanded(
                          flex: 45,
                          child: _RightPanel(
                            obscurePassword: _obscurePassword,
                            organizationIdController: _organizationIdController,
                            emailController: _emailController,
                            passwordController: _passwordController,
                            onToggleObscure: () => setState(
                                () => _obscurePassword = !_obscurePassword),
                            availableHeight: availableHeight,
                          ),
                        ),
                      ],
                    ),
            ),

            // THEME TOGGLE — Top Right
            const Positioned(
              top: 8,
              right: 8,
              child: ThemeToggleButton(compact: true),
            ),
          ],
        );
      }),
    );
  }
}

class _LeftPanel extends StatelessWidget {
  final double availableHeight;
  const _LeftPanel({required this.availableHeight});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // RELOCATED BRANDING
        Padding(
          padding: const EdgeInsets.fromLTRB(48, 48, 48, 0),
          child: const AstraLogo(size: 24)
              .animate()
              .fadeIn(duration: 400.ms)
              .slideX(begin: -0.1, end: 0),
        ),

        // MAIN CONTENT
        Expanded(
          child: Stack(
            children: [
              // BACKGROUND
              Positioned.fill(
                child: Container(color: c.bgPrimary),
              ),

              // FOREGROUND CONTENT
              SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(48, 64, 48, 48),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // HEADLINE BLOCK
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "ZERO\nTRUST",
                            style: AppTextStyles.display(
                              size: availableHeight < 700 ? 56 : 80,
                              weight: FontWeight.w900,
                              color: c.textPrimary,
                              height: 0.9,
                              letterSpacing: -2,
                              shadows: c.isDark
                                  ? [
                                      Shadow(
                                        color: c.textPrimary
                                            .withValues(alpha: 0.3),
                                        blurRadius: 20,
                                      ),
                                    ]
                                  : [],
                            ),
                          )
                              .animate()
                              .fadeIn(duration: 600.ms)
                              .slideX(begin: -0.05, end: 0),
                          const SizedBox(height: 8),
                          Text(
                            "TOTAL\nCUSTODY",
                            style: AppTextStyles.display(
                              size: availableHeight < 700 ? 56 : 80,
                              weight: FontWeight.w900,
                              color: AppColors.accentAmber,
                              height: 0.9,
                              letterSpacing: -2,
                              shadows: c.isDark
                                  ? [
                                      Shadow(
                                        color: AppColors.accentAmber
                                            .withValues(alpha: 0.4),
                                        blurRadius: 30,
                                      ),
                                    ]
                                  : [],
                            ),
                          )
                              .animate(delay: 150.ms)
                              .fadeIn(duration: 600.ms)
                              .slideX(begin: -0.05, end: 0),
                        ],
                      ),

                      const SizedBox(height: 48),

                      const SizedBox(height: 12),

                      const SizedBox(height: 48),

                      Text(
                        "AI-powered semantic detection and cryptographic\nchain of custody for sports media organizations.",
                        style: AppTextStyles.body(
                          size: 16,
                          weight: FontWeight.w400,
                          color: c.textSecondary,
                          height: 1.6,
                        ),
                      ).animate(delay: 450.ms).fadeIn(),

                      const SizedBox(height: 64),

                      // LIVE METRICS BLOCK
                      const _MetricsDashboard(),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        const SizedBox.shrink(),
      ],
    );
  }
}

class _RightPanel extends StatelessWidget {
  final bool obscurePassword;
  final TextEditingController organizationIdController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleObscure;
  final double availableHeight;

  const _RightPanel({
    required this.obscurePassword,
    required this.organizationIdController,
    required this.emailController,
    required this.passwordController,
    required this.onToggleObscure,
    required this.availableHeight,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return AnimatedContainer(
      duration: 300.ms,
      color: c.bgPrimary,
      child: Stack(
        children: [
          // SUBTLE BACKGROUND ACCENT
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.accentAmber.withValues(alpha: 0.05),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          Column(
            children: [
              // ZONE A: HEADER BAR
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 0),
                child: Row(
                  children: [
                    _HomeLink(),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 440),
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: AnimatedContainer(
                          duration: 400.ms,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 40, vertical: 48),
                          decoration: BoxDecoration(
                            color: c.bgSecondary.withValues(alpha: 0.4),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color: c.borderDefault.withValues(alpha: 0.5),
                              width: 1,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 40,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "ADMINISTRATOR",
                                style: AppTextStyles.display(
                                  size: 13,
                                  weight: FontWeight.w800,
                                  color: AppColors.accentAmber,
                                  letterSpacing: 4,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                "ACCESS TERMINAL",
                                style: AppTextStyles.display(
                                  size: 32,
                                  weight: FontWeight.w900,
                                  color: c.textPrimary,
                                  letterSpacing: -1,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Container(
                                width: 40,
                                height: 3,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      AppColors.accentAmber,
                                      c.accentBlue
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              const SizedBox(height: 24),
                              Text(
                                "Restricted to verified organizational identities Secure connection active",
                                style: AppTextStyles.body(
                                  size: 14,
                                  color: c.textSecondary,
                                  height: 1.5,
                                ),
                              ),
                              SizedBox(height: availableHeight < 600 ? 32 : 48),
                              const _FormLabel(
                                  label: "ORGANIZATION ID",
                                  color: AppColors.accentAmber),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                hint: "e.g. ASTRA-7XK29P",
                                controller: organizationIdController,
                              ),
                              const SizedBox(height: 24),
                              const _FormLabel(
                                  label: "IDENTITY",
                                  color: AppColors.accentAmber),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                hint: "admin@organization.com",
                                controller: emailController,
                              ),
                              const SizedBox(height: 24),
                              const _FormLabel(
                                  label: "CREDENTIAL",
                                  color: AppColors.accentAmber),
                              const SizedBox(height: 8),
                              _StyledTextField(
                                hint: "••••••••••••",
                                isPassword: true,
                                obscureText: obscurePassword,
                                controller: passwordController,
                                onToggle: onToggleObscure,
                              ),
                              const SizedBox(height: 32),
                              _AuthButton(
                                organizationIdController:
                                    organizationIdController,
                                emailController: emailController,
                                passwordController: passwordController,
                              ),
                              const SizedBox(height: 24),
                              const _SecurityStatusBar(),
                              const SizedBox(height: 24),
                              Center(
                                child: OutlinedButton(
                                  onPressed: () => _showSignUpDialog(context),
                                  style: OutlinedButton.styleFrom(
                                    side: BorderSide(color: c.borderDefault),
                                    shape: const RoundedRectangleBorder(
                                        borderRadius: BorderRadius.zero),
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 24, vertical: 16),
                                  ),
                                  child: Text(
                                    "REGISTER YOUR ORGANIZATION",
                                    style: AppTextStyles.display(
                                      size: 11,
                                      weight: FontWeight.w700,
                                      color: c.textSecondary,
                                      letterSpacing: 1.5,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              Text(
                                "SYSTEM NOTICE: Unauthorized access is a violation of organizational policy All terminal sessions are encrypted and logged",
                                style: AppTextStyles.body(
                                  size: 12,
                                  color: c.textMuted,
                                  height: 1.5,
                                  weight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        )
                            .animate()
                            .fadeIn(duration: 600.ms)
                            .slideY(begin: 0.05, end: 0),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MobileView extends StatelessWidget {
  final bool obscurePassword;
  final TextEditingController organizationIdController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final VoidCallback onToggleObscure;

  const _MobileView({
    required this.obscurePassword,
    required this.organizationIdController,
    required this.emailController,
    required this.passwordController,
    required this.onToggleObscure,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    return Container(
      color: c.bgSecondary,
      child: Center(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.all(40.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AstraLogo(size: 20),
                  const SizedBox(height: 12),
                  Text(
                    "ADMIN TERMINAL",
                    style: AppTextStyles.display(
                      size: 28,
                      weight: FontWeight.w900,
                      color: c.textPrimary,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: 32),
                  const _FormLabel(
                      label: "ORGANIZATION ID", color: AppColors.accentAmber),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    hint: "e.g. ASTRA-7XK29P",
                    controller: organizationIdController,
                  ),
                  const SizedBox(height: 20),
                  const _FormLabel(
                      label: "IDENTITY", color: AppColors.accentAmber),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    hint: "admin@organization.com",
                    controller: emailController,
                  ),
                  const SizedBox(height: 20),
                  const _FormLabel(
                      label: "CREDENTIAL", color: AppColors.accentAmber),
                  const SizedBox(height: 8),
                  _StyledTextField(
                    hint: "••••••••••••",
                    isPassword: true,
                    obscureText: obscurePassword,
                    controller: passwordController,
                    onToggle: onToggleObscure,
                  ),
                  const SizedBox(height: 32),
                  _AuthButton(
                    organizationIdController: organizationIdController,
                    emailController: emailController,
                    passwordController: passwordController,
                  ),
                  const SizedBox(height: 24),
                  const _SecurityStatusBar(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Redundant painters removed.

class _MetricsDashboard extends StatelessWidget {
  const _MetricsDashboard();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return AnimatedContainer(
      duration: 300.ms,
      decoration: BoxDecoration(
        color: c.bgSecondary.withValues(alpha: 0.5),
        border:
            Border.all(color: c.borderDefault.withValues(alpha: 0.5), width: 1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        children: [
          // Removed the odd dual-color top bar
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "LIVE THREAT DETECTION METRICS",
                          style: AppTextStyles.display(
                            size: 13,
                            weight: FontWeight.w800,
                            color: c.textMuted,
                            letterSpacing: 2,
                          ),
                        ),
                      ],
                    ),
                    Icon(PhosphorIcons.pulse(), color: c.accentBlue, size: 24),
                  ],
                ),
                const SizedBox(height: 32),
                Row(
                  children: [
                    const Expanded(
                        child: _LiveStat("THREATS NEUTRALIZED", "4,821",
                            AppColors.accentAmber)),
                    Container(
                        width: 1,
                        height: 40,
                        color: c.borderDefault.withValues(alpha: 0.5)),
                    Expanded(
                        child:
                            _LiveStat("ACTIVE SESSIONS", "142", c.accentBlue)),
                    Container(
                        width: 1,
                        height: 40,
                        color: c.borderDefault.withValues(alpha: 0.5)),
                    const Expanded(
                        child: _LiveStat(
                            "LATENCY", "12ms", AppColors.accentGreen)),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LiveStat extends StatelessWidget {
  final String label;
  final String value;
  final Color accent;
  const _LiveStat(this.label, this.value, this.accent);

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.mono(
            size: 12,
            weight: FontWeight.w600,
            color: c.textMuted,
          ),
        ),
        Text(
          value,
          style: AppTextStyles.display(
            size: 28,
            weight: FontWeight.w800,
            color: accent,
          ),
        ),
      ],
    );
  }
}

class _FormLabel extends StatelessWidget {
  final String label;
  final Color color;
  const _FormLabel({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 4, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: AppTextStyles.display(
            size: 14,
            weight: FontWeight.w700,
            color: color,
            letterSpacing: 2,
          ),
        ),
      ],
    );
  }
}

class _StyledTextField extends StatelessWidget {
  final String hint;
  final bool isPassword;
  final bool obscureText;
  final TextEditingController? controller;
  final VoidCallback? onToggle;

  const _StyledTextField({
    required this.hint,
    this.isPassword = false,
    this.obscureText = false,
    this.controller,
    this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      decoration: BoxDecoration(
        color: c.bgSurface,
        border: const Border(
            left: BorderSide(color: AppColors.accentAmber, width: 3)),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        style: AppTextStyles.body(color: c.textPrimary, size: 15),
        decoration: InputDecoration(
          hintText: hint,
          suffixIcon: isPassword
              ? IconButton(
                  icon: Icon(
                      obscureText
                          ? PhosphorIcons.eyeClosed()
                          : PhosphorIcons.eye(),
                      size: 18),
                  color: c.textMuted,
                  onPressed: onToggle,
                )
              : null,
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
            await FirebaseAuth.instance.signInWithEmailAndPassword(
              email: email,
              password: password,
            );

            final user = FirebaseAuth.instance.currentUser;
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
          duration: 200.ms,
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                _isHovering
                    ? AppColors.accentAmber
                    : AppColors.accentAmber.withValues(alpha: 0.9),
                _isHovering
                    ? AppColors.accentAmber.withValues(alpha: 0.9)
                    : AppColors.accentAmber.withValues(alpha: 0.8),
              ],
            ),
            borderRadius: BorderRadius.circular(4),
            boxShadow: _isHovering
                ? [
                    BoxShadow(
                      color: AppColors.accentAmber.withValues(alpha: 0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : [],
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                right: -5,
                top: -5,
                child: Icon(
                  PhosphorIcons.shieldCheck(),
                  size: 48,
                  color: Colors.black.withValues(alpha: 0.04),
                ),
              ),
              Center(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "AUTHENTICATE ACCESS",
                      style: AppTextStyles.display(
                        size: 15,
                        weight: FontWeight.w900,
                        color: AppColors.textOnAmber,
                        letterSpacing: 2,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      PhosphorIcons.arrowRight(),
                      color: AppColors.textOnAmber,
                      size: 20,
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

class _SecurityStatusBar extends StatelessWidget {
  const _SecurityStatusBar();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.accentGreen.withValues(alpha: 0.05),
        border: Border.all(color: AppColors.accentGreen.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const _SimpleStatusDot(color: AppColors.accentGreen, size: 6),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              "SECURE CONNECTION ESTABLISHED",
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.display(
                size: 12,
                weight: FontWeight.w700,
                color: AppColors.accentGreen,
                letterSpacing: 1,
              ),
            ),
          ),
          Icon(PhosphorIcons.lockKey(), size: 14, color: AppColors.accentGreen),
        ],
      ),
    );
  }
}

class _SimpleStatusDot extends StatelessWidget {
  final Color color;
  final double size;
  const _SimpleStatusDot({required this.color, required this.size});
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      );
}

class _HomeLink extends StatefulWidget {
  @override
  State<_HomeLink> createState() => _HomeLinkState();
}

class _HomeLinkState extends State<_HomeLink> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: () => context.go('/'),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.click,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              PhosphorIcons.arrowLeft(),
              size: 12,
              color: _isHovering ? c.textSecondary : c.textMuted,
            ),
            const SizedBox(width: 6),
            Text(
              "HOME",
              style: AppTextStyles.mono(
                size: 9,
                weight: FontWeight.w600,
                color: _isHovering ? c.textSecondary : c.textMuted,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void _showSignUpDialog(BuildContext context) {
  final c = context.colors;
  final organizationNameController = TextEditingController();
  final adminFullNameController = TextEditingController();
  final adminEmailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool termsAccepted = false;
  String? selectedOrgType;

  String generateOrganizationId() {
    final raw =
        DateTime.now().millisecondsSinceEpoch.toRadixString(36).toUpperCase();
    final suffix = raw.length > 6 ? raw.substring(raw.length - 6) : raw;
    return 'ASTRA-$suffix';
  }

  showDialog(
    context: context,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    builder: (context) => StatefulBuilder(
      builder: (context, setState) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(horizontal: 20),
          child: Container(
            width: 520,
            decoration: BoxDecoration(
              color: c.bgSecondary,
              border: Border.all(color: c.borderDefault),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // MODAL HEADER
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: c.bgTertiary,
                    border: Border(bottom: BorderSide(color: c.borderDefault)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "REGISTER ORGANIZATION",
                            style: AppTextStyles.mono(
                              size: 14,
                              weight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Create your Sentinel AI administrator account",
                            style: AppTextStyles.body(
                              size: 12,
                              color: c.textSecondary,
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.x(), size: 20),
                        color: c.textMuted,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),

                // MODAL BODY
                Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _SignUpField(
                              label: "ORGANIZATION NAME",
                              hint: "e.g. BCCI — Board of Control",
                              controller: organizationNameController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SignUpField(
                              label: "ORG TYPE",
                              hint: "",
                              isDropdown: true,
                              dropdownValue: selectedOrgType,
                              onDropdownChanged: (value) {
                                setState(() => selectedOrgType = value);
                              },
                              items: const [
                                "Cricket Board",
                                "Football League",
                                "Esports Org",
                                "Basketball League",
                                "Other"
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SignUpField(
                              label: "ADMIN FULL NAME",
                              hint: "e.g. Rahul Sharma",
                              controller: adminFullNameController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SignUpField(
                              label: "ADMIN EMAIL",
                              hint: "admin@organization.com",
                              controller: adminEmailController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: _SignUpField(
                              label: "PASSWORD",
                              hint: "Min 12 characters",
                              isPassword: true,
                              controller: passwordController,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _SignUpField(
                              label: "CONFIRM PASSWORD",
                              hint: "Repeat password",
                              isPassword: true,
                              controller: confirmPasswordController,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: () =>
                            setState(() => termsAccepted = !termsAccepted),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: Checkbox(
                                value: termsAccepted,
                                onChanged: (v) =>
                                    setState(() => termsAccepted = v ?? false),
                                fillColor: WidgetStateProperty.resolveWith(
                                    (s) => s.contains(WidgetState.selected)
                                        ? AppColors.accentAmber
                                        : Colors.transparent),
                                checkColor: AppColors.textOnAmber,
                                side: BorderSide(color: c.borderDefault),
                                shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.zero),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: "I agree to the ",
                                      style: AppTextStyles.body(
                                          size: 12, color: c.textSecondary),
                                    ),
                                    TextSpan(
                                      text: "Terms of Service",
                                      style: AppTextStyles.body(
                                        size: 12,
                                        color: AppColors.accentAmber,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                    TextSpan(
                                      text: " and ",
                                      style: AppTextStyles.body(
                                          size: 12, color: c.textSecondary),
                                    ),
                                    TextSpan(
                                      text: "Privacy Policy",
                                      style: AppTextStyles.body(
                                        size: 12,
                                        color: AppColors.accentAmber,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // MODAL FOOTER
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border(top: BorderSide(color: c.borderDefault)),
                  ),
                  child: Row(
                    children: [
                      OutlinedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: c.borderDefault),
                          shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero),
                        ),
                        child: Text(
                          "CANCEL",
                          style: AppTextStyles.mono(
                              size: 12,
                              weight: FontWeight.w700,
                              color: c.textSecondary),
                        ),
                      ),
                      const Spacer(),
                      Opacity(
                        opacity: termsAccepted ? 1.0 : 0.4,
                        child: ElevatedButton(
                          onPressed: termsAccepted
                              ? () async {
                                  final orgName =
                                      organizationNameController.text.trim();
                                  final fullName =
                                      adminFullNameController.text.trim();
                                  final email =
                                      adminEmailController.text.trim();
                                  final password = passwordController.text;
                                  final confirmPassword =
                                      confirmPasswordController.text;
                                  final organizationId =
                                      generateOrganizationId();

                                  if (orgName.isEmpty ||
                                      fullName.isEmpty ||
                                      email.isEmpty ||
                                      password.isEmpty ||
                                      selectedOrgType == null) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Please fill all fields and select org type')),
                                    );
                                    return;
                                  }

                                  if (!termsAccepted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Accept Terms of Service to continue')),
                                    );
                                    return;
                                  }

                                  if (password != confirmPassword) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content:
                                              Text('Passwords do not match')),
                                    );
                                    return;
                                  }

                                  try {
                                    final credential = await FirebaseAuth
                                        .instance
                                        .createUserWithEmailAndPassword(
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
                                        'organizationType': selectedOrgType,
                                        'adminFullName': fullName,
                                        'adminEmail': email,
                                        'createdAt':
                                            FieldValue.serverTimestamp(),
                                      });
                                    }

                                    AppRouter.isAuthenticated = true;
                                    AppRouter.currentOrganizationId =
                                        organizationId;
                                    AppRouter.currentAdminName = fullName;
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Account created. Organization ID: $organizationId',
                                        ),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  } on FirebaseAuthException catch (e) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                          content: Text(e.message ??
                                              'Registration failed')),
                                    );
                                  } catch (_) {
                                    if (!context.mounted) return;
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text('Registration failed')),
                                    );
                                  }
                                }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentAmber,
                            foregroundColor: AppColors.textOnAmber,
                            shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.zero),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 14),
                          ),
                          child: Text(
                            "CREATE ORGANIZATION ACCOUNT →",
                            style: AppTextStyles.display(
                                size: 12,
                                weight: FontWeight.w900,
                                color: AppColors.textOnAmber),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    ),
  ).whenComplete(() {
    organizationNameController.dispose();
    adminFullNameController.dispose();
    adminEmailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
  });
}

class _SignUpField extends StatelessWidget {
  final String label;
  final String hint;
  final bool isPassword;
  final bool isDropdown;
  final List<String>? items;
  final TextEditingController? controller;
  final String? dropdownValue;
  final ValueChanged<String?>? onDropdownChanged;

  const _SignUpField({
    required this.label,
    required this.hint,
    this.isPassword = false,
    this.isDropdown = false,
    this.items,
    this.controller,
    this.dropdownValue,
    this.onDropdownChanged,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.mono(
            size: 9,
            weight: FontWeight.w600,
            color: c.textMuted,
            letterSpacing: 2.5,
          ),
        ),
        const SizedBox(height: 8),
        if (isDropdown)
          DropdownButtonFormField<String>(
            initialValue: dropdownValue,
            dropdownColor: c.bgSecondary,
            style: AppTextStyles.body(color: c.textPrimary, size: 14),
            decoration: InputDecoration(
              filled: true,
              fillColor: c.bgSurface,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: c.borderDefault)),
              focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: AppColors.accentAmber)),
            ),
            items: items!
                .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                .toList(),
            onChanged: onDropdownChanged,
            hint: Text("Select...",
                style: AppTextStyles.body(color: c.textMuted, size: 14)),
          )
        else
          _StyledTextField(
            hint: hint,
            isPassword: isPassword,
            controller: controller,
          ),
      ],
    );
  }
}
