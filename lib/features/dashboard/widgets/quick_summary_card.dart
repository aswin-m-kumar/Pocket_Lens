import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';

class QuickSummaryCard extends StatelessWidget {
  final String label;
  final double amount;
  final Color? amountColor;

  const QuickSummaryCard({
    super.key,
    required this.label,
    required this.amount,
    this.amountColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kBgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: kBorderSubtle, width: 1),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: kTextSecondary,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            CurrencyFormatter.format(amount),
            style: TextStyle(
              fontFamily: 'DM Sans',
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: amountColor ?? kTextPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
