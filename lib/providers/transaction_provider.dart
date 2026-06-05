import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/models/transaction_model.dart';
import '../repositories/isar_transaction_repository.dart';
import '../repositories/transaction_repository.dart';

class TransactionNotifier extends AsyncNotifier<List<Transaction>> {
  TransactionRepository get _repo => ref.read(transactionRepositoryProvider);

  @override
  Future<List<Transaction>> build() async {
    return _repo.getAllTransactions();
  }

  Future<void> add(Transaction t) async {
    state = const AsyncValue<List<Transaction>>.loading();
    state = await AsyncValue.guard<List<Transaction>>(() async {
      await _repo.addTransaction(t);
      return _repo.getAllTransactions();
    });
  }

  Future<void> updateTx(Transaction t) async {
    state = const AsyncValue<List<Transaction>>.loading();
    state = await AsyncValue.guard<List<Transaction>>(() async {
      await _repo.updateTransaction(t);
      return _repo.getAllTransactions();
    });
  }

  Future<void> delete(int id) async {
    state = const AsyncValue<List<Transaction>>.loading();
    state = await AsyncValue.guard<List<Transaction>>(() async {
      await _repo.deleteTransaction(id);
      return _repo.getAllTransactions();
    });
  }
}

final AsyncNotifierProvider<TransactionNotifier, List<Transaction>> transactionProvider =
    AsyncNotifierProvider<TransactionNotifier, List<Transaction>>(() {
  return TransactionNotifier();
});
