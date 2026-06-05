import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class BalanceCard extends StatelessWidget {
  final double balance;
  final double monthlyIncome;
  final double monthlyExpense;

  const BalanceCard({
    super.key,
    required this.balance,
    required this.monthlyIncome,
    required this.monthlyExpense,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: kBorderSubtle, width: 1),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Header Row
          const Row(
            children: <Widget>[
              Text(
                'Current Balance',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: kTextSecondary,
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(width: 6),
              Icon(
                PhosphorIconsRegular.info,
                color: kTextSecondary,
                size: 14,
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Balance Amount Row
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                CurrencyFormatter.format(balance),
                style: const TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 44,
                  fontWeight: FontWeight.w700,
                  color: kTextPrimary,
                  letterSpacing: -1.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Badges Row
          Row(
            children: <Widget>[
              // Income badge
              _buildBadge(
                label: '+${CurrencyFormatter.format(monthlyIncome)}',
                color: kColorIncome,
              ),
              const SizedBox(width: 8),
              // Expense badge
              _buildBadge(
                label: '−${CurrencyFormatter.format(monthlyExpense).replaceAll('−', '')}',
                color: kColorExpense,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'DM Sans',
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
