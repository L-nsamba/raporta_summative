
import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/daily_report_count.dart';

class WeeklyReportsChart extends StatelessWidget {
  final List<DailyReportCount> weeklyReports;

  const WeeklyReportsChart({
    super.key,
    required this.weeklyReports,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Handle an unexpectedly empty list.
    if (weeklyReports.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Center(
            child: Text('No weekly report data available.'),
          ),
        ),
      );
    }

    // Keep the days in chronological order.
    final reports = [...weeklyReports]
      ..sort((a, b) => a.date.compareTo(b.date));

    // Find the highest report count.
    final maxCount = reports.fold<int>(
      0,
      (highest, day) => math.max(highest, day.count),
    );

    // Ensure that the chart has a usable vertical scale,
    // even when all report counts are zero.
    final maxY = math.max(1, maxCount + 1).toDouble();

    final yInterval = math.max(1, (maxY / 4).ceil()).toDouble();

    const weekdayLabels = [
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun',
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Weekly Reports',
              style: theme.textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text(
              'Reports submitted this week',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),

            LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SizedBox(
                    width: math.max(
                      constraints.maxWidth,
                      320.0,
                    ),
                    height: 230,
                    child: BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: maxY,
                        alignment: BarChartAlignment.spaceAround,

                        // Horizontal grid lines.
                        gridData: FlGridData(
                          show: true,
                          drawVerticalLine: false,
                          horizontalInterval: yInterval,
                        ),

                        borderData: FlBorderData(
                          show: false,
                        ),

                        // Axis labels.
                        titlesData: FlTitlesData(
                          topTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          rightTitles: const AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: false,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 36,
                              interval: yInterval,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 32,
                              getTitlesWidget: (value, meta) {
                                final index = value.toInt();

                                if (index < 0 ||
                                    index >= reports.length ||
                                    value != index.toDouble()) {
                                  return const SizedBox.shrink();
                                }

                                final weekday =
                                    reports[index].date.weekday;

                                return SideTitleWidget(
                                  meta: meta,
                                  child: Text(
                                    weekdayLabels[weekday - 1],
                                    style: theme.textTheme.labelSmall,
                                  ),
                                );
                              },
                            ),
                          ),
                        ),

                        // Generate one bar per day using actual data.
                        barGroups: List.generate(
                          reports.length,
                          (index) {
                            final day = reports[index];

                            return BarChartGroupData(
                              x: index,
                              barRods: [
                                BarChartRodData(
                                  toY: day.count.toDouble(),
                                  width: 18,
                                  color: colorScheme.primary,
                                  borderRadius:
                                      const BorderRadius.vertical(
                                    top: Radius.circular(5),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
