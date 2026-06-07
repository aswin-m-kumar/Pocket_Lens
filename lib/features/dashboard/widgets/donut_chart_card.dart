import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class DonutChartCard extends StatefulWidget {
  final Map<String, double> breakdown;
  final double totalExpense;

  const DonutChartCard({
    super.key,
    required this.breakdown,
    required this.totalExpense,
  });

  @override
  State<DonutChartCard> createState() => _DonutChartCardState();
}

class _DonutChartCardState extends State<DonutChartCard> {
  int _touchedIndex = -1;

  Color _getCategoryColor(String cat) {
    switch (cat) {
      case 'Food & Snacks':
        return kCatFood;
      case 'Entertainment':
        return kCatEntertain;
      case 'Travel':
        return kCatTravel;
      case 'Fixed Expense':
        return kCatFixed;
      case 'Miscellaneous':
      default:
        return kCatMisc;
    }
  }

  String _getShortName(String category) {
    switch (category) {
      case 'Food & Snacks':
        return 'Food';
      case 'Entertainment':
        return 'Entertain';
      case 'Travel':
        return 'Travel';
      case 'Fixed Expense':
        return 'Fixed';
      case 'Miscellaneous':
        return 'Misc';
      default:
        return category;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories = <String>[
      'Food & Snacks',
      'Entertainment',
      'Travel',
      'Miscellaneous',
      'Fixed Expense',
    ];
    final List<String> activeCats = categories.where((String cat) {
      return (widget.breakdown[cat] ?? 0.0) > 0.0;
    }).toList();

    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          const Text(
            'Spending Breakdown',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 20),

          // Chart + Center text stack
          SizedBox(
            height: 180,
            child: Stack(
              children: <Widget>[
                PieChart(
                  PieChartData(
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, PieTouchResponse? pieTouchResponse) {
                        setState(() {
                          if (!event.isInterestedForInteractions ||
                              pieTouchResponse == null ||
                              pieTouchResponse.touchedSection == null) {
                            _touchedIndex = -1;
                            return;
                          }
                          _touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                        });
                      },
                    ),
                    borderData: FlBorderData(show: false),
                    sectionsSpace: 2,
                    centerSpaceRadius: 62,
                    sections: _buildSections(activeCats),
                  ),
                ),

                // Center Text Display
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: _buildCenterText(activeCats),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  List<Widget> _buildCenterText(List<String> activeCats) {
    if (widget.totalExpense <= 0.0) {
      return <Widget>[
        const Text(
          'Total Spent',
          style: TextStyle(
            color: kTextSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 2),
        const Text(
          '₹0',
          style: TextStyle(
            color: kTextPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ];
    }

    final bool isAnySectionTouched = _touchedIndex >= 0 && _touchedIndex < activeCats.length;

    if (isAnySectionTouched) {
      final String cat = activeCats[_touchedIndex];
      final double amt = widget.breakdown[cat] ?? 0.0;
      final double pct = (amt / widget.totalExpense) * 100;

      return <Widget>[
        Text(
          _getShortName(cat),
          style: TextStyle(
            color: _getCategoryColor(cat),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '${pct.toStringAsFixed(0)}%',
          style: const TextStyle(
            color: kTextPrimary,
            fontSize: 22,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
          ),
        ),
      ];
    }

    // Default Overall spent center text
    return <Widget>[
      const Text(
        'Total Spent',
        style: TextStyle(
          color: kTextSecondary,
          fontSize: 11,
          fontWeight: FontWeight.w400,
        ),
      ),
      const SizedBox(height: 2),
      Text(
        CurrencyFormatter.format(widget.totalExpense),
        style: const TextStyle(
          color: kTextPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
    ];
  }

  List<PieChartSectionData> _buildSections(List<String> activeCats) {
    if (widget.totalExpense <= 0.0) {
      return <PieChartSectionData>[
        PieChartSectionData(
          color: kBorderSubtle,
          value: 1,
          radius: 12,
          showTitle: false,
        ),
      ];
    }

    return List<PieChartSectionData>.generate(activeCats.length, (int index) {
      final String cat = activeCats[index];
      final double amt = widget.breakdown[cat] ?? 0.0;
      final bool isTouched = index == _touchedIndex;
      final double radius = isTouched ? 16.0 : 12.0;

      return PieChartSectionData(
        color: _getCategoryColor(cat),
        value: amt,
        radius: radius,
        showTitle: false,
      );
    });
  }

  Widget _buildLegend() {
    final List<String> categories = <String>[
      'Food & Snacks',
      'Entertainment',
      'Travel',
      'Miscellaneous',
      'Fixed Expense',
    ];
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: categories.map((String cat) {
        final double amt = widget.breakdown[cat] ?? 0.0;
        final Color color = _getCategoryColor(cat);
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: amt > 0.0 ? color : color.withValues(alpha: 0.25),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              cat,
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 12,
                color: amt > 0.0 ? kTextSecondary : kTextMuted,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}
