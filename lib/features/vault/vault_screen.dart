import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/config/demo_config.dart';
import '../../core/widgets/section_header.dart';
import '../../core/widgets/scale_button.dart';
import '../../core/widgets/shimmer_box.dart';
import 'vault_mock_data.dart';
import 'widgets/asset_card.dart';
import 'widgets/upload_modal.dart';

class VaultScreen extends StatefulWidget {
  const VaultScreen({super.key});

  @override
  State<VaultScreen> createState() => _VaultScreenState();
}

class _VaultScreenState extends State<VaultScreen> {
  String _selectedFilter = "ALL";
  String _searchQuery = "";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _simulateLoading();
  }

  void _simulateLoading() async {
    await Future.delayed(const Duration(milliseconds: 1000));
    if (mounted) setState(() => _isLoading = false);
  }

  void _showUploadModal() {
    showDialog(
      context: context,
      barrierColor: Colors.black.withAlpha(178), // 0.7 opacity approx
      builder: (context) => const UploadModal(),
    );
  }

  @override
  Widget build(BuildContext context) {
    // DEMO MODE: using mock data. Set kDemoMode = false to use Firestore.
    final assets = kDemoMode ? VaultMockData.assets : <VaultedAsset>[]; 

    final filteredAssets = assets.where((asset) {
      final matchesFilter = _selectedFilter == "ALL" || asset.category == _selectedFilter;
      final matchesSearch = asset.name.toLowerCase().contains(_searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // HEADER
            SectionHeader(
              title: "ASSET VAULT",
              subtitle: "Cryptographically secured media repository — C2PA manifest + AES-256 steganographic watermarking",
              trailing: ScaleButton(
                onTap: _showUploadModal,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.accentAmber,
                    foregroundColor: AppColors.textOnAmber,
                    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                  ),
                  onPressed: () {}, // Handled by ScaleButton
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(PhosphorIcons.plus(), size: 14),
                      const SizedBox(width: 8),
                      Text("ADD ASSET", style: AppTextStyles.buttonLabel),
                    ],
                  ),
                ),
              ),
            ),

            // VAULT STATS STRIP
            Container(
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                border: Border.all(color: AppColors.borderDefault),
              ),
              margin: const EdgeInsets.only(bottom: 24),
              child: Row(
                children: [
                   Expanded(
                    child: _StatCell(
                      icon: PhosphorIcons.shieldCheck(),
                      color: AppColors.accentBlue,
                      value: "247",
                      label: "ASSETS VAULTED",
                    ),
                  ),
                  const _VerticalDivider(),
                  Expanded(
                    child: _StatCell(
                      icon: PhosphorIcons.database(),
                      color: AppColors.accentAmber,
                      value: "2.4 TB",
                      label: "STORAGE USED",
                    ),
                  ),
                  const _VerticalDivider(),
                  Expanded(
                    child: _StatCell(
                      icon: PhosphorIcons.checkCircle(),
                      color: AppColors.accentGreen,
                      value: "100%",
                      label: "C2PA INTEGRITY",
                    ),
                  ),
                ],
              ),
            ),

            // FILTER + SEARCH BAR
            Row(
              children: [
                Expanded(
                  flex: 5,
                  child: TextFormField(
                    style: AppTextStyles.mono(size: 13, color: AppColors.textPrimary),
                    onChanged: (v) => setState(() => _searchQuery = v),
                    decoration: InputDecoration(
                      hintText: "SEARCH VAULT BY ASSET NAME OR TAG...",
                      hintStyle: AppTextStyles.mono(size: 11, color: AppColors.textMuted),
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Icon(PhosphorIcons.magnifyingGlass(), size: 16, color: AppColors.textMuted),
                      ),
                      filled: true,
                      fillColor: AppColors.bgTertiary,
                      border: const OutlineInputBorder(
                        borderSide: BorderSide(color: AppColors.borderDefault),
                        borderRadius: BorderRadius.zero,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 7,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _FilterChip(
                          label: "ALL",
                          isSelected: _selectedFilter == "ALL",
                          onTap: () => setState(() => _selectedFilter = "ALL"),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "HIGHLIGHT",
                          isSelected: _selectedFilter == "HIGHLIGHT",
                          onTap: () => setState(() => _selectedFilter = "HIGHLIGHT"),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "PRESS CONF",
                          isSelected: _selectedFilter == "PRESS_CONF",
                          onTap: () => setState(() => _selectedFilter = "PRESS_CONF"),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "TRAINING",
                          isSelected: _selectedFilter == "TRAINING",
                          onTap: () => setState(() => _selectedFilter = "TRAINING"),
                        ),
                        const SizedBox(width: 8),
                        _FilterChip(
                          label: "PROMO",
                          isSelected: _selectedFilter == "PROMO",
                          onTap: () => setState(() => _selectedFilter = "PROMO"),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ASSET GRID
            LayoutBuilder(
              builder: (context, constraints) {
                if (_isLoading) {
                  final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: crossAxisCount,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 0.78,
                    ),
                    itemCount: 6,
                    itemBuilder: (context, index) => const ShimmerBox(height: 300, width: double.infinity),
                  );
                }

                if (filteredAssets.isEmpty) {
                  return Container(
                    height: 400,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.borderDefault, style: BorderStyle.none),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(PhosphorIcons.folderOpen(), size: 48, color: AppColors.textMuted.withAlpha(51)),
                          const SizedBox(height: 16),
                          Text(
                            "NO ASSETS FOUND",
                            style: AppTextStyles.mono(size: 14, weight: FontWeight.w600, color: AppColors.textMuted),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            "Try adjusting your filters or search query.",
                            style: AppTextStyles.caption,
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final crossAxisCount = constraints.maxWidth > 1200 ? 3 : 2;
                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.78,
                  ),
                  itemCount: filteredAssets.length,
                  itemBuilder: (context, index) {
                    return AssetCard(asset: filteredAssets[index]);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCell extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String value;
  final String label;

  const _StatCell({
    required this.icon,
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Row(
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTextStyles.mono(size: 20, weight: FontWeight.w700, color: AppColors.textPrimary),
              ),
              Text(
                label,
                style: AppTextStyles.mono(size: 10, color: AppColors.textMuted, letterSpacing: 2),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _VerticalDivider extends StatelessWidget {
  const _VerticalDivider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 40,
      color: AppColors.borderDefault,
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.accentAmber : Colors.transparent,
          border: Border.all(
            color: isSelected ? AppColors.accentAmber : AppColors.borderDefault,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.mono(
            size: 11,
            weight: FontWeight.w600,
            color: isSelected ? AppColors.textOnAmber : AppColors.textSecondary,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
