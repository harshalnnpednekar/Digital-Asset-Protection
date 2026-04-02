import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_theme_colors.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/scale_button.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  int _activeCategory = 0;

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Workspace', 'icon': PhosphorIcons.briefcase()},
    {'title': 'Protection', 'icon': PhosphorIcons.shieldCheck()},
    {'title': 'API & Webhooks', 'icon': PhosphorIcons.code()},
    {'title': 'Notifications', 'icon': PhosphorIcons.bell()},
    {'title': 'Billing', 'icon': PhosphorIcons.creditCard()},
  ];

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionHeader(
              title: "General Settings",
              subtitle: "Manage your organization's workspace and security configurations.",
            ),
            const SizedBox(height: 32),
            Expanded(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // SIDE NAV
                  SizedBox(
                    width: 240,
                    child: Column(
                      children: List.generate(_categories.length, (index) {
                        final cat = _categories[index];
                        final isSelected = _activeCategory == index;
                        return _SidebarItem(
                          title: cat['title'],
                          icon: cat['icon'],
                          isSelected: isSelected,
                          onTap: () => setState(() => _activeCategory = index),
                        );
                      }),
                    ),
                  ),

                  const SizedBox(width: 48),

                  // CONTENT AREA
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(40),
                      decoration: BoxDecoration(
                        color: c.bgSecondary,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: c.borderDefault),
                        boxShadow: c.isDark ? [] : [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.03),
                            blurRadius: 30,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: _buildActiveCategory(c),
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
  }

  Widget _buildActiveCategory(AppThemeColors c) {
    switch (_activeCategory) {
      case 0: return _WorkspaceSettings(c: c);
      case 1: return _ProtectionSettings(c: c);
      case 2: return _ApiSettings(c: c);
      default:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(PhosphorIcons.gearSix(), size: 48, color: c.textMuted.withOpacity(0.3)),
              const SizedBox(height: 16),
              Text("Additional Configuration", style: AppTextStyles.sectionHeading.copyWith(color: c.textMuted)),
              const SizedBox(height: 8),
              Text("This module is currently unavailable for your account.", 
                   style: AppTextStyles.body(size: 14, color: c.textMuted)),
            ],
          ),
        );
    }
  }
}

class _SidebarItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: ScaleButton(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? c.accentBlue.withOpacity(c.isDark ? 0.15 : 0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? c.accentBlue.withOpacity(0.3) : Colors.transparent,
            ),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: isSelected ? c.accentBlue : c.textMuted),
              const SizedBox(width: 12),
              Text(
                title,
                style: AppTextStyles.navLabel.copyWith(
                  color: isSelected ? c.textPrimary : c.textMuted,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WorkspaceSettings extends StatelessWidget {
  final AppThemeColors c;
  const _WorkspaceSettings({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: "Workspace Identity", c: c),
        const SizedBox(height: 32),
        _SettingsRow(
          label: "Workspace Name",
          child: _SettingsInput(hint: "Sentinel Media Protection Ltd."),
        ),
        _SettingsRow(
          label: "Administrator Email",
          child: _SettingsInput(hint: "admin@sentinel-ai.com"),
        ),
        _SettingsRow(
          label: "Cloud Integration Region",
          child: _SettingsDropdown(items: ["India (Mumbai)", "US East (Virginia)", "EU West (Dublin)"]),
        ),
        const Spacer(),
        _SaveBar(c: c),
      ],
    );
  }
}

class _ProtectionSettings extends StatelessWidget {
  final AppThemeColors c;
  const _ProtectionSettings({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: "Standard Protection Rules", c: c),
        const SizedBox(height: 32),
        _SettingsRow(
          label: "Detection Confidence",
          description: "Minimum similarity required for automatic flagging.",
          child: Slider(value: 0.85, onChanged: (_) {}, activeColor: c.accentBlue),
        ),
        _SettingsToggle(
          label: "Background DMCA Filing",
          description: "Automatically file requests when confidence exceeds 98%.",
          value: true,
        ),
        _SettingsToggle(
          label: "Platform Alerts",
          description: "Notify social platforms of detected account anomalies.",
          value: false,
        ),
        const Spacer(),
        _SaveBar(c: c),
      ],
    );
  }
}

