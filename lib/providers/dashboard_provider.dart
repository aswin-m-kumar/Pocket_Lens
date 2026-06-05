import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/analytics_engine.dart';
import 'analytics_provider.dart';
import 'balance_provider.dart';

class DashboardData {
  final double balance;
  final AnalyticsResult? analytics;

  DashboardData({required this.balance, this.analytics});
}

final Provider<DashboardData> dashboardProvider =
    Provider<DashboardData>((Ref ref) {
  final double balance = ref.watch(balanceProvider);
  final AnalyticsResult? analytics = ref.watch(analyticsProvider);
  return DashboardData(balance: balance, analytics: analytics);
});
