import '../../database/models/transaction_model.dart';
import 'date_utils.dart';

class AnalyticsResult {
  final double currentBalance;
  final double todayExpense;
  final double weekExpense;
  final double monthExpense;
  final double monthIncome;
  final double avgDailySpend;
  final Map<String, double> categoryBreakdown; // category -> total expense amount (monthly)
  final String topCategory;
  final double topCategoryPercentage;
  final int incomeCountThisMonth;
  final double weekOverWeekChange; // percentage change (e.g., +18% or -12%)
  final List<String> insights;

  // Period-aware fields — scoped to whatever period the user selected on dashboard
  final double periodExpense;
  final double periodIncome;
  final Map<String, double> periodCategoryBreakdown;

  AnalyticsResult({
    required this.currentBalance,
    required this.todayExpense,
    required this.weekExpense,
    required this.monthExpense,
    required this.monthIncome,
    required this.avgDailySpend,
    required this.categoryBreakdown,
    required this.topCategory,
    required this.topCategoryPercentage,
    required this.incomeCountThisMonth,
    required this.weekOverWeekChange,
    required this.insights,
    required this.periodExpense,
    required this.periodIncome,
    required this.periodCategoryBreakdown,
  });
}

class AnalyticsEngine {
  /// Explicit mapping from dashboard period strings to date boundaries.
  /// Returns the start-of-period DateTime for the given filter string.
  ///
  /// 'Today'      → start of today (00:00:00)
  /// 'This Week'  → Monday 00:00:00 of current week
  /// 'This Month' → 1st of current month 00:00:00
  /// 'This Year'  → Jan 1st of current year 00:00:00
  static DateTime _getPeriodStart(String period) {
    switch (period) {
      case 'Today':
        return AppDateUtils.getStartOfToday();
      case 'This Week':
        return AppDateUtils.getStartOfWeek();
      case 'This Month':
        return AppDateUtils.getStartOfMonth();
      case 'This Year':
        return AppDateUtils.getStartOfYear();
      default:
        return AppDateUtils.getStartOfMonth(); // safe fallback
    }
  }

