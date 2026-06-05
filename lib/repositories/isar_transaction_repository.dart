import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';

import '../database/isar_service.dart';
import '../database/models/transaction_model.dart';
import 'transaction_repository.dart';

class IsarTransactionRepository implements TransactionRepository {
  final IsarService _isarService;

  IsarTransactionRepository(this._isarService);

  Isar get _isar => _isarService.isar;

  @override
  Future<void> addTransaction(Transaction t) async {
    await _isar.writeTxn(() async {
      await _isar.transactions.put(t);
    });
  }

  @override
  Future<void> updateTransaction(Transaction t) async {
    await _isar.writeTxn(() async {
      await _isar.transactions.put(t);
    });
  }

  @override
  Future<void> deleteTransaction(int id) async {
    await _isar.writeTxn(() async {
      await _isar.transactions.delete(id);
    });
  }

  @override
  Future<List<Transaction>> getAllTransactions() async {
    return _isar.txn(() async {
      return _isar.transactions.where().sortByDateDesc().findAll();
    });
  }

  @override
  Future<List<Transaction>> getByDateRange(DateTime from, DateTime to) async {
    return _isar.txn(() async {
      return _isar.transactions
          .filter()
          .dateBetween(from, to)
          .sortByDateDesc()
          .findAll();
    });
  }

  @override
  Future<double> getCurrentBalance() async {
    final txs = await getAllTransactions();
    double balance = 0.0;
    for (final tx in txs) {
      if (tx.type == TransactionType.income) {
        balance += tx.amount;
      } else {
        balance -= tx.amount;
      }
    }
    return balance;
  }

  @override
  Future<Map<String, double>> getCategoryBreakdown(
      DateTime from, DateTime to) async {
    final txs = await getByDateRange(from, to);
    final breakdown = <String, double>{};
    for (final tx in txs) {
      if (tx.type == TransactionType.expense) {
        breakdown[tx.category] = (breakdown[tx.category] ?? 0.0) + tx.amount;
      }
    }
    return breakdown;
  }
}

final transactionRepositoryProvider = Provider<TransactionRepository>((ref) {
  final isarService = ref.watch(isarServiceProvider);
  return IsarTransactionRepository(isarService);
});
