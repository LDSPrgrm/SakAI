import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_api_client/sakai_api_client.dart' as api;
import 'package:sakai_shared/sakai_shared.dart';

import '../../../app/providers.dart';
import '../../../app/router.dart';

/// Shown after the driver submits onboarding docs. Polls document status every
/// 15 seconds; routes home when ALL required docs are approved.
class ApprovalPendingScreen extends ConsumerStatefulWidget {
  const ApprovalPendingScreen({super.key});

  @override
  ConsumerState<ApprovalPendingScreen> createState() =>
      _ApprovalPendingScreenState();
}

class _ApprovalPendingScreenState extends ConsumerState<ApprovalPendingScreen> {
  Timer? _poll;
  bool _loading = true;
  String? _error;
  List<api.DriverDocumentResponse> _docs = const [];

  @override
  void initState() {
    super.initState();
    _fetch();
    _poll = Timer.periodic(const Duration(seconds: 15), (_) => _fetch());
  }

  @override
  void dispose() {
    _poll?.cancel();
    super.dispose();
  }

  Future<void> _fetch() async {
    try {
      final repo = ref.read(driverDocumentRepositoryProvider);
      final docs = await repo.listDocuments();
      if (!mounted) return;
      setState(() {
        _docs = docs;
        _loading = false;
        _error = null;
      });
      if (_allApproved(docs)) {
        _poll?.cancel();
        if (mounted) context.go(Routes.home);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.toString();
      });
    }
  }

  bool _allApproved(List<api.DriverDocumentResponse> docs) {
    if (docs.isEmpty) return false;
    return docs.every((d) => d.uploadStatus == api.UploadStatus.approved);
  }

  @override
  Widget build(BuildContext context) {
    final t = SakaiDesignTokens.of(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Approval pending')),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(t.spaceLg),
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? SakaiEmptyState(
                      icon: Icons.error_outline,
                      title: 'Couldn\'t fetch status',
                      message: _error,
                      primaryLabel: 'Retry',
                      onPrimary: _fetch,
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Icon(
                          Icons.hourglass_top,
                          size: 64,
                          color: theme.colorScheme.primary,
                        ),
                        SizedBox(height: t.spaceMd),
                        Text(
                          'We\'re reviewing your documents',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        SizedBox(height: t.spaceSm),
                        Text(
                          'You\'ll be able to go online once everything is approved. We\'ll re-check every 15 seconds.',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        SizedBox(height: t.spaceLg),
                        Expanded(
                          child: ListView.separated(
                            itemCount: _docs.length,
                            separatorBuilder: (_, _) =>
                                SizedBox(height: t.spaceXs),
                            itemBuilder: (context, i) => _DocTile(_docs[i]),
                          ),
                        ),
                        SakaiSecondaryButton(
                          label: 'Refresh',
                          onPressed: _fetch,
                        ),
                      ],
                    ),
        ),
      ),
    );
  }
}

class _DocTile extends StatelessWidget {
  const _DocTile(this.doc);
  final api.DriverDocumentResponse doc;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (icon, color, label) = _statusVisuals(doc.uploadStatus, theme);
    return SakaiSurfaceCard(
      child: Row(
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              _prettyType(doc.documentType.name),
              style: theme.textTheme.titleMedium,
            ),
          ),
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _statusVisuals(
    api.UploadStatus status,
    ThemeData theme,
  ) {
    if (status == api.UploadStatus.approved) {
      return (Icons.check_circle, Colors.green, 'Approved');
    }
    if (status == api.UploadStatus.rejected) {
      return (Icons.cancel, theme.colorScheme.error, 'Rejected');
    }
    if (status == api.UploadStatus.underReview) {
      return (Icons.search, theme.colorScheme.onSurfaceVariant, 'Reviewing');
    }
    return (Icons.schedule, theme.colorScheme.onSurfaceVariant, 'Pending');
  }

  String _prettyType(String name) {
    if (name.isEmpty) return name;
    return name[0].toUpperCase() + name.substring(1);
  }
}
