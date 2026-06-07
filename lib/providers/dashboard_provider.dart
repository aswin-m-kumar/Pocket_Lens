import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/analytics_engine.dart';
import 'analytics_provider.dart';
import 'balance_provider.dart';

class DashboardData {
  final double balance;
  final AnalyticsResult? analytics;
  final String selectedPeriod;

  DashboardData({
    required this.balance,
    this.analytics,
    required this.selectedPeriod,
  });
}

final Provider<DashboardData> dashboardProvider =
    Provider<DashboardData>((Ref ref) {
  final double balance = ref.watch(balanceProvider);
  final AnalyticsResult? analytics = ref.watch(analyticsProvider);
  final String selectedPeriod = ref.watch(dashboardPeriodProvider);
  return DashboardData(
    balance: balance,
    analytics: analytics,
    selectedPeriod: selectedPeriod,
  );
});
