import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/constants/app_constants.dart';
import '../../core/theme/app_colors.dart';
import '../../database/models/transaction_model.dart';
import '../../providers/recent_amounts_provider.dart';
import '../../providers/transaction_provider.dart';

class AddTransactionScreen extends ConsumerStatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  ConsumerState<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends ConsumerState<AddTransactionScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  TransactionType _type = TransactionType.expense;
  late String _category;
  DateTime _selectedDate = DateTime.now();
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();
    _category = expenseCategories[0];

    // Auto focus the amount field when tab is opened
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _amountFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    _amountFocusNode.dispose();
    super.dispose();
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      // Expense Categories
      case 'Food & Snacks':
        return PhosphorIconsRegular.forkKnife;
      case 'Entertainment':
        return PhosphorIconsRegular.gameController;
      case 'Travel':
        return PhosphorIconsRegular.car;
      case 'Miscellaneous':
        return PhosphorIconsRegular.dotsThree;
      case 'Fixed Expense':
        return PhosphorIconsRegular.buildings;
      // Income Categories
      case 'Parents':
        return PhosphorIconsRegular.house;
      case 'Scholarship':
        return PhosphorIconsRegular.graduationCap;
      case 'Part-Time':
        return PhosphorIconsRegular.briefcase;
      case 'Friend Repayment':
        return PhosphorIconsRegular.handshake;
      case 'Other':
        return PhosphorIconsRegular.coins;
      default:
        return PhosphorIconsRegular.question;
    }
  }

  String _formatDate(DateTime date) {
    final DateTime now = DateTime.now();
    if (date.year == now.year && date.month == now.month && date.day == now.day) {
      return 'Today';
    }
    const List<String> monthNames = <String>[
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${monthNames[date.month]} ${date.day}, ${date.year}';
  }

  void _presentDatePicker() async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.dark().copyWith(
            colorScheme: const ColorScheme.dark(
              primary: kAccent,
              onPrimary: Colors.white,
              surface: kBgElevated,
              onSurface: kTextPrimary,
            ),
            dialogTheme: const DialogThemeData(
              backgroundColor: kBgElevated,
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  void _saveTransaction() async {
    final String amtText = _amountController.text.trim();
    final double? amt = double.tryParse(amtText);

    if (amt == null || amt <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: kColorExpense,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    final Transaction tx = Transaction()
      ..amount = amt
      ..type = _type
      ..category = _category
      ..note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim()
      ..date = _selectedDate
      ..createdAt = DateTime.now();

    // Perform database insertion
    await ref.read(transactionProvider.notifier).add(tx);

    // Save to SharedPreferences recent list
    ref.read(recentAmountsProvider.notifier).addAmount(amt);

    if (!mounted) return;

    // Reset Form state
    setState(() {
      _amountController.clear();
      _noteController.clear();
      _selectedDate = DateTime.now();
      _category = _type == TransactionType.expense ? expenseCategories[0] : incomeCategories[0];
      _showSuccess = true;
    });

    // Hide success indicator after 2 seconds
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSuccess = false;
        });
      }
    });

    // Dismiss keyboard
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories =
        _type == TransactionType.expense ? expenseCategories : incomeCategories;

    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Screen Title
              const Text(
                'Add Transaction',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),

              // Success Banner (Simple non-flashy green indicator)
              if (_showSuccess) ...<Widget>[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: kColorIncome.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kColorIncome, width: 1),
                  ),
                  child: const Row(
                    children: <Widget>[
                      Icon(PhosphorIconsRegular.checkCircle, color: kColorIncome),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Transaction saved successfully!',
                          style: TextStyle(
                            color: kColorIncome,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Amount Input Field
              Container(
                decoration: BoxDecoration(
                  color: kBgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _amountFocusNode.hasFocus ? kAccent : kBorderSubtle,
                    width: 1,
                  ),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: TextField(
                  controller: _amountController,
                  focusNode: _amountFocusNode,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  cursorColor: kAccent,
                  style: const TextStyle(
                    fontFamily: 'DM Sans',
                    fontSize: 36,
                    fontWeight: FontWeight.w700,
                    color: kTextPrimary,
                  ),
                  decoration: const InputDecoration(
                    prefixText: '₹ ',
                    prefixStyle: TextStyle(
                      color: kTextSecondary,
                      fontSize: 32,
                      fontWeight: FontWeight.w700,
                    ),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    hintText: '0',
                    hintStyle: TextStyle(color: kTextMuted),
                  ),
                  onTap: () {
                    setState(() {}); // refresh border highlighting
                  },
                ),
              ),
              const SizedBox(height: 20),

              // Transaction Type Toggle
              _buildTypeToggle(),
              const SizedBox(height: 24),

              // Recent Amount Suggestion Chips
              _buildRecentChips(),

              // Category Selector Label
              const Text(
                'Category',
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Category Chips Grid
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((String cat) {
                  final bool isSelected = _category == cat;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _category = cat;
                      });
                    },
                    child: Container(
                      height: 38,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? kAccent.withValues(alpha: 0.18) : kBgElevated,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: isSelected ? kAccent : kBorderSubtle,
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(
                            _getCategoryIcon(cat),
                            color: isSelected ? kAccent : kTextSecondary,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            cat,
                            style: TextStyle(
                              color: isSelected ? kAccent : kTextSecondary,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),

              // Optional Fields Section
              const Text(
                'Details',
                style: TextStyle(
                  color: kTextSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 10),

              // Note TextField
              Container(
                decoration: BoxDecoration(
                  color: kBgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderSubtle, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: TextField(
                  controller: _noteController,
                  cursorColor: kAccent,
                  style: const TextStyle(color: kTextPrimary, fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Add a note (optional)',
                    hintStyle: TextStyle(color: kTextMuted),
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Date Selector Button
              GestureDetector(
                onTap: _presentDatePicker,
                child: Container(
                  height: 48,
                  decoration: BoxDecoration(
                    color: kBgElevated,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kBorderSubtle, width: 1),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          const Icon(PhosphorIconsRegular.calendar, color: kTextSecondary, size: 18),
                          const SizedBox(width: 10),
                          Text(
                            _formatDate(_selectedDate),
                            style: const TextStyle(color: kTextPrimary, fontSize: 14),
                          ),
                        ],
                      ),
                      const Icon(PhosphorIconsRegular.caretDown, color: kTextSecondary, size: 16),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 36),

              // Save Button with visual scale animation feedback
              ScaleOnTap(
                onTap: _saveTransaction,
                child: Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: kAccent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Save Transaction',
                    style: TextStyle(
                      fontFamily: 'DM Sans',
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kBgElevated,
        borderRadius: BorderRadius.circular(12),
      ),
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double width = constraints.maxWidth / 2;
          return Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                left: _type == TransactionType.expense ? 0 : width,
                child: Container(
                  width: width,
                  height: 44,
                  decoration: BoxDecoration(
                    color: kBgCard,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: kAccent, width: 1),
                  ),
                ),
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _type = TransactionType.expense;
                          _category = expenseCategories[0];
                        });
                      },
                      child: Center(
                        child: Text(
                          'Expense',
                          style: TextStyle(
                            color: _type == TransactionType.expense ? kTextPrimary : kTextMuted,
                            fontWeight:
                                _type == TransactionType.expense ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        setState(() {
                          _type = TransactionType.income;
                          _category = incomeCategories[0];
                        });
                      },
                      child: Center(
                        child: Text(
                          'Income',
                          style: TextStyle(
                            color: _type == TransactionType.income ? kTextPrimary : kTextMuted,
                            fontWeight:
                                _type == TransactionType.income ? FontWeight.w600 : FontWeight.w400,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildRecentChips() {
    final List<double> recents = ref.watch(recentAmountsProvider);
    if (recents.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Text(
          'Recent Amounts',
          style: TextStyle(
            color: kTextSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.2,
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 32,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: recents.length,
            separatorBuilder: (BuildContext context, int index) => const SizedBox(width: 8),
            itemBuilder: (BuildContext context, int index) {
              final double amt = recents[index];
              final String amtText = amt % 1 == 0 ? amt.toInt().toString() : amt.toStringAsFixed(1);
              return ScaleOnTap(
                onTap: () {
                  _amountController.text = amtText;
                  // Set cursor to the end
                  _amountController.selection = TextSelection.fromPosition(
                    TextPosition(offset: _amountController.text.length),
                  );
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: kBgElevated,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: kBorderSubtle, width: 1),
                  ),
                  child: Text(
                    '₹$amtText',
                    style: const TextStyle(
                      color: kTextSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }
}

// ScaleOnTap provides visual scaling feedback (0.95 -> 1.0) on tap
class ScaleOnTap extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;

  const ScaleOnTap({super.key, required this.child, required this.onTap});

  @override
  State<ScaleOnTap> createState() => _ScaleOnTapState();
}

class _ScaleOnTapState extends State<ScaleOnTap> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
      lowerBound: 0.95,
      upperBound: 1.0,
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.reverse(),
      onTapUp: (_) {
        _controller.forward();
        widget.onTap();
      },
      onTapCancel: () => _controller.forward(),
      child: ScaleTransition(
        scale: _controller,
        child: widget.child,
      ),
    );
  }
}
