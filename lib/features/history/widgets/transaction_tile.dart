import 'package:flutter/material.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../database/models/transaction_model.dart';

class TransactionTile extends StatelessWidget {
  final Transaction transaction;
  final VoidCallback onTap;

  const TransactionTile({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  IconData _getCategoryIcon(String category) {
    switch (category) {
      // Expense Categories
      case 'Food & Snacks':
        return PhosphorIconsRegular.forkKnife;
      case 'Entertainment':
        return PhosphorIconsRegular.gameController;
      case 'Travel':
        return PhosphorIconsRegular.car;
      case 'Miscellaneous':
        return PhosphorIconsRegular.dotsThree;
      // Income Categories
      case 'Parents':
        return PhosphorIconsRegular.house;
      case 'Scholarship':
        return PhosphorIconsRegular.graduationCap;
      case 'Part-Time':
        return PhosphorIconsRegular.briefcase;
      case 'Friend Repayment':
        return PhosphorIconsRegular.handshake;
      case 'Other':
        return PhosphorIconsRegular.coins;
      default:
        return PhosphorIconsRegular.question;
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    const List<String> monthNames = <String>[
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month]} ${date.day}, ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final bool isExpense = transaction.type == TransactionType.expense;
    final bool hasNote = transaction.note != null && transaction.note!.trim().isNotEmpty;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: <Widget>[
            // Leading category icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: kBgElevated,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                _getCategoryIcon(transaction.category),
                color: isExpense ? kColorExpense : kColorIncome,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Category title and optional note
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    transaction.category,
                    style: const TextStyle(
                      color: kTextPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    hasNote ? transaction.note! : _formatDate(transaction.date),
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Trailing amount and optional secondary date line
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${isExpense ? '−' : '+'}${CurrencyFormatter.format(transaction.amount).replaceAll('−', '')}',
                  style: TextStyle(
                    color: isExpense ? kColorExpense : kColorIncome,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (hasNote) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(
                    _formatDate(transaction.date),
                    style: const TextStyle(
                      color: kTextMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
