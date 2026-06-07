# Pocket Lens — Minimalist Offline Expense Tracker

Pocket Lens is a lightweight, offline-first expense tracking application built for Android, designed with a focus on simplicity, speed, and beautiful, high-density dashboard layouts. 

The application is built to answer three simple questions immediately:
1. **How much money is currently available?** (All-time net balance)
2. **Where is money being spent?** (Dynamic category breakdown and donut charts)
3. **What are the spending patterns over time?** (Period-based analytics & automated insights)

---

## 🛠️ Technology Stack

- **UI Framework:** [Flutter](https://flutter.dev/) (Latest stable)
- **State Management:** [Riverpod](https://riverpod.dev/) (v2 with Notifiers)
- **Local Database:** [Isar Database](https://isar.dev/) (High-performance, offline-first NoSQL with custom schema indexes)
- **Charts:** [fl_chart](https://pub.dev/packages/fl_chart) (Custom interactive donut charts)
- **Fonts & Typography:** [Google Fonts - DM Sans](https://fonts.google.com/specimen/DM+Sans) (Clean, geometric, tight letter-spacing for amounts)
- **Icons:** [Phosphor Icons](https://pub.dev/packages/phosphoricons_flutter) (Consistent, rounded weights)
- **Architecture:** Feature-First Clean Architecture (Simplified for agility)

---

## ✨ Core Features

### 1. Interactive Dashboard Tab
- **Period Filter Bar:** Sleek, horizontal sliding selectors (**Today**, **This Week**, **This Month**, and **This Year**) that instantly and reactively update the entire screen's metrics.
- **Hero Balance Card:** Prominent top-level card displaying all-time net balance along with period-aware Income and Expense summaries corresponding to the active filter.
- **Category Breakdown Card:** A gorgeous, interactive panel showing a structured list of expenditures categorized and sorted by highest amount. Includes matching HSL progress bars showing category percentages and Phosphor icons.
- **Donut Chart Card:** Renders category breakdown for expenses. Tapping a segment highlights it and dynamically shows the category and percentage inside the center hole.
- **Insights Carousel:** A swipe-based card rotating daily averages, week-over-week spending changes, and top income frequencies.

### 2. Add Transaction Tab
- **5-Second Log Flow:** Focuses the amount text field automatically when opened and displays the numeric decimal keyboard.
- **Quick Amount Suggestions:** LRU-evicting chips cached in `SharedPreferences` allowing the user to tap and instantly fill the amount for repeating transactions.
- **Animated Toggle:** Slides smoothly between Expense and Income tabs.
- **Dynamic Category Selector:** Automatically updates category chips depending on the type selected.

### 3. History & Insights Tab
- **Scrollable List:** Lists transactions newest first, formatted cleanly with Indian Rupee (`₹`) symbols and custom category icons.
- **Date Range Filters:** Quickly filter by Today, This Week, This Month, This Year, or All Time.
- **Live Note Search:** Real-time search that filters transactions matching note keywords.
- **Slide-to-Delete:** Swipe any item left to reveal a trash container and trigger a confirmation dialog.
- **BottomSheet Editor:** Tap any transaction to edit its amount, category, date, or note immediately.

---

## 🎨 Design System

Pocket Lens uses a refined dark utility design system reminiscent of premium dashboard panels. 

### Color Palette
- **Scaffold Background:** `kBgDeep` (`#0E0E11`)
- **Card Background:** `kBgCard` (`#1A1A1F`)
- **Modals/Sheets:** `kBgElevated` (`#232329`)
- **Subtle Borders:** `kBorderSubtle` (`#2C2C34`)
- **Primary Text:** `kTextPrimary` (`#F0F0F5`)
- **Secondary Text:** `kTextSecondary` (`#8E8E9A`)
- **Accent Color:** `kAccent` (`#7B7FF5`) — Indigo-lavender
- **Semantic Colors:**
  - Income / Positives: `kColorIncome` (`#3DD68C`) — Green
  - Expense / Negatives: `kColorExpense` (`#FFFF6B6B`) — Coral Red
- **Category-specific Palette:** Food (`#FF9F43`), Entertainment (`#54A0FF`), Travel (`#A29BFE`), Fixed (`#FD79A8`), Misc (`#636E72`)

---

## 📐 Project Structure

```
lib/
├── core/
│   ├── theme/          # HSL Color palette, typography, App theme (DM Sans)
│   ├── constants/      # Static categories, dashboard filters, and keys
│   └── utils/          # Indian Rupee formatter, date utilities, and pure math analytics engine
│
├── database/
│   ├── isar_service.dart # Isar singleton database manager
│   └── models/         # Transaction schema model and auto-generated classes
│
├── repositories/       # Abstract repository interfaces and Isar implementations
│
├── providers/          # CRUD providers, shared preferences state, and derived balance/analytics
│
├── features/
│   ├── dashboard/      # Dashboard screen and widgets
│   │   └── widgets/    # Balance card, donut chart, category breakdown card, insights
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
