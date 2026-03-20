import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:travelly/features/documents/presentation/widgets/document_card.dart';
import 'package:travelly/features/documents/presentation/widgets/add_document_dialog.dart';
import 'package:travelly/features/documents/data/services/document_service.dart';
import 'package:travelly/core/widgets/primary_button.dart'; // PrimaryFabButton
import 'package:travelly/features/documents/data/services/document_download_service.dart';
import 'package:travelly/features/documents/presentation/screens/document_viewer_screen.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';

class DocumentsScreen extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const DocumentsScreen({super.key, this.onBackPressed});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<Map<String, dynamic>> _documentsFuture;
  final DocumentService _documentService = DocumentService();
  final DocumentDownloadService _downloadService = DocumentDownloadService();
  
  final Map<String, bool> _downloadingIds = {};

  @override
  void initState() {
    super.initState();
    _refreshDocuments();
  }

  void _refreshDocuments() {
    setState(() {
      _documentsFuture = _documentService.fetchDocuments();
    });
  }

  Future<void> _deleteDocument(String id) async {
    try {
      await _documentService.deleteDocument(id);
      _refreshDocuments();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document deleted successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error deleting document: $e')),
        );
      }
    }
  }

  Future<void> _downloadDocument(String id, String url, String title) async {
    if (_downloadingIds[id] == true) return;

    setState(() {
      _downloadingIds[id] = true;
    });

    try {
      final savedPath = await _downloadService.downloadDocument(url, title);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(savedPath != null ? 'Downloaded to \$savedPath' : 'Download cancelled or failed.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error downloading: \$e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _downloadingIds[id] = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
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
              } else if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              } else if (!snapshot.hasData || (snapshot.data!['documents'] as List).isEmpty) {
                return const Center(child: Text('No documents found.'));
              }

              final documents = snapshot.data!['documents'] as List;

              return ListView.builder(
                padding: EdgeInsets.only(
                  left: 20,
                  right: 20,
                  top: MediaQuery.of(context).padding.top + 120,
                  bottom: 120, // ample space for fab
                ),
                itemCount: documents.length,
                itemBuilder: (context, index) {
                  final doc = documents[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: DocumentCard(
                      id: doc['id'],
                      emoji: doc['emoji'],
                      title: doc['title'],
                      subtitle: doc['subtitle'],
                      onView: doc['url'] != null ? () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => DocumentViewerScreen(
                              url: doc['url'],
                              title: doc['title'],
                            ),
                          ),
                        );
                      } : null,
                      onDownload: doc['url'] != null ? () => _downloadDocument(doc['id'], doc['url'], doc['title']) : null,
                      onDelete: () => _deleteDocument(doc['id']),
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
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (ctx) => const AddDocumentDialog(),
                  );

                  if (result != null && mounted) {
                    try {
                      await _documentService.uploadDocument(result);
                      if (!context.mounted) return;
                      _refreshDocuments();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Document uploaded successfully')),
                      );
                    } catch (e) {
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error uploading document: $e')),
                      );
                    }
                  }
                },
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
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
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
                        final count = snapshot.hasData ? (snapshot.data!['documents'] as List).length : 0;
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
