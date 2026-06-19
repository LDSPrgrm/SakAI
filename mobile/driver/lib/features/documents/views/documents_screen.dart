import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';
import '../view_models/document_view_model.dart';
import '../../../app/router.dart';

class DocumentsScreen extends ConsumerWidget {
  const DocumentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentViewModelProvider);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(documentViewModelProvider.notifier).fetchDocuments(),
          ),
        ],
      ),
      body: Builder(
        builder: (context) {
          final tokens = SakaiDesignTokens.of(context);
          if (state.isLoading) {
            return SakaiSkeleton.list(itemCount: 4);
          }
          if (state.errorMessage != null) {
            return SakaiErrorState(
              message: state.errorMessage,
              onRetry: () =>
                  ref.read(documentViewModelProvider.notifier).fetchDocuments(),
            );
          }
          if (state.documents.isEmpty) {
            return SakaiEmptyState(
              icon: Icons.description_outlined,
              title: 'No documents uploaded yet',
              message: 'Upload your license, vehicle papers, and ID to start driving.',
              primaryLabel: 'Upload First Document',
              onPrimary: () => context.push(Routes.uploadDocument),
            );
          }
          return ListView.builder(
            padding: EdgeInsets.all(tokens.spaceMd),
            itemCount: state.documents.length,
            itemBuilder: (context, index) {
              final doc = state.documents[index];
              return _DocumentCard(document: doc);
            },
          );
        },
      ),
      floatingActionButton: state.documents.isNotEmpty
          ? FloatingActionButton.extended(
              onPressed: () => context.push(Routes.uploadDocument),
              label: const Text('Upload New'),
              icon: const Icon(Icons.add),
            )
          : null,
    );
  }
}

class _DocumentCard extends StatelessWidget {
  final dynamic document; // DriverDocumentResponse

  const _DocumentCard({required this.document});

  @override
  Widget build(BuildContext context) {
    final status = document.uploadStatus;
    final tokens = SakaiDesignTokens.of(context);
    final (badgeStatus, statusIcon) = _statusVisuals(status);

    return Card(
      margin: EdgeInsets.only(bottom: tokens.spaceMd),
      child: ExpansionTile(
        leading: Icon(statusIcon, color: _statusColor(badgeStatus, context)),
        title: Text(
          _formatDocType(document.documentType),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Padding(
          padding: EdgeInsets.only(top: tokens.spaceXs),
          child: Align(
            alignment: Alignment.centerLeft,
            child: SakaiStatusBadge(
              status: badgeStatus,
              label: _formatStatus(status),
              dense: true,
            ),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _InfoRow(label: 'Document Number', value: document.documentNumber ?? 'N/A'),
                if (document.expiryDate != null)
                  _InfoRow(
                    label: 'Expiry Date',
                    value: DateFormat('yyyy-MM-dd').format(document.expiryDate.toDateTime()),
                  ),
                const SizedBox(height: 12),
                if (document.imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      document.imageUrl,
                      height: 200,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        height: 200,
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        child: const Center(
                            child: Icon(Icons.broken_image, size: 48)),
                      ),
                    ),
                  ),
                if (document.rejectionReason != null && status == 'rejected')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Rejection Reason: ${document.rejectionReason}',
                      style: TextStyle(
                        color: SakaiSemanticColors.of(context).danger,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDocType(String type) {
    return type.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
  }

  String _formatStatus(String status) {
    return status.split('_').map((s) => s[0].toUpperCase() + s.substring(1)).join(' ');
  }

  (SakaiStatus, IconData) _statusVisuals(String status) {
    switch (status) {
      case 'approved':
        return (SakaiStatus.success, Icons.check_circle);
      case 'rejected':
        return (SakaiStatus.danger, Icons.cancel);
      case 'under_review':
        return (SakaiStatus.warning, Icons.hourglass_empty);
      default:
        return (SakaiStatus.neutral, Icons.help_outline);
    }
  }

  Color _statusColor(SakaiStatus status, BuildContext ctx) {
    final s = SakaiSemanticColors.of(ctx);
    switch (status) {
      case SakaiStatus.success:
        return s.success;
      case SakaiStatus.danger:
        return s.danger;
      case SakaiStatus.warning:
      case SakaiStatus.pending:
        return s.warning;
      case SakaiStatus.info:
        return s.accentBlue;
      case SakaiStatus.neutral:
        return s.neutral;
    }
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
