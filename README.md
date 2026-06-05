# Pocket Lens — Minimalist Offline Expense Tracker

Pocket Lens is a lightweight, offline-first Android expense tracking application designed for college students with irregular income. 

The application is built to answer three simple questions immediately:
1. **How much money is currently available?**
2. **Where is money being spent?**
3. **What are the spending patterns over time?**

---

## 🛠️ Technology Stack

- **Framework:** [Flutter](https://flutter.dev/) (Latest stable)
- **State Management:** [Riverpod](https://riverpod.dev/) (v2 with Notifiers)
- **Local Database:** [Isar Database](https://isar.dev/) (High-performance, offline-first NoSQL)
- **Charts:** [fl_chart](https://pub.dev/packages/fl_chart)
- **Icons:** [Phosphor Icons](https://pub.dev/packages/phosphoricons_flutter) (Consistent, rounded weights)
- **Architecture:** Feature-First Clean Architecture (Simplified)

---

## ✨ Core Features

### 1. Dashboard Tab
- **Current Balance Card:** Highly prominent top-level hero card showing active digital funds. Includes live indicators for monthly income and expenses.
- **Quick Summary Indicators:** Simple cards tracking Today, Week, and Month spending alongside Monthly Income.
- **Interactive Donut Chart:** Renders category breakdown for expenses. Tapping a segment highlights it and dynamically shows the category and percentage inside the center hole.
- **Insights Card:** Swipe-based carousel displaying daily averages, week-over-week spending changes, and top income frequencies.

### 2. Add Transaction Tab
- **5-Second Log Flow:** Focuses the amount text field automatically when opened and displays the numeric keyboard.
- **Recent Amount suggestions:** Chips cached in `SharedPreferences` allowing the user to tap and instantly fill the amount for repeating transactions.
- **Animated Toggle:** Slides smoothly between Expense and Income tabs.
- **Dynamic Category Selector:** Automatically updates category chips depending on the type selected.

### 3. History & Insights Tab
- **Scrollable List:** Lists transactions newest first, formatted cleanly with Indian Rupee (`₹`) symbols and custom category icons.
- **Date Range Filters:** Quickly filter by Today, This Week, This Month, This Year, or All Time.
- **Live Note Search:** Real-time search that filters transactions matching note keywords.
- **Slide-to-Delete:** Swipe any item left to reveal a trash container and trigger a confirmation dialog.
- **BottomSheet Editor:** Tap any transaction to edit its amount, category, date, or note immediately.

---

## 📐 Project Structure

```
lib/
├── core/
│   ├── theme/          # HSL Color palette, typography, App theme (DM Sans)
│   ├── constants/      # Static categories and filter keys
│   └── utils/          # Indian Rupee formatter, date utilities, and pure math analytics engine
│
├── database/
│   ├── isar_service.dart # Isar singleton database manager
│   └── models/         # Transaction schema model and auto-generated classes
│
├── repositories/       # Abstract repository interfaces and Isar implementations
├── providers/          # CRUD providers, shared preferences state, and derived balance/analytics
├── features/
│   ├── dashboard/      # Dashboard screen and widgets
│   ├── add_transaction/# Add Transaction screen and form components
│   └── history/        # History list, filter bar, edit bottom sheet
│
└── widgets/            # Custom App bottom navigation bar (active dot indicator)
```

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (stable channel)
- Android SDK / Emulator configured

### Running the App

1. Clone this repository:
   ```bash
   git clone https://github.com/aswin-m-kumar/Pocket_Lens.git
   cd Pocket_Lens
   ```

2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```

3. Run code generation (required for Isar database schema):
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

4. Launch the application:
   ```bash
   flutter run
   ```

### Running Tests
Execute unit and widget tests:
```bash
flutter test
```
