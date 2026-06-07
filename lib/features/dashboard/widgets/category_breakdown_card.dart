import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class CategoryBreakdownCard extends StatelessWidget {
  final Map<String, double> categoryBreakdown;
  final String selectedPeriod;

  const CategoryBreakdownCard({
    super.key,
    required this.categoryBreakdown,
    required this.selectedPeriod,
  });

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

  IconData _getCategoryIcon(String cat) {
    switch (cat) {
      case 'Food & Snacks':
        return PhosphorIconsRegular.forkKnife;
      case 'Entertainment':
        return PhosphorIconsRegular.gameController;
      case 'Travel':
        return PhosphorIconsRegular.car;
      case 'Fixed Expense':
        return PhosphorIconsRegular.buildings;
      case 'Miscellaneous':
      default:
        return PhosphorIconsRegular.dotsThree;
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ordered categories — display in this canonical order
    final List<String> allCategories = <String>[
      'Food & Snacks',
      'Entertainment',
      'Travel',
      'Miscellaneous',
      'Fixed Expense',
    ];

    // Filter to only categories with non-zero spend
    final List<String> activeCategories = allCategories.where((String cat) {
      return (categoryBreakdown[cat] ?? 0.0) > 0.0;
    }).toList();

    final bool isEmpty = activeCategories.isEmpty;

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
          // Header
          const Text(
            'Expenses by Category',
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: kTextPrimary,
            ),
          ),
          const SizedBox(height: 16),

          if (isEmpty)
            _buildEmptyState()
          else
            ...activeCategories.map((String cat) {
              final double amount = categoryBreakdown[cat] ?? 0.0;
              return _buildCategoryRow(cat, amount);
            }),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Center(
        child: Column(
          children: <Widget>[
            Icon(
              PhosphorIconsRegular.chartPieSlice,
              size: 36,
              color: kTextMuted.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 10),
            const Text(
              'No expenses this period',
              style: TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTextMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryRow(String category, double amount) {
    final Color color = _getCategoryColor(category);
    final IconData icon = _getCategoryIcon(category);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: <Widget>[
          // Color dot
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: color,
              size: 16,
            ),
          ),
          const SizedBox(width: 12),

          // Category name
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontFamily: 'DM Sans',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: kTextPrimary,
              ),
            ),
          ),

          // Amount (right-aligned)
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
