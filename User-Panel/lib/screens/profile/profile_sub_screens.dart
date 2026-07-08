import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:wavego_user/core/config/app_config.dart';
import 'package:wavego_user/core/constants/support_constants.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/theme/app_radius.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/place_models.dart';
import 'package:wavego_user/models/user_models.dart';
import 'package:wavego_user/core/utils/profile_name_resolver.dart';
import 'package:wavego_user/providers/app_providers.dart';
import 'package:wavego_user/providers/profile_display_provider.dart';
import 'package:wavego_user/core/utils/profile_refresh.dart';
import 'package:wavego_user/repositories/user_repositories.dart';
import 'package:wavego_user/services/saved_places_service.dart';
import 'package:wavego_user/services/user_services.dart';
import 'package:wavego_user/screens/profile/support_screens.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

String _emergencyContactLabel(UserProfile? profile) {
  final name = profile?.emergencyContactName?.trim() ?? '';
  final phone = profile?.emergencyContactPhone?.trim() ?? '';
  if (name.isNotEmpty && phone.isNotEmpty) return '$name • $phone';
  if (phone.isNotEmpty) return phone;
  if (name.isNotEmpty) return name;
  return 'Add emergency contact';
}

class ProfileSettingsScreen extends ConsumerWidget {
  const ProfileSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelAsync = ref.watch(resolvedProfileLabelProvider);
    final profile = ref.watch(userProfileProvider).valueOrNull;

