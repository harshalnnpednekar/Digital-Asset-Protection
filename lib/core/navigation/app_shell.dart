import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/sentinel_logo.dart';
import '../widgets/scale_button.dart';
import '../widgets/judge_guide_modal.dart';
import 'app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isCollapsed = constraints.maxWidth < 900;
          return Stack(
            children: [
              Row(
                children: [
                  _buildSidebar(context, isCollapsed),
                  const VerticalDivider(width: 1, color: AppColors.borderDefault),
                  Expanded(child: child),
                ],
              ),
              
              // HELP BUTTON (DEMO GUIDE)
              Positioned(
                bottom: 24,
                right: 24,
                child: ScaleButton(
                  onTap: () => JudgeGuideModal.show(context),
                  child: FloatingActionButton(
                    onPressed: () {}, // Handled by ScaleButton
                    backgroundColor: AppColors.accentBlue,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 8,
                    shape: const CircleBorder(),
                    child: Icon(PhosphorIcons.bookOpen(), size: 24),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSidebar(BuildContext context, bool isCollapsed) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: isCollapsed ? 64 : 220,
      color: AppColors.bgSecondary,
      child: Column(
        children: [
          // TOP SECTION: LOGO
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24, horizontal: isCollapsed ? 0 : 20),
            child: isCollapsed 
              ? Column(
                  children: [
                    Text("S", style: AppTextStyles.mono(size: 20, weight: FontWeight.w700, color: AppColors.accentAmber)),
                    Text("AI", style: AppTextStyles.mono(size: 12, weight: FontWeight.w700, color: AppColors.accentBlue)),
                  ],
                )
              : const SentinelLogo(),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderDefault, height: 1),
          
          // NAV ITEMS SECTION
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: isCollapsed ? 8 : 12, vertical: 12),
              children: [
                _NavItem(
                  icon: PhosphorIcons.chartBar(),
                  label: "Dashboard",
                  route: '/dashboard',
                  isCollapsed: isCollapsed,
                ),
                _NavItem(
                  icon: PhosphorIcons.shieldCheck(),
                  label: "Asset Vault",
                  route: '/vault',
                  isCollapsed: isCollapsed,
                ),
                _NavItem(
                  icon: PhosphorIcons.waveform(),
                  label: "Threat Radar",
                  route: '/threats',
                  isCollapsed: isCollapsed,
                ),
                _NavItem(
                  icon: PhosphorIcons.gitBranch(),
                  label: "Contagion Map",
                  route: '/contagion',
                  isCollapsed: isCollapsed,
                ),
              ],
            ),
          ),
          
          // BOTTOM SECTION
          Padding(
            padding: EdgeInsets.all(isCollapsed ? 8 : 16.0),
            child: Column(
              children: [
                const Divider(color: AppColors.borderDefault, height: 1),
                const SizedBox(height: 12),
                _NavItem(
                  icon: PhosphorIcons.gear(),
                  label: "Settings",
                  route: '/settings',
                  isCollapsed: isCollapsed,
                ),
                const SizedBox(height: 16),
                if (!isCollapsed)
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18,
                        backgroundColor: AppColors.bgTertiary,
                        child: Text("SA", style: AppTextStyles.mono(size: 14, color: AppColors.textPrimary)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Admin User", style: AppTextStyles.sans(size: 12, weight: FontWeight.w500, color: AppColors.textPrimary)),
                            Text("admin@sentinel.ai", style: AppTextStyles.mono(size: 10, color: AppColors.textMuted), overflow: TextOverflow.ellipsis),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: Icon(PhosphorIcons.signOut(), size: 18),
                        color: AppColors.textMuted,
                        onPressed: () {
                          AppRouter.isAuthenticated = false;
                          context.go('/login');
                        },
                      ),
                    ],
                  )
                else
                  IconButton(
                    icon: Icon(PhosphorIcons.signOut(), size: 20),
                    color: AppColors.textMuted,
                    onPressed: () {
                      AppRouter.isAuthenticated = false;
                      context.go('/login');
                    },
                  ),
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
    final location = GoRouterState.of(context).matchedLocation;
    final isSelected = location.startsWith(widget.route);

    final content = AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeOut,
      width: double.infinity,
      height: 40,
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.bgTertiary : (_isHovering ? AppColors.bgOverlay : Colors.transparent),
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
              color: isSelected ? AppColors.accentAmber : (_isHovering ? AppColors.textSecondary : AppColors.textMuted),
            ),
            if (!widget.isCollapsed) ...[
              const SizedBox(width: 10),
              Text(
                widget.label,
                style: AppTextStyles.navLabel.copyWith(
                  color: isSelected ? AppColors.accentAmber : (_isHovering ? AppColors.textPrimary : AppColors.textSecondary),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
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
          color: AppColors.bgSurface,
          border: Border.all(color: AppColors.borderDefault),
        ),
        textStyle: AppTextStyles.mono(size: 10, color: AppColors.textPrimary),
        child: item,
      );
    }

    return item;
  }
}
