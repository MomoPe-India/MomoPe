import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_typography.dart';
import '../../models/revenue_trend.dart';

/// Revenue Line Chart Widget
/// Shows daily revenue trend with gradient fill
class RevenueLineChart extends StatelessWidget {
  final RevenueTrend trend;

  const RevenueLineChart({super.key, required this.trend});

  @override
  Widget build(BuildContext context) {
    if (trend.dailyValues.isEmpty) {
      return const Center(child: Text('No data'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          horizontalInterval: _calculateInterval(trend.maxValue),
          getDrawingHorizontalLine: (value) {
            return FlLine(
              color: AppColors.neutral300,
              strokeWidth: 1,
              dashArray: [5, 5],
            );
          },
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
              reservedSize: 30,
              interval: _getBottomInterval(),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= trend.labels.length) {
                  return const SizedBox();
                }

                // Show every nth label to avoid crowding
                final showEvery = trend.labels.length > 14 ? 7 : trend.labels.length > 7 ? 3 : 2;
                if (index % showEvery != 0 && index != trend.labels.length - 1) {
                  return const SizedBox();
                }

                final date = DateTime.parse(trend.labels[index]);
                return Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    DateFormat('MM/dd').format(date),
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.neutral600,
                      fontSize: 10,
                    ),
                  ),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 45,
              interval: _calculateInterval(trend.maxValue),
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
        borderData: FlBorderData(
          show: true,
          border: Border(
            bottom: BorderSide(color: AppColors.neutral300, width: 1),
            left: BorderSide(color: AppColors.neutral300, width: 1),
          ),
        ),
        minX: 0,
        maxX: (trend.dailyValues.length - 1).toDouble(),
        minY: 0,
        maxY: trend.maxValue * 1.2, // 20% padding on top
        lineBarsData: [
          LineChartBarData(
            spots: trend.dailyValues
                .asMap()
                .entries
                .map((e) => FlSpot(e.key.toDouble(), e.value))
                .toList(),
            isCurved: true,
            gradient: AppColors.primaryGradient,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                return FlDotCirclePainter(
                  radius: 4,
                  color: Colors.white,
                  strokeWidth: 2,
                  strokeColor: AppColors.primaryTeal,
                );
              },
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                colors: [
                  AppColors.primaryTeal.withOpacity(0.3),
                  AppColors.primaryTeal.withOpacity(0.05),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
        ],
        lineTouchData: LineTouchData(
          touchTooltipData: LineTouchTooltipData(
            tooltipBgColor: AppColors.primaryTeal,
            tooltipRoundedRadius: 8,
            getTooltipItems: (touchedSpots) {
              return touchedSpots.map((spot) {
                final date = DateTime.parse(trend.labels[spot.x.toInt()]);
                return LineTooltipItem(
                  '${DateFormat('MMM dd').format(date)}\n₹${spot.y.toStringAsFixed(0)}',
                  AppTypography.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                );
              }).toList();
            },
          ),
        ),
      ),
    );
  }

  double _calculateInterval(double maxValue) {
    if (maxValue <= 0) return 100;
    if (maxValue <= 500) return 100;
    if (maxValue <= 1000) return 200;
    if (maxValue <= 5000) return 1000;
    if (maxValue <= 10000) return 2000;
    return 5000;
  }

  double _getBottomInterval() {
    return 1; // Show every day but filter in getTitlesWidget
  }

  String _formatCurrency(double value) {
    if (value >= 1000) {
      return '${(value / 1000).toStringAsFixed(0)}k';
    }
    return value.toStringAsFixed(0);
  }
}
