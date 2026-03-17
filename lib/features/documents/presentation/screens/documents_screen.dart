import 'package:flutter/material.dart';

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
        preferredSize: const Size.fromHeight(
          74.0,
        ), // Increased height for more top spacing
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
              ), // Increased top padding here
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
                      Text(
                        '4 Documents Uploaded',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
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
            children: [
              _buildDocumentCard(
                emoji: '🚂',
                title: 'Train Ticket - Delhi to pathankot',
                subtitle: 'Jan 15, 2024 · By Rahul',
              ),
              const SizedBox(height: 12),
              _buildDocumentCard(
                emoji: '🏨',
                title: 'Hotel Booking - Snow Valley Resort',
                subtitle: 'Jan 15-18, 2024 · By Amit',
              ),
              const SizedBox(height: 12),
              _buildDocumentCard(
                emoji: '🚂',
                title: 'Return Train Ticket',
                subtitle: 'Jan 18, 2024 · By Rahul',
              ),
              const SizedBox(height: 12),
              _buildDocumentCard(
                emoji: '📄',
                title: 'Hawkins Pass Permit',
                subtitle: 'Jan 16, 2024 · By Priya',
              ),
              const SizedBox(
                height: 100,
              ), // Additional padding for FAB and bottom navbar
            ],
          ),
          Positioned(
            bottom: 24,
            left: 0,
            right: 0,
            child: Center(child: _buildAddButton()),
          ),
        ],
      ),
    );
  }

  Widget _buildDocumentCard({
    required String emoji,
    required String title,
    required String subtitle,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(9.68),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.08),
            blurRadius: 16.133,
            offset: const Offset(0, 3.227),
            spreadRadius: -3.227,
          ),
        ],
      ),
      padding: const EdgeInsets.all(12.9),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD9F0FC),
              borderRadius: BorderRadius.circular(9.68),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12.9,
                    fontWeight: FontWeight.w500,
                    fontFamily: 'Nunito',
                    color: Color(0xFF212022),
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 9.68,
                    fontWeight: FontWeight.w400,
                    fontFamily: 'Nunito',
                    color: Color(0xFF8B8893),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 25.8,
                height: 25.8,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.remove_red_eye_outlined,
                    size: 12.9,
                    color: Color(0xFF8B8893),
                  ),
                  onPressed: () {},
                ),
              ),
              const SizedBox(width: 3.2),
              Container(
                width: 25.8,
                height: 25.8,
                decoration: BoxDecoration(shape: BoxShape.circle),
                child: IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(
                    Icons.download_outlined,
                    size: 12.9,
                    color: Color(0xFF8B8893),
                  ),
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF8DA78),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38332E).withValues(alpha: 0.12),
            blurRadius: 27.5,
            offset: const Offset(0, 7.3),
            spreadRadius: -5.5,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.add, size: 20, color: Color(0xFF1A1A1A)),
          const SizedBox(width: 8),
          const Text(
            'Add Document',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}
