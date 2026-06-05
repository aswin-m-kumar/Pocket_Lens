import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../database/models/transaction_model.dart';
import '../../../providers/transaction_provider.dart';
import '../../add_transaction/add_transaction_screen.dart'; // import ScaleOnTap

class EditTransactionSheet extends ConsumerStatefulWidget {
  final Transaction transaction;

  const EditTransactionSheet({super.key, required this.transaction});

  @override
  ConsumerState<EditTransactionSheet> createState() => _EditTransactionSheetState();
}

class _EditTransactionSheetState extends ConsumerState<EditTransactionSheet> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  final FocusNode _amountFocusNode = FocusNode();

  late TransactionType _type;
  late String _category;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _amountController.text = widget.transaction.amount % 1 == 0
        ? widget.transaction.amount.toInt().toString()
        : widget.transaction.amount.toString();
    _noteController.text = widget.transaction.note ?? '';
    _type = widget.transaction.type;
    _category = widget.transaction.category;
    _selectedDate = widget.transaction.date;
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

  void _deleteTransaction() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: kBgElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Delete Transaction', style: TextStyle(color: kTextPrimary)),
        content: const Text(
          'Are you sure you want to delete this transaction?',
          style: TextStyle(color: kTextSecondary),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: kTextSecondary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: kColorExpense)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref.read(transactionProvider.notifier).delete(widget.transaction.id);
      if (mounted) {
        Navigator.pop(context); // close sheet
      }
    }
  }

  void _updateTransaction() async {
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

    final Transaction updatedTx = Transaction()
      ..id = widget.transaction.id
      ..amount = amt
      ..type = _type
      ..category = _category
      ..note = _noteController.text.trim().isEmpty ? null : _noteController.text.trim()
      ..date = _selectedDate
      ..createdAt = widget.transaction.createdAt;

    await ref.read(transactionProvider.notifier).updateTx(updatedTx);

    if (mounted) {
      Navigator.pop(context); // close sheet
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> categories =
        _type == TransactionType.expense ? expenseCategories : incomeCategories;

    return Container(
      decoration: const BoxDecoration(
        color: kBgElevated,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 20,
        bottom: 24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                const Text(
                  'Edit Transaction',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  onPressed: _deleteTransaction,
                  icon: const Icon(PhosphorIconsRegular.trash, color: kColorExpense),
                  iconSize: 22,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Amount Input Field
            Container(
              decoration: BoxDecoration(
                color: kBgCard,
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
                  setState(() {});
                },
              ),
            ),
            const SizedBox(height: 20),

            // Transaction Type Toggle
            _buildTypeToggle(),
            const SizedBox(height: 20),

            // Category Selector
            const Text(
              'Category',
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
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
                      color: isSelected ? kAccent.withValues(alpha: 0.18) : kBgCard,
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
            const SizedBox(height: 20),

            // Optional note & date
            const Text(
              'Details',
              style: TextStyle(
                color: kTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 10),

            Container(
              decoration: BoxDecoration(
                color: kBgCard,
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

            GestureDetector(
              onTap: _presentDatePicker,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: kBgCard,
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
            const SizedBox(height: 24),

            // Save Button
            ScaleOnTap(
              onTap: _updateTransaction,
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: kAccent,
                  borderRadius: BorderRadius.circular(14),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Save Changes',
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
    );
  }

  Widget _buildTypeToggle() {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        color: kBgCard,
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
                    color: kBgElevated,
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
}
