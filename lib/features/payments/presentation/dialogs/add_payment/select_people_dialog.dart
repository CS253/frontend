import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_user_tile.dart';

class SelectPeopleDialog extends StatefulWidget {
  final String groupId;
  final List<String>? initialPeopleIds;
  final VoidCallback onBack;
  final Function(List<String>) onContinue;

  const SelectPeopleDialog({
    super.key,
    required this.groupId,
    this.initialPeopleIds,
    required this.onBack,
    required this.onContinue,
  });

  @override
  State<SelectPeopleDialog> createState() => _SelectPeopleDialogState();
}

class _SelectPeopleDialogState extends State<SelectPeopleDialog> {
  final Set<String> selectedIds = {};
  bool _isLoading = true;
  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    if (widget.initialPeopleIds != null) {
      selectedIds.addAll(widget.initialPeopleIds!);
    }
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await PaymentRepository().getGroupMembers(widget.groupId);
      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
      ),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: widget.onBack,
                  child: const Padding(
                    padding: EdgeInsets.all(4.0),
                    child: Icon(
                      Icons.arrow_back,
                      size: 20,
                      color: Color(0xFF38332E),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'Select People',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: const Color(0xFF38332E),
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 350,
              child: _isLoading 
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => PaymentUserTile.buildLoading(),
                  )
                : ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      final isSelected = selectedIds.contains(member.userId);
                      return PaymentUserTile(
                        member: member,
                        isSelected: isSelected,
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedIds.remove(member.userId);
                            } else {
                              selectedIds.add(member.userId);
                            }
                          });
                        },
                      );
                    },
                  ),
            ),
            const SizedBox(height: 16),
            DialogPrimaryButton(
              text: 'Continue',
              onPressed: () {
                if (selectedIds.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select at least one person')),
                  );
                  return;
                }
                widget.onContinue(selectedIds.toList());
              },
            ),
          ],
        ),
      ),
    );
  }
}
