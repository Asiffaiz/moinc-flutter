import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/documents/domain/models/document_model.dart';

class DocumentUploadDialog extends StatefulWidget {
  const DocumentUploadDialog({super.key});

  @override
  State<DocumentUploadDialog> createState() => _DocumentUploadDialogState();
}

class _DocumentUploadDialogState extends State<DocumentUploadDialog> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  String? _selectedFileName;
  bool _isUploading = false;
  double _uploadProgress = 0.0;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _selectFile() {
    // In a real app, this would use a file picker
    setState(() {
      _selectedFileName = 'selected_document.pdf';
    });
  }

  void _uploadDocument() {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _isUploading = true;
      _uploadProgress = 0.0;
    });

    // Simulate upload progress
    Future.delayed(const Duration(milliseconds: 500), () {
      setState(() {
        _uploadProgress = 0.3;
      });

      Future.delayed(const Duration(milliseconds: 700), () {
        setState(() {
          _uploadProgress = 0.6;
        });

        Future.delayed(const Duration(milliseconds: 800), () {
          setState(() {
            _uploadProgress = 0.9;
          });

          Future.delayed(const Duration(milliseconds: 500), () {
            // Create a new document model
            final newDocument = DocumentModel(
              id: DateTime.now().millisecondsSinceEpoch.toString(),
              title: _titleController.text,
              fileName: _selectedFileName ?? 'document.pdf',
              fileType: 'pdf',
              fileSize: '3.2 MB',
              uploadDate: DateTime.now(),
              description:
                  _descriptionController.text.isNotEmpty
                      ? _descriptionController.text
                      : null,
              isTraining: true,
            );

            Navigator.of(context).pop(newDocument);
          });
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppTheme.secondaryColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.upload_file,
                      color: AppTheme.primaryColor,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Upload Document',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Upload PDF or DOC files to train your AI agent',
                  style: TextStyle(color: AppTheme.lightTextColor, fontSize: 14),
                ),
                const SizedBox(height: 24),
                _buildFileSelector(),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _titleController,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: AppTheme.inputDecoration(
                    labelText: 'Document Title',
                    hintText: 'Enter a title for this document',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  style: const TextStyle(color: AppTheme.textColor),
                  decoration: AppTheme.inputDecoration(
                    labelText: 'Description (Optional)',
                    hintText: 'Enter a description for this document',
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                if (_isUploading) ...[
                  LinearProgressIndicator(
                    value: _uploadProgress,
                    backgroundColor: Colors.white.withOpacity(0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      'Uploading... ${(_uploadProgress * 100).toInt()}%',
                      style: const TextStyle(color: AppTheme.lightTextColor),
                    ),
                  ),
                  const SizedBox(height: 16),
                ] else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: const Text(
                          'Cancel',
                          style: TextStyle(color: AppTheme.lightTextColor),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed:
                            _selectedFileName == null ? null : _uploadDocument,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.black,
                          disabledBackgroundColor: AppTheme.primaryColor
                              .withOpacity(0.3),
                          disabledForegroundColor: Colors.black45,
                        ),
                        child: const Text('Upload'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFileSelector() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppTheme.secondaryColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              _selectedFileName != null
                  ? AppTheme.primaryColor
                  : Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child:
          _selectedFileName == null
              ? InkWell(
                onTap: _selectFile,
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload,
                        size: 48,
                        color: AppTheme.primaryColor.withOpacity(0.7),
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Click to select a file',
                        style: TextStyle(color: AppTheme.textColor, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'PDF, DOC, DOCX (max 20MB)',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.6),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              )
              : Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryColor.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _selectedFileName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            '3.2 MB',
                            style: TextStyle(
                              color: AppTheme.lightTextColor,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        setState(() {
                          _selectedFileName = null;
                        });
                      },
                      icon: const Icon(Icons.close, color: AppTheme.lightTextColor),
                    ),
                  ],
                ),
              ),
    );
  }
}
