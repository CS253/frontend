import 'package:flutter/material.dart';
import 'package:travelly/features/documents/presentation/widgets/document_card.dart';
import 'package:travelly/features/documents/presentation/widgets/add_document_dialog.dart';
import 'package:travelly/core/widgets/primary_button.dart';

class DocumentsScreen extends StatefulWidget {
  const DocumentsScreen({super.key});

  @override
  State<DocumentsScreen> createState() => _DocumentsScreenState();
}

class _DocumentsScreenState extends State<DocumentsScreen> {
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
                left: 16.0, right: 16.0, top: 22.0, bottom: 8.0,
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
                          fontSize: 16, fontWeight: FontWeight.w600,
                          color: Color(0xFF212022),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '4 Documents Uploaded',
                        style: TextStyle(
                          fontSize: 12, fontWeight: FontWeight.w400,
                          color: const Color(0xFF8B8893),
                        ),
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
          ListView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            children: const [
              DocumentCard(
                emoji: '🚂',
                title: 'Train Ticket - Delhi to pathankot',
                subtitle: 'Jan 15, 2024 · By Rahul',
              ),
              SizedBox(height: 12),
              DocumentCard(
                emoji: '🏨',
                title: 'Hotel Booking - Snow Valley Resort',
                subtitle: 'Jan 15-18, 2024 · By Amit',
              ),
              SizedBox(height: 12),
              DocumentCard(
                emoji: '🚂',
                title: 'Return Train Ticket',
                subtitle: 'Jan 18, 2024 · By Rahul',
              ),
              SizedBox(height: 12),
              DocumentCard(
                emoji: '📄',
                title: 'Hawkins Pass Permit',
                subtitle: 'Jan 16, 2024 · By Priya',
              ),
              SizedBox(height: 100),
            ],
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(
              child: PrimaryButton(
                label: 'Add Document',
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => const AddDocumentDialog(),
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
