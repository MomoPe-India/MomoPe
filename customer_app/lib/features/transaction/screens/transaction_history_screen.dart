// lib/features/transaction/screens/transaction_history_screen.dart
//
// Premium Transaction History screen — filter tabs, modern cards,
// running coin totals, pull-to-refresh, smooth empty + error states.

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/models.dart';
import '../../../core/theme.dart';

// ── Provider ──────────────────────────────────────────────────────────────────

final _txnHistoryProvider = FutureProvider<List<TransactionModel>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];
  final data = await Supabase.instance.client.rpc(
    'get_customer_transactions',
    params: {'firebase_uid': uid},
  );
  final list = data as List? ?? [];
  return list.map((t) => TransactionModel.fromMap(t as Map<String, dynamic>)).toList();
});

// ── Filter tabs ───────────────────────────────────────────────────────────────

const _kFilters = ['All', 'Success', 'Failed', 'Pending'];

// ── Screen ────────────────────────────────────────────────────────────────────

class TransactionHistoryScreen extends ConsumerStatefulWidget {
  const TransactionHistoryScreen({super.key});

  @override
  ConsumerState<TransactionHistoryScreen> createState() => _TransactionHistoryScreenState();
}

class _TransactionHistoryScreenState extends ConsumerState<TransactionHistoryScreen> {
  int _filterIdx = 0;

  List<TransactionModel> _applyFilter(List<TransactionModel> all) {
    if (_filterIdx == 0) return all;
    final key = _kFilters[_filterIdx].toLowerCase();
    return all.where((t) => t.status == key).toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme     = context.theme;
    final txnsAsync = ref.watch(_txnHistoryProvider);

    return Scaffold(
      backgroundColor: theme.bg,
      appBar: AppBar(
        backgroundColor: theme.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Transactions',
          style: TextStyle(color: theme.textPrimary, fontSize: 20, fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.textSecondary),
            onPressed: () => ref.invalidate(_txnHistoryProvider),
          ),
        ],
      ),
      body: txnsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _ErrorState(onRetry: () => ref.invalidate(_txnHistoryProvider)),
        data: (all) {
          // Summary stats (from all transactions regardless of filter)
          final successTxns = all.where((t) => t.status == 'success');
          final totalSpent   = successTxns.fold<double>(0, (s, t) => s + t.grossAmount);
          final totalEarned  = successTxns.fold<double>(0, (s, t) => s + (t.coinsEarned ?? 0));
          final totalRedeemed= successTxns.fold<double>(0, (s, t) => s + t.coinsApplied);

          final filtered = _applyFilter(all);

          return RefreshIndicator(
            color: theme.primary,
            onRefresh: () async => ref.invalidate(_txnHistoryProvider),
            child: CustomScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              slivers: [
                // ── Summary card ─────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                    child: _SummaryCard(
                      totalSpent: totalSpent,
                      coinsEarned: totalEarned,
                      coinsRedeemed: totalRedeemed,
                      txnCount: all.length,
                    ),
                  ),
                ),

                // ── Filter tabs ───────────────────────────────────────────────
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                    child: Row(
                      children: List.generate(_kFilters.length, (i) {
                        final selected = i == _filterIdx;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _filterIdx = i),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: EdgeInsets.only(right: i < _kFilters.length - 1 ? 6 : 0),
                              padding: const EdgeInsets.symmetric(vertical: 9),
                              decoration: BoxDecoration(
                                color: selected ? theme.primary : theme.surfaceAlt,
                                borderRadius: BorderRadius.circular(50),
                                boxShadow: selected
                                    ? [BoxShadow(color: theme.primary.withValues(alpha: 0.3), blurRadius: 8, offset: const Offset(0, 3))]
                                    : [],
                              ),
                              child: Text(
                                _kFilters[i],
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: selected ? Colors.white : theme.textSecondary,
                                  fontSize: 12,
                                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ),

                // ── List ─────────────────────────────────────────────────────
                if (filtered.isEmpty)
                  SliverFillRemaining(child: _EmptyState(filter: _kFilters[_filterIdx]))
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 100),
                    sliver: SliverList.separated(
                      itemCount: filtered.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (_, i) => _TxnCard(txn: filtered[i]),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ── Summary Card ──────────────────────────────────────────────────────────────

class _SummaryCard extends StatelessWidget {
  final double totalSpent, coinsEarned, coinsRedeemed;
  final int txnCount;
  const _SummaryCard({
    required this.totalSpent,
    required this.coinsEarned,
    required this.coinsRedeemed,
    required this.txnCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final moneyFmt = NumberFormat('#,##0', 'en_IN');

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: theme.coinGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: theme.primary.withValues(alpha: 0.3), blurRadius: 20, offset: const Offset(0, 8)),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Total Spent', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  '₹${moneyFmt.format(totalSpent)}',
                  style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.w900),
                ),
              ]),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '$txnCount payments',
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(children: [
            _SumStat(label: 'Coins Earned', value: '+${coinsEarned.toStringAsFixed(0)}', color: Colors.white),
            Container(width: 1, height: 32, color: Colors.white.withValues(alpha: 0.3), margin: const EdgeInsets.symmetric(horizontal: 16)),
            _SumStat(label: 'Coins Redeemed', value: '-${coinsRedeemed.toStringAsFixed(0)}', color: Colors.white70),
          ]),
        ],
      ),
    );
  }
}

