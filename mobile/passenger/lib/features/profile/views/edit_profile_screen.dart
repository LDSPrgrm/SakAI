import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart';

import '../view_models/edit_profile_view_model.dart';

/// Edit profile screen with form validation and save functionality.
class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = ref.read(editProfileNotifierProvider);
    _nameController = TextEditingController(text: state.name);
    _phoneController = TextEditingController(text: state.phone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(editProfileNotifierProvider);
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    // Listen for save success to show snackbar and pop
    ref.listen<EditProfileState>(editProfileNotifierProvider, (_, next) {
      if (next.isSuccess) {
        SakaiSnackBar.success(context, 'Profile updated successfully');
        if (context.canPop()) {
          context.pop();
        }
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: EdgeInsets.all(tokens.spaceLg),
              children: [
                // Name field
                SakaiTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Enter your full name',
                  errorText: state.nameError,
                  enabled: !state.isSaving,
                  onChanged: (value) {
                    ref
                        .read(editProfileNotifierProvider.notifier)
                        .updateName(value);
                  },
                ),

                const SizedBox(height: 8),

                // Phone field
                SakaiTextField(
                  controller: _phoneController,
                  label: 'Phone (optional)',
                  hint: '+1234567890',
                  errorText: state.phoneError,
                  enabled: !state.isSaving,
                  keyboardType: TextInputType.phone,
                  onChanged: (value) {
                    ref
                        .read(editProfileNotifierProvider.notifier)
                        .updatePhone(value);
                  },
                ),

                const SizedBox(height: 24),

                // Error message from API
                if (state.errorMessage != null) ...[
                  Container(
                    padding: EdgeInsets.all(tokens.spaceMd),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.errorContainer,
                      borderRadius: BorderRadius.circular(tokens.radiusSm),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            state.errorMessage!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Save button
                SakaiPrimaryButton(
                  label: state.isSaving ? 'Saving...' : 'Save Changes',
                  icon: state.isSaving ? null : Icons.check,
                  onPressed: state.isSaving
                      ? null
                      : () {
                          ref
                              .read(editProfileNotifierProvider.notifier)
                              .saveProfile();
                        },
                ),

                SizedBox(height: tokens.spaceSm),

                // Cancel button
                SakaiSecondaryButton(
                  label: 'Cancel',
                  onPressed: state.isSaving
                      ? null
                      : () {
                          if (context.canPop()) context.pop();
                        },
                ),
              ],
            ),

            // Loading overlay while saving
            if (state.isSaving)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
          ],
        ),
      ),
    );
  }
}
