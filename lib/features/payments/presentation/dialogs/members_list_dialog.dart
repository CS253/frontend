import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';

/// Dialog that shows the list of group members.
class MembersListDialog extends StatelessWidget {
  final String groupId;

  const MembersListDialog({super.key, required this.groupId});

  static void show(BuildContext context, {required String groupId}) {
    showDialog(
      context: context,
      builder: (_) => MembersListDialog(groupId: groupId),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 32),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Group Members',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.3,
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Icon(Icons.close, size: 20, color: Color(0xFF8A8075)),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FutureBuilder<List<MemberModel>>(
              future: PaymentRepository().getGroupMembers(groupId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Center(child: CircularProgressIndicator()),
                  );
                }
                if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        'No members found',
                        style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF8A8075)),
                      ),
                    ),
                  );
                }

                final members = snapshot.data!;
                return ConstrainedBox(
                  constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: members.length,
                    separatorBuilder: (_, a1) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final member = members[index];
                      return Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFDFDFB),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: member.avatarColor,
                              ),
                              child: Center(
                                child: Text(
                                  member.initials,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color: const Color(0xFF38332E),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      color: const Color(0xFF38332E),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (member.email.isNotEmpty) ...[
                                    const SizedBox(height: 2),
                                    Text(
                                      member.email,
                                      style: GoogleFonts.plusJakartaSans(
                                        fontSize: 12,
                                        color: const Color(0xFF8A8075),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
