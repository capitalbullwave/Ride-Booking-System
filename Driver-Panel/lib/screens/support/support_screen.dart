import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  List<FaqItem> _faq = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final faq = await ref.read(supportRepositoryProvider).getFaq();
    setState(() { _faq = faq; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Support'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'FAQ'),
              Tab(text: 'Tickets'),
              Tab(text: 'Contact'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _faq.length,
                    itemBuilder: (context, index) {
                      final item = _faq[index];
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ExpansionTile(
                          title: Text(item.question),
                          children: [Padding(padding: const EdgeInsets.all(16), child: Text(item.answer))],
                        ),
                      );
                    },
                  ),
            const EmptyStateWidget(title: 'No tickets', subtitle: 'Raise a ticket if you need help'),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  AppButton(label: 'Live Chat', icon: Icons.chat, onPressed: () {}),
                  const SizedBox(height: 12),
                  AppButton(label: 'Raise Ticket', variant: AppButtonVariant.outline, icon: Icons.support_agent, onPressed: () => _showTicketDialog(context)),
                  const SizedBox(height: 12),
                  AppButton(label: 'Call Support', variant: AppButtonVariant.outline, icon: Icons.phone, onPressed: () {}),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTicketDialog(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raise Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: subjectCtrl, decoration: const InputDecoration(labelText: 'Subject')),
            const SizedBox(height: 12),
            TextField(controller: messageCtrl, decoration: const InputDecoration(labelText: 'Message'), maxLines: 3),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          AppButton(
            label: 'Submit',
            expand: false,
            onPressed: () async {
              await ref.read(supportRepositoryProvider).createTicket(
                subject: subjectCtrl.text,
                message: messageCtrl.text,
              );
              if (context.mounted) {
                Navigator.pop(context);
                AppDialog.showSuccess(context: context, title: 'Ticket Created', message: 'We\'ll get back to you soon.');
              }
            },
          ),
        ],
      ),
    );
  }
}
