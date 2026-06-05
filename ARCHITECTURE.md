# Pocket Lens — Architecture Documentation

## Overview

Pocket Lens is a fully offline, local-first Android expense tracker built with Flutter. There is no backend, no authentication, and no cloud sync. All data lives on-device via Isar Database.

---

## Technology Stack

| Layer | Technology |
|---|---|
| UI Framework | Flutter (latest stable) |
| State Management | Riverpod |
| Local Database | Isar |
| Charts | fl_chart |
| Platform | Android only |

---

## Architectural Style

**Feature-First Clean Architecture (Simplified)**

Three layers per feature:
1. **Data** — Isar models + repository implementations
2. **Domain** — Repository interfaces + business logic
3. **Presentation** — Riverpod providers + UI widgets

No use cases layer. For an app of this scope, a repository + provider split is sufficient without over-engineering.

---

## Folder Structure

```
lib/
├── core/
│   ├── theme/
│   │   └── app_theme.dart           # Dark theme, colors, typography
│   ├── constants/
│   │   └── app_constants.dart       # Category lists, filter labels
│   └── utils/
│       ├── currency_formatter.dart  # ₹ formatting helpers
│       ├── date_utils.dart          # Date range helpers
│       └── analytics_engine.dart   # Pure functions for all metric calculations
│
├── database/
│   ├── isar_service.dart            # Isar instance initialization (singleton)
│   └── models/
│       └── transaction_model.dart   # Isar @Collection model
│
├── repositories/
│   ├── transaction_repository.dart  # Abstract interface
│   └── isar_transaction_repository.dart  # Isar implementation
│
├── providers/
│   ├── transaction_provider.dart    # CRUD state
│   ├── analytics_provider.dart      # Derived analytics state
│   ├── balance_provider.dart        # Current balance (watches transactions)
│   └── dashboard_provider.dart      # Aggregated dashboard state
│
├── features/
│   ├── dashboard/
│   │   ├── dashboard_screen.dart
│   │   └── widgets/
│   │       ├── balance_card.dart
│   │       ├── quick_summary_card.dart
│   │       ├── donut_chart_card.dart
│   │       └── insights_card.dart
│   │
│   ├── add_transaction/
│   │   ├── add_transaction_screen.dart
│   │   └── widgets/
│   │       ├── amount_input.dart
│   │       ├── type_toggle.dart
│   │       ├── category_selector.dart
│   │       └── recent_amounts_chips.dart
│   │
│   └── history/
│       ├── history_screen.dart
│       └── widgets/
│           ├── transaction_list.dart
│           ├── transaction_tile.dart
│           ├── filter_bar.dart
│           └── edit_transaction_sheet.dart
│
├── widgets/                         # Truly shared widgets
│   └── app_bottom_nav.dart
│
└── main.dart
```

---

## Data Model

### Transaction (`transaction_model.dart`)

```dart
@collection
class Transaction {
  Id id = Isar.autoIncrement;

  @Index()
  late double amount;

  @enumerated
  late TransactionType type;       // income | expense

  late String category;

  String? note;

  @Index()
  late DateTime date;

  late DateTime createdAt;
}

enum TransactionType { income, expense }
```

**Index rationale:**
- `date` is indexed → fast date-range queries (today / week / month filters)
- `amount` is indexed → fast aggregate calculations

---

## Repository Layer

### Interface (`transaction_repository.dart`)

```dart
abstract class TransactionRepository {
  Future<void> addTransaction(Transaction t);
  Future<void> updateTransaction(Transaction t);
  Future<void> deleteTransaction(int id);
  Future<List<Transaction>> getAllTransactions();
  Future<List<Transaction>> getByDateRange(DateTime from, DateTime to);
  Future<double> getCurrentBalance();
  Future<Map<String, double>> getCategoryBreakdown(DateTime from, DateTime to);
}
```

### Implementation (`isar_transaction_repository.dart`)

- Wraps `IsarService` singleton
- All writes use `isar.writeTxn()`
- All reads use `isar.txn()` or `.where()` query builders
- `getCurrentBalance()` = sum of all income − sum of all expenses (computed in-memory from full list; fast enough at this data volume)

