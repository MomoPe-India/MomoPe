import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';

enum ViewMode { list, map }

/// Toggle widget to switch between Map and List views
class ViewToggle extends StatelessWidget {
  final ViewMode currentMode;
  final ValueChanged<ViewMode> onModeChanged;

  const ViewToggle({
    super.key,
    required this.currentMode,
    required this.onModeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: AppColors.neutral100,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              icon: Icons.list_rounded,
              label: 'List',
              mode: ViewMode.list,
              isSelected: currentMode == ViewMode.list,
            ),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: _buildToggleButton(
              icon: Icons.map_rounded,
              label: 'Map',
              mode: ViewMode.map,
              isSelected: currentMode == ViewMode.map,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required IconData icon,
    required String label,
    required ViewMode mode,
    required bool isSelected,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => onModeChanged(mode),
        borderRadius: BorderRadius.circular(8),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primaryTeal
                    : AppColors.neutral600,
                size: 20,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: AppTypography.labelLarge.copyWith(
                  color: isSelected
                      ? AppColors.primaryTeal
                      : AppColors.neutral600,
                  fontWeight:
                      isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
