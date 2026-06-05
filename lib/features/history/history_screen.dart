import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/date_utils.dart';
import '../../database/models/transaction_model.dart';
import '../../providers/transaction_provider.dart';
import 'widgets/edit_transaction_sheet.dart';
import 'widgets/filter_bar.dart';
import 'widgets/transaction_tile.dart';

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  String _selectedFilter = 'This Month';
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  bool _doesDateMatchFilter(DateTime date, String filter) {
    switch (filter) {
      case 'Today':
        final DateTime start = AppDateUtils.getStartOfToday();
        final DateTime end = AppDateUtils.getEndOfToday();
        return date.isAfter(start.subtract(const Duration(microseconds: 1))) &&
            date.isBefore(end.add(const Duration(microseconds: 1)));
      case 'This Week':
        final DateTime start = AppDateUtils.getStartOfWeek();
        return date.isAfter(start.subtract(const Duration(microseconds: 1)));
      case 'This Month':
        final DateTime start = AppDateUtils.getStartOfMonth();
        return date.isAfter(start.subtract(const Duration(microseconds: 1)));
      case 'This Year':
        final DateTime start = AppDateUtils.getStartOfYear();
        return date.isAfter(start.subtract(const Duration(microseconds: 1)));
      case 'All Time':
      default:
        return true;
    }
  }

  void _openEditSheet(Transaction tx) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return EditTransactionSheet(transaction: tx);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<Transaction>> txsAsync = ref.watch(transactionProvider);

    return Scaffold(
      backgroundColor: kBgDeep,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Screen Title
              const Text(
                'History',
                style: TextStyle(
                  color: kTextPrimary,
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Search Notes Bar (Always visible, clean and borderless)
              Container(
                decoration: BoxDecoration(
                  color: kBgElevated,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kBorderSubtle, width: 1),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Row(
                  children: <Widget>[
                    const Icon(PhosphorIconsRegular.magnifyingGlass, color: kTextSecondary, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        cursorColor: kAccent,
                        style: const TextStyle(color: kTextPrimary, fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'Search notes...',
                          hintStyle: TextStyle(color: kTextMuted),
                          border: InputBorder.none,
                          isDense: true,
                        ),
                        onChanged: (String val) {
                          setState(() {
                            _searchQuery = val.trim();
                          });
                        },
                      ),
                    ),
                    if (_searchQuery.isNotEmpty)
                      GestureDetector(
                        onTap: () {
                          _searchController.clear();
                          setState(() {
                            _searchQuery = '';
                          });
                        },
                        child: const Icon(PhosphorIconsRegular.x, color: kTextSecondary, size: 16),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Horizontal Filter Bar
              FilterBar(
                selectedFilter: _selectedFilter,
                onFilterChanged: (String newFilter) {
                  setState(() {
                    _selectedFilter = newFilter;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Transaction List
              Expanded(
                child: txsAsync.when(
                  data: (List<Transaction> allTxs) {
                    // Filter in memory
                    final List<Transaction> filteredTxs = allTxs.where((Transaction tx) {
                      final bool dateMatches = _doesDateMatchFilter(tx.date, _selectedFilter);
                      final bool searchMatches = _searchQuery.isEmpty ||
                          (tx.note != null &&
                              tx.note!.toLowerCase().contains(_searchQuery.toLowerCase()));
                      return dateMatches && searchMatches;
                    }).toList();

                    if (filteredTxs.isEmpty) {
                      return _buildEmptyState();
                    }

                    return ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      itemCount: filteredTxs.length,
                      separatorBuilder: (BuildContext context, int index) => const SizedBox(height: 4),
                      itemBuilder: (BuildContext context, int index) {
                        final Transaction tx = filteredTxs[index];

                        return Dismissible(
                          key: ValueKey<int>(tx.id),
                          direction: DismissDirection.endToStart,
                          confirmDismiss: (DismissDirection direction) async {
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
                            return confirm == true;
                          },
                          onDismissed: (DismissDirection direction) async {
                            await ref.read(transactionProvider.notifier).delete(tx.id);
                          },
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 20),
                            decoration: BoxDecoration(
                              color: kColorExpense.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(PhosphorIconsRegular.trash, color: kColorExpense),
                          ),
                          child: TransactionTile(
                            transaction: tx,
                            onTap: () => _openEditSheet(tx),
                          ),
                        );
                      },
                    );
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(color: kAccent),
                  ),
                  error: (Object err, StackTrace stack) => Center(
                    child: Text(
                      'Error: $err',
                      style: const TextStyle(color: kColorExpense),
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

  Widget _buildEmptyState() {
    final bool isFiltered = _selectedFilter != 'All Time' || _searchQuery.isNotEmpty;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            isFiltered ? PhosphorIconsRegular.funnel : PhosphorIconsRegular.receipt,
            size: 48,
            color: kTextMuted,
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'Nothing here' : 'No transactions yet',
            style: const TextStyle(
              color: kTextSecondary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered ? 'Try a different filter' : 'Add your first one',
            style: const TextStyle(
              color: kTextMuted,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
