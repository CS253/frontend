import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_split_row.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/add_payment/select_people_dialog.dart';

class EditSplitDialog extends StatefulWidget {
  final String groupId;
  final double totalAmount;
  final String currencySymbol;
  final bool initialSplitEqually;
  final List<String> initialSelectedPeopleIds;
  final Map<String, double> initialCustomAmounts;
  final List<MemberModel> allMembers;

  const EditSplitDialog({
    super.key,
    required this.groupId,
    required this.totalAmount,
    required this.currencySymbol,
    required this.initialSplitEqually,
    required this.initialSelectedPeopleIds,
    required this.initialCustomAmounts,
    required this.allMembers,
  });

  @override
  State<EditSplitDialog> createState() => _EditSplitDialogState();
}

class _EditSplitDialogState extends State<EditSplitDialog> {
  late bool _splitEqually;
  late List<String> _selectedPeopleIds;
  final Map<String, TextEditingController> _splitControllers = {};

  @override
  void initState() {
    super.initState();
    _splitEqually = widget.initialSplitEqually;
    _selectedPeopleIds = List.from(widget.initialSelectedPeopleIds);

    for (var id in _selectedPeopleIds) {
      double amt = widget.initialCustomAmounts[id] ?? 0.0;
      _splitControllers[id] = TextEditingController(text: amt.toStringAsFixed(2));
    }

    if (_splitEqually) {
      _recalculateSplits();
    }
  }

  @override
  void dispose() {
    for (var c in _splitControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  void _recalculateSplits() {
    if (!_splitEqually) return;

    double total = widget.totalAmount;
    int divisor = _selectedPeopleIds.length;
    if (divisor == 0) return;

    int totalCents = (total * 100).round();
    int fCents = totalCents ~/ divisor;
    int remainder = totalCents % divisor;

    int y = remainder;
    int x = divisor - y;

    double f = fCents / 100.0;
    double c = (fCents + 1) / 100.0;

    List<String> ids = List.from(_selectedPeopleIds);
    // Note: To keep it deterministic during editing we don't shuffle here
    // or we use a fixed seed if needed. Let's just apply sequentially.

    for (int i = 0; i < ids.length; i++) {
      String id = ids[i];
      if (_splitControllers.containsKey(id)) {
        if (i < x) {
          _splitControllers[id]!.text = f.toStringAsFixed(2);
        } else {
          _splitControllers[id]!.text = c.toStringAsFixed(2);
        }
      }
    }
  }

  void _updatePeople(List<String> newIds) {
    setState(() {
      _selectedPeopleIds = newIds;
      final Map<String, TextEditingController> newControllers = {};
      for (var id in newIds) {
        if (_splitControllers.containsKey(id)) {
          newControllers[id] = _splitControllers[id]!;
        } else {
          newControllers[id] = TextEditingController(text: '0.00');
        }
      }
      _splitControllers.keys.where((k) => !newIds.contains(k)).forEach((k) {
        _splitControllers[k]?.dispose();
      });
      _splitControllers.clear();
      _splitControllers.addAll(newControllers);
      
      if (_splitEqually) _recalculateSplits();
    });
  }

  void _onSave() {
    // Validate sum if custom
    double sum = 0;
    for (var c in _splitControllers.values) {
      sum += double.tryParse(c.text) ?? 0.0;
    }

    if ((sum * 100).round() != (widget.totalAmount * 100).round()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Split amounts must exactly equal the total.')),
      );
      return;
    }

    final result = {
      'splitEqually': _splitEqually,
      'selectedPeopleIds': _selectedPeopleIds,
      'customAmounts': _splitControllers.map((k, v) => MapEntry(k, double.tryParse(v.text) ?? 0.0)),
    };
    Navigator.pop(context, result);
  }

  @override
  Widget build(BuildContext context) {
    final activeMembers = widget.allMembers
        .where((m) => _selectedPeopleIds.contains(m.userId))
        .toList();

    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Edit Split',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: const Color(0xFF38332E),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, size: 20),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Toggle & Edit People Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _splitEqually = !_splitEqually;
                      if (_splitEqually) _recalculateSplits();
                    });
                  },
                  child: Row(
                    children: [
                      Switch.adaptive(
                        value: _splitEqually,
                        activeColor: const Color(0xFF9FDFCA),
                        onChanged: (v) {
                          setState(() {
                            _splitEqually = v;
                            if (_splitEqually) _recalculateSplits();
                          });
                        },
                      ),
                      Text(
                        'Split equally',
                        style: GoogleFonts.plusJakartaSans(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (ctx) => SelectPeopleDialog(
                        groupId: widget.groupId,
                        initialPeopleIds: _selectedPeopleIds,
                        onBack: () => Navigator.pop(ctx),
                        onContinue: (ids) {
                          Navigator.pop(ctx);
                          _updatePeople(ids);
                        },
                      ),
                    );
                  },
                  icon: const Icon(Icons.person_add_alt_1, size: 16),
                  label: const Text('People'),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            ConstrainedBox(
              constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.4),
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: activeMembers.length,
                itemBuilder: (context, index) {
                  final member = activeMembers[index];
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: PaymentSplitRow(
                      member: member,
                      controller: _splitControllers[member.userId]!,
                      currencySymbol: widget.currencySymbol,
                      onManualEdit: () {
                        if (_splitEqually) setState(() => _splitEqually = false);
                      },
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 20),
            DialogPrimaryButton(
              text: 'Done',
              onPressed: _onSave,
              backgroundColor: const Color(0xFF9FDFCA),
              textColor: const Color(0xFF339977),
            ),
          ],
        ),
      ),
    );
  }
}
