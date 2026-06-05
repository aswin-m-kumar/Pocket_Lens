import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/analytics_engine.dart';
import '../database/models/transaction_model.dart';
import 'transaction_provider.dart';

final Provider<AnalyticsResult?> analyticsProvider =
    Provider<AnalyticsResult?>((Ref ref) {
  final AsyncValue<List<Transaction>> txsAsync = ref.watch(transactionProvider);
  return txsAsync.maybeWhen(
    data: (List<Transaction> txs) => AnalyticsEngine.calculate(txs),
    orElse: () => null,
  );
});
