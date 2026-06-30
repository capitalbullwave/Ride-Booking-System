import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';

class SosScreen extends ConsumerStatefulWidget {
  const SosScreen({super.key});

  @override
  ConsumerState<SosScreen> createState() => _SosScreenState();
}

class _SosScreenState extends ConsumerState<SosScreen> {
  List<EmergencyContact> _contacts = [];
  bool _triggered = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final contacts = await ref.read(supportRepositoryProvider).getEmergencyContacts();
    setState(() => _contacts = contacts);
  }

  Future<void> _triggerSos() async {
    final confirmed = await AppDialog.showConfirm(
      context: context,
      title: 'Emergency SOS',
      message: 'This will alert emergency services and share your live location.',
      confirmLabel: 'Trigger SOS',
      confirmVariant: AppButtonVariant.danger,
    );
    if (confirmed != true) return;

    await ref.read(supportRepositoryProvider).triggerSos(lat: 19.0760, lng: 72.8777);
    setState(() => _triggered = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Emergency SOS')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            if (_triggered)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.check_circle, color: AppColors.error),
                    SizedBox(width: 12),
                    Expanded(child: Text('SOS triggered! Help is on the way. Your location has been shared.')),
                  ],
                ),
              ),
            const Spacer(),
            GestureDetector(
              onTap: _triggerSos,
              child: Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(color: AppColors.error.withValues(alpha: 0.4), blurRadius: 30, spreadRadius: 10),
                  ],
                ),
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.emergency, color: Colors.white, size: 48),
                    SizedBox(height: 8),
                    Text('SOS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text('Tap to trigger emergency alert', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            const Spacer(),
            Text('Emergency Contacts', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            ..._contacts.map((c) => Card(
              child: ListTile(
                leading: const Icon(Icons.contact_phone, color: AppColors.error),
                title: Text(c.name),
                subtitle: Text('${c.phone}${c.relation != null ? ' • ${c.relation}' : ''}'),
                trailing: IconButton(icon: const Icon(Icons.phone), onPressed: () {}),
              ),
            )),
            const SizedBox(height: 12),
            AppButton(label: 'Share Live Location', variant: AppButtonVariant.outline, icon: Icons.share_location, onPressed: () {}),
          ],
        ),
      ),
    );
  }
}
