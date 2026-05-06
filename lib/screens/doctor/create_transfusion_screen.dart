import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';

/// Full-screen form for the doctor to create a new transfusion record
/// for a specific patient. Mirrors the field set used by the web admin
/// form so the same record shape is created on both platforms.
class CreateTransfusionScreen extends StatefulWidget {
  final int patientId;
  final String patientTag;

  const CreateTransfusionScreen({
    super.key,
    required this.patientId,
    required this.patientTag,
  });

  @override
  State<CreateTransfusionScreen> createState() => _CreateTransfusionScreenState();
}

class _CreateTransfusionScreenState extends State<CreateTransfusionScreen> {
  final _formKey = GlobalKey<FormState>();

  // Basic
  DateTime _transfusionDate = DateTime.now();
  final _bloodBagNumberCtrl = TextEditingController();
  final _donorBloodGroupCtrl = TextEditingController();
  final _unitsTransfusedCtrl = TextEditingController();
  final _bloodBagTypeCtrl = TextEditingController();

  // Pre-transfusion
  final _preHemoglobinCtrl = TextEditingController();
  final _preTempCtrl = TextEditingController();
  final _prePulseCtrl = TextEditingController();
  final _preBpSystolicCtrl = TextEditingController();
  final _preBpDiastolicCtrl = TextEditingController();
  final _patientWeightCtrl = TextEditingController();
  bool _preSymptoms = false;
  final _preSymptomsNotesCtrl = TextEditingController();

  // Timeline
  TimeOfDay? _startTime;
  TimeOfDay? _endTime;

  // Safety
  bool _crossMatching = false;
  bool _preWarmed = false;
  bool _consent = false;

  // Post-transfusion
  final _postHemoglobinCtrl = TextEditingController();
  final _postTempCtrl = TextEditingController();
  final _postPulseCtrl = TextEditingController();
  final _postBpSystolicCtrl = TextEditingController();
  final _postBpDiastolicCtrl = TextEditingController();

  // Reaction
  final _reactionDetailsCtrl = TextEditingController();
  final _reactionTreatmentCtrl = TextEditingController();

  // Medications
  bool _medicationGiven = false;
  final _medicationsCtrl = TextEditingController();

  // Other
  final _notesCtrl = TextEditingController();
  final _recommendedLabTestsCtrl = TextEditingController();
  DateTime? _nextScheduledDate;

  bool _saving = false;

  @override
  void dispose() {
    _bloodBagNumberCtrl.dispose();
    _donorBloodGroupCtrl.dispose();
    _unitsTransfusedCtrl.dispose();
    _bloodBagTypeCtrl.dispose();
    _preHemoglobinCtrl.dispose();
    _preTempCtrl.dispose();
    _prePulseCtrl.dispose();
    _preBpSystolicCtrl.dispose();
    _preBpDiastolicCtrl.dispose();
    _patientWeightCtrl.dispose();
    _preSymptomsNotesCtrl.dispose();
    _postHemoglobinCtrl.dispose();
    _postTempCtrl.dispose();
    _postPulseCtrl.dispose();
    _postBpSystolicCtrl.dispose();
    _postBpDiastolicCtrl.dispose();
    _reactionDetailsCtrl.dispose();
    _reactionTreatmentCtrl.dispose();
    _medicationsCtrl.dispose();
    _notesCtrl.dispose();
    _recommendedLabTestsCtrl.dispose();
    super.dispose();
  }

