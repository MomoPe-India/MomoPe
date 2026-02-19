import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/performance_metrics.dart';

/// Payment Method Pie Chart
/// Shows distribution between cash and coin payments
class PaymentPieChart extends StatefulWidget {
  final PerformanceMetrics metrics;

  const PaymentPieChart({super.key, required this.metrics});

  @override
  State<PaymentPieChart> createState() => _PaymentPieChartState();
}

class _PaymentPieChartState extends State<PaymentPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    if (widget.metrics.paymentMethodBreakdown.isEmpty) {
      return const Center(child: Text('No payment data'));
    }

    return Row(
      children: [
        // Pie Chart
        Expanded(
          flex: 3,
          child: PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {
                  setState(() {
                    if (!event.isInterestedForInteractions ||
                        pieTouchResponse == null ||
                        pieTouchResponse.touchedSection == null) {
                      touchedIndex = -1;
                      return;
                    }
                    touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                  });
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 2,
              centerSpaceRadius: 50,
              sections: _buildSections(),
            ),
          ),
        ),

        // Legend
        Expanded(
          flex: 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildLegendItem('Cash', widget.metrics.cashPercentage, AppColors.primaryTeal),
              const SizedBox(height: 12),
              _buildLegendItem('Coins', widget.metrics.coinsPercentage, AppColors.rewardsGold),
            ],
          ),
        ),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final sections = <PieChartSectionData>[];

    // Cash section
    if (widget.metrics.cashPercentage > 0) {
      sections.add(
        PieChartSectionData(
          color: AppColors.primaryTeal,
          value: widget.metrics.cashPercentage,
          title: '${widget.metrics.cashPercentage.toStringAsFixed(0)}%',
          radius: touchedIndex == 0 ? 65 : 55,
          titleStyle: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: touchedIndex == 0 ? 16 : 14,
          ),
        ),
      );
    }

    // Coins section
    if (widget.metrics.coinsPercentage > 0) {
      sections.add(
        PieChartSectionData(
          color: AppColors.rewardsGold,
          value: widget.metrics.coinsPercentage,
          title: '${widget.metrics.coinsPercentage.toStringAsFixed(0)}%',
          radius: touchedIndex == 1 ? 65 : 55,
          titleStyle: AppTypography.bodyMedium.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: touchedIndex == 1 ? 16 : 14,
          ),
        ),
      );
    }

    return sections;
  }

  Widget _buildLegendItem(String label, double percentage, Color color) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral700,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: AppTypography.bodySmall.copyWith(
                  color: AppColors.neutral600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
