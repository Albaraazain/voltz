import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/colors.dart';
import '../../../providers/electrician_stats_provider.dart';
import 'package:intl/intl.dart';

class EarningsChart extends StatelessWidget {
  const EarningsChart({super.key});

  String _getTitle(int value, String period) {
    final now = DateTime.now();
    switch (period) {
      case 'week':
        final weekday = DateFormat('E').format(
          now
              .subtract(Duration(days: now.weekday - 1))
              .add(Duration(days: value)),
        );
        return weekday.substring(0, 3);
      case 'month':
        return 'Week ${value + 1}';
      case 'year':
        return DateFormat('MMM').format(DateTime(now.year, value + 1));
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ElectricianStatsProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!provider.stats.hasData || provider.stats.data == null) {
          return const Center(child: Text('No data available'));
        }

        final stats = provider.stats.data!;
        final period = provider.selectedPeriod;

        // Calculate maxY with a minimum value of 100
        final maxY = stats.earningsData.isEmpty
            ? 100.0
            : (stats.earningsData
                    .map((e) => e.value)
                    .reduce((max, value) => value > max ? value : max)) *
                1.2;
        final adjustedMaxY = maxY < 100 ? 100.0 : maxY;

        // Ensure interval is never zero by using a minimum value
        final horizontalInterval =
            (adjustedMaxY / 4).clamp(25.0, double.infinity);

        return LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              horizontalInterval: horizontalInterval,
              verticalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                );
              },
              getDrawingVerticalLine: (value) {
                return FlLine(
                  color: AppColors.border,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              rightTitles:
                  AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 ||
                        value.toInt() >= stats.earningsData.length) {
                      return const Text('');
                    }
                    return Text(
                      _getTitle(value.toInt(), period),
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: horizontalInterval,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      '\$${value.toInt()}',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    );
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            minX: 0,
            maxX: stats.earningsData.length - 1.0,
            minY: 0,
            maxY: adjustedMaxY,
            lineBarsData: [
              LineChartBarData(
                spots: List.generate(
                  stats.earningsData.length,
                  (index) => FlSpot(
                    index.toDouble(),
                    stats.earningsData[index].value,
                  ),
                ),
                isCurved: true,
                color: AppColors.accent,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: AppColors.accent,
                      strokeWidth: 2,
                      strokeColor: AppColors.surface,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
