# Pocket Lens — Design System

## Design Philosophy

**Tone:** Refined dark utility. Like a high-end instrument panel — dense with information, but never cluttered. Every pixel earns its place.

**Core principle:** The app should feel like it was designed by someone who actually uses it. No decorative chrome. No padding for padding's sake. Information first, always.

**Memorable quality:** Numbers feel *alive* — the balance is always the loudest thing on screen.

---

## Color Palette

```dart
// app_colors.dart

// Backgrounds
const kBgDeep     = Color(0xFF0E0E11);   // Primary screen background
const kBgCard     = Color(0xFF1A1A1F);   // Card surfaces
const kBgElevated = Color(0xFF232329);   // Elevated cards, modals, bottom sheets

// Borders & Dividers
const kBorderSubtle = Color(0xFF2C2C34); // Subtle borders, dividers

// Text
const kTextPrimary   = Color(0xFFF0F0F5); // Main text, balance number
const kTextSecondary = Color(0xFF8E8E9A); // Labels, captions
const kTextMuted     = Color(0xFF55555F); // Placeholders, disabled

// Semantic
const kColorIncome  = Color(0xFF3DD68C); // Green — income, positive balance
const kColorExpense = Color(0xFFFF6B6B); // Coral red — expenses

// Accent
const kAccent = Color(0xFF7B7FF5);       // Indigo-lavender — CTAs, active states

// Category Colors (Donut Chart)
const kCatFood     = Color(0xFFFF9F43); // Warm amber
const kCatEntertain= Color(0xFF54A0FF); // Sky blue
const kCatTravel   = Color(0xFFA29BFE); // Soft purple
const kCatMisc     = Color(0xFF636E72); // Neutral gray
```

**Usage rules:**
- Never use pure `#000000` or `#FFFFFF`
- `kColorIncome` and `kColorExpense` are the only two high-saturation colors used prominently
- `kAccent` is used sparingly — only for the primary CTA and active nav indicator
- Card backgrounds use `kBgCard`, not `kBgDeep`, so they lift off the page

---

## Typography

```dart
// Font: DM Sans (Google Fonts)
// Weights used: 300, 400, 500, 600, 700

// Balance / Hero Numbers
kTextHero: DM Sans, 48sp, weight 700, kTextPrimary
           letterSpacing: -1.5

// Large Labels (section totals, screen titles)
kTextHeading: DM Sans, 22sp, weight 600, kTextPrimary
              letterSpacing: -0.5

// Card Titles
kTextTitle: DM Sans, 16sp, weight 600, kTextPrimary

// Body / Transaction amounts
kTextBody: DM Sans, 14sp, weight 400, kTextPrimary

// Labels / Captions
kTextCaption: DM Sans, 12sp, weight 400, kTextSecondary
              letterSpacing: 0.2

// Chips / Tags
kTextChip: DM Sans, 13sp, weight 500, kTextSecondary
```

**Rationale:** DM Sans has slightly rounded geometry that softens the dark UI without going playful. The tight letter-spacing on large numbers gives the balance card a premium, editorial feel.

---

## Spacing Scale

Based on a 4dp base unit.

```
4   — xs   : icon padding, tight gaps
8   — sm   : between label and value
12  — md   : card internal padding (top/bottom)
16  — base : default horizontal screen margin, card padding
20  — lg   : between card sections
24  — xl   : between major sections
32  — 2xl  : screen top padding
```

**Screen edge margin:** 16dp on all screens.

---

## Border Radius

```
4   — Tags, chips
12  — Input fields, small cards
16  — Standard cards
20  — Bottom sheets, modals
28  — Balance card (hero card only)
```

---

## Elevation & Depth

No hard drop shadows. Use background color difference for depth.

| Layer | Background | Use |
|---|---|---|
| Screen | `kBgDeep` | Base layer |
| Card | `kBgCard` | Standard cards |
| Elevated | `kBgElevated` | Bottom sheet, focused input, modal |
| Border | `kBorderSubtle` | Card outlines (1dp, optional) |

Cards may use a 1dp border in `kBorderSubtle` for extra definition — especially on the balance card.

---

## Component Specs

### Balance Card

```
Background   : kBgCard
Border       : 1dp, kBorderSubtle
Border Radius: 28dp
Padding      : 24dp all sides
Height       : ~140dp

Layout:
  Row: "Current Balance" label (kTextCaption) + optional info icon
  Spacer: 8dp
  Row: ₹ symbol (kTextHeading) + amount (kTextHero) — left aligned
  Spacer: 12dp
  Row: "+₹X income" chip (kColorIncome, small)  |  "−₹X spent" chip (kColorExpense, small)
```

### Transaction Tile

```
Background   : transparent (list item)
Padding      : 12dp vertical, 0dp horizontal (inside ListView)
Divider      : none — whitespace separates items

Layout:
  Leading : Category icon in a 40×40 rounded container (kBgElevated, radius 12)
  Title   : Category name (kTextBody, weight 500)
  Subtitle: Note if present, else date (kTextCaption)
  Trailing: Amount — color kColorIncome or kColorExpense, weight 600
             Date line below amount (kTextCaption, kTextMuted)
```

### Category Chip (Add Transaction)

```
Selected   : background kAccent @ 18% opacity, border kAccent, text kAccent
Unselected : background kBgElevated, border kBorderSubtle, text kTextSecondary
Height     : 38dp
Padding    : 12dp horizontal
Radius     : 12dp
Icon       : 16dp, left of label, 6dp gap
```

### Amount Input Field

```
Background   : kBgElevated
Border       : 1dp kBorderSubtle (unfocused), 1dp kAccent (focused)
Border Radius: 12dp
Font         : DM Sans 36sp weight 700, kTextPrimary
Prefix       : "₹" in kTextSecondary, 32sp
Cursor       : kAccent
Padding      : 16dp horizontal, 20dp vertical
Keyboard     : numberDecimalPad
```

