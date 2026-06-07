import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/analytics_engine.dart';
import '../database/models/transaction_model.dart';
import 'transaction_provider.dart';

/// The currently selected dashboard period. Default: 'This Month'.
final StateProvider<String> dashboardPeriodProvider =
    StateProvider<String>((Ref ref) => 'This Month');

final Provider<AnalyticsResult?> analyticsProvider =
    Provider<AnalyticsResult?>((Ref ref) {
  final AsyncValue<List<Transaction>> txsAsync = ref.watch(transactionProvider);
  final String selectedPeriod = ref.watch(dashboardPeriodProvider);
  return txsAsync.maybeWhen(
    data: (List<Transaction> txs) =>
        AnalyticsEngine.calculate(txs, selectedPeriod: selectedPeriod),
    orElse: () => null,
  );
});
