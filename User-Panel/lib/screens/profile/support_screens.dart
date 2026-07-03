import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:wavego_user/core/constants/support_constants.dart';
import 'package:wavego_user/core/routes/route_names.dart';
import 'package:wavego_user/core/theme/app_colors.dart';
import 'package:wavego_user/core/utils/extensions.dart';
import 'package:wavego_user/models/support_models.dart';
import 'package:wavego_user/services/user_services.dart';
import 'package:wavego_user/widgets/common/app_button.dart';

/// Tabbed Support screen — FAQ, Tickets, Contact (matches driver panel).
class UserSupportScreen extends ConsumerStatefulWidget {
  const UserSupportScreen({super.key});

  @override
  ConsumerState<UserSupportScreen> createState() => _UserSupportScreenState();
}

class _UserSupportScreenState extends ConsumerState<UserSupportScreen> {
  List<FaqItem> _faq = [];
  List<SupportTicketSummary> _tickets = [];
  bool _loadingFaq = true;
  bool _loadingTickets = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final service = ref.read(supportServiceProvider);
    final results = await Future.wait([
      service.getFaq(),
      service.getTickets(),
    ]);
    if (!mounted) return;
    setState(() {
      _faq = results[0] as List<FaqItem>;
      _tickets = results[1] as List<SupportTicketSummary>;
      _loadingFaq = false;
      _loadingTickets = false;
    });
  }

  Future<void> _refreshTickets() async {
    setState(() => _loadingTickets = true);
    final tickets = await ref.read(supportServiceProvider).getTickets();
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
    if (_loadingFaq) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_faq.isEmpty) {
      return const Center(child: Text('No FAQ available'));
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
    if (_loadingTickets) {
      return const Center(child: CircularProgressIndicator());
    }

    return RefreshIndicator(
      onRefresh: _refreshTickets,
      child: _tickets.isEmpty
          ? ListView(
              children: [
                const SizedBox(height: 80),
                const Center(child: Text('No tickets yet')),
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
                    child: _TicketListTile(
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
          Text(
            'Call our support team anytime or raise a ticket for trip or payment issues.',
            style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Call $kSupportPhoneNumber',
            icon: Icons.phone,
            onPressed: () => launchSupportCall(context),
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
                context.showSnackBar('Subject and message are required.');
                return;
              }
              try {
                final ticket = await ref.read(supportServiceProvider).createTicket(
                      subject: subject,
                      message: message,
                    );
                if (dialogContext.mounted) Navigator.pop(dialogContext);
                await _refreshTickets();
                if (context.mounted) {
                  context.showSnackBar('Ticket created');
                  context.push(RouteNames.supportTicketDetail, extra: ticket.id);
                }
              } catch (_) {
                if (dialogContext.mounted) {
                  context.showSnackBar('Failed to create ticket');
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class CreateSupportTicketScreen extends ConsumerStatefulWidget {
  const CreateSupportTicketScreen({
    super.key,
    required this.category,
    required this.icon,
  });

  final String category;
  final IconData icon;

  @override
  ConsumerState<CreateSupportTicketScreen> createState() =>
      _CreateSupportTicketScreenState();
}

class _CreateSupportTicketScreenState
    extends ConsumerState<CreateSupportTicketScreen> {
  final _subjectController = TextEditingController();
  final _messageController = TextEditingController();
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _subjectController.text = 'Help with ${widget.category.toLowerCase()}';
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();
    if (subject.length < 3 || message.length < 5) {
      context.showSnackBar('Please enter a subject and at least 5 characters in your message.');
      return;
    }

    setState(() => _submitting = true);
    try {
      final ticket = await ref.read(supportServiceProvider).createTicket(
            subject: subject,
            message: message,
            category: widget.category,
          );
      if (!mounted) return;
      context.showSnackBar('Ticket created successfully');
      context.go(RouteNames.supportTicketDetail, extra: ticket.id);
    } catch (e) {
      if (mounted) context.showSnackBar('Could not create ticket. Please try again.');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.category)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Icon(widget.icon, size: 48, color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            'Describe your issue and our team will respond shortly.',
            style: TextStyle(color: AppColors.mutedForeground, height: 1.5),
          ),
          const SizedBox(height: 24),
          TextField(
            controller: _subjectController,
            decoration: const InputDecoration(
              labelText: 'Subject',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _messageController,
            minLines: 5,
            maxLines: 8,
            decoration: const InputDecoration(
              labelText: 'Message',
              hintText: 'Tell us what happened…',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          AppButton(
            label: 'Create ticket',
            isLoading: _submitting,
            onPressed: _submitting ? null : _submit,
          ),
        ],
      ),
    );
  }
}

class SupportTicketsScreen extends ConsumerStatefulWidget {
  const SupportTicketsScreen({super.key});

  @override
  ConsumerState<SupportTicketsScreen> createState() =>
      _SupportTicketsScreenState();
}

class _SupportTicketsScreenState extends ConsumerState<SupportTicketsScreen> {
  late Future<List<SupportTicketSummary>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(supportServiceProvider).getTickets();
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ref.read(supportServiceProvider).getTickets();
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My tickets')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<SupportTicketSummary>>(
          future: _future,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('Unable to load tickets')),
                ],
              );
            }

            final tickets = snapshot.data ?? [];
            if (tickets.isEmpty) {
              return ListView(
                children: const [
                  SizedBox(height: 120),
                  Center(child: Text('No support tickets yet')),
                ],
              );
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: tickets.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final ticket = tickets[index];
                return _TicketListTile(
                  ticket: ticket,
                  onTap: () => context.push(
                    RouteNames.supportTicketDetail,
                    extra: ticket.id,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class SupportTicketDetailScreen extends ConsumerStatefulWidget {
  const SupportTicketDetailScreen({super.key, required this.ticketId});

  final String ticketId;

  @override
  ConsumerState<SupportTicketDetailScreen> createState() =>
      _SupportTicketDetailScreenState();
}

class _SupportTicketDetailScreenState
    extends ConsumerState<SupportTicketDetailScreen> {
  late Future<SupportTicketDetail> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(supportServiceProvider).getTicket(widget.ticketId);
  }

  Future<void> _refresh() async {
    setState(() {
      _future = ref.read(supportServiceProvider).getTicket(widget.ticketId);
    });
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ticket details')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<SupportTicketDetail>(
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
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        ticket.subject,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    _StatusChip(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Updated ${_formatDate(ticket.updatedAt)}',
                  style: TextStyle(color: AppColors.mutedForeground, fontSize: 12),
                ),
                const SizedBox(height: 20),
                ...ticket.messages.map(
                  (msg) => Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _MessageBubble(message: msg),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      return DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.parse(iso));
    } catch (_) {
      return iso;
    }
  }
}

class _TicketListTile extends StatelessWidget {
  const _TicketListTile({required this.ticket, required this.onTap});

  final SupportTicketSummary ticket;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
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
              const SizedBox(width: 8),
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

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final label = status.replaceAll('_', ' ');
    Color bg;
    Color fg;
    switch (status) {
      case 'resolved':
      case 'closed':
        bg = AppColors.success.withValues(alpha: 0.15);
        fg = AppColors.success;
      case 'in_progress':
        bg = Colors.amber.withValues(alpha: 0.2);
        fg = Colors.amber.shade800;
      default:
        bg = AppColors.primary.withValues(alpha: 0.12);
        fg = AppColors.primary;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }
}

class _MessageBubble extends StatelessWidget {
  const _MessageBubble({required this.message});

  final SupportTicketMessage message;

  @override
  Widget build(BuildContext context) {
    final isAdmin = message.isAdmin;
    return Align(
      alignment: isAdmin ? Alignment.centerLeft : Alignment.centerRight,
      child: Container(
        constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isAdmin ? AppColors.primary.withValues(alpha: 0.08) : AppColors.muted,
          borderRadius: BorderRadius.circular(14),
          border: isAdmin ? Border.all(color: AppColors.primary.withValues(alpha: 0.2)) : null,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              message.sender,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
            ),
            const SizedBox(height: 6),
            Text(message.message, style: const TextStyle(height: 1.4)),
          ],
        ),
      ),
    );
  }
}

Future<void> launchSupportCall(BuildContext context) async {
  final uri = Uri(scheme: 'tel', path: kSupportPhoneNumber);
  final launched = await launchUrl(uri);
  if (!launched && context.mounted) {
    context.showSnackBar('Could not open phone dialer');
  }
}
