import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_theme_colors.dart';
import '../theme/theme_provider.dart';
import '../../core/widgets/astra_logo.dart';
import '../widgets/scale_button.dart';
import '../widgets/judge_guide_modal.dart';
import '../widgets/theme_toggle_button.dart';
import 'app_router.dart';

class AppShell extends ConsumerWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  String _getCurrentScreenName(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    switch (location) {
      case '/dashboard':   return 'Dashboard';
      case '/vault':       return 'Asset Vault';
      case '/threats':     return 'Threat Radar';
      case '/contagion':   return 'Contagion Map';
      case '/settings':    return 'Settings';
      default:             return 'ASTRA';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;

    return Focus(
      autofocus: true,
      onKeyEvent: (node, event) {
        if (event is KeyDownEvent) {
          final isCtrlOrCmd = HardwareKeyboard.instance.isControlPressed || 
                               HardwareKeyboard.instance.isMetaPressed;
          final isShift = HardwareKeyboard.instance.isShiftPressed;
          final isL = event.logicalKey == LogicalKeyboardKey.keyL;

          if (isCtrlOrCmd && isShift && isL) {
            final isDark = ref.read(isDarkProvider);
            ref.read(themeModeProvider.notifier).state =
              isDark ? ThemeMode.light : ThemeMode.dark;
            return KeyEventResult.handled;
          }
        }
        return KeyEventResult.ignored;
      },
      child: Scaffold(
        backgroundColor: c.bgPrimary,
        body: LayoutBuilder(
          builder: (context, constraints) {
            final isCollapsed = constraints.maxWidth < 900;
            return Row(
              children: [
                _buildSidebar(context, isCollapsed, c),
                VerticalDivider(width: 1, color: c.borderDefault),
                Expanded(
                  child: Column(
                    children: [
                      _buildTopBar(context, c),
                      Expanded(
                        child: Stack(
                          children: [
                            child,
                            // HELP BUTTON (DEMO GUIDE)
                            Positioned(
                              bottom: 24,
                              right: 24,
                              child: ScaleButton(
                              child: FloatingActionButton(
                                onPressed: () => JudgeGuideModal.show(context),
                                backgroundColor: c.accentBlue,
                                foregroundColor: Colors.white,
                                elevation: 8,
                                shape: const CircleBorder(),
                                child: Icon(PhosphorIcons.bookOpen(), size: 24),
                              ),
                            ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, AppThemeColors c) {
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border(bottom: BorderSide(color: c.borderDefault, width: 1)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          // LEFT: Breadcrumb
          Row(
            children: [
              Icon(PhosphorIcons.caretRight(), size: 12, color: c.textMuted),
              const SizedBox(width: 8),
              Text(
                _getCurrentScreenName(context),
                style: AppTextStyles.display(
                  size: 13,
                  weight: FontWeight.w700,
                  color: c.textPrimary,
                  letterSpacing: 1.2,
                ),
              ),
            ],
          ),
          const Spacer(),
          // CENTER: (Removed as requested)
          const Spacer(),
          // RIGHT: Bell + Toggle + User
          Row(
            children: [
              PopupMenuButton<String>(
                offset: const Offset(0, 45),
                color: c.bgSecondary,
                elevation: 4,
                shadowColor: Colors.black26,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: BorderSide(color: c.borderDefault),
                ),
                icon: Stack(
                  children: [
                    Icon(PhosphorIcons.bell(), size: 18, color: c.textSecondary),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Container(
                        width: 8, height: 8,
                        decoration: BoxDecoration(
                          color: AppColors.accentCrimson,
                          shape: BoxShape.circle,
                          border: Border.all(color: c.bgSecondary, width: 1.5),
                        ),
                      ),
                    ),
                  ],
                ),
                onSelected: (value) {},
                itemBuilder: (context) => [
                  _buildNotificationItem(context, "New Leak Detected", "IPL Highlights found on Telegram", AppColors.accentCrimson),
                  _buildNotificationItem(context, "System Update", "Vulnerability scanner updated to v2.4", c.accentBlue),
                  _buildNotificationItem(context, "Report Ready", "Weekly threat analysis is available", AppColors.accentGreen),
                ],
              ),
              const SizedBox(width: 8),
              const ThemeToggleButton(compact: true),
              const SizedBox(width: 12),
              Container(width: 1, height: 20, color: c.borderDefault),
              const SizedBox(width: 12),
              Container(
                width: 32, height: 32,
                color: c.bgTertiary,
                child: Center(
                  child: Text(
                    "SA",
                    style: AppTextStyles.display(
                      size: 12,
                      weight: FontWeight.w700,
                      color: AppColors.accentAmber,
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

  Widget _buildSidebar(BuildContext context, bool isCollapsed, AppThemeColors c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 64 : 220,
      color: c.bgSecondary,
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: isCollapsed ? 24 : 32,
              horizontal: isCollapsed ? 0 : 16,
            ),
            child: AstraLogo(
              size: isCollapsed ? 28 : 36,
              showText: !isCollapsed,
            ),
          ),
          const SizedBox(height: 12),
          Divider(color: c.borderDefault, height: 1),
          
          // NAV ITEMS
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 12),
              children: [
                _NavItem(icon: PhosphorIcons.chartBar(), label: "Dashboard", route: '/dashboard', isCollapsed: isCollapsed),
                _NavItem(icon: PhosphorIcons.shieldCheck(), label: "Asset Vault", route: '/vault', isCollapsed: isCollapsed),
                _NavItem(icon: PhosphorIcons.waveform(), label: "Threat Radar", route: '/threats', isCollapsed: isCollapsed),
                _NavItem(icon: PhosphorIcons.treeStructure(), label: "Propagation Flow", route: '/contagion', isCollapsed: isCollapsed),
              ],
            ),
          ),
          
          // BOTTOM
          Padding(
            padding: EdgeInsets.all(isCollapsed ? 8 : 16.0),
            child: Column(
              children: [
                Divider(color: c.borderDefault, height: 1),
                const SizedBox(height: 12),
                _NavItem(icon: PhosphorIcons.gear(), label: "Settings", route: '/settings', isCollapsed: isCollapsed),
                const SizedBox(height: 16),
                if (!isCollapsed)
                   Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: c.bgTertiary,
                        child: Text("SA", style: AppTextStyles.display(size: 14, color: AppColors.accentAmber)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Admin User", style: AppTextStyles.body(size: 13, weight: FontWeight.w600, color: c.textPrimary)),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.signOut(), size: 18),
                        color: c.textMuted,
                        onPressed: () {
                          AppRouter.isAuthenticated = false;
                          context.go('/login');
                        },
                      ),
                    ],
                  )
                else ...[
                  const SizedBox(height: 8),
                  IconButton(
                    icon: Icon(PhosphorIcons.signOut(), size: 20),
                    color: c.textMuted,
                    onPressed: () {
                      AppRouter.isAuthenticated = false;
                      context.go('/login');
                    },
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatefulWidget {
  final IconData icon;
  final String label;
  final String route;
  final bool isCollapsed;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
    this.isCollapsed = false,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final location = GoRouterState.of(context).matchedLocation;
    final isSelected = location.startsWith(widget.route);

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? c.bgTertiary : (_isHovering ? c.bgOverlay : Colors.transparent),
        border: Border(
          left: BorderSide(
            color: isSelected ? AppColors.accentAmber : Colors.transparent,
            width: 3,
          ),
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(left: isSelected ? 9.0 : 12.0, right: 12.0),
        child: Row(
          mainAxisAlignment: widget.isCollapsed ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(
              widget.icon,
              size: 18,
              color: isSelected ? AppColors.accentAmber : (_isHovering ? c.textSecondary : c.textMuted),
            ),
            if (!widget.isCollapsed) ...[
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppTextStyles.navLabel.copyWith(
                  fontSize: 14,
                  color: isSelected ? AppColors.accentAmber : (_isHovering ? c.textPrimary : c.textSecondary),
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );

    final item = MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: ScaleButton(
        onTap: () => context.go(widget.route),
        child: content,
      ),
    );

    if (widget.isCollapsed) {
      return Tooltip(
        message: widget.label,
        preferBelow: false,
        verticalOffset: 20,
        decoration: BoxDecoration(
          color: c.bgSurface,
          border: Border.all(color: c.borderDefault),
        ),
        textStyle: AppTextStyles.body(size: 12, color: c.textPrimary, weight: FontWeight.w600),
        child: item,
      );
    }

    return item;
  }
}
PopupMenuItem<String> _buildNotificationItem(BuildContext context, String title, String sub, Color color) {
  final c = context.colors;
  return PopupMenuItem<String>(
    enabled: false,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text(title, style: AppTextStyles.body(size: 13, weight: FontWeight.w700, color: c.textPrimary)),
          ],
        ),
        const SizedBox(height: 4),
        Text(sub, style: AppTextStyles.body(size: 11, color: c.textMuted)),
        const Divider(height: 16),
      ],
    ),
  );
}
