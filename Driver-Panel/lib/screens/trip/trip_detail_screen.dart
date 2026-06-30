import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/date_formatter.dart';
import 'package:wavego_driver/models/trip_model.dart';
import 'package:wavego_driver/repositories/trip_repository.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';
import 'package:wavego_driver/widgets/common/stat_card.dart';

class TripDetailScreen extends ConsumerStatefulWidget {
  const TripDetailScreen({super.key, required this.tripId});
  final String tripId;

  @override
  ConsumerState<TripDetailScreen> createState() => _TripDetailScreenState();
}

class _TripDetailScreenState extends ConsumerState<TripDetailScreen> {
  TripDetail? _trip;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final trip = await ref.read(tripRepositoryProvider).getTripDetail(widget.tripId);
    setState(() { _trip = trip; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final trip = _trip!;

    return Scaffold(
      appBar: AppBar(title: Text('Trip #${trip.id.substring(trip.id.length - 4)}')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Route', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  _Loc(Icons.trip_origin, AppColors.success, trip.pickupAddress),
                  const SizedBox(height: 12),
                  _Loc(Icons.location_on, AppColors.error, trip.destinationAddress),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(title: 'Distance', value: DateFormatter.distance(trip.distance), icon: Icons.straighten)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: 'Duration', value: DateFormatter.duration(trip.duration), icon: Icons.access_time)),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _DetailRow('Fare', DateFormatter.currency(trip.fare)),
                  _DetailRow('Commission', DateFormatter.currency(trip.commission)),
                  _DetailRow('Net Earnings', DateFormatter.currency(trip.netEarnings), bold: true),
                  _DetailRow('Payment', trip.paymentMode),
                  if (trip.passengerName != null) _DetailRow('Passenger', trip.passengerName!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Loc extends StatelessWidget {
  const _Loc(this.icon, this.color, this.text);
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(child: Text(text)),
      ],
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow(this.label, this.value, {this.bold = false});
  final String label;
  final String value;
  final bool bold;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label),
          Text(value, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.w600)),
        ],
      ),
    );
  }
}

class EarningsScreen extends ConsumerStatefulWidget {
  const EarningsScreen({super.key});

  @override
  ConsumerState<EarningsScreen> createState() => _EarningsScreenState();
}

class _EarningsScreenState extends ConsumerState<EarningsScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  EarningsSummary? _earnings;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _load();
  }

  Future<void> _load() async {
    final data = await ref.read(tripRepositoryProvider).getEarnings();
    setState(() { _earnings = data; _loading = false; });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Earnings'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Today'), Tab(text: 'Weekly'), Tab(text: 'Monthly')],
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _earnings == null
              ? const ErrorStateWidget(message: 'Failed to load earnings')
              : TabBarView(
                  controller: _tabController,
                  children: [
                    _EarningsTab(amount: _earnings!.todayEarnings, trips: _earnings!.todayTrips, chart: _earnings!.chart),
                    _EarningsTab(amount: _earnings!.weeklyEarnings, trips: _earnings!.totalTrips, chart: _earnings!.chart),
                    _EarningsTab(amount: _earnings!.monthlyEarnings, trips: _earnings!.totalTrips, chart: _earnings!.chart, showBonuses: true, bonuses: _earnings!.bonuses, incentives: _earnings!.incentives),
                  ],
                ),
    );
  }
}

class _EarningsTab extends StatelessWidget {
  const _EarningsTab({required this.amount, required this.trips, required this.chart, this.showBonuses = false, this.bonuses = 0, this.incentives = 0});
  final double amount;
  final int trips;
  final List<EarningsDataPoint> chart;
  final bool showBonuses;
  final double bonuses;
  final double incentives;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        StatCard(title: 'Total Earnings', value: DateFormatter.currency(amount), icon: Icons.currency_rupee, color: AppColors.secondary),
        const SizedBox(height: 12),
        StatCard(title: 'Trips', value: '$trips', icon: Icons.local_taxi),
        if (showBonuses) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(title: 'Bonuses', value: DateFormatter.currency(bonuses), icon: Icons.card_giftcard, color: AppColors.accent)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(title: 'Incentives', value: DateFormatter.currency(incentives), icon: Icons.emoji_events, color: AppColors.warning)),
            ],
          ),
        ],
        const SizedBox(height: 24),
        Text('Earnings Chart', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
        const SizedBox(height: 16),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              borderData: FlBorderData(show: false),
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      final index = value.toInt();
                      if (index >= 0 && index < chart.length) {
                        return Text(chart[index].label, style: const TextStyle(fontSize: 10));
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: chart.asMap().entries.map((e) {
                return BarChartGroupData(
                  x: e.key,
                  barRods: [BarChartRodData(toY: e.value.amount, color: AppColors.primary, width: 16, borderRadius: const BorderRadius.vertical(top: Radius.circular(4)))],
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }
}