    return Scaffold(
      appBar: AppBar(title: const Text('Account Settings')),
      body: labelAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load profile')),
        data: (resolved) => ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.person_outline),
              title: const Text('Edit profile'),
              subtitle: Text(resolved.name),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.profileEdit),
            ),
            ListTile(
              leading: const Icon(Icons.phone_outlined),
              title: const Text('Phone number'),
              subtitle: Text(resolved.phone.isNotEmpty ? resolved.phone : 'Not set'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.profilePhone),
            ),
            ListTile(
              leading: const Icon(Icons.email_outlined),
              title: const Text('Email'),
              subtitle: Text(profile?.email ?? 'Add your email'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.profileEmail),
            ),
            ListTile(
              leading: const Icon(Icons.contact_emergency_outlined),
              title: const Text('Emergency contact'),
              subtitle: Text(
                _emergencyContactLabel(profile),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.profileEmergencyContact),
            ),
            ListTile(
              leading: const Icon(Icons.notifications_outlined),
              title: const Text('Notifications'),
              subtitle: const Text('Push, SMS and email alerts'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(RouteNames.profileNotifications),
            ),
          ],
        ),
      ),
    );
  }
}

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  bool _saving = false;
  String? _appliedProfileKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      refreshUserProfile(ref);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _applyProfileFields(UserProfile? user) {
    if (user == null) return;

    final dashboard = ref.read(homeDashboardProvider).valueOrNull;
    final resolvedName = ProfileNameResolver.fromProfileAndDashboard(
      profile: user,
      dashboard: dashboard,
    );

    final key = '${user.id}|$resolvedName|${user.email ?? ''}';
    if (_appliedProfileKey == key) return;
    _appliedProfileKey = key;

    _nameController.text = resolvedName;
    _emailController.text = user.email ?? '';
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);
    final dashboardAsync = ref.watch(homeDashboardProvider);

    ref.listen<AsyncValue<UserProfile?>>(userProfileProvider, (_, next) {
      next.whenData(_applyProfileFields);
    });
    ref.listen<AsyncValue<HomeDashboard>>(homeDashboardProvider, (_, next) {
      final user = ref.read(userProfileProvider).valueOrNull;
      if (user != null) _applyProfileFields(user);
    });

    profileAsync.whenData(_applyProfileFields);
    dashboardAsync.whenData((_) {
      final user = profileAsync.valueOrNull;
      if (user != null) _applyProfileFields(user);
    });

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Unable to load profile'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => refreshUserProfile(ref),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (user) {
          final resolved = ref.watch(resolvedProfileLabelProvider).valueOrNull;
          final initial = resolved?.initial ?? user?.displayInitial ?? 'U';

          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 44,
                  backgroundColor: AppColors.primary,
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => context.showSnackBar('Photo upload — coming soon'),
                  child: const Text('Change photo'),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full name',
                    hintText: 'Enter your full name',
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const Spacer(),
                AppButton(
                  label: 'Save changes',
                  isLoading: _saving,
                  onPressed: _saving
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          if (name.length < 2) {
                            context.showSnackBar('Enter your full name');
                            return;
                          }
                          setState(() => _saving = true);
                          try {
                            await ref.read(authRepositoryProvider).updateProfile(
                                  fullName: name,
                                  email: _emailController.text.trim(),
                                );
                            refreshUserProfile(ref);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            context.showSnackBar('Profile updated successfully');
                          } catch (_) {
                            if (context.mounted) {
                              context.showSnackBar('Could not update profile');
                            }
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class PhoneSettingsScreen extends ConsumerWidget {
  const PhoneSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Phone Number')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load')),
        data: (user) => Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(AppRadius.card),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.phone, color: AppColors.primary),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(user?.phone ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                          const Text('Verified', style: TextStyle(color: AppColors.success, fontSize: 13)),
                        ],
                      ),
                    ),
                    const Icon(Icons.verified, color: AppColors.success, size: 20),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              AppButton(
                label: 'Change phone number',
                variant: AppButtonVariant.outline,
                onPressed: () => context.push(RouteNames.phoneLogin),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EmailSettingsScreen extends ConsumerStatefulWidget {
  const EmailSettingsScreen({super.key});

  @override
  ConsumerState<EmailSettingsScreen> createState() => _EmailSettingsScreenState();
}

class _EmailSettingsScreenState extends ConsumerState<EmailSettingsScreen> {
  final _emailController = TextEditingController();
  bool _saving = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Email')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load')),
        data: (user) {
          if (!_hydrated) {
            _emailController.text = user?.email ?? '';
            _hydrated = true;
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email address',
                    hintText: 'you@example.com',
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save email',
                  isLoading: _saving,
                  onPressed: _saving
                      ? null
                      : () async {
                          setState(() => _saving = true);
                          try {
                            await ref.read(authRepositoryProvider).updateProfile(
                                  email: _emailController.text.trim(),
                                );
                            refreshUserProfile(ref);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            context.showSnackBar('Email saved');
                          } catch (_) {
                            if (context.mounted) {
                              context.showSnackBar('Could not save email');
                            }
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class EmergencyContactSettingsScreen extends ConsumerStatefulWidget {
  const EmergencyContactSettingsScreen({super.key});

  @override
  ConsumerState<EmergencyContactSettingsScreen> createState() =>
      _EmergencyContactSettingsScreenState();
}

class _EmergencyContactSettingsScreenState
    extends ConsumerState<EmergencyContactSettingsScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _saving = false;
  bool _hydrated = false;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _normalizePhone(String raw) {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length == 12 && digits.startsWith('91')) {
      return digits.substring(2);
    }
    if (digits.length == 11 && digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Emergency contact')),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load')),
        data: (user) {
          if (!_hydrated) {
            _nameController.text = user?.emergencyContactName ?? '';
            _phoneController.text = user?.emergencyContactPhone ?? '';
            _hydrated = true;
          }
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Add someone we can reach in an emergency during your rides.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _nameController,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Contact name',
                    hintText: 'e.g. Parent, spouse, friend',
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Contact phone',
                    hintText: '10-digit mobile number',
                    prefixText: '+91 ',
                  ),
                ),
                const SizedBox(height: 24),
                AppButton(
                  label: 'Save emergency contact',
                  isLoading: _saving,
                  onPressed: _saving
                      ? null
                      : () async {
                          final name = _nameController.text.trim();
                          final phone = _normalizePhone(_phoneController.text);
                          if (name.isEmpty) {
                            context.showSnackBar('Please enter contact name');
                            return;
                          }
                          if (phone.length != 10) {
                            context.showSnackBar('Enter a valid 10-digit phone number');
                            return;
                          }
                          setState(() => _saving = true);
                          try {
                            await ref.read(authRepositoryProvider).updateProfile(
                                  emergencyContactName: name,
                                  emergencyContactPhone: phone,
                                );
                            refreshUserProfile(ref);
                            if (!context.mounted) return;
                            Navigator.pop(context);
                            context.showSnackBar('Emergency contact saved');
                          } catch (_) {
                            if (context.mounted) {
                              context.showSnackBar('Could not save emergency contact');
                            }
                          } finally {
                            if (mounted) setState(() => _saving = false);
                          }
                        },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  bool _push = true;
  bool _sms = true;
  bool _email = false;
  bool _promos = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Push notifications'),
            subtitle: const Text('Ride updates and driver alerts'),
            value: _push,
            onChanged: (v) => setState(() => _push = v),
          ),
          SwitchListTile(
            title: const Text('SMS alerts'),
            subtitle: const Text('OTP and trip confirmations'),
            value: _sms,
            onChanged: (v) => setState(() => _sms = v),
          ),
          SwitchListTile(
            title: const Text('Email updates'),
            subtitle: const Text('Receipts and account changes'),
            value: _email,
            onChanged: (v) => setState(() => _email = v),
          ),
          SwitchListTile(
            title: const Text('Promotions'),
            subtitle: const Text('Offers and discount codes'),
            value: _promos,
            onChanged: (v) => setState(() => _promos = v),
          ),
        ],
      ),
    );
  }
}

class SavedPlacesScreen extends ConsumerStatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen> {
  bool _showFavoritesOnly = false;