---

## State Management

All state is managed via **Riverpod**. UI never touches the repository directly.

### Provider Dependency Graph

```
IsarService (singleton)
    └── transactionProvider (StateNotifier)
            ├── balanceProvider (derived)
            ├── analyticsProvider (derived)
            └── dashboardProvider (derived — combines balance + analytics)
```

### Provider Responsibilities

| Provider | Type | Responsibility |
|---|---|---|
| `transactionProvider` | `AsyncNotifierProvider` | CRUD operations, holds full transaction list |
| `balanceProvider` | `Provider` (derived) | Computes current balance from transaction list |
| `analyticsProvider` | `Provider` (derived) | Runs `AnalyticsEngine` on transaction list |
| `dashboardProvider` | `Provider` (derived) | Bundles balance + analytics for Dashboard screen |

**Key rule:** Providers are derived — no manual `refresh()` needed. When `transactionProvider` state changes, all downstream providers recompute automatically.

---

## Analytics Engine

`core/utils/analytics_engine.dart` — pure Dart, no Flutter dependency, no Isar dependency.

**Input:** `List<Transaction>`
**Output:** `AnalyticsResult` (plain data class)

```dart
class AnalyticsResult {
  final double currentBalance;
  final double todayExpense;
  final double weekExpense;
  final double monthExpense;
  final double monthIncome;
  final double avgDailySpend;
  final Map<String, double> categoryBreakdown;   // for donut chart
  final String topCategory;
  final int incomeCountThisMonth;
  final double weekOverWeekChange;               // % change
  final List<String> insights;                   // pre-generated insight strings
}
```

All calculations are pure functions. No async, no side effects. This makes the engine trivially testable.

---

## Navigation

**Bottom Navigation Bar** — 3 tabs, index-based routing via `IndexedStack` (preserves scroll state).

```
Index 0 → Dashboard
Index 1 → Add Transaction
Index 2 → History & Insights
```

No named routes required. No deep linking. `IndexedStack` is preferred over `Navigator.push` for tab persistence.

---

## Database Initialization

`IsarService` is initialized once in `main.dart` before `runApp()` and provided via a `Provider<IsarService>`.

```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final isar = await IsarService.init();
  runApp(
    ProviderScope(
      overrides: [isarServiceProvider.overrideWithValue(isar)],
      child: const PocketLensApp(),
    ),
  );
}
```

---

## Recent Amounts (Quick Chips)

Stored separately from transactions — a small `List<double>` persisted via `SharedPreferences` (not Isar, since it's UI-level state, not financial data).

- Max 20 entries, LRU eviction
- Shown as tappable chips on the Add Transaction screen
- Updated on every successful save

---

## Error Handling Strategy

- Database errors: caught at repository layer, surfaced as `AsyncError` state in providers
- UI displays an inline error card (not a crash dialog)
- Empty states handled per-screen with contextual messaging
- No network errors (offline-only app)

---

## Key Design Decisions

**Why Isar over SQLite/Drift?**
Isar is Flutter-native, requires zero SQL boilerplate, and has excellent performance for local-only apps. Schema migration is simpler for a single-developer project.

**Why no Use Cases layer?**
At this scale, adding a use case layer between repository and provider adds indirection without benefit. The `AnalyticsEngine` acts as the domain logic layer for calculations.

**Why `IndexedStack` for navigation?**
Preserves scroll position and provider state across tab switches without re-mounting widgets — important for the History list.

**Why pure functions in `AnalyticsEngine`?**
Keeps business logic isolated, testable, and UI-framework-agnostic. The engine can be unit-tested without spinning up Flutter or Isar.

---

## Development Phase Map

| Phase | Scope |
|---|---|
| 1 | Project setup: packages, theme, navigation shell |
| 2 | Isar model, repository, CRUD providers |
| 3 | Add Transaction screen |
| 4 | History screen (list, edit, delete, filter) |
| 5 | Dashboard screen (balance, summaries) |
| 6 | Analytics engine + donut chart + insights |
| 7 | Polish: animations, empty states, error states |
