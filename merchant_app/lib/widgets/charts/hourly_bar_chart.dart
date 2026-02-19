import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';

/// Hourly Bar Chart Widget
/// Shows revenue distribution by hour of day
class HourlyBarChart extends StatelessWidget {
  final Map<int, double> hourlyData; // {hour: revenue}
  final int peakHour;

  const HourlyBarChart({
    super.key,
    required this.hourlyData,
    required this.peakHour,
  });

  @override
  Widget build(BuildContext context) {
    if (hourlyData.isEmpty) {
      return const Center(child: Text('No hourly data'));
    }

    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: _getMaxY(),
        barTouchData: BarTouchData(
          touchTooltipData: BarTouchTooltipData(
            tooltipBgColor: AppColors.primaryTeal,
            tooltipRoundedRadius: 8,
            getTooltipItem: (group, groupIndex, rod, rodIndex) {
              final hour = group.x.toInt();
              return BarTooltipItem(
                '${_formatHour(hour)}\n₹${rod.toY.toStringAsFixed(0)}',
                AppTypography.bodySmall.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
        ),
        titlesData: FlTitlesData(
          show: true,
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final hour = value.toInt();
                // Show every 4 hours
                if (hour % 4 != 0) {
                  return const SizedBox();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    _formatHour(hour),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
              reservedSize: 30,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              getTitlesWidget: (value, meta) {
                return Text(
                  _formatCurrency(value),
                  style: AppTypography.bodySmall.copyWith(
                    color: AppColors.neutral600,
                    fontSize: 10,
                  ),
                );
              },
            ),
          ),
        ),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _getMaxY() / 4,
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.neutral300,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
        ),
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.neutral300, width: 1),
            left: BorderSide(color: AppColors.neutral300, width: 1),
          ),
        ),
        barGroups: _buildBarGroups(),
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return hourlyData.entries.map((entry) {
      final hour = entry.key;
      final revenue = entry.value;
      final isPeak = hour == peakHour;

      return BarChartGroupData(
        x: hour,
        barRods: [
          BarChartRodData(
            toY: revenue,
            gradient: isPeak
                ? AppColors.goldGradient
                : LinearGradient(
                    colors: [
                      AppColors.primaryTeal,
                      AppColors.primaryTeal.withOpacity(0.7),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  ),
            width: 8,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
          ),
        ],
      );
    }).toList();
  }

  double _getMaxY() {
    if (hourlyData.isEmpty) return 100;
    final max = hourlyData.values.reduce((a, b) => a > b ? a : b);
    return max * 1.2; // 20% padding
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12AM';
    if (hour < 12) return '${hour}AM';
    if (hour == 12) return '12PM';
    return '${hour - 12}PM';
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