### Quick Amount Chips

```
Height     : 32dp
Padding    : 10dp horizontal
Radius     : 8dp
Background : kBgElevated
Border     : 1dp kBorderSubtle
Text       : kTextChip style
Tap action : fills amount field, brief scale animation (0.95 → 1.0)
```

### Type Toggle (Expense / Income)

```
Container  : kBgElevated, full-width, radius 12dp, height 44dp
Active pill : kBgCard with 1dp kAccent border, slides with AnimatedPositioned
Text active : kTextPrimary, weight 600
Text inactive: kTextMuted, weight 400
```

### Primary Button (Save)

```
Background   : kAccent
Height       : 52dp
Border Radius: 14dp
Text         : "Save Transaction", DM Sans 16sp weight 600, white
Margin       : 16dp horizontal, 24dp bottom
Disabled     : kAccent @ 40% opacity
Tap feedback : brief scale down (0.97)
```

### Bottom Navigation Bar

```
Background   : kBgCard
Height       : 64dp (+ system nav inset)
Border Top   : 1dp kBorderSubtle
Active icon  : kAccent, filled variant
Inactive icon: kTextMuted, outlined variant
No labels    : icon-only navigation
Active dot   : 4dp circle in kAccent, centered below icon
```

### Filter Bar (History)

```
Scrollable horizontal row of chips
Selected    : kAccent @ 18% bg, kAccent border, kAccent text
Unselected  : transparent, no border, kTextSecondary
Height      : 32dp chips
Gap between : 8dp
```

### Donut Chart

```
Library   : fl_chart PieChart
Hole size : 60% (radius ratio)
Sections  : kCatFood, kCatEntertain, kCatTravel, kCatMisc
Stroke    : 2dp kBgDeep between sections (creates gap effect)
Center    : total expense amount in kTextHeading
Touch     : tap section → highlight + show category + % in center
```

### Insights Card

```
Background   : kBgCard
Border Radius: 16dp
Padding      : 16dp
Icon         : 20dp spark/lightbulb icon in kAccent, top-left
Text         : kTextBody, kTextSecondary
One insight per card; PageView or single rotating card — not a list
```

---

## Iconography

Use **Phosphor Icons** (`phosphor_flutter` package) — consistent weight, rounded style that matches DM Sans.

| Category | Icon |
|---|---|
| Food & Snacks | `fork-knife` |
| Entertainment | `game-controller` |
| Travel | `car` |
| Miscellaneous | `dots-three` |
| Parents | `house` |
| Scholarship | `graduation-cap` |
| Part-Time | `briefcase` |
| Friend Repayment | `handshake` |
| Other Income | `coins` |
| Add | `plus` |
| Dashboard | `squares-four` |
| History | `clock-counter-clockwise` |
| Delete | `trash` |
| Edit | `pencil-simple` |
| Filter | `funnel` |
| Search | `magnifying-glass` |

Icon size: **22dp** in bottom nav, **20dp** in list tiles, **16dp** in chips.

---

## Motion & Animations

Keep animations **functional, not decorative**. They confirm actions and direct attention.

| Interaction | Animation |
|---|---|
| Tab switch | `IndexedStack` — no animation (instant, feels fast) |
| Add Transaction save | Amount field scales to 0, success checkmark fades in briefly |
| Transaction tile delete | Slide out left + fade, list reflows with `AnimatedList` |
| Balance update | Number counts up/down with `AnimatedSwitcher` + custom ticker |
| Chip tap (quick amounts) | Scale: 1.0 → 0.95 → 1.0, duration 100ms |
| Bottom sheet open | Standard `showModalBottomSheet` with `barrierColor` at 60% black |
| Screen load | No skeleton — show data immediately (local DB, no async latency) |

**Duration defaults:**
- Fast feedback: 100ms
- Transitions: 200ms
- Number counts: 400ms ease-out

---

## Empty States

No stock illustrations. Use icon + text only.

```
Icon   : Phosphor icon, 48dp, kTextMuted
Title  : DM Sans 18sp weight 600, kTextSecondary
Body   : DM Sans 14sp, kTextMuted, centered, max 2 lines
CTA    : Text button in kAccent if actionable
```

Examples:
- History empty: receipt icon → "No transactions yet" → "Add your first one"
- Filtered empty: funnel icon → "Nothing here" → "Try a different filter"

---

## Flutter Theme Setup

```dart
ThemeData get appTheme => ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: kBgDeep,
  colorScheme: const ColorScheme.dark(
    surface: kBgCard,
    primary: kAccent,
    error: kColorExpense,
  ),
  cardTheme: const CardThemeData(
    color: kBgCard,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    ),
    margin: EdgeInsets.zero,
  ),
  textTheme: GoogleFonts.dmSansTextTheme(ThemeData.dark().textTheme),
  dividerTheme: const DividerThemeData(color: kBorderSubtle, thickness: 1),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kBgCard,
    selectedItemColor: kAccent,
    unselectedItemColor: kTextMuted,
    showSelectedLabels: false,
    showUnselectedLabels: false,
    type: BottomNavigationBarType.fixed,
  ),
);
```

---

## Do / Don't

| Do | Don't |
|---|---|
| Use `kBgDeep` for screens, `kBgCard` for cards | Mix background levels inconsistently |
| Keep income green, expense red — always | Use accent color for amounts |
| Show ₹ symbol inline with the amount | Put ₹ on a separate line |
| Use weight 700 for all money values | Use regular weight for numbers |
| Separate sections with space | Use visible dividers between sections |
| One CTA per screen | Multiple competing buttons |
| Phosphor icons throughout | Mix icon libraries |
