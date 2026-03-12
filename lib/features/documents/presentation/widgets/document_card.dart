import 'package:flutter/material.dart';

/// A reusable document card widget.
class DocumentCard extends StatelessWidget {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final VoidCallback? onView;
  final VoidCallback? onDownload;
  final VoidCallback? onDelete;

  const DocumentCard({
    super.key,
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    this.onView,
    this.onDownload,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
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
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.remove_red_eye_outlined, size: 16, color: Color(0xFF8B8893)),
                onPressed: onView ?? () {},
              ),
              const SizedBox(width: 8),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.download_outlined, size: 16, color: Color(0xFF8B8893)),
                onPressed: onDownload ?? () {},
              ),
              if (onDelete != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.delete_outline, size: 16, color: Color(0xFF8B8893)),
                  onPressed: onDelete,
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
