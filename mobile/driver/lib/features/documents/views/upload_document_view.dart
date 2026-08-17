import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sakai_shared/sakai_shared.dart';
import 'package:driver/features/documents/view_models/document_view_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class UploadDocumentView extends ConsumerStatefulWidget {
  const UploadDocumentView({super.key});

  @override
  ConsumerState<UploadDocumentView> createState() => _UploadDocumentViewState();
}

class _UploadDocumentViewState extends ConsumerState<UploadDocumentView> {
  final _formKey = GlobalKey<FormState>();
  final _documentNumberController = TextEditingController();
  String _selectedType = 'license';
  DateTime? _expiryDate;
  File? _imageFile;
  final _picker = ImagePicker();

  final List<String> _documentTypes = ['license', 'insurance', 'registration'];

  @override
  void dispose() {
    _documentNumberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectExpiryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 365)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 3650)),
    );
    if (picked != null) {
      setState(() {
        _expiryDate = picked;
      });
    }
  }

  Future<void> _upload() async {
    if (!_formKey.currentState!.validate()) return;
    if (_imageFile == null) {
      SakaiSnackBar.warning(context, 'Please select an image');
      return;
    }

    final success = await ref.read(documentViewModelProvider.notifier).uploadDocument(
          documentType: _selectedType,
          documentNumber: _documentNumberController.text,
          imagePath: _imageFile!.path,
          expiryDate: _expiryDate,
        );

    if (success && mounted) {
      SakaiSnackBar.success(context, 'Document uploaded successfully');
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentViewModelProvider);
    final theme = Theme.of(context);

    return SakaiScreenScaffold(
      title: 'Upload Document',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SakaiSurfaceCard(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // ignore: deprecated_member_use
                      DropdownButtonFormField<String>(
                        initialValue: _selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Document Type',
                          border: OutlineInputBorder(),
                        ),
                        items: _documentTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type[0].toUpperCase() + type.substring(1)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      ),
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: TextFormField(
                          controller: _documentNumberController,
                          decoration: const InputDecoration(
                            labelText: 'Document Number',
                            hintText: 'Enter the number on the document',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Required' : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      InkWell(
                        onTap: _selectExpiryDate,
                        child: InputDecorator(
                          decoration: const InputDecoration(
                            labelText: 'Expiry Date (Optional)',
                            border: OutlineInputBorder(),
                            suffixIcon: Icon(Icons.calendar_today),
                          ),
                          child: Text(
                            _expiryDate == null ? 'Not set' : DateFormat.yMMMd().format(_expiryDate!),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text('Document Image', style: theme.textTheme.titleMedium),
              const SizedBox(height: 8),
              SakaiSurfaceCard(
                child: InkWell(
                  onTap: _pickImage,
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      border: Border.all(color: theme.colorScheme.outline),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _imageFile == null
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add_a_photo_outlined, size: 48, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(height: 8),
                              Text(
                                'Tap to select or take a photo',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.file(_imageFile!, fit: BoxFit.cover),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              if (state.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.errorMessage!,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: SakaiSemanticColors.of(context).danger,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SakaiPrimaryButton(
                onPressed: state.isUploading ? null : _upload,
                label: state.isUploading ? 'Uploading...' : 'Upload Document',
              ),
              const SizedBox(height: 16),
              SakaiSecondaryButton(
                onPressed: state.isUploading ? null : () => Navigator.of(context).pop(),
                label: 'Cancel',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
