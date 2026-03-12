import 'package:flutter/material.dart';
import 'package:travelly/features/documents/presentation/widgets/document_card.dart';
import 'package:travelly/features/documents/presentation/widgets/add_document_dialog.dart';
import 'package:travelly/features/documents/data/services/document_service.dart';
import 'package:travelly/core/widgets/primary_button.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
  late Future<Map<String, dynamic>> _documentsFuture;
  final DocumentService _documentService = DocumentService();

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(74.0),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFEDEDED), width: 0.8),
            ),
          ),
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.only(
                left: 16.0,
                right: 16.0,
                top: 22.0,
                bottom: 8.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
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
                  const Icon(Icons.menu, color: Color(0xFF212022), size: 24),
                ],
              ),
            ),
          ),
        ),
      ),
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
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
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
                      onDelete: () => _deleteDocument(doc['id']),
                    ),
                  );
                },
              );
            },
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: PrimaryButton(
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
}