  String _formatTimeIso(DateTime date, TimeOfDay? time) {
    if (time == null) return '';
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute);
    return dt.toUtc().toIso8601String();
  }

  String? _emptyToNull(String s) => s.trim().isEmpty ? null : s.trim();
  int? _intOrNull(String s) => int.tryParse(s.trim());

  Future<void> _pickDate(BuildContext context, {required DateTime initial, required ValueChanged<DateTime> onPick}) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime.now().subtract(const Duration(days: 365 * 5)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) onPick(picked);
  }

  Future<void> _pickTime(BuildContext context, {required ValueChanged<TimeOfDay> onPick}) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) onPick(picked);
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);

    final body = <String, dynamic>{
      'transfusionDate': DateFormat('yyyy-MM-dd').format(_transfusionDate),
      if (_emptyToNull(_bloodBagNumberCtrl.text) != null) 'bloodBagNumber': _emptyToNull(_bloodBagNumberCtrl.text),
      if (_emptyToNull(_donorBloodGroupCtrl.text) != null) 'donorBloodGroup': _emptyToNull(_donorBloodGroupCtrl.text),
      if (_emptyToNull(_unitsTransfusedCtrl.text) != null) 'unitsTransfused': _emptyToNull(_unitsTransfusedCtrl.text),
      if (_emptyToNull(_bloodBagTypeCtrl.text) != null) 'bloodBagType': _emptyToNull(_bloodBagTypeCtrl.text),

      // Pre
      if (_emptyToNull(_preHemoglobinCtrl.text) != null) 'preHemoglobin': _emptyToNull(_preHemoglobinCtrl.text),
      if (_emptyToNull(_preTempCtrl.text) != null) 'preTempC': _emptyToNull(_preTempCtrl.text),
      if (_intOrNull(_prePulseCtrl.text) != null) 'prePulseBpm': _intOrNull(_prePulseCtrl.text),
      if (_intOrNull(_preBpSystolicCtrl.text) != null) 'preBpSystolic': _intOrNull(_preBpSystolicCtrl.text),
      if (_intOrNull(_preBpDiastolicCtrl.text) != null) 'preBpDiastolic': _intOrNull(_preBpDiastolicCtrl.text),
      if (_emptyToNull(_patientWeightCtrl.text) != null) 'patientWeightKg': _emptyToNull(_patientWeightCtrl.text),
      'preSymptomsPresent': _preSymptoms,
      if (_preSymptoms && _emptyToNull(_preSymptomsNotesCtrl.text) != null)
        'preSymptomsNotes': _emptyToNull(_preSymptomsNotesCtrl.text),

      // Timeline
      if (_startTime != null) 'startTime': _formatTimeIso(_transfusionDate, _startTime),
      if (_endTime != null) 'endTime': _formatTimeIso(_transfusionDate, _endTime),

      // Safety
      'crossMatchingDone': _crossMatching,
      'preWarmed': _preWarmed,
      'consentSigned': _consent,

      // Post
      if (_emptyToNull(_postHemoglobinCtrl.text) != null) 'postHemoglobin': _emptyToNull(_postHemoglobinCtrl.text),
      if (_emptyToNull(_postTempCtrl.text) != null) 'postTempC': _emptyToNull(_postTempCtrl.text),
      if (_intOrNull(_postPulseCtrl.text) != null) 'postPulseBpm': _intOrNull(_postPulseCtrl.text),
      if (_intOrNull(_postBpSystolicCtrl.text) != null) 'postBpSystolic': _intOrNull(_postBpSystolicCtrl.text),
      if (_intOrNull(_postBpDiastolicCtrl.text) != null) 'postBpDiastolic': _intOrNull(_postBpDiastolicCtrl.text),

      // Reaction
      if (_emptyToNull(_reactionDetailsCtrl.text) != null) 'reactionDetails': _emptyToNull(_reactionDetailsCtrl.text),
      if (_emptyToNull(_reactionTreatmentCtrl.text) != null) 'reactionTreatment': _emptyToNull(_reactionTreatmentCtrl.text),

      // Medications
      'medicationGiven': _medicationGiven,
      if (_emptyToNull(_medicationsCtrl.text) != null) 'medications': _emptyToNull(_medicationsCtrl.text),

      // Other
      if (_emptyToNull(_notesCtrl.text) != null) 'notes': _emptyToNull(_notesCtrl.text),
      if (_emptyToNull(_recommendedLabTestsCtrl.text) != null) 'recommendedLabTests': _emptyToNull(_recommendedLabTestsCtrl.text),
      if (_nextScheduledDate != null) 'nextScheduledDate': DateFormat('yyyy-MM-dd').format(_nextScheduledDate!),
    };

    final controller = Get.find<DoctorPatientDetailController>(tag: widget.patientTag);
    final ok = await controller.createTransfusion(body);

    if (mounted) {
      setState(() => _saving = false);
      if (ok) {
        Get.back();
        Get.snackbar('Saved', 'Transfusion report created',
            snackPosition: SnackPosition.BOTTOM);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.doctorGreen,
        foregroundColor: Colors.white,
        title: const Text('New Transfusion Report'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          children: [
            _section(colors, 'Basic Info', [
              _dateField(
                colors,
                label: 'Transfusion Date *',
                value: _transfusionDate,
                onTap: () => _pickDate(
                  context,
                  initial: _transfusionDate,
                  onPick: (d) => setState(() => _transfusionDate = d),
                ),
              ),
              _textField(colors, _bloodBagNumberCtrl, 'Blood Unit ID'),
              _textField(colors, _donorBloodGroupCtrl, 'Donor Blood Group'),
              _textField(colors, _unitsTransfusedCtrl, 'Volume (ml)', type: TextInputType.number),
              _textField(colors, _bloodBagTypeCtrl, 'Blood Bag Type'),
            ]),

            _section(colors, 'Pre-Transfusion', [
              _textField(colors, _preHemoglobinCtrl, 'Hemoglobin (g/dL)', type: TextInputType.number),
              _textField(colors, _preTempCtrl, 'Temperature (°C)', type: TextInputType.number),
              _textField(colors, _prePulseCtrl, 'Pulse (bpm)', type: TextInputType.number),
              Row(children: [
                Expanded(child: _textField(colors, _preBpSystolicCtrl, 'BP Systolic', type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _textField(colors, _preBpDiastolicCtrl, 'BP Diastolic', type: TextInputType.number)),
              ]),
              _textField(colors, _patientWeightCtrl, 'Weight (kg)', type: TextInputType.number),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Symptoms before', style: TextStyle(color: colors.textPrimary, fontSize: 14)),
                value: _preSymptoms,
                activeThumbColor: AppColors.doctorGreen,
                onChanged: (v) => setState(() => _preSymptoms = v),
              ),
              if (_preSymptoms) _textField(colors, _preSymptomsNotesCtrl, 'Symptoms notes'),
            ]),

            _section(colors, 'Timeline', [
              _timeField(colors, label: 'Start Time', value: _startTime, onTap: () => _pickTime(context, onPick: (t) => setState(() => _startTime = t))),
              _timeField(colors, label: 'End Time', value: _endTime, onTap: () => _pickTime(context, onPick: (t) => setState(() => _endTime = t))),
            ]),

            _section(colors, 'Safety Checks', [
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Cross-matching done', style: TextStyle(color: colors.textPrimary, fontSize: 14)),
                value: _crossMatching,
                activeColor: AppColors.doctorGreen,
                onChanged: (v) => setState(() => _crossMatching = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Pre-warmed', style: TextStyle(color: colors.textPrimary, fontSize: 14)),
                value: _preWarmed,
                activeColor: AppColors.doctorGreen,
                onChanged: (v) => setState(() => _preWarmed = v ?? false),
              ),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Consent signed', style: TextStyle(color: colors.textPrimary, fontSize: 14)),
                value: _consent,
                activeColor: AppColors.doctorGreen,
                onChanged: (v) => setState(() => _consent = v ?? false),
              ),
            ]),

            _section(colors, 'Post-Transfusion', [
              _textField(colors, _postHemoglobinCtrl, 'Hemoglobin (g/dL)', type: TextInputType.number),
              _textField(colors, _postTempCtrl, 'Temperature (°C)', type: TextInputType.number),
              _textField(colors, _postPulseCtrl, 'Pulse (bpm)', type: TextInputType.number),
              Row(children: [
                Expanded(child: _textField(colors, _postBpSystolicCtrl, 'BP Systolic', type: TextInputType.number)),
                const SizedBox(width: 10),
                Expanded(child: _textField(colors, _postBpDiastolicCtrl, 'BP Diastolic', type: TextInputType.number)),
              ]),
            ]),

            _section(colors, 'Reaction & Treatment', [
              _textField(colors, _reactionDetailsCtrl, 'Reaction details', maxLines: 3),
              _textField(colors, _reactionTreatmentCtrl, 'Treatment given', maxLines: 3),
            ]),

            _section(colors, 'Medications', [
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text('Medication given', style: TextStyle(color: colors.textPrimary, fontSize: 14)),
                value: _medicationGiven,
                activeThumbColor: AppColors.doctorGreen,
                onChanged: (v) => setState(() => _medicationGiven = v),
              ),
              if (_medicationGiven)
                _textField(colors, _medicationsCtrl, 'Medications (comma-separated)', maxLines: 2),
            ]),

            _section(colors, 'Other', [
              _textField(colors, _notesCtrl, 'Notes', maxLines: 3),
              _textField(colors, _recommendedLabTestsCtrl, 'Recommended lab tests', maxLines: 2),
              _dateField(
                colors,
                label: 'Next transfusion date',
                value: _nextScheduledDate,
                onTap: () => _pickDate(
                  context,
                  initial: _nextScheduledDate ?? DateTime.now().add(const Duration(days: 28)),
                  onPick: (d) => setState(() => _nextScheduledDate = d),
                ),
                clearable: true,
                onClear: () => setState(() => _nextScheduledDate = null),
              ),
            ]),

            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saving ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.doctorGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  elevation: 0,
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Text('Save Report',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _section(AppThemeColors colors, String title, List<Widget> children) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.surfaceColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colors.borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: colors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _textField(
    AppThemeColors colors,
    TextEditingController controller,
    String label, {
    TextInputType? type,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextFormField(
        controller: controller,
        keyboardType: type,
        maxLines: maxLines,
        style: TextStyle(color: colors.textPrimary, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
          filled: true,
          fillColor: colors.backgroundColor,
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: colors.borderColor),
          ),
        ),
      ),
    );
  }

  Widget _dateField(
    AppThemeColors colors, {
    required String label,
    required DateTime? value,
    required VoidCallback onTap,
    bool clearable = false,
    VoidCallback? onClear,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.calendar_month, size: 18, color: colors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      value == null ? 'Tap to pick' : DateFormat('dd MMM yyyy').format(value),
                      style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
              if (clearable && value != null)
                IconButton(
                  icon: Icon(Icons.close, size: 18, color: colors.textSecondary),
                  onPressed: onClear,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timeField(
    AppThemeColors colors, {
    required String label,
    required TimeOfDay? value,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: colors.backgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: colors.borderColor),
          ),
          child: Row(
            children: [
              Icon(Icons.access_time, size: 18, color: colors.textSecondary),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: TextStyle(color: colors.textSecondary, fontSize: 11)),
                    const SizedBox(height: 2),
                    Text(
                      value == null ? 'Tap to pick' : value.format(context),
                      style: TextStyle(color: colors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
