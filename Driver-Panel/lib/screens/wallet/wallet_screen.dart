import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/theme/app_radius.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/models/trip_model.dart';
import 'package:wavego_driver/models/wallet_model.dart';
import 'package:wavego_driver/repositories/trip_repository.dart';
import 'package:wavego_driver/repositories/wallet_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

enum _TxnFilter { all, pending, credit, debit }

enum _EarningsPeriod { today, week, month }

class WalletScreen extends ConsumerStatefulWidget {
  const WalletScreen({super.key, this.initialTab = 1, this.embedded = false});

  final int initialTab;
  final bool embedded;

  @override
  ConsumerState<WalletScreen> createState() => _WalletScreenState();
}

class _WalletScreenState extends ConsumerState<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  WalletInfo? _wallet;
  EarningsSummary? _earnings;
  List<WalletTransaction> _transactions = [];
  _TxnFilter _txnFilter = _TxnFilter.all;
  _EarningsPeriod _earningsPeriod = _EarningsPeriod.week;
  bool _loading = true;
  int _referBannerIndex = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 2,
      vsync: this,
      initialIndex: widget.initialTab.clamp(0, 1),
    );
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final walletRepo = ref.read(walletRepositoryProvider);
      final tripRepo = ref.read(tripRepositoryProvider);
      final results = await Future.wait([
        walletRepo.getWallet(),
        walletRepo.getTransactions(),
        tripRepo.getEarnings(),
      ]);
      if (!mounted) return;
      setState(() {
        _wallet = results[0] as WalletInfo;
        _transactions = results[1] as List<WalletTransaction>;
        _earnings = results[2] as EarningsSummary;
        _loading = false;
      });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<WalletTransaction> get _filteredTransactions {
    return _transactions.where((t) {
      switch (_txnFilter) {
        case _TxnFilter.pending:
          return t.status.toLowerCase() == 'pending';
        case _TxnFilter.credit:
          return t.type.toLowerCase() == 'credit';
        case _TxnFilter.debit:
          return t.type.toLowerCase() == 'debit';
        case _TxnFilter.all:
          return true;
      }
    }).toList();
  }

  Future<void> _withdraw() async {
    if (_wallet == null) return;
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Withdraw Funds',
      message:
          'Withdraw ${DateFormatter.currency(_wallet!.currentBalance)} to your linked account?',
    );
    if (confirmed != true) return;

    try {
      await ref.read(walletRepositoryProvider).withdraw(
            WithdrawRequest(
              amount: _wallet!.currentBalance,
              paymentMethod: 'bank',
            ),
          );
      if (mounted) {
        AppDialog.showSuccess(
          context: context,
          title: 'Withdrawal initiated',
          message: 'Funds will reach your account in 1–3 business days.',
        );
        _load();
      }
    } catch (e) {
      if (mounted) {
        AppDialog.showError(context: context, message: e.toString());
      }
    }
  }

  Future<void> _onAddAccount() async {
    final bank = _wallet?.bank;
    final saved = await context.push<bool>(
      RouteNames.paymentMethod,
      extra: bank,
    );
    if (saved == true && mounted) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        automaticallyImplyLeading: !widget.embedded,
        title: Text(
          'Earnings',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: -0.3,
              ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: OutlinedButton.icon(
              onPressed: () => context.push(RouteNames.support),
              icon: const Icon(Icons.headset_mic_outlined, size: 18),
              label: const Text('Help'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textPrimary,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.chip),
                ),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: TabBar(
            controller: _tabController,
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500),
            tabs: const [
              Tab(text: 'All Earnings'),
              Tab(text: 'Wallet'),
            ],
          ),
        ),
      ),
      body: _loading
          ? const _WalletLoadingSkeleton()
          : TabBarView(
              controller: _tabController,
              children: [
                _EarningsTab(
                  earnings: _earnings,
                  period: _earningsPeriod,
                  onPeriodChanged: (p) => setState(() => _earningsPeriod = p),
                  onRefresh: _load,
                ),
                _WalletTab(
                  wallet: _wallet,
                  transactions: _filteredTransactions,
                  txnFilter: _txnFilter,
                  referBannerIndex: _referBannerIndex,
                  onRefresh: _load,
                  onAddAccount: _onAddAccount,
                  onWithdraw: _wallet?.bank != null ? _withdraw : null,
                  onFilterChanged: (filter) =>
                      setState(() => _txnFilter = filter),
                  onReferBannerChanged: (index) =>
                      setState(() => _referBannerIndex = index),
                ),
              ],
            ),
    );
  }
}

