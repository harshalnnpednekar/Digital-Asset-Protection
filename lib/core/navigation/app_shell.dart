import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/sentinel_logo.dart';
import 'app_router.dart';

class AppShell extends StatelessWidget {
  final Widget child;

  const AppShell({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Row(
        children: [
          _buildSidebar(context),
          const VerticalDivider(width: 1, color: AppColors.borderDefault),
          Expanded(child: child),
        ],
      ),
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Container(
      width: 220,
      color: AppColors.bgSecondary,
      child: Column(
        children: [
          // TOP SECTION
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 24, 20, 20),
            child: SentinelLogo(),
          ),
          const SizedBox(height: 12),
          const Divider(color: AppColors.borderDefault, height: 1),
          
          // NAV ITEMS SECTION
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              children: [
                _NavItem(
                  icon: PhosphorIcons.chartBar(),
                  label: "Dashboard",
                  route: '/dashboard',
                ),
                _NavItem(
                  icon: PhosphorIcons.shieldCheck(),
                  label: "Asset Vault",
                  route: '/vault',
                ),
                _NavItem(
                  icon: PhosphorIcons.waveform(),
                  label: "Threat Radar",
                  route: '/threats',
                ),
                _NavItem(
                  icon: PhosphorIcons.gitBranch(),
                  label: "Contagion Map",
                  route: '/contagion',
                ),
              ],
            ),
          ),
          
          // BOTTOM SECTION
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Divider(color: AppColors.borderDefault, height: 1),
                const SizedBox(height: 12),
                _NavItem(
                  icon: PhosphorIcons.gear(),
                  label: "Settings",
                  route: '/settings',
                ),
                const SizedBox(height: 16),
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

  const _NavItem({
    required this.icon,
    required this.label,
    required this.route,
  });

  @override
  State<_NavItem> createState() => _NavItemState();
}

class _NavItemState extends State<_NavItem> {
  bool _isHovering = false;

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final isSelected = location.startsWith(widget.route);

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => context.go(widget.route),
        child: AnimatedContainer(
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
              children: [
                Icon(
                  widget.icon,
                  size: 16,
                  color: isSelected ? AppColors.accentAmber : (_isHovering ? AppColors.textSecondary : AppColors.textMuted),
                ),
                const SizedBox(width: 10),
                Text(
                  widget.label,
                  style: AppTextStyles.navLabel.copyWith(
                    color: isSelected ? AppColors.accentAmber : (_isHovering ? AppColors.textPrimary : AppColors.textSecondary),
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
