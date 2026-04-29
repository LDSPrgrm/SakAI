import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:sakai_shared/sakai_shared.dart' hide SavedPlace;

import '../models/saved_place.dart';
import '../view_models/saved_places_view_model.dart';

class SavedPlacesScreen extends ConsumerStatefulWidget {
  const SavedPlacesScreen({super.key});

  @override
  ConsumerState<SavedPlacesScreen> createState() => _SavedPlacesScreenState();
}

class _SavedPlacesScreenState extends ConsumerState<SavedPlacesScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      ref.read(savedPlacesNotifierProvider.notifier).loadSavedPlaces();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(savedPlacesNotifierProvider);
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Places'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) context.pop();
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddPlaceBottomSheet(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Place'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              onRefresh: () => ref.read(savedPlacesNotifierProvider.notifier).loadSavedPlaces(),
              child: state.savedPlaces.isEmpty && state.status == SavedPlacesStatus.loaded
                  ? _buildEmptyState(theme)
                  : ListView.builder(
                      padding: EdgeInsets.all(tokens.spaceLg),
                      itemCount: state.savedPlaces.length,
                      itemBuilder: (context, index) {
                        final place = state.savedPlaces[index];
                        return _buildPlaceCard(context, place, theme, tokens);
                      },
                    ),
            ),
            if (state.status == SavedPlacesStatus.loading)
              Container(
                color: Colors.black26,
                child: const Center(child: CircularProgressIndicator()),
              ),
            if (state.errorMessage != null)
              _buildErrorBanner(state.errorMessage!, theme, tokens),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 80.0, horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.place_outlined,
                size: 64,
                color: theme.colorScheme.secondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Saved Places',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Add places like home or work for faster booking.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorBanner(String message, ThemeData theme, SakaiDesignTokens tokens) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: EdgeInsets.all(tokens.spaceMd),
        color: theme.colorScheme.errorContainer,
        child: Text(
          message,
          style: TextStyle(color: theme.colorScheme.onErrorContainer),
        ),
      ),
    );
  }

  Widget _buildPlaceCard(
    BuildContext context,
    SavedPlace place,
    ThemeData theme,
    SakaiDesignTokens tokens,
  ) {
    IconData iconData = Icons.place;
    switch (place.type) {
      case SavedPlaceType.home:
        iconData = Icons.home;
        break;
      case SavedPlaceType.work:
        iconData = Icons.work;
        break;
      case SavedPlaceType.other:
        iconData = Icons.place;
        break;
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(tokens.radiusMd),
        side: BorderSide(color: theme.colorScheme.outlineVariant),
      ),
      child: ListTile(
        contentPadding: EdgeInsets.all(tokens.spaceMd),
        leading: CircleAvatar(
          backgroundColor: theme.colorScheme.primaryContainer,
          child: Icon(iconData, color: theme.colorScheme.primary),
        ),
        title: Text(
          place.name,
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(place.address),
            const SizedBox(height: 2),
            Text(
              'Lat: ${place.latitude.toStringAsFixed(5)}, Lon: ${place.longitude.toStringAsFixed(5)}',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ],
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
          onPressed: () async {
            final confirmed = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Delete Saved Place?'),
                content: Text('Are you sure you want to remove "${place.name}"?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(false),
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(true),
                    child: Text('Delete', style: TextStyle(color: theme.colorScheme.error)),
                  ),
                ],
              ),
            );

            if (confirmed == true) {
              await ref.read(savedPlacesNotifierProvider.notifier).deleteSavedPlace(place.id);
            }
          },
        ),
      ),
    );
  }

  void _showAddPlaceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const AddPlaceBottomSheet(),
    );
  }
}

class AddPlaceBottomSheet extends ConsumerStatefulWidget {
  const AddPlaceBottomSheet({super.key});

  @override
  ConsumerState<AddPlaceBottomSheet> createState() => _AddPlaceBottomSheetState();
}

class _AddPlaceBottomSheetState extends ConsumerState<AddPlaceBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _latController;
  late TextEditingController _lonController;
  SavedPlaceType _selectedType = SavedPlaceType.other;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _addressController = TextEditingController();
    _latController = TextEditingController(text: '1.290270');
    _lonController = TextEditingController(text: '103.851959');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _latController.dispose();
    _lonController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = SakaiDesignTokens.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: tokens.spaceLg,
        right: tokens.spaceLg,
        top: tokens.spaceLg,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Add Saved Place',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              SakaiTextField(
                controller: _nameController,
                hint: 'Place Name (e.g., Grandma\'s House)',
              ),
              const SizedBox(height: 12),
              SakaiTextField(
                controller: _addressController,
                hint: 'Address',
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: SakaiTextField(
                      controller: _latController,
                      hint: 'Latitude',
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: SakaiTextField(
                      controller: _lonController,
                      hint: 'Longitude',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                'Place Type',
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildTypeOption(SavedPlaceType.home, Icons.home, 'Home'),
                  _buildTypeOption(SavedPlaceType.work, Icons.work, 'Work'),
                  _buildTypeOption(SavedPlaceType.other, Icons.place, 'Other'),
                ],
              ),
              const SizedBox(height: 24),
              SakaiPrimaryButton(
                label: 'Save Place',
                onPressed: () async {
                  if (_nameController.text.trim().isEmpty ||
                      _addressController.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please fill in all required fields.')),
                    );
                    return;
                  }

                  final lat = double.tryParse(_latController.text) ?? 0.0;
                  final lon = double.tryParse(_lonController.text) ?? 0.0;

                  final success = await ref
                      .read(savedPlacesNotifierProvider.notifier)
                      .addSavedPlace(
                        name: _nameController.text.trim(),
                        address: _addressController.text.trim(),
                        latitude: lat,
                        longitude: lon,
                        type: _selectedType,
                      );

                  if (success && context.mounted) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Saved place added successfully!'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption(SavedPlaceType type, IconData icon, String label) {
    final isSelected = _selectedType == type;
    final theme = Theme.of(context);

    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      avatar: Icon(
        icon,
        color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
        size: 18,
      ),
      selectedColor: theme.colorScheme.primary,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedType = type;
          });
        }
      },
    );
  }
}