class _ApiSettings extends StatelessWidget {
  final AppThemeColors c;
  const _ApiSettings({required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionTitle(title: "Credential Management", c: c),
        const SizedBox(height: 32),
        _SettingsRow(
          label: "AI Engine API Key",
          child: _SettingsInput(hint: "sk-••••••••••••••••••••••••", isPassword: true),
        ),
        _SettingsRow(
          label: "Event Endpoint URL",
          child: _SettingsInput(hint: "https://api.sentinel-ai.com/v1/webhooks"),
        ),
        const SizedBox(height: 48),
        _SectionTitle(title: "System Status", c: c),
        const SizedBox(height: 24),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: c.bgPrimary,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.borderDefault),
          ),
          child: Row(
            children: [
              Icon(PhosphorIcons.checkCircle(PhosphorIconsStyle.fill), color: AppColors.accentGreen, size: 24),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Platform Synchronization", style: AppTextStyles.cardTitle),
                  Text("Real-time sync active with 14ms average latency", style: AppTextStyles.body(size: 13, color: c.textSecondary)),
                ],
              ),
            ],
          ),
        ),
        const Spacer(),
        _SaveBar(c: c),
      ],
    );
  }
}

// SHARED COMPONENTS
class _SectionTitle extends StatelessWidget {
  final String title;
  final AppThemeColors c;
  const _SectionTitle({required this.title, required this.c});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: AppTextStyles.sectionHeading.copyWith(color: AppColors.accentAmber)),
        const SizedBox(height: 8),
        Container(width: 40, height: 2, color: AppColors.accentAmber.withOpacity(0.4)),
      ],
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final String label;
  final String? description;
  final Widget child;

  const _SettingsRow({required this.label, this.description, required this.child});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body(size: 15, weight: FontWeight.w600, color: c.textPrimary)),
                if (description != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(description!, style: AppTextStyles.body(size: 13, color: c.textSecondary)),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 32),
          Expanded(flex: 3, child: child),
        ],
      ),
    );
  }
}

class _SettingsToggle extends StatelessWidget {
  final String label;
  final String description;
  final bool value;

  const _SettingsToggle({required this.label, required this.description, required this.value});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: 28),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTextStyles.body(size: 15, weight: FontWeight.w600, color: c.textPrimary)),
                Text(description, style: AppTextStyles.body(size: 13, color: c.textSecondary)),
              ],
            ),
          ),
          Switch(
            value: value, 
            onChanged: (_) {},
            activeColor: AppColors.accentAmber,
          ),
        ],
      ),
    );
  }
}

class _SettingsInput extends StatelessWidget {
  final String hint;
  final bool isPassword;
  const _SettingsInput({required this.hint, this.isPassword = false});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return TextField(
      obscureText: isPassword,
      cursorColor: AppColors.accentAmber,
      style: AppTextStyles.body(size: 14, color: c.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: AppTextStyles.body(size: 14, color: c.textMuted),
        filled: true,
        fillColor: c.bgPrimary,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide(color: c.borderDefault)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: const BorderSide(color: AppColors.accentAmber)),
      ),
    );
  }
}

class _SettingsDropdown extends StatelessWidget {
  final List<String> items;
  const _SettingsDropdown({required this.items});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: c.bgPrimary,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: c.borderDefault),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: items[0],
          isExpanded: true,
          dropdownColor: c.bgSecondary,
          items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: AppTextStyles.body(size: 14)))).toList(),
          onChanged: (_) {},
        ),
      ),
    );
  }
}

class _SaveBar extends StatelessWidget {
  final AppThemeColors c;
  const _SaveBar({required this.c});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: c.bgPrimary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.borderDefault),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () {},
            child: Text("Reset to default", style: AppTextStyles.buttonLabel.copyWith(color: c.textMuted)),
          ),
          const SizedBox(width: 16),
          ScaleButton(
            onTap: () {},
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: c.accentBlue,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {},
              child: Text("Save Changes", style: AppTextStyles.buttonLabel.copyWith(color: Colors.white)),
            ),
          ),
        ],
      ),
    );
  }
}
