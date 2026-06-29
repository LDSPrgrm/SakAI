import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:sakai_shared/sakai_shared.dart';
import '../view_models/document_view_model.dart';

class UploadDocumentScreen extends ConsumerStatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  ConsumerState<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends ConsumerState<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _numberController = TextEditingController();
  String _selectedType = 'license';
  DateTime? _expiryDate;
  XFile? _image;
  final _picker = ImagePicker();

  final List<Map<String, String>> _docTypes = [
    {'value': 'license', 'label': 'Driver License'},
    {'value': 'registration', 'label': 'Vehicle Registration'},
    {'value': 'insurance', 'label': 'Insurance Policy'},
    {'value': 'id_card', 'label': 'National ID / Passport'},
  ];

  @override
  void dispose() {
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _image = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        SakaiSnackBar.error(context, 'Error picking image: $e');
      }
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

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_image == null) {
      SakaiSnackBar.warning(
        context,
        'Please select or take a photo of the document',
      );
      return;
    }

    final success = await ref.read(documentViewModelProvider.notifier).uploadDocument(
          documentType: _selectedType,
          documentNumber: _numberController.text,
          imagePath: _image!.path,
          expiryDate: _expiryDate,
        );

    if (success && mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(documentViewModelProvider);
    final scheme = Theme.of(context).colorScheme;

    // Show success/error messages from state
    ref.listen(documentViewModelProvider, (previous, next) {
      if (next.successMessage != null) {
        SakaiSnackBar.success(context, next.successMessage!);
        ref.read(documentViewModelProvider.notifier).clearMessages();
      }
      if (next.errorMessage != null) {
        SakaiSnackBar.error(context, next.errorMessage!);
        ref.read(documentViewModelProvider.notifier).clearMessages();
      }
    });

    return Scaffold(
      appBar: SakaiAppBar(
        title: const Text('Upload Document'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Document Details',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              DropdownButtonFormField<String>(
                initialValue: _selectedType,
                decoration: const InputDecoration(
                  labelText: 'Document Type',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: _docTypes.map((type) {
                  return DropdownMenuItem(
                    value: type['value'],
                    child: Text(type['label']!),
                  );
                }).toList(),
                onChanged: (val) => setState(() => _selectedType = val!),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _numberController,
                decoration: const InputDecoration(
                  labelText: 'Document Number',
                  hintText: 'e.g. License # or ID #',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.numbers),
                ),
                validator: (val) =>
                    (val == null || val.isEmpty) ? 'Please enter the document number' : null,
              ),
              const SizedBox(height: 16),
              InkWell(
                onTap: _selectExpiryDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'Expiry Date (Optional)',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  child: Text(
                    _expiryDate == null
                        ? 'Select Date'
                        : DateFormat('yyyy-MM-dd').format(_expiryDate!),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Document Photo',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              GestureDetector(
                onTap: () => _showImageSourceActionSheet(),
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: scheme.outlineVariant),
                  ),
                  child: _image == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add_a_photo,
                                size: 48, color: scheme.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('Tap to add a photo',
                                style: TextStyle(color: scheme.onSurfaceVariant)),
                          ],
                        )
                      : Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(File(_image!.path), fit: BoxFit.cover),
                            ),
                            Positioned(
                              right: 8,
                              top: 8,
                              child: CircleAvatar(
                                backgroundColor: Colors.black54,
                                child: IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.white),
                                  onPressed: () => _showImageSourceActionSheet(),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: state.isUploading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: state.isUploading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('SUBMIT FOR REVIEW', style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showImageSourceActionSheet() {
    SakaiModalSheet.show<void>(
      context,
      builder: (sheetCtx) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SakaiListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Take a Photo'),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickImage(ImageSource.camera);
            },
          ),
          SakaiListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Choose from Gallery'),
            onTap: () {
              Navigator.pop(sheetCtx);
              _pickImage(ImageSource.gallery);
            },
          ),
        ],
      ),
    );
  }
}
