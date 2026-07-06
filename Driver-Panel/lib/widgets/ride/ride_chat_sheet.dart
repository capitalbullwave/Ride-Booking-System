import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/core/utils/extensions.dart';
import 'package:wavego_driver/providers/ride_chat_provider.dart';
import 'package:wavego_driver/services/ride_chat_service.dart';
import 'package:wavego_driver/services/ride_realtime_service.dart';

Future<void> showRideChatSheet({
  required BuildContext context,
  required WidgetRef ref,
  required String rideId,
  required String peerName,
}) async {
  ref.read(rideChatSheetOpenProvider.notifier).state = true;
  try {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => _RideChatSheet(
        rideId: rideId,
        peerName: peerName,
      ),
    );
  } finally {
    ref.read(rideChatSheetOpenProvider.notifier).state = false;
  }
}

class _RideChatSheet extends ConsumerStatefulWidget {
  const _RideChatSheet({
    required this.rideId,
    required this.peerName,
  });

  final String rideId;
  final String peerName;

  @override
  ConsumerState<_RideChatSheet> createState() => _RideChatSheetState();
}

class _RideChatSheetState extends ConsumerState<_RideChatSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <RideChatMessage>[];
  StreamSubscription<Map<String, dynamic>>? _realtimeSub;
  Timer? _pollTimer;
  bool _loading = true;
  bool _sending = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _listenRealtime();
    _pollTimer = Timer.periodic(const Duration(seconds: 1), (_) => _pollMessages());
  }

  void _listenRealtime() {
    final realtime = ref.read(rideRealtimeProvider);
    unawaited(realtime.connect());
    realtime.subscribeRide(widget.rideId);
    _realtimeSub = realtime.messages.listen(_onRealtimeMessage);
  }

  void _onRealtimeMessage(Map<String, dynamic> msg) {
    if (msg['event']?.toString() != 'chat_message') return;
    if (msg['ride_id']?.toString() != widget.rideId) return;
    _appendMessage(RideChatMessage.fromJson(msg));
  }

  void _appendMessage(RideChatMessage incoming) {
    if (_messages.any((m) => m.id == incoming.id)) return;
    if (!mounted) return;
    setState(() => _messages.add(incoming));
    _scrollToBottom();
  }

  Future<void> _loadMessages() async {
    try {
      final items = await ref.read(rideChatServiceProvider).listMessages(widget.rideId);
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(items);
        _loading = false;
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.userMessage;
      });
    }
  }

  Future<void> _pollMessages() async {
    try {
      final items = await ref.read(rideChatServiceProvider).listMessages(widget.rideId);
      if (!mounted) return;
      var added = false;
      for (final item in items) {
        if (!_messages.any((m) => m.id == item.id)) {
          _messages.add(item);
          added = true;
        }
      }
      if (added) {
        setState(() {});
        _scrollToBottom();
      }
    } catch (_) {}
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    final optimistic = RideChatMessage(
      id: 'local-${DateTime.now().millisecondsSinceEpoch}',
      rideId: widget.rideId,
      senderId: 'me',
      senderType: 'driver',
      message: text,
      senderName: 'You',
    );
    _controller.clear();
    _appendMessage(optimistic);

    setState(() => _sending = true);
    try {
      final sent = await ref.read(rideChatServiceProvider).sendMessage(widget.rideId, text);
      if (!mounted) return;
      setState(() {
        _messages.removeWhere((m) => m.id == optimistic.id);
        if (!_messages.any((m) => m.id == sent.id)) {
          _messages.add(sent);
        }
      });
      _scrollToBottom();
    } catch (e) {
      if (!mounted) return;
      setState(() => _messages.removeWhere((m) => m.id == optimistic.id));
      context.showSnackBar(e.userMessage, isError: true);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  @override
  void dispose() {
    _realtimeSub?.cancel();
    _pollTimer?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.72,
        child: Column(
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Chat',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        Text(
                          widget.peerName,
                          style: const TextStyle(color: AppColors.mutedForeground, fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.error)))
                      : _messages.isEmpty
                          ? const Center(
                              child: Text(
                                'No messages yet.\nSay hi to your passenger!',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppColors.mutedForeground),
                              ),
                            )
                          : ListView.builder(
                              controller: _scrollController,
                              padding: const EdgeInsets.all(16),
                              itemCount: _messages.length,
                              itemBuilder: (context, index) {
                                final msg = _messages[index];
                                final mine = msg.senderType == 'driver';
                                return Align(
                                  alignment: mine ? Alignment.centerRight : Alignment.centerLeft,
                                  child: Container(
                                    margin: const EdgeInsets.only(bottom: 8),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 8,
                                    ),
                                    constraints: BoxConstraints(
                                      maxWidth: MediaQuery.sizeOf(context).width * 0.75,
                                    ),
                                    decoration: BoxDecoration(
                                      color: mine
                                          ? AppColors.primary.withValues(alpha: 0.12)
                                          : AppColors.muted.withValues(alpha: 0.35),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (!mine && (msg.senderName?.isNotEmpty ?? false))
                                          Text(
                                            msg.senderName!,
                                            style: const TextStyle(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.primary,
                                            ),
                                          ),
                                        Text(msg.message),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _send(),
                      decoration: const InputDecoration(
                        hintText: 'Type a message...',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _sending ? null : _send,
                    icon: _sending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                          )
                        : const Icon(Icons.send_rounded),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