  @override
  Widget build(BuildContext context) {
    final placesAsync = ref.watch(savedAddressesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(_showFavoritesOnly ? 'Favourite Places' : 'Saved Places'),
        actions: [
          IconButton(
            tooltip: _showFavoritesOnly ? 'Show saved places' : 'Show fav places',
            onPressed: () => setState(() => _showFavoritesOnly = !_showFavoritesOnly),
            icon: Icon(_showFavoritesOnly ? Icons.favorite : Icons.favorite_border),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddPlaceSheet(context),
        child: const Icon(Icons.add),
      ),
      body: placesAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('Unable to load saved places')),
        data: (places) {
          final visible =
              _showFavoritesOnly ? places.where((p) => p.isFavorite).toList() : places;
          if (visible.isEmpty) {
            return const Center(child: Text('No saved places yet'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: visible.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (_, i) {
              final place = visible[i];
              return Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  onTap: () => _showPlaceDetail(context, place.title, place.address),
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.place, color: AppColors.primary),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(place.title,
                                  style: const TextStyle(fontWeight: FontWeight.w600)),
                              Text(
                                place.address,
                                style: const TextStyle(
                                    color: AppColors.mutedForeground, fontSize: 13),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          tooltip: place.isFavorite
                              ? 'Remove from favorites'
                              : 'Add to favorites',
                          onPressed: () async {
                            await ref.read(savedPlacesServiceProvider).toggleFavorite(place.id);
                            refreshSavedAddresses(ref);
                          },
                          icon: Icon(
                            place.isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: place.isFavorite
                                ? AppColors.error
                                : AppColors.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showPlaceDetail(BuildContext context, String label, String address) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(label, style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(address, style: const TextStyle(color: AppColors.mutedForeground)),
            const SizedBox(height: 20),
            AppButton(
              label: 'Use for next ride',
              onPressed: () {
                Navigator.pop(ctx);
                context.showSnackBar('$label set as destination');
              },
            ),
            const SizedBox(height: 8),
            AppButton(
              label: 'Edit place',
              variant: AppButtonVariant.outline,
              onPressed: () {
                Navigator.pop(ctx);
                context.showSnackBar('Edit $label — coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showAddPlaceSheet(BuildContext context) {
    final labelController = TextEditingController();
    final addressController = TextEditingController();
    SelectedPlace? selected;

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add saved place',
                style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: labelController,
                decoration: const InputDecoration(labelText: 'Label (e.g. Home)'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: addressController,
                readOnly: true,
                decoration: const InputDecoration(
                  labelText: 'Address',
                  hintText: 'Tap to choose from map/search',
                  suffixIcon: Icon(Icons.map_outlined),
                ),
                onTap: () async {
                  final result = await context.push<SelectedPlace>(
                    RouteNames.location,
                    extra: 'dropoff',
                  );
                  if (result == null) return;
                  selected = result;
                  addressController.text = result.label;
                  setSheetState(() {});
                },
              ),
              const SizedBox(height: 20),
              AppButton(
                label: 'Save place',
                onPressed: () async {
                  final title = labelController.text.trim();
                  final addr = addressController.text.trim();
                  if (title.isEmpty || addr.isEmpty) {
                    context.showSnackBar('Enter label and address', isError: true);
                    return;
                  }
                  if (AppConfig.enableMockApi) {
                    await ref.read(savedPlacesServiceProvider).add(
                          title: title,
                          address: addr,
                          latitude: selected?.latitude,
                          longitude: selected?.longitude,
                        );
                  } else {
                    await ref.read(profileServiceProvider).addAddress(
                          label: title,
                          addressLine: addr,
                          latitude: selected?.latitude,
                          longitude: selected?.longitude,
                        );
                  }
                  refreshSavedAddresses(ref);
                  if (ctx.mounted) Navigator.pop(ctx);
                  if (context.mounted) context.showSnackBar('Place saved');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HelpTopicScreen extends StatelessWidget {
  const HelpTopicScreen({super.key, required this.title, required this.icon, required this.body});

  final String title;
  final IconData icon;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(icon, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(body, style: const TextStyle(height: 1.5, color: AppColors.foreground)),
            const SizedBox(height: 24),
            AppButton(
              label: 'Call $kSupportPhoneNumber',
              icon: Icons.phone,
              onPressed: () => launchSupportCall(context),
            ),
          ],
        ),
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About Bull Wave Rides')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.local_taxi, color: Colors.white, size: 40),
            ),
            const SizedBox(height: 16),
            Text(
              AppConfig.appName,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text('Version 1.0.0', style: TextStyle(color: AppColors.mutedForeground)),
            const SizedBox(height: 24),
            const Text(
              'Bull Wave Rides is your all-in-one mobility platform for rides, parcel delivery, and emergency ambulance services across your city.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
            ),
            const Spacer(),
            AppButton(
              label: 'Terms of Service',
              variant: AppButtonVariant.outline,
              onPressed: () => context.showSnackBar('Terms of Service'),
            ),
            const SizedBox(height: 12),
            AppButton(
              label: 'Privacy Policy',
              variant: AppButtonVariant.outline,
              onPressed: () => context.showSnackBar('Privacy Policy'),
            ),
          ],
        ),
      ),
    );
  }
}
