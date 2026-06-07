import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../providers/analytics_provider.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/category_breakdown_card.dart';
import 'widgets/donut_chart_card.dart';
import 'widgets/insights_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DashboardData data = ref.watch(dashboardProvider);

    if (data.analytics == null) {
      return const Scaffold(
        backgroundColor: kBgDeep,
        body: Center(
          child: CircularProgressIndicator(color: kAccent),
        ),
      );
    }

    final res = data.analytics!;

    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Screen Title
              const Text(
                'Dashboard',
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: kTextPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 16),

              // Period Filter Bar
              _buildPeriodFilterBar(ref, data.selectedPeriod),
              const SizedBox(height: 20),

              // Hero Balance Card — ALWAYS all-time (Total Income − Total Expenses)
              BalanceCard(
                balance: data.balance,
                monthlyIncome: res.periodIncome,
                monthlyExpense: res.periodExpense,
                periodLabel: _getPeriodLabel(data.selectedPeriod),
              ),
              const SizedBox(height: 20),

              // Expenses by Category (period-aware)
              CategoryBreakdownCard(
                categoryBreakdown: res.periodCategoryBreakdown,
                selectedPeriod: data.selectedPeriod,
              ),
              const SizedBox(height: 20),

              // Donut Chart Card (period-aware)
              DonutChartCard(
                breakdown: res.periodCategoryBreakdown,
                totalExpense: res.periodExpense,
              ),
              const SizedBox(height: 20),

              // Insights Card
              InsightsCard(
                insights: res.insights,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getPeriodLabel(String period) {
    switch (period) {
      case 'Today':
        return 'Today';
      case 'This Week':
        return 'This Week';
      case 'This Month':
        return 'This Month';
      case 'This Year':
        return 'This Year';
      default:
        return 'This Month';
    }
  }

  Widget _buildPeriodFilterBar(WidgetRef ref, String selectedPeriod) {
    return SizedBox(
      height: 32,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: dashboardFilters.length,
        separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String filter = dashboardFilters[index];
          final bool isSelected = filter == selectedPeriod;

          return GestureDetector(
            onTap: () {
              ref.read(dashboardPeriodProvider.notifier).state = filter;
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 32,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? kAccent.withValues(alpha: 0.18) : Colors.transparent,
                borderRadius: BorderRadius.circular(16),
                border: isSelected ? Border.all(color: kAccent, width: 1) : null,
              ),
              child: Text(
                filter,
                style: TextStyle(
                  fontFamily: 'DM Sans',
                  color: isSelected ? kAccent : kTextSecondary,
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
