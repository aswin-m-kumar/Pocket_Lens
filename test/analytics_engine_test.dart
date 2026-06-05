import 'package:flutter_test/flutter_test.dart';
import 'package:pocketlens/core/utils/analytics_engine.dart';
import 'package:pocketlens/database/models/transaction_model.dart';

void main() {
  test('AnalyticsEngine calculate basic totals and insights', () {
    final DateTime now = DateTime.now();
    final List<Transaction> txs = <Transaction>[
      Transaction()
        ..id = 1
        ..amount = 1000.0
        ..type = TransactionType.income
        ..category = 'Parents'
        ..date = now
        ..createdAt = now,
      Transaction()
        ..id = 2
        ..amount = 200.0
        ..type = TransactionType.expense
        ..category = 'Food & Snacks'
        ..date = now
        ..createdAt = now,
      Transaction()
        ..id = 3
        ..amount = 300.0
        ..type = TransactionType.expense
        ..category = 'Travel'
        ..date = now
        ..createdAt = now,
    ];

    final AnalyticsResult result = AnalyticsEngine.calculate(txs);

    expect(result.currentBalance, 500.0);
    expect(result.monthExpense, 500.0);
    expect(result.monthIncome, 1000.0);
    expect(result.topCategory, 'Travel');
    expect(result.topCategoryPercentage, 60.0);
    expect(result.incomeCountThisMonth, 1);
  });
}
