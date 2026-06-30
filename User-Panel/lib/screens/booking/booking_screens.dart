import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key, required this.field});

  final String field;

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final _searchController = TextEditingController();

  static const _suggestions = [
    'Connaught Place, New Delhi',
    'Indira Gandhi International Airport',
    'Cyber City, Gurugram',
    'India Gate, New Delhi',
    'Select Citywalk, Saket',
    'Hauz Khas Village',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPickup = widget.field == 'pickup';
    final query = _searchController.text.toLowerCase();
    final filtered = _suggestions
        .where((s) => query.isEmpty || s.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(isPickup ? 'Set pickup' : 'Set destination'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                hintText: 'Search location',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() {});
                        },
                      )
                    : null,
              ),
            ),
          ),
          if (isPickup)
            ListTile(
              leading: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.my_location, color: AppColors.primary),
              ),
              title: const Text('Use current location'),
              subtitle: const Text('GPS based'),
              onTap: () => context.pop('Current Location'),
            ),
          Expanded(
            child: ListView.separated(
              itemCount: filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, index) {
                final place = filtered[index];
                return ListTile(
                  leading: const Icon(Icons.place_outlined, color: AppColors.mutedForeground),
                  title: Text(place),
                  onTap: () => context.pop(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class BookRideScreen extends StatelessWidget {
  const BookRideScreen({super.key});

  static const _vehicles = [
    ('Bike', '₹45', '4 min', Icons.two_wheeler),
    ('Auto', '₹65', '5 min', Icons.electric_rickshaw),
    ('Cab', '₹120', '6 min', Icons.directions_car),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Choose a ride')),
      body: Column(
        children: [
          Container(
            height: 180,
            width: double.infinity,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.muted,
              borderRadius: BorderRadius.circular(AppRadius.card),
            ),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.map_outlined, size: 48, color: AppColors.mutedForeground),
                  SizedBox(height: 8),
                  Text('Map preview', style: TextStyle(color: AppColors.mutedForeground)),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              children: [
                ..._vehicles.map(
                  (v) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(AppRadius.card),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        Icon(v.$4, size: 32, color: AppColors.primary),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(v.$1, style: const TextStyle(fontWeight: FontWeight.bold)),
                              Text(v.$3, style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text(
                          v.$2,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: AppButton(
              label: 'Confirm booking',
              onPressed: () => context.push('/book/searching'),
            ),
          ),
        ],
      ),
    );
  }
}

class RideSearchingScreen extends StatefulWidget {
  const RideSearchingScreen({super.key});

  @override
  State<RideSearchingScreen> createState() => _RideSearchingScreenState();
}

class _RideSearchingScreenState extends State<RideSearchingScreen> {
  @override
  void initState() {
    super.initState();
    Future<void>.delayed(const Duration(seconds: 3), () {
      if (mounted) context.pushReplacement('/book/tracking');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(strokeWidth: 3),
            ),
            const SizedBox(height: 24),
            Text(
              'Finding your captain...',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              'Matching with nearby drivers',
              style: TextStyle(color: AppColors.mutedForeground),
            ),
          ],
        ),
      ),
    );
  }
}

class RideTrackingScreen extends StatelessWidget {
  const RideTrackingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live tracking')),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: AppColors.muted,
              child: const Center(
                child: Icon(Icons.map, size: 64, color: AppColors.mutedForeground),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.primary,
                      child: const Text('A', style: TextStyle(color: Colors.white)),
                    ),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Amit Singh', style: TextStyle(fontWeight: FontWeight.bold)),
                          Text('Honda Activa • DL 5S AB 4521',
                              style: TextStyle(color: AppColors.mutedForeground, fontSize: 13)),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        '4 mins away',
                        style: TextStyle(color: AppColors.success, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.phone),
                        label: const Text('Call'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.message),
                        label: const Text('Message'),
                      ),
                    ),
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
