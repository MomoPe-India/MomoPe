// lib/features/alerts/screens/notifications_screen.dart
//
// Displays push notification history for the current user.
// Reads from `notifications` table (if present) or shows a clean empty state.
// Also surfaces recent transaction activity as notification cards.

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/intl.dart';

import '../../../core/theme.dart';

// ── Provider ─────────────────────────────────────────────────────────────────

final _alertsProvider = FutureProvider<List<Map<String, dynamic>>>((ref) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null) return [];

  // Fetch recent transactions as notification feed
  // (sorted most recent first, max 30 items)
  final result = await Supabase.instance.client
      .from('transactions')
      .select('id, status, gross_amount, fiat_amount, coins_applied, created_at, merchants(business_name)')
      .eq('user_id', uid)
      .order('created_at', ascending: false)
      .limit(30);

  return (result as List).cast<Map<String, dynamic>>();
});

// ── Screen ────────────────────────────────────────────────────────────────────

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(_alertsProvider);

    return Scaffold(
      backgroundColor: context.theme.bg,
      appBar: AppBar(
        backgroundColor: context.theme.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Alerts',
          style: TextStyle(
            color: context.theme.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: context.theme.textSecondary),
            onPressed: () => ref.invalidate(_alertsProvider),
          ),
        ],
      ),
      body: alertsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded, size: 48, color: context.theme.textMuted),
              const SizedBox(height: 12),
              Text('Could not load alerts', style: TextStyle(color: context.theme.textSecondary)),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => ref.invalidate(_alertsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return _EmptyState();
          }
          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _AlertCard(txn: items[i]),
          );
        },
      ),
    );
  }
}

// ── Alert Card ────────────────────────────────────────────────────────────────

class _AlertCard extends StatelessWidget {
  final Map<String, dynamic> txn;
  const _AlertCard({required this.txn});

  @override
  Widget build(BuildContext context) {
    final status = txn['status'] as String? ?? '';
    final grossAmount = (txn['gross_amount'] as num?)?.toDouble() ?? 0;
    final coinsApplied = (txn['coins_applied'] as num?)?.toDouble() ?? 0;
    final createdAt = txn['created_at'] as String? ?? '';
    final merchantName = (txn['merchants'] as Map<String, dynamic>?)?['business_name'] as String? ?? 'Merchant';

    final isSuccess = status == 'success';
    final isFailed  = status == 'failed';

    final Color iconColor = isSuccess
        ? context.theme.success
        : isFailed
            ? context.theme.error
            : context.theme.textMuted;

    final IconData iconData = isSuccess
        ? Icons.check_circle_rounded
        : isFailed
            ? Icons.cancel_rounded
            : Icons.hourglass_top_rounded;

    String timeLabel = '';
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      timeLabel = DateFormat('d MMM · h:mm a').format(dt);
    } catch (_) {}

    String title;
    String subtitle;

    if (isSuccess) {
      title = 'Payment at $merchantName';
      subtitle = '₹${grossAmount.toStringAsFixed(0)} paid'
          '${coinsApplied > 0 ? ' · ${coinsApplied.toStringAsFixed(0)} coins redeemed' : ''}';
    } else if (isFailed) {
      title = 'Payment failed at $merchantName';
      subtitle = '₹${grossAmount.toStringAsFixed(0)} · '
          '${coinsApplied > 0 ? 'Coins restored' : 'No coins affected'}';
    } else {
      title = 'Payment pending at $merchantName';
      subtitle = '₹${grossAmount.toStringAsFixed(0)} · Processing…';
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: context.theme.card,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: context.theme.surfaceAlt),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(iconData, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: context.theme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: context.theme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            timeLabel,
            style: TextStyle(
              color: context.theme.textMuted,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Empty state ────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: context.theme.surface,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                size: 40,
                color: context.theme.textMuted,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No alerts yet',
              style: TextStyle(
                color: context.theme.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your payment receipts, coin credits,\nand updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: context.theme.textSecondary,
                fontSize: 13,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
