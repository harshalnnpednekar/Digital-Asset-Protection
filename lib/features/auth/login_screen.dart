import 'dart:math';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/widgets/custom_chip.dart';
import '../../core/widgets/sentinel_logo.dart';
import '../../core/widgets/status_dot.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Row(
        children: [
          // LEFT PANEL: 55%
          Expanded(
            flex: 55,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // Layer 1: Background Geometry
                CustomPaint(
                  painter: _NodeGraphPainter(),
                ),
                // Layer 2: Content overlay
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 64.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const CustomChip(
                          label: "CLASSIFIED // SPORTS IP PROTECTION",
                          color: AppColors.accentAmber,
                        ),
                        const SizedBox(height: 32),
                        const SentinelLogo(isLarge: true),
                        const SizedBox(height: 16),
                        Text(
                          "Zero Trust.\nTotal Custody.",
                          style: AppTextStyles.mono(size: 36, weight: FontWeight.w700, color: AppColors.textPrimary).copyWith(height: 1.2),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          "AI-powered piracy detection and cryptographic\nchain of custody for sports media organizations.",
                          style: AppTextStyles.sans(size: 14, color: AppColors.textSecondary).copyWith(height: 1.6),
                        ),
                        const SizedBox(height: 40),
                        
                        // Tech Badges
                        Wrap(
                          spacing: 16,
                          runSpacing: 16,
                          children: [
                            _buildTechBadge(PhosphorIcons.lock(), "C2PA SECURED"),
                            _buildTechBadge(PhosphorIcons.cpu(), "AES-256 ENCRYPTED"),
                            _buildTechBadge(PhosphorIcons.eye(), "AI MONITORED", isLast: true),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // RIGHT PANEL: 45%
          Expanded(
            flex: 45,
            child: Container(
              decoration: const BoxDecoration(
                color: AppColors.bgSecondary,
                border: Border(
                  left: BorderSide(color: AppColors.borderDefault, width: 1),
                ),
              ),
              child: Center(
                child: SizedBox(
                  width: 380,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Text("ADMINISTRATOR ACCESS", style: AppTextStyles.mono(size: 11, weight: FontWeight.w600, color: AppColors.accentAmber, letterSpacing: 4)),
                      const SizedBox(height: 12),
                      Text("Sign in to Command Center", style: AppTextStyles.mono(size: 22, weight: FontWeight.w700, color: AppColors.textPrimary)),
                      const SizedBox(height: 8),
                      Text("Restricted to authorized personnel only", style: AppTextStyles.sans(size: 13, color: AppColors.textMuted)),
                      const SizedBox(height: 40),
                      
                      Text("EMAIL ADDRESS", style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 8),
                      TextFormField(
                        style: AppTextStyles.mono(size: 14, color: AppColors.textPrimary),
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          hintText: "admin@organization.com",
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Text("PASSWORD", style: AppTextStyles.sectionLabel),
                      const SizedBox(height: 8),
                      TextFormField(
                        obscureText: _obscurePassword,
                        style: AppTextStyles.mono(size: 14, color: AppColors.textPrimary),
                        decoration: InputDecoration(
                          hintText: "••••••••••••",
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePassword ? PhosphorIcons.eye() : PhosphorIcons.eyeSlash(),
                              color: AppColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.accentAmber,
                            foregroundColor: AppColors.textOnAmber,
                            elevation: 0,
                            shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                          ),
                          onPressed: () {
                            AppRouter.isAuthenticated = true;
                            context.go('/dashboard');
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text("AUTHENTICATE", style: AppTextStyles.buttonLabel),
                              const SizedBox(width: 8),
                              Icon(PhosphorIcons.arrowRight(), size: 16, color: AppColors.textOnAmber),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const StatusDot(color: AppColors.accentGreen, size: 6),
                          const SizedBox(width: 8),
                          Text("[ SECURE CONNECTION ESTABLISHED ]", style: AppTextStyles.mono(size: 10, color: AppColors.accentGreen, letterSpacing: 1)),
                        ],
                      ),
                      
                      const Spacer(),
                      
                      Center(
                        child: Text("SENTINEL AI v1.0 // HACKATHON BUILD", style: AppTextStyles.mono(size: 9, color: AppColors.textMuted, letterSpacing: 2)),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTechBadge(IconData icon, String label, {bool isLast = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: AppColors.textMuted),
        const SizedBox(width: 6),
        Text(label, style: AppTextStyles.caption),
        if (!isLast) ...[
          const SizedBox(width: 16),
          Container(width: 1, height: 14, color: AppColors.borderDefault),
        ]
      ],
    );
  }
}

class _NodeGraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final rand = Random(42); // Seeded for consistency
    const int nodeCount = 15;
    
    final nodes = List.generate(nodeCount, (i) {
      return Offset(
        rand.nextDouble() * size.width,
        rand.nextDouble() * size.height,
      );
    });
    
    final normalNodePaint = Paint()..color = AppColors.borderDefault;
    final threatNodePaint = Paint()..color = AppColors.accentAmber.withAlpha(102);
    
    final normalLinePaint = Paint()..color = AppColors.borderSubtle..strokeWidth = 1.0;
    
    // Draw lines between somewhat close nodes
    for (int i = 0; i < nodes.length; i++) {
      for (int j = i + 1; j < nodes.length; j++) {
        final dist = (nodes[i] - nodes[j]).distance;
        if (dist < 300) {
          // If both nodes are threat nodes (let's say indices 0, 1, 2 are threats)
          if (i < 3 && j < 3) {
             _drawDashedLine(canvas, nodes[i], nodes[j], Paint()..color = AppColors.accentCrimson.withAlpha(51)..strokeWidth = 1.0);
          } else {
             canvas.drawLine(nodes[i], nodes[j], normalLinePaint);
          }
        }
      }
    }
    
    // Draw nodes
    for (int i = 0; i < nodes.length; i++) {
      if (i < 3) {
        canvas.drawCircle(nodes[i], 6, threatNodePaint);
      } else {
        canvas.drawCircle(nodes[i], 3.5, normalNodePaint);
      }
    }
  }

  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint) {
    final distance = (p2 - p1).distance;
    const dashWidth = 5.0;
    const dashSpace = 5.0;
    var currentDistance = 0.0;
    final dx = (p2.dx - p1.dx) / distance;
    final dy = (p2.dy - p1.dy) / distance;

    while (currentDistance < distance) {
      final start = Offset(p1.dx + dx * currentDistance, p1.dy + dy * currentDistance);
      currentDistance += dashWidth;
      final endDistance = currentDistance > distance ? distance : currentDistance;
      final end = Offset(p1.dx + dx * endDistance, p1.dy + dy * endDistance);
      canvas.drawLine(start, end, paint);
      currentDistance += dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