class _WalletLoadingSkeleton extends StatelessWidget {
  const _WalletLoadingSkeleton();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        ShimmerLoading(height: 180, borderRadius: 20),
        SizedBox(height: 16),
        ShimmerLoading(height: 88, borderRadius: 20),
        SizedBox(height: 24),
        ShimmerLoading(height: 24, width: 160, borderRadius: 8),
        SizedBox(height: 12),
        ShimmerLoading(height: 36, borderRadius: 20),
        SizedBox(height: 20),
        ListSkeleton(itemCount: 4, itemHeight: 64),
      ],
    );
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab({
    required this.earnings,
    required this.period,
    required this.onPeriodChanged,
    required this.onRefresh,
  });

  final EarningsSummary? earnings;
  final _EarningsPeriod period;
  final ValueChanged<_EarningsPeriod> onPeriodChanged;
  final Future<void> Function() onRefresh;

  double _amountForPeriod(EarningsSummary e) => switch (period) {
        _EarningsPeriod.today => e.todayEarnings,
        _EarningsPeriod.week => e.weeklyEarnings,
        _EarningsPeriod.month => e.monthlyEarnings,
      };

  int _tripsForPeriod(EarningsSummary e) => switch (period) {
        _EarningsPeriod.today => e.todayTrips,
        _ => e.totalTrips,
      };

  String _periodLabel() => switch (period) {
        _EarningsPeriod.today => 'Today',
        _EarningsPeriod.week => 'This week',
        _EarningsPeriod.month => 'This month',
      };

  @override
  Widget build(BuildContext context) {
    if (earnings == null) {
      return ErrorStateWidget(
        message: 'Failed to load earnings',
        onRetry: onRefresh,
      );
    }

    final e = earnings!;
    final chartData = e.chart.isNotEmpty
        ? e.chart
        : [
            EarningsDataPoint(label: 'Mon', amount: e.weeklyEarnings * 0.12),
            EarningsDataPoint(label: 'Tue', amount: e.weeklyEarnings * 0.18),
            EarningsDataPoint(label: 'Wed', amount: e.weeklyEarnings * 0.15),
            EarningsDataPoint(label: 'Thu', amount: e.weeklyEarnings * 0.2),
            EarningsDataPoint(label: 'Fri', amount: e.weeklyEarnings * 0.22),
            EarningsDataPoint(label: 'Sat', amount: e.weeklyEarnings * 0.08),
            EarningsDataPoint(label: 'Sun', amount: e.weeklyEarnings * 0.05),
          ];

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(AppRadius.card),
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.22),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _periodLabel(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateFormatter.currency(_amountForPeriod(e)),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${_tripsForPeriod(e)} trips completed',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _PeriodChip(
                label: 'Today',
                selected: period == _EarningsPeriod.today,
                onTap: () => onPeriodChanged(_EarningsPeriod.today),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'Week',
                selected: period == _EarningsPeriod.week,
                onTap: () => onPeriodChanged(_EarningsPeriod.week),
              ),
              const SizedBox(width: 8),
              _PeriodChip(
                label: 'Month',
                selected: period == _EarningsPeriod.month,
                onTap: () => onPeriodChanged(_EarningsPeriod.month),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _EarningsChartCard(data: chartData),
          const SizedBox(height: 16),
          _EarningCard(
            label: 'Today',
            amount: e.todayEarnings,
            trips: e.todayTrips,
            icon: Icons.wb_sunny_outlined,
          ),
          const SizedBox(height: 10),
          _EarningCard(
            label: 'This Week',
            amount: e.weeklyEarnings,
            trips: e.totalTrips,
            icon: Icons.date_range_outlined,
          ),
          const SizedBox(height: 10),
          _EarningCard(
            label: 'This Month',
            amount: e.monthlyEarnings,
            trips: e.totalTrips,
            icon: Icons.calendar_month_outlined,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _SmallStatCard(
                  label: 'Bonuses',
                  value: DateFormatter.currency(e.bonuses),
                  icon: Icons.card_giftcard_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _SmallStatCard(
                  label: 'Incentives',
                  value: DateFormatter.currency(e.incentives),
                  icon: Icons.emoji_events_outlined,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EarningsChartCard extends StatelessWidget {
  const _EarningsChartCard({required this.data});

  final List<EarningsDataPoint> data;

  @override
  Widget build(BuildContext context) {
    final maxY = data.fold<double>(
      0,
      (max, p) => p.amount > max ? p.amount : max,
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earnings trend',
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: BarChart(
              BarChartData(
                maxY: maxY <= 0 ? 100 : maxY * 1.2,
                gridData: FlGridData(
                  show: true,
                  drawVerticalLine: false,
                  horizontalInterval: maxY <= 0 ? 25 : maxY / 4,
                  getDrawingHorizontalLine: (_) => FlLine(
                    color: AppColors.border,
                    strokeWidth: 1,
                  ),
                ),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  topTitles: const AxisTitles(),
                  rightTitles: const AxisTitles(),
                  leftTitles: const AxisTitles(),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 28,
                      getTitlesWidget: (value, meta) {
                        final i = value.toInt();
                        if (i < 0 || i >= data.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Text(
                            data[i].label,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontSize: 10,
                                ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List.generate(data.length, (i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: [
                      BarChartRodData(
                        toY: data[i].amount,
                        width: 14,
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(6),
                        ),
                        color: AppColors.primary,
                        backDrawRodData: BackgroundBarChartRodData(
                          show: true,
                          toY: maxY <= 0 ? 100 : maxY * 1.2,
                          color: AppColors.muted.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PeriodChip extends StatelessWidget {
  const _PeriodChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _EarningCard extends StatelessWidget {
  const _EarningCard({
    required this.label,
    required this.amount,
    required this.trips,
    required this.icon,
  });

  final String label;
  final double amount;
  final int trips;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormatter.currency(amount),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.3,
                      ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$trips trips',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SmallStatCard extends StatelessWidget {
  const _SmallStatCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primary, size: 22),
          const SizedBox(height: 10),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
        ],
      ),
    );
  }
}

class _WalletTab extends StatelessWidget {
  const _WalletTab({
    required this.wallet,
    required this.transactions,
    required this.txnFilter,
    required this.referBannerIndex,
    required this.onRefresh,
    required this.onAddAccount,
    required this.onWithdraw,
    required this.onFilterChanged,
    required this.onReferBannerChanged,
  });

  final WalletInfo? wallet;
  final List<WalletTransaction> transactions;
  final _TxnFilter txnFilter;
  final int referBannerIndex;
  final Future<void> Function() onRefresh;
  final VoidCallback onAddAccount;
  final VoidCallback? onWithdraw;
  final ValueChanged<_TxnFilter> onFilterChanged;
  final ValueChanged<int> onReferBannerChanged;

  @override
  Widget build(BuildContext context) {
    if (wallet == null) {
      return ErrorStateWidget(
        message: 'Failed to load wallet',
        onRetry: onRefresh,
      );
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
        children: [
          _WalletBalanceCard(
            wallet: wallet!,
            onAddAccount: onAddAccount,
            onWithdraw: onWithdraw,
          ),
          const SizedBox(height: 12),
          _SettlementInfoBanner(),
          const SizedBox(height: 14),
          _ReferBannerCarousel(
            index: referBannerIndex,
            onChanged: onReferBannerChanged,
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                'Transaction History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                    ),
              ),
              const Spacer(),
              Text(
                '${transactions.length} items',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _FilterChip(
                  label: 'All',
                  selected: txnFilter == _TxnFilter.all,
                  onTap: () => onFilterChanged(_TxnFilter.all),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Pending',
                  selected: txnFilter == _TxnFilter.pending,
                  onTap: () => onFilterChanged(_TxnFilter.pending),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Credits',
                  selected: txnFilter == _TxnFilter.credit,
                  onTap: () => onFilterChanged(_TxnFilter.credit),
                ),
                const SizedBox(width: 8),
                _FilterChip(
                  label: 'Debits',
                  selected: txnFilter == _TxnFilter.debit,
                  onTap: () => onFilterChanged(_TxnFilter.debit),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          if (transactions.isEmpty)
            _EmptyTransactions(filter: txnFilter)
          else
            ...transactions.map((t) => _TransactionTile(transaction: t)),
        ],
      ),
    );
  }
}

class _WalletBalanceCard extends StatelessWidget {
  const _WalletBalanceCard({
    required this.wallet,
    required this.onAddAccount,
    required this.onWithdraw,
  });

  final WalletInfo wallet;
  final VoidCallback onAddAccount;
  final VoidCallback? onWithdraw;

  @override
  Widget build(BuildContext context) {
    final bank = wallet.bank;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withValues(alpha: 0.08),
                  AppColors.secondary.withValues(alpha: 0.15),
                ],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppRadius.card),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Available balance',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                    ),
                    const Spacer(),
                    if (bank != null) _BankLinkedBadge(bank: bank),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  DateFormatter.currency(wallet.currentBalance),
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1,
                        letterSpacing: -0.8,
                      ),
                ),
                if (wallet.pendingBalance > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        size: 14,
                        color: AppColors.warning,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Pending settlement: ${DateFormatter.currency(wallet.pendingBalance)}',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppColors.warning,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _MiniStat(
                        label: 'Total earned',
                        value: DateFormatter.currency(wallet.totalEarnings),
                      ),
                    ),
                    Container(width: 1, height: 36, color: AppColors.border),
                    Expanded(
                      child: _MiniStat(
                        label: 'Withdrawn',
                        value: DateFormatter.currency(wallet.totalWithdrawn),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: bank != null ? 'Account' : 'Add Bank',
                        icon: Icons.account_balance_outlined,
                        variant: AppButtonVariant.secondary,
                        height: 46,
                        onPressed: onAddAccount,
                      ),
                    ),
                    if (onWithdraw != null && wallet.currentBalance > 0) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        child: AppButton(
                          label: 'Withdraw',
                          variant: AppButtonVariant.primary,
                          height: 46,
                          onPressed: onWithdraw,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _BankLinkedBadge extends StatelessWidget {
  const _BankLinkedBadge({required this.bank});

  final BankInfo bank;

  @override
  Widget build(BuildContext context) {
    final label = bank.upiId != null && bank.upiId!.isNotEmpty
        ? 'UPI linked'
        : 'Bank linked';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.verified, size: 14, color: AppColors.success),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}

class _MiniStat extends StatelessWidget {
  const _MiniStat({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        children: [
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _SettlementInfoBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 18, color: AppColors.info),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Weekly settlement every Monday. Transfers take 1–3 business days.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.35,
                  ),
            ),
          ),
          TextButton(
            onPressed: () => context.push(RouteNames.support),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: const Text('Learn more'),
          ),
        ],
      ),
    );
  }
}

class _ReferBannerCarousel extends StatefulWidget {
  const _ReferBannerCarousel({
    required this.index,
    required this.onChanged,
  });

  final int index;
  final ValueChanged<int> onChanged;

  @override
  State<_ReferBannerCarousel> createState() => _ReferBannerCarouselState();
}

class _ReferBannerCarouselState extends State<_ReferBannerCarousel> {
  late PageController _pageController;

  List<(String, String, String, Color, Color)> get _banners => [
        (
          'Refer and Earn',
          'Up to ₹500',
          'Invite captains and earn when they complete rides.',
          AppColors.secondary.withValues(alpha: 0.35),
          AppColors.primary,
        ),
        (
          'Ride streak bonus',
          'Earn more',
          'Complete more trips this week for extra incentives.',
          AppColors.info.withValues(alpha: 0.12),
          AppColors.primary,
        ),
      ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.index);
  }

  @override
  void didUpdateWidget(covariant _ReferBannerCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.index != widget.index) {
      _pageController.animateToPage(
        widget.index,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 108,
          child: PageView.builder(
            controller: _pageController,
            itemCount: _banners.length,
            onPageChanged: widget.onChanged,
            itemBuilder: (context, i) {
              final (title, subtitle, desc, bg, accent) = _banners[i];
              return Container(
                margin: const EdgeInsets.only(right: 4),
                padding: const EdgeInsets.fromLTRB(18, 16, 14, 16),
                decoration: BoxDecoration(
                  color: bg,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            title,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            subtitle,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.w800,
                                  color: accent,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            desc,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: AppColors.textSecondary,
                                  height: 1.3,
                                ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.payments_outlined,
                      size: 44,
                      color: accent.withValues(alpha: 0.65),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(_banners.length, (i) {
            final active = i == widget.index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 18 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active ? AppColors.primary : AppColors.muted,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.muted,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: selected ? Colors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }
}

class _EmptyTransactions extends StatelessWidget {
  const _EmptyTransactions({required this.filter});

  final _TxnFilter filter;

  String get _message => switch (filter) {
        _TxnFilter.pending => 'No pending transactions',
        _TxnFilter.credit => 'No credits yet',
        _TxnFilter.debit => 'No debits yet',
        _ => 'No transactions yet',
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 28),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.receipt_long_outlined,
              size: 36,
              color: AppColors.primary.withValues(alpha: 0.55),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            _message,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your ride payouts and withdrawals will show here.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppColors.textSecondary,
                ),
          ),
        ],
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.transaction});

  final WalletTransaction transaction;

  @override
  Widget build(BuildContext context) {
    final isCredit = transaction.type.toLowerCase() == 'credit';
    final iconColor = isCredit ? AppColors.success : AppColors.error;
    final bgColor = iconColor.withValues(alpha: 0.1);

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.foreground.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              isCredit ? Icons.south_west : Icons.north_east,
              color: iconColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  transaction.description ?? _titleForType(transaction.type),
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 3),
                Text(
                  _formatDate(transaction.createdAt),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${isCredit ? '+' : '−'}${DateFormatter.currency(transaction.amount)}',
                style: TextStyle(
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                  color: iconColor,
                ),
              ),
              if (transaction.status.toLowerCase() == 'pending')
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.warning.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    'Pending',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.warning,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  String _titleForType(String type) => switch (type.toLowerCase()) {
        'credit' => 'Ride earnings',
        'debit' => 'Withdrawal',
        _ => type,
      };

  String _formatDate(String raw) {
    try {
      return DateFormatter.date(DateTime.parse(raw));
    } catch (_) {
      return raw.split('T').first;
    }
  }
}
