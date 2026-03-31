import 'dart:async';
import 'package:flutter/material.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class UploadModal extends StatefulWidget {
  const UploadModal({super.key});

  @override
  State<UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends State<UploadModal> {
  bool _showProgress = false;
  String _assetName = "";
  String _selectedCategory = "HIGHLIGHT";
  String _selectedDistribution = "Partner: StreamMax India";
  
  // Progress state
  int _currentStep = 0; // 0 to 5
  final List<String> _steps = [
    "UPLOADING TO SECURE STORAGE",
    "INJECTING C2PA MANIFEST + AES-256 WATERMARK",
    "EXTRACTING FRAMES VIA FFMPEG (1 FPS)",
    "GENERATING AI VECTOR EMBEDDINGS (CLIP)",
    "WRITING TO FIRESTORE VAULT",
  ];

  void _startUpload() async {
    setState(() {
      _showProgress = true;
      _currentStep = 1;
    });

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _currentStep = 2);

    await Future.delayed(const Duration(milliseconds: 2000));
    if (!mounted) return;
    setState(() => _currentStep = 3);

    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;
    setState(() => _currentStep = 4);

    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    setState(() => _currentStep = 5);

    await Future.delayed(const Duration(milliseconds: 1000));
    if (!mounted) return;
    setState(() => _currentStep = 6); // Success state
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
      child: Container(
        width: 560,
        decoration: BoxDecoration(
          color: AppColors.bgSecondary,
          border: Border.all(color: AppColors.borderDefault),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // HEADER
            _ModalHeader(onClose: () => Navigator.pop(context)),
            
            // BODY
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: _showProgress ? _buildProgressView() : _buildFormView(),
            ),
            
            // FOOTER (Only in form view)
            if (!_showProgress)
              _ModalFooter(
                onCancel: () => Navigator.pop(context),
                onStart: _startUpload,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormView() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // DRAG & DROP ZONE
        GestureDetector(
          onTap: () {
            // TODO: WIRE FILE PICKER
          },
          child: CustomPaint(
            painter: DashedBorderPainter(color: AppColors.accentBlue.withAlpha(102)),
            child: Container(
              height: 140,
              width: double.infinity,
              color: AppColors.bgTertiary,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(PhosphorIcons.cloudArrowUp(), size: 32, color: AppColors.accentBlue),
                    const SizedBox(height: 10),
                    Text(
                      "DRAG VIDEO FILE HERE",
                      style: AppTextStyles.mono(
                        size: 13,
                        weight: FontWeight.w600,
                        color: AppColors.textPrimary,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "or click to browse — MP4, MOV, AVI",
                      style: AppTextStyles.sans(size: 11, color: AppColors.textMuted),
                    ),
                    const SizedBox(height: 10),
                    _MiniChip(label: "MAX FILE SIZE: 50GB", color: AppColors.textMuted),
                  ],
                ),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 20),
        
        Text("ASSET NAME", style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        TextFormField(
          style: AppTextStyles.mono(size: 13, color: AppColors.textPrimary),
          onChanged: (v) => _assetName = v,
          decoration: _inputDecoration("e.g. IPL 2025 — MI vs CSK Highlights"),
        ),
        
        const SizedBox(height: 16),
        
        Text("ASSET CATEGORY", style: AppTextStyles.sectionLabel),
        const SizedBox(height: 8),
        Row(
          children: [
            _CategoryChip(
              label: "HIGHLIGHT",
              isSelected: _selectedCategory == "HIGHLIGHT",
              onTap: () => setState(() => _selectedCategory = "HIGHLIGHT"),
            ),
            const SizedBox(width: 8),
            _CategoryChip(
              label: "PRESS CONF",
              isSelected: _selectedCategory == "PRESS_CONF",
              onTap: () => setState(() => _selectedCategory = "PRESS_CONF"),
            ),
            const SizedBox(width: 8),
            _CategoryChip(
              label: "TRAINING",
              isSelected: _selectedCategory == "TRAINING",
              onTap: () => setState(() => _selectedCategory = "TRAINING"),
            ),
            const SizedBox(width: 8),
            _CategoryChip(
              label: "PROMO",
              isSelected: _selectedCategory == "PROMO",
              onTap: () => setState(() => _selectedCategory = "PROMO"),
            ),
          ],
        ),
        
        const SizedBox(height: 16),
        
        Text("INTERNAL DISTRIBUTION TARGET", style: AppTextStyles.sectionLabel),
        const SizedBox(height: 4),
        Text(
          "⚠  This assignment creates a unique steganographic marker for forensic leak tracing",
          style: AppTextStyles.sans(size: 11, color: AppColors.accentCrimson),
        ),
        const SizedBox(height: 8),
        
        DropdownButtonFormField<String>(
          value: _selectedDistribution,
          dropdownColor: AppColors.bgSecondary,
          style: AppTextStyles.mono(size: 13, color: AppColors.textPrimary),
          decoration: _inputDecoration(""),
          items: [
            "Partner: StreamMax India",
            "Partner: DSport",
            "Partner: Sony LIV",
            "Broadcast: JioCinema",
            "Employee: R. Mehta (Video Lead)",
            "Employee: A. Kumar (Broadcast)",
          ].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
          onChanged: (v) => setState(() => _selectedDistribution = v!),
        ),
      ],
    );
  }

  Widget _buildProgressView() {
    if (_currentStep == 6) {
      return Column(
        children: [
          Icon(PhosphorIcons.shieldCheck(PhosphorIconsStyle.fill), size: 48, color: AppColors.accentGreen),
          const SizedBox(height: 12),
          Text(
            "ASSET VAULTED SUCCESSFULLY",
            style: AppTextStyles.mono(
              size: 16,
              weight: FontWeight.w700,
              color: AppColors.accentGreen,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Asset '$_assetName' vaulted successfully. Steganographic Patient Zero marker embedded. C2PA manifest signed.",
            style: AppTextStyles.sans(size: 12, color: AppColors.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accentAmber,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: () => Navigator.pop(context),
              child: Text("CLOSE", style: AppTextStyles.buttonLabel),
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "CRYPTOGRAPHIC PIPELINE ACTIVE",
          style: AppTextStyles.mono(
            size: 14,
            weight: FontWeight.w700,
            color: AppColors.accentAmber,
            letterSpacing: 1,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          "Do not close this window during processing",
          style: AppTextStyles.sans(size: 12, color: AppColors.textMuted),
        ),
        const SizedBox(height: 24),
        
        for (int i = 0; i < _steps.length; i++)
          _UploadStepRow(
            label: _steps[i],
            status: _getStepStatus(i + 1),
            distributionTarget: i == 1 ? _selectedDistribution : null,
          ),
      ],
    );
  }

  StepStatus _getStepStatus(int stepNum) {
    if (_currentStep > stepNum) return StepStatus.complete;
    if (_currentStep == stepNum) return StepStatus.active;
    return StepStatus.pending;
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: AppTextStyles.sans(size: 13, color: AppColors.textMuted),
      filled: true,
      fillColor: AppColors.bgTertiary,
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.borderDefault),
        borderRadius: BorderRadius.zero,
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: AppColors.accentBlue),
        borderRadius: BorderRadius.zero,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    );
  }
}

class _ModalHeader extends StatelessWidget {
  final VoidCallback onClose;
  const _ModalHeader({required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("INGEST NEW ASSET", style: AppTextStyles.mono(size: 16, weight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 4),
              Text(
                "Asset will be cryptographically watermarked and AI-vectorized",
                style: AppTextStyles.sans(size: 12, color: AppColors.textMuted),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: Icon(PhosphorIcons.x(), color: AppColors.textMuted),
            onPressed: onClose,
          ),
        ],
      ),
    );
  }
}

class _ModalFooter extends StatelessWidget {
  final VoidCallback onCancel;
  final VoidCallback onStart;

  const _ModalFooter({required this.onCancel, required this.onStart});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        border: Border(top: BorderSide(color: AppColors.borderDefault)),
      ),
      child: Row(
        children: [
          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.accentAmber),
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: onCancel,
            child: Text(
              "CANCEL",
              style: AppTextStyles.mono(size: 13, weight: FontWeight.w700, color: AppColors.accentAmber),
            ),
          ),
          const Spacer(),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.accentAmber,
              shape: const RoundedRectangleBorder(borderRadius: BorderRadius.zero),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
            ),
            onPressed: () {
              // TODO: CALL /process-asset BACKEND
              onStart();
            },
            child: Text("BEGIN CRYPTOGRAPHIC VAULTING  →", style: AppTextStyles.buttonLabel),
          ),
        ],
      ),
    );
  }
}

