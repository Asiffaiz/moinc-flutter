import 'package:flutter/material.dart';
import 'package:moinc/config/theme.dart';
import 'package:moinc/features/documents/domain/models/document_model.dart';
import 'package:moinc/features/documents/presentation/widgets/document_item.dart';
import 'package:moinc/features/documents/presentation/widgets/document_upload_dialog.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  bool _isLoading = false;
  final List<DocumentModel> _documents = [];
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadDummyDocuments();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadDummyDocuments() {
    setState(() {
      _isLoading = true;
    });

    // Simulate network delay
    Future.delayed(const Duration(milliseconds: 800), () {
      setState(() {
        _documents.clear();
        _documents.addAll(_dummyDocuments);
        _isLoading = false;
      });
    });
  }

  void _showUploadDialog() {
    showDialog(
      context: context,
      builder: (context) => const DocumentUploadDialog(),
    ).then((value) {
      if (value != null && value is DocumentModel) {
        setState(() {
          _documents.insert(0, value);
        });
      }
    });
  }

  List<DocumentModel> get _filteredDocuments {
    if (_searchQuery.isEmpty) {
      return _documents;
    }

    final query = _searchQuery.toLowerCase();
    return _documents.where((doc) {
      return doc.title.toLowerCase().contains(query) ||
          doc.fileName.toLowerCase().contains(query) ||
          doc.description?.toLowerCase().contains(query) == true;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Knowledge Base'),
        backgroundColor: AppTheme.secondaryColor,
        foregroundColor: AppTheme.primaryColor,
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child:
                _isLoading
                    ? const Center(
                      child: CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                      ),
                    )
                    : _documents.isEmpty
                    ? _buildEmptyState()
                    : _buildDocumentsList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showUploadDialog,
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.black,
        elevation: 4,
        child: const Icon(Icons.edit_document),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: TextField(
        controller: _searchController,
        style: const TextStyle(color: Colors.white),
        decoration: AppTheme.inputDecoration(
          hintText: 'Search documents...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      setState(() {
                        _searchController.clear();
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.folder_open,
            size: 80,
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),
          const SizedBox(height: 16),
          Text(
            'No documents yet',
            style: AppTheme.headingSmall.copyWith(color: Colors.white),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload PDF or DOC files to train your AI agent',
            style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _showUploadDialog,
            icon: const Icon(Icons.upload_file),
            label: const Text('Upload Document'),
            style: AppTheme.primaryButtonStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentsList() {
    final filteredDocs = _filteredDocuments;

    return filteredDocs.isEmpty
        ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off,
                size: 64,
                color: AppTheme.primaryColor.withOpacity(0.7),
              ),
              const SizedBox(height: 16),
              Text(
                'No matching documents',
                style: AppTheme.headingSmall.copyWith(color: Colors.white),
              ),
              const SizedBox(height: 8),
              Text(
                'Try a different search term',
                style: AppTheme.bodyMedium.copyWith(color: Colors.white70),
              ),
            ],
          ),
        )
        : RefreshIndicator(
          onRefresh: () async {
            _loadDummyDocuments();
          },
          color: AppTheme.primaryColor,
          child: ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: filteredDocs.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final document = filteredDocs[index];
              return DocumentItem(
                document: document,
                onDelete: () {
                  setState(() {
                    _documents.removeWhere((doc) => doc.id == document.id);
                  });
                },
              );
            },
          ),
        );
  }
}

// Dummy data for development
final List<DocumentModel> _dummyDocuments = [
  DocumentModel(
    id: '1',
    title: 'Company Handbook 2025',
    fileName: 'company_handbook_2025.pdf',
    fileType: 'pdf',
    fileSize: '2.4 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 2)),
    description: 'Complete company handbook with policies and procedures',
    isProcessed: true,
  ),
  DocumentModel(
    id: '2',
    title: 'Product Specifications',
    fileName: 'product_specs_v3.docx',
    fileType: 'docx',
    fileSize: '1.7 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 5)),
    description: 'Technical specifications for all current products',
    isProcessed: true,
  ),
  DocumentModel(
    id: '3',
    title: 'Customer Service Guidelines',
    fileName: 'customer_service_guidelines.pdf',
    fileType: 'pdf',
    fileSize: '3.8 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 10)),
    description: 'Guidelines for handling customer inquiries and complaints',
    isProcessed: true,
  ),
  DocumentModel(
    id: '4',
    title: 'Market Research Report Q4',
    fileName: 'market_research_q4_2024.pdf',
    fileType: 'pdf',
    fileSize: '5.2 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 15)),
    description: 'Comprehensive market analysis for Q4 2024',
    isTraining: true,
  ),
  DocumentModel(
    id: '5',
    title: 'Technical Documentation',
    fileName: 'api_documentation_v2.pdf',
    fileType: 'pdf',
    fileSize: '4.1 MB',
    uploadDate: DateTime.now().subtract(const Duration(days: 20)),
    description: 'API documentation for developers',
    isError: true,
    errorMessage: 'File format not supported',
  ),
];
