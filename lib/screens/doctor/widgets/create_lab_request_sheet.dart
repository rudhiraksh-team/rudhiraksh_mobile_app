import 'package:flutter/material.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';

class CreateLabRequestSheet extends StatefulWidget {
  final Future<bool> Function(String testName, {String? labName, String? notes}) onSubmit;

  const CreateLabRequestSheet({super.key, required this.onSubmit});

  @override
  State<CreateLabRequestSheet> createState() => _CreateLabRequestSheetState();
}

class _CreateLabRequestSheetState extends State<CreateLabRequestSheet> {
  final _testNameController = TextEditingController();
  final _labNameController = TextEditingController();
  final _notesController = TextEditingController();
  bool _isSubmitting = false;
  String? _testNameError;

  @override
  void dispose() {
    _testNameController.dispose();
    _labNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final testName = _testNameController.text.trim();
    if (testName.isEmpty) {
      setState(() => _testNameError = 'Test name is required');
      return;
    }
    setState(() {
      _testNameError = null;
      _isSubmitting = true;
    });

    final success = await widget.onSubmit(
      testName,
      labName: _labNameController.text.trim().isNotEmpty ? _labNameController.text.trim() : null,
      notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
    );

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (success) Navigator.of(context).pop();
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
          const SizedBox(height: 20),
          Text(
            'Request Report',
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Request a report from the Blood Bank for this patient',
            style: TextStyle(
              color: colors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 20),
          _buildField(
            controller: _testNameController,
            label: 'Test / Report Name *',
            hint: 'e.g. CBC, Ferritin Level, Iron Studies',
            error: _testNameError,
            colors: colors,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _labNameController,
            label: 'Lab Name (optional)',
            hint: 'e.g. Blood Bank Lab',
            colors: colors,
          ),
          const SizedBox(height: 14),
          _buildField(
            controller: _notesController,
            label: 'Notes (optional)',
            hint: 'Any additional notes...',
            maxLines: 3,
            colors: colors,
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: _isSubmitting ? null : _submit,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.doctorGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
              child: _isSubmitting
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  : const Text(
                      'Submit Request',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    String? error,
    int maxLines = 1,
    required AppThemeColors colors,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: colors.textPrimary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          style: TextStyle(color: colors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
            errorText: error,
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
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: colors.primaryColor, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
