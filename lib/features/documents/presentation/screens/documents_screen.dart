import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';
import 'package:travelly/core/widgets/primary_button.dart';
import 'package:travelly/core/api/api_client.dart';
import 'package:travelly/features/documents/data/services/document_download_service.dart';
import 'package:travelly/features/documents/data/services/document_service.dart';
import 'package:travelly/features/documents/presentation/screens/document_viewer_screen.dart';
import 'package:travelly/features/documents/presentation/widgets/add_document_dialog.dart';
import 'package:travelly/features/documents/presentation/widgets/document_card.dart';
import 'package:url_launcher/url_launcher.dart';

class DocumentsScreen extends StatefulWidget {
  final String groupId;
  final VoidCallback? onBackPressed;

  const DocumentsScreen({super.key, required this.groupId, this.onBackPressed});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<Map<String, dynamic>> _documentsFuture;
  late final DocumentService _documentService;
  final DocumentDownloadService _downloadService = DocumentDownloadService();
  final Map<String, bool> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _documentService = DocumentService(apiClient: context.read<ApiClient>());
    _refreshDocuments();
  }

  void _refreshDocuments() {
    _documentsFuture = _documentService.fetchDocuments(groupId: widget.groupId);
  }

  Future<void> _deleteDocument(String id) async {
    try {
      await _documentService.deleteDocument(id);
      if (!mounted) {
        return;
      }
      setState(_refreshDocuments);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document deleted successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting document: $e')));
    }
  }

  Future<void> _downloadDocument(String id, String url, String title) async {
    if (_downloadingIds[id] == true) {
      return;
    }

    setState(() {
      _downloadingIds[id] = true;
    });

    try {
      final savedPath = await _downloadService.downloadDocument(url, title);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            savedPath != null
                ? 'Downloaded to $savedPath'
                : 'Download cancelled or failed.',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error downloading: $e')));
    } finally {
      if (!mounted) {
        return;
      }
      setState(() {
        _downloadingIds[id] = false;
      });
    }
  }

  Future<void> _uploadDocument() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) => const AddDocumentDialog(),
    );

    if (result == null || !mounted) {
      return;
    }

    try {
      await _documentService.uploadDocument(
        groupId: widget.groupId,
        filePath: result['filePath'] as String,
        title: result['name'] as String,
      );
      if (!mounted) {
        return;
      }
      setState(_refreshDocuments);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Document uploaded successfully')),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error uploading document: $e')));
    }
  }

  Future<void> _openDocument(Map<String, dynamic> doc) async {
    final url = doc['url'] as String?;
    if (url == null || url.isEmpty) {
      return;
    }

    final extension = (doc['extension'] as String? ?? '').toLowerCase();
    if (extension == 'pdf') {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) =>
              DocumentViewerScreen(url: url, title: doc['title'] as String),
        ),
      );
      return;
    }

    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.groupId.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('A trip id is required to open documents.')),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          FutureBuilder<Map<String, dynamic>>(
            future: _documentsFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              final documents =
                  (snapshot.data?['documents'] as List<dynamic>? ?? []);
              if (documents.isEmpty) {
                return const Center(child: Text('No documents found.'));
              }

              return ListView.builder(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: MediaQuery.of(context).padding.top + 120,
                  bottom: 120,
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index] as Map<String, dynamic>;
                  final url = doc['url'] as String?;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DocumentCard(
                      id: doc['id'] as String,
                      emoji: doc['emoji'] as String,
                      title: doc['title'] as String,
                      subtitle: doc['subtitle'] as String,
                      onView: url == null ? null : () => _openDocument(doc),
                      onDownload: url == null
                          ? null
                          : () => _downloadDocument(
                              doc['id'] as String,
                              url,
                              (doc['title'] as String?) ??
                                  (doc['fileName'] as String? ?? 'document'),
                            ),
                      onDelete: () => _deleteDocument(doc['id'] as String),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildGlassyHeader(),
          ),
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: PrimaryFabButton(
                label: 'Add Document',
                onPressed: _uploadDocument,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassyHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.6),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GlassBackButton(onPressed: widget.onBackPressed),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'Documents',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF212022),
                      ),
                    ),
                    const SizedBox(height: 2),
                    FutureBuilder<Map<String, dynamic>>(
                      future: _documentsFuture,
                      builder: (context, snapshot) {
                        final count =
                            (snapshot.data?['documents'] as List<dynamic>?)
                                ?.length ??
                            0;

                        return Text(
                          '$count Documents Uploaded',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Color(0xFF8B8893),
                          ),
                        );
                      },
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
