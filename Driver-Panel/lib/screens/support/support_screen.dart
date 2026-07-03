import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavego_driver/core/constants/support_constants.dart';
import 'package:wavego_driver/core/routes/route_names.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/widgets/common/app_button.dart';
import 'package:wavego_driver/widgets/common/app_dialog.dart';
import 'package:wavego_driver/widgets/common/shimmer_loading.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class SupportScreen extends ConsumerStatefulWidget {
  const SupportScreen({super.key});

  @override
  ConsumerState<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends ConsumerState<SupportScreen> {
  List<FaqItem> _faq = [];
  List<SupportTicket> _tickets = [];
  bool _loadingFaq = true;
  bool _loadingTickets = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final repo = ref.read(supportRepositoryProvider);
    final results = await Future.wait([
      repo.getFaq(),
      repo.getTickets(),
    ]);
    if (!mounted) return;
    setState(() {
      _faq = results[0] as List<FaqItem>;
      _tickets = results[1] as List<SupportTicket>;
      _loadingFaq = false;
      _loadingTickets = false;
    });
  }

  Future<void> _refreshTickets() async {
    setState(() => _loadingTickets = true);
    final tickets = await ref.read(supportRepositoryProvider).getTickets();
    if (!mounted) return;
    setState(() {
      _tickets = tickets;
      _loadingTickets = false;
    });
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
            _buildFaqTab(),
            _buildTicketsTab(),
            _buildContactTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildFaqTab() {
    if (_loadingFaq) return const ListSkeleton();
    if (_faq.isEmpty) {
      return const EmptyStateWidget(
        title: 'No FAQ yet',
        subtitle: 'Check back later or contact support.',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _faq.length,
      itemBuilder: (context, index) {
        final item = _faq[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ExpansionTile(
            title: Text(item.question),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: Text(item.answer),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTicketsTab() {
    if (_loadingTickets) return const ListSkeleton();

    return RefreshIndicator(
      onRefresh: _refreshTickets,
      child: _tickets.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                const EmptyStateWidget(
                  title: 'No tickets',
                  subtitle: 'Raise a ticket if you need help',
                ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: AppButton(
                    label: 'Raise Ticket',
                    icon: Icons.support_agent,
                    onPressed: () => _showTicketDialog(context),
                  ),
                ),
              ],
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'All tickets (${_tickets.length})',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextButton(
                      onPressed: () => _showTicketDialog(context),
                      child: const Text('New ticket'),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ..._tickets.map(
                  (ticket) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _DriverTicketTile(
                      ticket: ticket,
                      onTap: () => context.push(
                        RouteNames.supportTicketDetail,
                        extra: ticket.id,
                      ),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildContactTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Need immediate help? Call our support team or raise a ticket.',
            style: TextStyle(height: 1.5),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Call $kSupportPhoneNumber',
            icon: Icons.phone,
            onPressed: _callSupport,
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Raise Ticket',
            variant: AppButtonVariant.outline,
            icon: Icons.support_agent,
            onPressed: () => _showTicketDialog(context),
          ),
        ],
      ),
    );
  }

  Future<void> _callSupport() async {
    final uri = Uri(scheme: 'tel', path: kSupportPhoneNumber);
    if (!await launchUrl(uri) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open phone dialer')),
      );
    }
  }

  void _showTicketDialog(BuildContext context) {
    final subjectCtrl = TextEditingController();
    final messageCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Raise Ticket'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: subjectCtrl,
              decoration: const InputDecoration(labelText: 'Subject'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: messageCtrl,
              decoration: const InputDecoration(labelText: 'Message'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          AppButton(
            label: 'Submit',
            expand: false,
            onPressed: () async {
              final subject = subjectCtrl.text.trim();
              final message = messageCtrl.text.trim();
              if (subject.length < 3 || message.length < 5) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('Subject (3+) and message (5+ chars) required'),
                  ),
                );
                return;
              }
              try {
                await ref.read(supportRepositoryProvider).createTicket(
                      subject: subject,
                      message: message,
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                await _refreshTickets();
                if (context.mounted) {
                  AppDialog.showSuccess(
                    context: context,
                    title: 'Ticket Created',
                    message: 'Admin will review your request soon.',
                  );
                }
              } catch (_) {
                if (dialogContext.mounted) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(content: Text('Failed to create ticket')),
                  );
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _DriverTicketTile extends StatelessWidget {
  const _DriverTicketTile({required this.ticket, required this.onTap});

  final SupportTicket ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ticket.subject,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(ticket.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.mutedForeground,
                      ),
                    ),
                  ],
                ),
              ),
              _StatusChip(status: ticket.status),
              const Icon(Icons.chevron_right, color: AppColors.mutedForeground),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}

class DriverSupportTicketDetailScreen extends ConsumerStatefulWidget {
  const DriverSupportTicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<DriverSupportTicketDetailScreen> createState() =>
      _DriverSupportTicketDetailScreenState();
}

class _DriverSupportTicketDetailScreenState
    extends ConsumerState<DriverSupportTicketDetailScreen> {
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(supportRepositoryProvider).getTicketDetail(widget.ticketId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ref.read(supportRepositoryProvider).getTicketDetail(widget.ticketId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket details')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<Map<String, dynamic>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Unable to load ticket')),
                ],
              );
            }

            final ticket = snapshot.data!;
            final messages = ticket['messages'] as List<dynamic>? ?? [];
            final status = ticket['status'] as String? ?? 'open';

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket['subject'] as String? ?? 'Support',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusChip(status: status),
                  ],
                ),
                const SizedBox(height: 20),
                ...messages.map((raw) {
                  final msg = raw as Map<String, dynamic>;
                  final isAdmin = (msg['sender_type'] as String? ?? '') == 'admin';
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Align(
                      alignment:
                          isAdmin ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        width: MediaQuery.sizeOf(context).width * 0.82,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: isAdmin
                              ? AppColors.primary.withValues(alpha: 0.08)
                              : AppColors.muted,
                          borderRadius: BorderRadius.circular(14),
                          border: isAdmin
                              ? Border.all(
                                  color: AppColors.primary.withValues(alpha: 0.2),
                                )
                              : null,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg['sender'] as String? ?? 'Support',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(msg['message'] as String? ?? ''),
                          ],
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