  static AnalyticsResult calculate(
    List<Transaction> transactions, {
    String selectedPeriod = 'This Month',
  }) {
    // ─── 1. Current Balance (ALL-TIME: Total Income − Total Expenses) ───
    // IMPORTANT: This must NEVER use period-filtered data.
    double totalIncome = 0.0;
    double totalExpense = 0.0;
    for (final tx in transactions) {
      if (tx.type == TransactionType.income) {
        totalIncome += tx.amount;
      } else {
        totalExpense += tx.amount;
      }
    }
    final double currentBalance = totalIncome - totalExpense;

    // ─── Date boundaries ───
    final DateTime todayStart = AppDateUtils.getStartOfToday();
    final DateTime todayEnd = AppDateUtils.getEndOfToday();
    final DateTime weekStart = AppDateUtils.getStartOfWeek();
    final DateTime monthStart = AppDateUtils.getStartOfMonth();
    final DateTime prevWeekStart = AppDateUtils.getStartOfPreviousWeek();
    final DateTime prevWeekEnd = AppDateUtils.getEndOfPreviousWeek();

    // Selected period boundary (explicit mapping)
    final DateTime periodStart = _getPeriodStart(selectedPeriod);

    double todayExpense = 0.0;
    double weekExpense = 0.0;
    double monthExpense = 0.0;
    double monthIncome = 0.0;
    int incomeCountThisMonth = 0;
    double prevWeekExpense = 0.0;

    // Period-scoped accumulators
    double periodExpense = 0.0;
    double periodIncome = 0.0;
    final Map<String, double> periodCategoryBreakdown = <String, double>{};

    final Map<String, double> categoryBreakdown = <String, double>{};
    final Map<String, int> incomeCategoryCountsThisMonth = <String, int>{};

    for (final tx in transactions) {
      final bool isToday = tx.date.isAfter(todayStart.subtract(const Duration(microseconds: 1))) &&
          tx.date.isBefore(todayEnd.add(const Duration(microseconds: 1)));
      final bool isThisWeek = tx.date.isAfter(weekStart.subtract(const Duration(microseconds: 1)));
      final bool isThisMonth = tx.date.isAfter(monthStart.subtract(const Duration(microseconds: 1)));
      final bool isPrevWeek = tx.date.isAfter(prevWeekStart.subtract(const Duration(microseconds: 1))) &&
          tx.date.isBefore(prevWeekEnd.add(const Duration(microseconds: 1)));
      final bool isInPeriod = tx.date.isAfter(periodStart.subtract(const Duration(microseconds: 1)));

      if (tx.type == TransactionType.expense) {
        if (isToday) {
          todayExpense += tx.amount;
        }
        if (isThisWeek) {
          weekExpense += tx.amount;
        }
        if (isThisMonth) {
          monthExpense += tx.amount;
          categoryBreakdown[tx.category] = (categoryBreakdown[tx.category] ?? 0.0) + tx.amount;
        }
        if (isPrevWeek) {
          prevWeekExpense += tx.amount;
        }
        // Period-scoped accumulation
        if (isInPeriod) {
          periodExpense += tx.amount;
          periodCategoryBreakdown[tx.category] =
              (periodCategoryBreakdown[tx.category] ?? 0.0) + tx.amount;
        }
      } else if (tx.type == TransactionType.income) {
        if (isThisMonth) {
          monthIncome += tx.amount;
          incomeCountThisMonth++;
          incomeCategoryCountsThisMonth[tx.category] =
              (incomeCategoryCountsThisMonth[tx.category] ?? 0) + 1;
        }
        // Period-scoped income
        if (isInPeriod) {
          periodIncome += tx.amount;
        }
      }
    }

    // Average daily spend
    final int daysPassed = DateTime.now().day;
    final double avgDailySpend = daysPassed > 0 ? (monthExpense / daysPassed) : 0.0;

    // Top Category
    String topCategory = '';
    double maxCategoryExpense = 0.0;
    categoryBreakdown.forEach((String cat, double amount) {
      if (amount > maxCategoryExpense) {
        maxCategoryExpense = amount;
        topCategory = cat;
      }
    });

    final double topCategoryPercentage =
        monthExpense > 0 ? (maxCategoryExpense / monthExpense) * 100 : 0.0;

    // Week-over-week comparison
    double weekOverWeekChange = 0.0;
    if (prevWeekExpense > 0) {
      weekOverWeekChange = ((weekExpense - prevWeekExpense) / prevWeekExpense) * 100;
    } else if (weekExpense > 0) {
      weekOverWeekChange = 100.0; // Assume 100% increase if no spending last week
    }

    // Generate Insights
    final List<String> insights = <String>[];

    // Insight 1: Top Category percentage
    if (topCategory.isNotEmpty && topCategoryPercentage > 0) {
      insights.add(
        'You spent ${topCategoryPercentage.toStringAsFixed(0)}% of your money on $topCategory this month.',
      );
    } else {
      insights.add('No expense data available for this month yet.');
    }

    // Insight 2: Average daily spending
    insights.add('Average daily spending is ₹${avgDailySpend.toStringAsFixed(0)}.');

    // Insight 3: Income frequency / sources
    if (incomeCategoryCountsThisMonth.isNotEmpty) {
      // Find the most frequent income source or just list one
      final String topIncomeSource = incomeCategoryCountsThisMonth.entries
          .reduce((a, b) => a.value > b.value ? a : b)
          .key;
      final int count = incomeCategoryCountsThisMonth[topIncomeSource] ?? 0;
      insights.add('$topIncomeSource transferred money $count times this month.');
    } else {
      insights.add('You received money $incomeCountThisMonth times this month.');
    }

    // Insight 4: Week comparison
    if (weekOverWeekChange > 0) {
      insights.add('Spending increased by ${weekOverWeekChange.toStringAsFixed(0)}% this week.');
    } else if (weekOverWeekChange < 0) {
      insights.add('Spending decreased by ${weekOverWeekChange.abs().toStringAsFixed(0)}% this week.');
    } else if (weekExpense > 0) {
      insights.add('Spending is identical to last week.');
    }

    return AnalyticsResult(
      currentBalance: currentBalance,
      todayExpense: todayExpense,
      weekExpense: weekExpense,
      monthExpense: monthExpense,
      monthIncome: monthIncome,
      avgDailySpend: avgDailySpend,
      categoryBreakdown: categoryBreakdown,
      topCategory: topCategory,
      topCategoryPercentage: topCategoryPercentage,
      incomeCountThisMonth: incomeCountThisMonth,
      weekOverWeekChange: weekOverWeekChange,
      insights: insights,
      periodExpense: periodExpense,
      periodIncome: periodIncome,
      periodCategoryBreakdown: periodCategoryBreakdown,
    );
  }
}
