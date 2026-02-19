import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/transaction.dart';
import 'merchant_provider.dart';

/// Merchant Transactions Stream Provider
/// Real-time subscription to merchant's transactions
final merchantTransactionsProvider = StreamProvider<List<Transaction>>((ref) {
  final merchantId = ref.watch(merchantIdProvider);
  
  if (merchantId == null) {
    return Stream.value([]);
  }

  return Supabase.instance.client
      .from('transactions')
      .stream(primaryKey: ['id'])
      .eq('merchant_id', merchantId)
      .order('created_at', ascending: false)
      .map((data) => data.map((json) => Transaction.fromJson(json)).toList());
});

/// Filtered Transactions Provider
/// Filter transactions by status
final filteredTransactionsProvider = Provider.family<AsyncValue<List<Transaction>>, String?>((ref, statusFilter) {
  final transactionsAsync = ref.watch(merchantTransactionsProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      if (statusFilter == null || statusFilter == 'all') {
        return AsyncValue.data(transactions);
      }
      
      final filtered = transactions.where((t) => t.status == statusFilter).toList();
      return AsyncValue.data(filtered);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});

/// Today's Transactions Provider
/// Transactions for current day only
final todayTransactionsProvider = Provider<AsyncValue<List<Transaction>>>((ref) {
  final transactionsAsync = ref.watch(merchantTransactionsProvider);
  
  return transactionsAsync.when(
    data: (transactions) {
      final now = DateTime.now();
      final startOfDay = DateTime(now.year, now.month, now.day);
      final endOfDay = startOfDay.add(const Duration(days: 1));
      
      final todayTxns = transactions.where((t) {
        final createdAt = t.createdAt;
        return createdAt.isAfter(startOfDay) && createdAt.isBefore(endOfDay);
      }).toList();
      
      return AsyncValue.data(todayTxns);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
});
