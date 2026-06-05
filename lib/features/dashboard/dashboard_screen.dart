import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/dashboard_provider.dart';
import 'widgets/balance_card.dart';
import 'widgets/donut_chart_card.dart';
import 'widgets/insights_card.dart';
import 'widgets/quick_summary_card.dart';

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
              const SizedBox(height: 20),

              // Hero Balance Card
              BalanceCard(
                balance: data.balance,
                monthlyIncome: res.monthIncome,
                monthlyExpense: res.monthExpense,
              ),
              const SizedBox(height: 20),

              // Summary Grid (Implemented as two responsive rows)
              Row(
                children: <Widget>[
                  Expanded(
                    child: QuickSummaryCard(
                      label: 'Today Spending',
                      amount: res.todayExpense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickSummaryCard(
                      label: 'Week Spending',
                      amount: res.weekExpense,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: <Widget>[
                  Expanded(
                    child: QuickSummaryCard(
                      label: 'Month Spending',
                      amount: res.monthExpense,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: QuickSummaryCard(
                      label: 'Income This Month',
                      amount: res.monthIncome,
                      amountColor: kColorIncome,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Donut Chart Card
              DonutChartCard(
                breakdown: res.categoryBreakdown,
                totalExpense: res.monthExpense,
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
}

