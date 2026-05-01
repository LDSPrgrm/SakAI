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
      appBar: AppBar(
        title: const Text('My Documents'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.read(documentViewModelProvider.notifier).fetchDocuments(),
          ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: CircularProgressIndicator())
          : state.errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(state.errorMessage!, style: const TextStyle(color: Colors.red)),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () =>
                            ref.read(documentViewModelProvider.notifier).fetchDocuments(),
                        child: const Text('Retry'),
                      ),
                    ],
                  ),
                )
              : state.documents.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.description_outlined, size: 64, color: Colors.grey),
                          const SizedBox(height: 16),
                          const Text(
                            'No documents uploaded yet.',
                            style: TextStyle(fontSize: 18, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),
                          ElevatedButton.icon(
                            onPressed: () => context.push(Routes.uploadDocument),
                            icon: const Icon(Icons.upload_file),
                            label: const Text('Upload First Document'),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: state.documents.length,
                      itemBuilder: (context, index) {
                        final doc = state.documents[index];
                        return _DocumentCard(document: doc);
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
    Color statusColor;
    IconData statusIcon;

    final semanticColors = SakaiSemanticColors.of(context);
    switch (status) {
      case 'approved':
        statusColor = semanticColors.success;
        statusIcon = Icons.check_circle;
        break;
      case 'rejected':
        statusColor = semanticColors.danger;
        statusIcon = Icons.cancel;
        break;
      case 'under_review':
        statusColor = semanticColors.warning;
        statusIcon = Icons.hourglass_empty;
        break;
      default:
        statusColor = Colors.grey;
        statusIcon = Icons.help_outline;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: statusColor.withValues(alpha: 0.1),
          child: Icon(statusIcon, color: statusColor),
        ),
        title: Text(
          _formatDocType(document.documentType),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text('Status: ${_formatStatus(status)}'),
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
                        color: Colors.grey[200],
                        child: const Center(child: Icon(Icons.broken_image, size: 48)),
                      ),
                    ),
                  ),
                if (document.rejectionReason != null && status == 'rejected')
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Text(
                      'Rejection Reason: ${document.rejectionReason}',
                      style: const TextStyle(color: Colors.red, fontWeight: FontWeight.w500),
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
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
