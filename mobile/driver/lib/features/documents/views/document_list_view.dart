import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:driver/features/documents/view_models/document_view_model.dart';
import 'package:driver/features/documents/views/upload_document_view.dart';
import 'package:intl/intl.dart';

class DocumentListView extends ConsumerWidget {
  const DocumentListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(documentViewModelProvider);
    final theme = Theme.of(context);

    return SakaiScreenScaffold(
      title: 'Documents',
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () => ref.read(documentViewModelProvider.notifier).fetchDocuments(),
        ),
      ],
      fab: FloatingActionButton(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const UploadDocumentView()),
        ),
        backgroundColor: theme.colorScheme.primary,
        child: const Icon(Icons.add),
      ),
      body: state.isLoading && state.documents.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, DocumentState state) {
    final theme = Theme.of(context);

    if (state.errorMessage != null && state.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(state.errorMessage!),
            const SizedBox(height: 16),
            SakaiPrimaryButton(
              onPressed: () => ref.read(documentViewModelProvider.notifier).fetchDocuments(),
              label: 'Retry',
            ),
          ],
        ),
      );
    }

    if (state.documents.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.description_outlined, size: 64, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 16),
            Text(
              'No documents uploaded yet',
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 24),
            SakaiPrimaryButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const UploadDocumentView()),
              ),
              label: 'Upload First Document',
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(documentViewModelProvider.notifier).fetchDocuments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: state.documents.length,
        itemBuilder: (context, index) {
          final doc = state.documents[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: SakaiSurfaceCard(
              child: ListTile(
                leading: _buildIconForType(context, doc.documentType),
                title: Text(
                  _formatDocumentType(doc.documentType),
                  style: theme.textTheme.titleMedium,
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Number: ${doc.documentNumber}'),
                    if (doc.expiryDate != null)
                      Text('Expires: ${DateFormat.yMMMd().format(doc.expiryDate!.toDateTime())}'),
                    Text('Uploaded: ${DateFormat.yMMMd().format(doc.uploadedAt)}'),
                  ],
                ),
                trailing: _buildStatusBadge(context, doc.uploadStatus),
                isThreeLine: true,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildIconForType(BuildContext context, DocumentType? type) {
    IconData iconData;
    switch (type) {
      case DocumentType.license:
        iconData = Icons.badge_outlined;
        break;
      case DocumentType.insurance:
        iconData = Icons.security_outlined;
        break;
      case DocumentType.registration:
        iconData = Icons.directions_car_outlined;
        break;
      default:
        iconData = Icons.file_present_outlined;
        break;
    }
    return CircleAvatar(
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      child: Icon(iconData, color: Theme.of(context).colorScheme.primary),
    );
  }

  String _formatDocumentType(DocumentType? type) {
    if (type == null) return 'Unknown Document';
    return type.name[0].toUpperCase() + type.name.substring(1).replaceAll('_', ' ');
  }

  Widget _buildStatusBadge(BuildContext context, UploadStatus? status) {
    Color color;
    String text;
    
    switch (status) {
      case UploadStatus.approved:
        color = Colors.green;
        text = 'Approved';
        break;
      case UploadStatus.rejected:
        color = Colors.red;
        text = 'Rejected';
        break;
      case UploadStatus.underReview:
        color = Colors.orange;
        text = 'Pending';
        break;
      default:
        color = Theme.of(context).colorScheme.onSurfaceVariant;
        text = 'Unknown';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha(25), // equivalent to withOpacity(0.1)
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(127)), // equivalent to withOpacity(0.5)
      ),
      child: Text(
        text,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: color, fontWeight: FontWeight.bold),
      ),
    );
  }
}