enum StepStatus { pending, active, complete }

class _UploadStepRow extends StatelessWidget {
  final String label;
  final StepStatus status;
  final String? distributionTarget;

  const _UploadStepRow({
    required this.label,
    required this.status,
    this.distributionTarget,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;
    switch (status) {
      case StepStatus.complete:
      case StepStatus.active:
        textColor = AppColors.textPrimary;
        break;
      case StepStatus.pending:
        textColor = AppColors.textMuted;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // INDICATOR
              Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: status == StepStatus.complete 
                      ? AppColors.accentGreen 
                      : (status == StepStatus.active ? AppColors.accentAmberDim : AppColors.bgTertiary),
                  border: Border.all(
                    color: status == StepStatus.active ? AppColors.accentAmber : AppColors.borderDefault,
                  ),
                ),
                child: status == StepStatus.complete
                    ? Icon(PhosphorIcons.check(), size: 12, color: AppColors.bgPrimary)
                    : (status == StepStatus.active 
                        ? const Center(child: SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: AppColors.accentAmber)))
                        : null),
              ),
              
              const SizedBox(width: 12),
              
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: AppTextStyles.mono(size: 12, weight: FontWeight.w600, color: textColor)),
                  if (status == StepStatus.active)
                    Text("Processing...", style: AppTextStyles.mono(size: 10, color: AppColors.accentAmber)),
                  if (status == StepStatus.complete)
                    Text("Done ✓", style: AppTextStyles.mono(size: 10, color: AppColors.accentGreen)),
                  if (status == StepStatus.pending)
                    Text("Queued", style: AppTextStyles.mono(size: 10, color: AppColors.textMuted)),
                ],
              ),
              
              const Spacer(),
              
              if (status == StepStatus.active)
                const SizedBox(
                  width: 100,
                  child: LinearProgressIndicator(
                    color: AppColors.accentAmber,
                    backgroundColor: AppColors.bgTertiary,
                    value: null,
                  ),
                ),
            ],
          ),
          if (status == StepStatus.complete && distributionTarget != null)
            Padding(
              padding: const EdgeInsets.only(left: 32, top: 4),
              child: Text(
                "Patient Zero marker assigned to: $distributionTarget",
                style: AppTextStyles.mono(size: 10, color: AppColors.accentCrimson),
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
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
          border: Border.all(color: isSelected ? AppColors.accentAmber : AppColors.borderDefault),
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

class _MiniChip extends StatelessWidget {
  final String label;
  final Color color;

  const _MiniChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withAlpha(26),
        border: Border.all(color: color.withAlpha(77)),
        borderRadius: BorderRadius.circular(2),
      ),
      child: Text(
        label,
        style: AppTextStyles.mono(size: 9, weight: FontWeight.w600, color: color),
      ),
    );
  }
}

class DashedBorderPainter extends CustomPainter {
  final Color color;
  DashedBorderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    const dashWidth = 8.0;
    const dashSpace = 4.0;
    
    final path = Path();
    // Re-calculating dash for each side to keep it simple
    
    // Top
    double x = 0;
    while (x < size.width) {
      path.moveTo(x, 0);
      path.lineTo(x + dashWidth, 0);
      x += dashWidth + dashSpace;
    }
    
    // Right
    double y = 0;
    while (y < size.height) {
      path.moveTo(size.width, y);
      path.lineTo(size.width, y + dashWidth);
      y += dashWidth + dashSpace;
    }
    
    // Bottom
    x = size.width;
    while (x > 0) {
      path.moveTo(x, size.height);
      path.lineTo(x - dashWidth, size.height);
      x -= dashWidth + dashSpace;
    }
    
    // Left
    y = size.height;
    while (y > 0) {
      path.moveTo(0, y);
      path.lineTo(0, y - dashWidth);
      y -= dashWidth + dashSpace;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