class _SumStat extends StatelessWidget {
  final String label, value;
  final Color color;
  const _SumStat({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: TextStyle(color: Colors.white60, fontSize: 11)),
      const SizedBox(height: 2),
      Text(value, style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w800)),
    ],
  );
}

// ── Transaction Card ──────────────────────────────────────────────────────────

class _TxnCard extends StatelessWidget {
  final TransactionModel txn;
  const _TxnCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final dateFmt = DateFormat('d MMM · h:mm a');
    final isSuccess = txn.status == 'success';
    final isFailed  = txn.status == 'failed';

    final Color statusColor = switch (txn.status) {
      'success'  => theme.success,
      'failed'   => theme.error,
      'refunded' => theme.warning,
      _          => theme.textMuted,
    };

    final IconData statusIcon = switch (txn.status) {
      'success'  => Icons.check_circle_rounded,
      'failed'   => Icons.cancel_rounded,
      'refunded' => Icons.undo_rounded,
      _          => Icons.hourglass_top_rounded,
    };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: theme.surfaceAlt),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: Merchant + Status
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Status icon circle
              Container(
                width: 42, height: 42,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      txn.merchantName ?? 'Merchant',
                      style: TextStyle(color: theme.textPrimary, fontWeight: FontWeight.w700, fontSize: 15),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      dateFmt.format(txn.createdAt.toLocal()),
                      style: TextStyle(color: theme.textMuted, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${txn.grossAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      color: theme.textPrimary,
                      fontWeight: FontWeight.w900,
                      fontSize: 18,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(50),
                    ),
                    child: Text(
                      txn.status.toUpperCase(),
                      style: TextStyle(color: statusColor, fontSize: 9, fontWeight: FontWeight.w800, letterSpacing: 0.5),
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Row 2: Coin details (only on success)
          if (isSuccess && ((txn.coinsEarned ?? 0) > 0 || txn.coinsApplied > 0)) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.surfaceAlt,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                children: [
                  const Icon(Icons.toll_rounded, size: 14, color: Color(0xFFFFB300)),
                  const SizedBox(width: 6),
                  if ((txn.coinsEarned ?? 0) > 0)
                    Text(
                      '+${(txn.coinsEarned ?? 0).toStringAsFixed(0)} earned',
                      style: TextStyle(color: theme.success, fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                  if ((txn.coinsEarned ?? 0) > 0 && txn.coinsApplied > 0)
                    Text('  ·  ', style: TextStyle(color: theme.textMuted, fontSize: 12)),
                  if (txn.coinsApplied > 0)
                    Text(
                      '${txn.coinsApplied.toStringAsFixed(0)} redeemed',
                      style: TextStyle(color: theme.warning, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                ],
              ),
            ),
          ],

          // Failed coin restore notice
          if (isFailed && txn.coinsApplied > 0) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.error.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(children: [
                Icon(Icons.undo_rounded, size: 13, color: theme.warning),
                const SizedBox(width: 6),
                Text(
                  '${txn.coinsApplied.toStringAsFixed(0)} coins restored',
                  style: TextStyle(color: theme.warning, fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ]),
            ),
          ],
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  final String filter;
  const _EmptyState({required this.filter});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    final isFiltered = filter != 'All';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80, height: 80,
              decoration: BoxDecoration(color: theme.surfaceAlt, shape: BoxShape.circle),
              child: Icon(Icons.receipt_long_rounded, size: 40, color: theme.textMuted),
            ),
            const SizedBox(height: 20),
            Text(
              isFiltered ? 'No $filter transactions' : 'No transactions yet',
              style: TextStyle(color: theme.textPrimary, fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 8),
            Text(
              isFiltered
                  ? 'Try switching to a different filter.'
                  : 'Scan a merchant QR to make your first payment and start earning Momo Coins.',
              textAlign: TextAlign.center,
              style: TextStyle(color: theme.textMuted, fontSize: 13, height: 1.5),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Error state ────────────────────────────────────────────────────────────────

class _ErrorState extends StatelessWidget {
  final VoidCallback onRetry;
  const _ErrorState({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final theme = context.theme;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.wifi_off_rounded, size: 48, color: theme.textMuted),
          const SizedBox(height: 12),
          Text('Could not load transactions', style: TextStyle(color: theme.textSecondary, fontSize: 15, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: onRetry,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(color: theme.primary.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(50)),
              child: Text('Retry', style: TextStyle(color: theme.primary, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}
