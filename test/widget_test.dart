import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:pocketlens/main.dart';
import 'package:pocketlens/database/models/transaction_model.dart';
import 'package:pocketlens/providers/recent_amounts_provider.dart';
import 'package:pocketlens/repositories/transaction_repository.dart';
import 'package:pocketlens/repositories/isar_transaction_repository.dart';

class FakeTransactionRepository implements TransactionRepository {
  @override
  Future<void> addTransaction(Transaction t) async {}
  @override
  Future<void> updateTransaction(Transaction t) async {}
  @override
  Future<void> deleteTransaction(int id) async {}
  @override
  Future<List<Transaction>> getAllTransactions() async => <Transaction>[];
  @override
  Future<List<Transaction>> getByDateRange(DateTime from, DateTime to) async => <Transaction>[];
  @override
  Future<double> getCurrentBalance() async => 0.0;
  @override
  Future<Map<String, double>> getCategoryBreakdown(DateTime from, DateTime to) async => <String, double>{};
}

void main() {
  testWidgets('PocketLensApp smoke test', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, List<String>>{});
    final SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: <Override>[
          sharedPreferencesProvider.overrideWithValue(sharedPreferences),
          transactionRepositoryProvider.overrideWithValue(FakeTransactionRepository()),
        ],
        child: const PocketLensApp(),
      ),
    );

    // Verify that the app mounts successfully
    expect(find.byType(PocketLensApp), findsOneWidget);
  });
}


