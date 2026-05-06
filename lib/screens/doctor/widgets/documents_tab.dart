import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:solar_icon_pack/solar_icon_pack.dart';
import 'package:rudhirakshapp/core/constants/app_colors.dart';
import 'package:rudhirakshapp/core/theme/app_theme_colors.dart';
import 'package:rudhirakshapp/controllers/doctor_patient_detail_controller.dart';
import 'package:rudhirakshapp/data/models/doctor_models.dart';
import 'package:rudhirakshapp/data/helper%20function/file_viewer_helper.dart';
import 'package:rudhirakshapp/screens/doctor/widgets/upload_document_sheet.dart';

class DocumentsTab extends StatelessWidget {
  final DoctorPatientDetailController controller;

  const DocumentsTab({super.key, required this.controller});

  void _openUploadSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.of(context).surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UploadDocumentSheet(
        title: 'Upload Document',
        onSubmit: (file, documentType, notes) async {
          if (file == null) return false;
          return controller.uploadDocument(
            file: file,
            documentType: documentType,
            notes: notes,
          );
        },
      ),
    );
  }

  void _openEditSheet(BuildContext context, PatientDocument doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppThemeColors.of(context).surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => UploadDocumentSheet(
        title: 'Edit Document',
        allowFilePicking: false,
        initialDocumentType: doc.documentType,
        initialNotes: doc.notes,
        onSubmit: (_, documentType, notes) {
          return controller.updateDocument(doc.id, {
            'documentType': ?documentType,
            'notes': ?notes,
          });
        },
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, PatientDocument doc) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete document?'),
        content: Text('Remove "${doc.fileName ?? 'this document'}" permanently?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteDocument(doc.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);

    return Stack(
      children: [
        Obx(() {
          if (controller.documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(SolarLinearIcons.document, size: 48, color: colors.textSecondary),
                  const SizedBox(height: 12),
                  Text(
                    'No documents yet',
                    style: TextStyle(color: colors.textSecondary, fontSize: 14),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap + to upload',
                    style: TextStyle(color: colors.textSecondary, fontSize: 12),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => controller.fetchAll(),
            color: colors.primaryColor,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
              itemCount: controller.documents.length,
              itemBuilder: (context, index) {
                final doc = controller.documents[index];
                return _DocumentRow(
                  doc: doc,
                  onTap: () => FileViewerHelper.showViewerSheet(
                    context,
                    url: doc.fileUrl,
                    fileName: doc.fileName,
                  ),
                  onEdit: () => _openEditSheet(context, doc),
                  onDelete: () => _confirmDelete(context, doc),
                );
              },
            ),
          );
        }),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            heroTag: 'doctor-doc-upload',
            onPressed: () => _openUploadSheet(context),
            backgroundColor: AppColors.doctorGreen,
            foregroundColor: Colors.white,
            icon: const Icon(Icons.add),
            label: const Text('Upload'),
          ),
        ),
      ],
    );
  }
}

class _DocumentRow extends StatelessWidget {
  final PatientDocument doc;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _DocumentRow({
    required this.doc,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppThemeColors.of(context);
    final isLabReport = doc.documentType == 'lab_report';
    final accent = isLabReport ? AppColors.coral : AppColors.indigo;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: colors.surfaceColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: colors.borderColor),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                isLabReport ? SolarLinearIcons.testTube : SolarLinearIcons.file,
                size: 22,
                color: accent,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    doc.fileName ?? 'Document',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      if (doc.documentType != null)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            doc.documentType!.replaceAll('_', ' '),
                            style: TextStyle(
                              color: accent,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Text(
                        doc.formattedDate,
                        style: TextStyle(color: colors.textSecondary, fontSize: 12),
                      ),
                    ],
                  ),
                  if (doc.uploadedByName != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'By ${doc.uploadedByName}',
                      style: TextStyle(color: colors.textSecondary, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),
            PopupMenuButton<String>(
              icon: Icon(Icons.more_vert, color: colors.textSecondary),
              onSelected: (value) {
                if (value == 'edit') onEdit();
                if (value == 'delete') onDelete();
              },
              itemBuilder: (_) => const [
                PopupMenuItem(value: 'edit', child: Text('Edit')),
                PopupMenuItem(
                  value: 'delete',
                  child: Text('Delete', style: TextStyle(color: Colors.red)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
