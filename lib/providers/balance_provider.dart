import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../database/models/transaction_model.dart';
import 'transaction_provider.dart';

final Provider<double> balanceProvider = Provider<double>((Ref ref) {
  final AsyncValue<List<Transaction>> txsAsync = ref.watch(transactionProvider);
  return txsAsync.maybeWhen(
    data: (List<Transaction> txs) {
      double balance = 0.0;
      for (final Transaction tx in txs) {
        if (tx.type == TransactionType.income) {
          balance += tx.amount;
        } else {
          balance -= tx.amount;
        }
      }
      return balance;
    },
    orElse: () => 0.0,
  );
});
