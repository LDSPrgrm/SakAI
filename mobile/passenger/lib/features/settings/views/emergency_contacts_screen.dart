import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:uuid/uuid.dart';

import '../models/emergency_contact.dart';
import '../view_models/emergency_contacts_view_model.dart';

/// Emergency contacts management screen.
class EmergencyContactsScreen extends ConsumerWidget {
  const EmergencyContactsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(emergencyContactsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Emergency Contacts'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: state.contacts.isEmpty
          ? _EmptyState(onAdd: () => _showAddDialog(context, ref))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                SakaiSurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Add up to 3 emergency contacts. These people will be '
                          'notified in case of an emergency during your rides.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                ...state.contacts.map(
                  (contact) => _ContactTile(
                    contact: contact,
                    onEdit: () => _showEditDialog(context, ref, contact),
                    onDelete: () => _showDeleteDialog(context, ref, contact),
                  ),
                ),
                if (state.canAddMore) ...[
                  const SizedBox(height: 16),
                  SakaiPrimaryButton(
                    label: 'Add Contact',
                    icon: Icons.add,
                    onPressed: () => _showAddDialog(context, ref),
                  ),
                ],
                if (!state.canAddMore) ...[
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Maximum contacts reached (3)',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ],
            ),
    );
  }

  void _showAddDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => _ContactFormDialog(
        onSave: (name, phone, relationship) async {
          final contact = EmergencyContactModel(
            id: const Uuid().v4(),
            name: name,
            phone: phone,
            relationship: relationship,
          );
          await ref
              .read(emergencyContactsProvider.notifier)
              .addContact(contact);
        },
      ),
    );
  }

  void _showEditDialog(
    BuildContext context,
    WidgetRef ref,
    EmergencyContactModel contact,
  ) {
    showDialog(
      context: context,
      builder: (_) => _ContactFormDialog(
        initialName: contact.name,
        initialPhone: contact.phone,
        initialRelationship: contact.relationship,
        onSave: (name, phone, relationship) async {
          final updated = contact.copyWith(
            name: name,
            phone: phone,
            relationship: relationship,
          );
          await ref
              .read(emergencyContactsProvider.notifier)
              .updateContact(updated);
        },
      ),
    );
  }

  void _showDeleteDialog(
    BuildContext context,
    WidgetRef ref,
    EmergencyContactModel contact,
  ) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Remove Contact'),
        content: Text(
          'Are you sure you want to remove "${contact.name}" from your emergency contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              ref
                  .read(emergencyContactsProvider.notifier)
                  .removeContact(contact.id);
              context.pop();
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }
}

// ─── Contact Tile ──────────────────────────────────────────────────

class _ContactTile extends StatelessWidget {
  const _ContactTile({
    required this.contact,
    required this.onEdit,
    required this.onDelete,
  });

  final EmergencyContactModel contact;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SakaiSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.person_outline,
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.relationship,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  contact.phone,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.edit_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: onEdit,
            tooltip: 'Edit',
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            onPressed: onDelete,
            tooltip: 'Remove',
          ),
        ],
      ),
    );
  }
}

// ─── Empty State ───────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.emergency_outlined,
              size: 80,
              color: theme.colorScheme.outlineVariant,
            ),
            const SizedBox(height: 24),
            Text(
              'No emergency contacts',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Add up to 3 emergency contacts who will be '
              'notified in case of an emergency.',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 32),
            SakaiPrimaryButton(
              label: 'Add Contact',
              icon: Icons.add,
              onPressed: onAdd,
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Contact Form Dialog ───────────────────────────────────────────

class _ContactFormDialog extends StatefulWidget {
  const _ContactFormDialog({
    required this.onSave,
    this.initialName,
    this.initialPhone,
    this.initialRelationship,
  });

  final Future<void> Function(String name, String phone, String relationship)
  onSave;
  final String? initialName;
  final String? initialPhone;
  final String? initialRelationship;

  @override
  State<_ContactFormDialog> createState() => _ContactFormDialogState();
}

class _ContactFormDialogState extends State<_ContactFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationshipController;

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _relationshipController = TextEditingController(
      text: widget.initialRelationship ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationshipController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    await widget.onSave(
      _nameController.text.trim(),
      _phoneController.text.trim(),
      _relationshipController.text.trim(),
    );

    if (mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.initialName != null;

    return AlertDialog(
      title: Text(isEditing ? 'Edit Contact' : 'Add Emergency Contact'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SakaiTextField(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter contact name',
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
              ),
              SakaiTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: 'Enter phone number',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
              ),
              SakaiTextField(
                controller: _relationshipController,
                label: 'Relationship',
                hint: 'e.g., Spouse, Parent, Friend',
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.done,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isSaving ? null : () => context.pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isSaving ? null : _handleSave,
          child: _isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.onPrimary,
                  ),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
