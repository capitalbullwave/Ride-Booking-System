import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wavego_driver/core/theme/app_colors.dart';
import 'package:wavego_driver/models/registration_model.dart';
import 'package:wavego_driver/repositories/notification_repository.dart';
import 'package:wavego_driver/widgets/common/document_status_badge.dart';
import 'package:wavego_driver/widgets/common/state_widgets.dart';

class DocumentsScreen extends ConsumerStatefulWidget {
  const DocumentsScreen({super.key});

  @override
  ConsumerState<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends ConsumerState<DocumentsScreen> {
  List<DocumentInfo> _documents = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final docs = await ref.read(documentRepositoryProvider).getDocuments();
    if (mounted) setState(() { _documents = docs; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Documents')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _documents.isEmpty
              ? const EmptyStateWidget(
                  title: 'No documents',
                  subtitle: 'Upload documents during registration',
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _documents.length,
                    itemBuilder: (context, index) {
                      final doc = _documents[index];
                      final status = documentStatusFromString(
                        doc.status,
                        isExpiring: doc.isExpiringSoon,
                      );
                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          leading: CircleAvatar(
                            backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                            child: Icon(
                              _iconForStatus(status),
                              color: AppColors.primary,
                            ),
                          ),
                          title: Text(doc.type, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text(
                            doc.expiryDate != null
                                ? 'Expires ${doc.expiryDate}'
                                : 'No expiry date',
                          ),
                          trailing: DocumentStatusBadge(status: status),
                          onTap: () {},
                        ),
                      );
                    },
                  ),
                ),
    );
  }

  IconData _iconForStatus(DocumentStatus status) {
    return switch (status) {
      DocumentStatus.verified => Icons.verified_outlined,
      DocumentStatus.rejected => Icons.error_outline,
      DocumentStatus.expired => Icons.event_busy,
      DocumentStatus.expiring => Icons.warning_amber,
      DocumentStatus.pending => Icons.schedule,
    };
  }
}
