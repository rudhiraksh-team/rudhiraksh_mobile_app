import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

/// Bottom sheet that lets the doctor pick a file (PDF or image) and enter
/// type/notes, then submits via the supplied callback.
///
/// Used both for "create document" (no initial values) and for "edit
/// document" (initial values pre-filled, no file picker).
class UploadDocumentSheet extends StatefulWidget {
  final String title;
  // For edit, file picking is hidden — the existing file URL is kept.
  final bool allowFilePicking;
  final String? initialDocumentType;
  final String? initialNotes;
  // Returns true on success so the sheet can close itself.
  final Future<bool> Function(File? file, String? documentType, String? notes) onSubmit;

  const UploadDocumentSheet({
    super.key,
    required this.title,
    required this.onSubmit,
    this.allowFilePicking = true,
    this.initialDocumentType,
    this.initialNotes,
  });

  @override
  State<UploadDocumentSheet> createState() => _UploadDocumentSheetState();
}

class _UploadDocumentSheetState extends State<UploadDocumentSheet> {
  late final TextEditingController _notesController;
  String? _documentType;
  File? _selectedFile;
  String? _selectedFileName;
  bool _submitting = false;
  String? _error;

  static const _docTypes = ['lab_report', 'mri', 'prescription', 'consent_form', 'other'];

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController(text: widget.initialNotes ?? '');
    _documentType = widget.initialDocumentType;
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickPdf() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'],
    );
    if (result?.files.single.path != null) {
      setState(() {
        _selectedFile = File(result!.files.single.path!);
        _selectedFileName = result.files.single.name;
        _error = null;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picked = await ImagePicker().pickImage(source: source, imageQuality: 80);
    if (picked != null) {
      setState(() {
        _selectedFile = File(picked.path);
        _selectedFileName = picked.name;
        _error = null;
      });
    }
  }

  Future<void> _submit() async {
    if (widget.allowFilePicking && _selectedFile == null) {
      setState(() => _error = 'Please pick a file to upload');
      return;
    }
    setState(() => _submitting = true);
    final ok = await widget.onSubmit(
      _selectedFile,
      _documentType,
      _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );
    if (mounted) {
      setState(() => _submitting = false);
      if (ok) Navigator.of(context).pop();
    }
  }

  String _typeLabel(String value) {
    switch (value) {
      case 'lab_report':
        return 'Lab Report';
      case 'mri':
        return 'MRI';
      case 'prescription':
        return 'Prescription';
      case 'consent_form':
        return 'Consent Form';
      case 'other':
        return 'Other';
      default:
        return value;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Padding(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: colors.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            widget.title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 16),
          if (widget.allowFilePicking) ...[
            Row(
              children: [
                Expanded(
                  child: _PickButton(
                    icon: Icons.picture_as_pdf,
                    label: 'PDF',
                    onTap: _pickPdf,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickButton(
                    icon: Icons.photo_camera,
                    label: 'Camera',
                    onTap: () => _pickImage(ImageSource.camera),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _PickButton(
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () => _pickImage(ImageSource.gallery),
                  ),
                ),
              ],
            ),
            if (_selectedFileName != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colors.backgroundColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.borderColor),
                ),
                child: Row(
                  children: [
                    Icon(Icons.attach_file, size: 18, color: colors.primaryColor),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _selectedFileName!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(color: colors.textPrimary, fontSize: 13),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, size: 18),
                      color: colors.textSecondary,
                      onPressed: () => setState(() {
                        _selectedFile = null;
                        _selectedFileName = null;
                      }),
                    ),
                  ],
                ),
              ),
            ],
            if (_error != null) ...[
              const SizedBox(height: 8),
              Text(_error!, style: const TextStyle(color: Colors.red, fontSize: 12)),
            ],
            const SizedBox(height: 14),
          ],
          // Document type
          Text(
            'Document type',
            style: TextStyle(color: colors.textSecondary, fontSize: 12, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          DropdownButtonFormField<String>(
            initialValue: _documentType,
            decoration: InputDecoration(
              filled: true,
              fillColor: colors.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.borderColor),
              ),
            ),
            items: [
              const DropdownMenuItem<String>(value: null, child: Text('— None —')),
              ..._docTypes.map((t) => DropdownMenuItem<String>(
                    value: t,
                    child: Text(_typeLabel(t)),
                  )),
            ],
            onChanged: (v) => setState(() => _documentType = v),
          ),
          const SizedBox(height: 12),
          // Notes
          TextField(
            controller: _notesController,
            maxLines: 3,
            style: TextStyle(color: colors.textPrimary, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Notes (optional)',
              hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
              filled: true,
              fillColor: colors.backgroundColor,
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.borderColor),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(color: colors.borderColor),
              ),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _submitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
              ),
              child: _submitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text('Save', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
    );
  }
}

class _PickButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _PickButton({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: colors.backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: colors.borderColor),
        ),
        child: Column(
          children: [
            Icon(icon, color: colors.primaryColor, size: 22),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                color: colors.textPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
