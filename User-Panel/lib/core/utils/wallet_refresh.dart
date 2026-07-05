import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/repositories/user_repositories.dart';

/// Instant wallet UI after Razorpay payment before network refresh completes.
final walletSummaryOverrideProvider = StateProvider<WalletSummary?>((ref) => null);

final resolvedWalletProvider = Provider<AsyncValue<WalletSummary>>((ref) {
  final override = ref.watch(walletSummaryOverrideProvider);
  if (override != null) {
    return AsyncData(override);
  }
  return ref.watch(walletProvider);
});

WalletSummary _mergeWalletSummary({
  required double balance,
  WalletSummary? current,
}) {
  final bonus = current?.bonusBalance ?? 0;
  return WalletSummary(
    balance: balance,
    bonusBalance: bonus,
    total: balance + bonus,
    paymentMethods: current?.paymentMethods ?? const [],
  );
}

void applyWalletBalance(WidgetRef ref, double balance) {
  final current = ref.read(resolvedWalletProvider).valueOrNull;
  ref.read(walletSummaryOverrideProvider.notifier).state =
      _mergeWalletSummary(balance: balance, current: current);
}

void applyWalletTopUp(WidgetRef ref, double addedAmount) {
  final current = ref.read(resolvedWalletProvider).valueOrNull;
  final nextBalance = (current?.balance ?? 0) + addedAmount;
  applyWalletBalance(ref, nextBalance);
}

Future<WalletSummary> refreshWallet(WidgetRef ref) async {
  try {
    final wallet = await ref.read(walletRepositoryProvider).getWallet();
    final current = ref.read(resolvedWalletProvider).valueOrNull;
    if (current != null && wallet.balance < current.balance) {
      return current;
    }
    ref.read(walletSummaryOverrideProvider.notifier).state = wallet;
    return wallet;
  } catch (_) {
    return ref.read(resolvedWalletProvider).valueOrNull ??
        const WalletSummary(
          balance: 0,
          bonusBalance: 0,
          total: 0,
          paymentMethods: [],
        );
  }
}
