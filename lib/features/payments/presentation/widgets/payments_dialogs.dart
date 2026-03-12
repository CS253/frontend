import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';

class AddPaymentDialog extends StatefulWidget {
  const AddPaymentDialog({super.key});

  @override
  State<AddPaymentDialog> createState() => _AddPaymentDialogState();
}

class _AddPaymentDialogState extends State<AddPaymentDialog> {
  String selectedPayer = 'Rushabh';
  String _selectedEmoji = '✈️';
  final TextEditingController amountController = TextEditingController(text: '19000');
  final TextEditingController descriptionController = TextEditingController(text: 'Flights');
  final TextEditingController dateController = TextEditingController(text: '29/02/2024');
  final TextEditingController transactionIdController = TextEditingController(text: '124421');
  
  List<MemberModel> _members = [];
  bool _isLoadingMembers = true;

  @override
  void initState() {
    super.initState();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await PaymentRepository().getTripMembers();
      if (mounted) {
        setState(() {
          _members = members;
          _isLoadingMembers = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingMembers = false;
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
                  onTap: () => Navigator.pop(context),
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
                  'Add Payment',
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
            _buildLabel('Amount *'),
            const SizedBox(height: 8),
            _buildTextField(
              prefixText: '₹   ',
              hintText: 'e.g., 2000',
              controller: amountController,
              isNumber: true,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                GestureDetector(
                  onTap: () => _showEmojiPicker(context),
                  child: Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF8),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(
                        color: const Color(0xFFEBE7E0),
                        width: 0.75,
                      ),
                    ),
                    child: Center(
                      child: Text(_selectedEmoji, style: const TextStyle(fontSize: 28)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Description *'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: 'Flights',
                        controller: descriptionController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildLabel('Paid by *'),
            const SizedBox(height: 8),
            _isLoadingMembers
                ? Container(
                    height: 42,
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCFAF8),
                      borderRadius: BorderRadius.circular(9),
                      border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: const Center(
                      child: SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF8A8075)),
                      ),
                    ),
                  )
                : _buildDropdown(
                    value: selectedPayer,
                    items: _members.map((e) => e.name).toList(),
                    onChanged: (val) {
                      if (val != null) setState(() => selectedPayer = val);
                    },
                  ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Date'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: '29/02/2024',
                        controller: dateController,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildLabel('Transaction ID'),
                      const SizedBox(height: 8),
                      _buildTextField(
                        hintText: '124421',
                        controller: transactionIdController,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => SelectPeopleDialog(
                      totalAmount: amountController.text.isNotEmpty ? amountController.text : '0',
                      description: descriptionController.text,
                      emoji: _selectedEmoji,
                      payer: selectedPayer,
                      date: dateController.text,
                      transactionId: transactionIdController.text,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEmojiPicker(BuildContext context) {
    final List<String> emojis = [
      '✈️', '🏨', '🚌', '🚗', '🎫', '🗺️', '💳', '🧳',
      '🍔', '☕', '🎭', '🎢', '⛺', '🚁', '🚲', '⛽',
      '💊', '🩺', '📞', '🔑', '🪪', '📦', '🎒', '👕',
      '📄', '🚂', '📋', '📑', '🔖', '🛂', '🎟️', '🛳️',
      '🏠', '📝', '🗓️', '💰', '🧾', '📸', '🏔️', '🏖️',
    ];

    showDialog(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: const Color(0xFFFCFAF8),
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75),
          ),
          insetPadding: const EdgeInsets.symmetric(horizontal: 40),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    InkWell(
                      onTap: () => Navigator.pop(ctx),
                      child: const Padding(
                        padding: EdgeInsets.all(4),
                        child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Select Emoji',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: const Color(0xFF38332E),
                        letterSpacing: -0.38,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 8,
                    mainAxisSpacing: 8,
                    crossAxisSpacing: 8,
                  ),
                  itemCount: emojis.length,
                  itemBuilder: (context, index) {
                    final emoji = emojis[index];
                    final isSelected = emoji == _selectedEmoji;
                    return GestureDetector(
                      onTap: () {
                        setState(() => _selectedEmoji = emoji);
                        Navigator.pop(ctx);
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFF8DA78).withValues(alpha: 0.3)
                              : const Color(0xFFFDFDFB),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFF8DA78)
                                : const Color(0xFFEBE7E0),
                            width: isSelected ? 1.5 : 0.75,
                          ),
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 22)),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: GoogleFonts.plusJakartaSans(
        fontWeight: FontWeight.w500,
        fontSize: 12,
        color: const Color(0xFF38332E),
      ),
    );
  }

  Widget _buildTextField({
    String? prefixText,
    required String hintText,
    TextEditingController? controller,
    bool isNumber = false,
  }) {
    return SizedBox(
      height: 42,
      child: TextField(
        controller: controller,
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        inputFormatters: isNumber
            ? [FilteringTextInputFormatter.digitsOnly]
            : null,
        decoration: InputDecoration(
          filled: true,
          fillColor: const Color(0xFFFCFAF8),
          prefixText: prefixText,
          prefixStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: const Color(0xFF38332E),
          ),
          hintText: hintText,
          hintStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.normal,
            fontSize: 14,
            color: const Color(0xFF8A8075),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 0,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(9),
            borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1),
          ),
        ),
        style: GoogleFonts.plusJakartaSans(
          fontWeight: FontWeight.bold,
          fontSize: 14,
          color: const Color(0xFF38332E),
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFFCFAF8),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(
            Icons.keyboard_arrow_down,
            color: Color(0xFF8A8075),
            size: 16,
          ),
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: 14,
            color: const Color(0xFF38332E),
          ),
          onChanged: onChanged,
          items: items.map<DropdownMenuItem<String>>((String val) {
            return DropdownMenuItem<String>(value: val, child: Text(val));
          }).toList(),
        ),
      ),
    );
  }
}

class SelectPeopleDialog extends StatefulWidget {
  final String totalAmount;
  final String description;
  final String emoji;
  final String payer;
  final String date;
  final String transactionId;

  const SelectPeopleDialog({
    super.key,
    required this.totalAmount,
    required this.description,
    required this.emoji,
    required this.payer,
    required this.date,
    required this.transactionId,
  });

  @override
  State<SelectPeopleDialog> createState() => _SelectPeopleDialogState();
}

class _SelectPeopleDialogState extends State<SelectPeopleDialog> {
  final Set<String> selectedNames = {};
  bool _isLoading = true;
  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    selectedNames.addAll(['Kashish', 'Rushabh', 'Ashish', 'Hipalantya', 'Aman', 'Suresh']);
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await PaymentRepository().getTripMembers();
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
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => const AddPaymentDialog(),
                    );
                  },
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
              height: 350, // Fixed height for scrollable area
              child: _isLoading 
                ? ListView.builder(
                    itemCount: 5,
                    itemBuilder: (context, index) => _buildLoadingMemberCard(),
                  )
                : ListView.builder(
                    itemCount: _members.length,
                    itemBuilder: (context, index) {
                      final member = _members[index];
                      final isSelected = selectedNames.contains(member.name);
                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            if (isSelected) {
                              selectedNames.remove(member.name);
                            } else {
                              selectedNames.add(member.name);
                            }
                          });
                        },
                        child: Container(
                          margin: const EdgeInsets.only(bottom: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFDFDFB),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: isSelected
                                  ? const Color(0xFF9FDFCA)
                                  : const Color.fromRGBO(235, 231, 224, 0.5),
                              width: isSelected ? 1.5 : 0.75,
                            ),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: member.avatarColor,
                                ),
                                child: Center(
                                  child: Text(
                                    member.initials,
                                    style: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  member.name,
                                  style: GoogleFonts.plusJakartaSans(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                    color: const Color(0xFF38332E),
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Color(0xFF9FDFCA),
                                  size: 20,
                                )
                              else
                                const Icon(
                                  Icons.circle_outlined,
                                  color: Color(0xFFEBE7E0),
                                  size: 20,
                                ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => SplitExpenseDialog(
                      totalAmount: widget.totalAmount,
                      selectedPeopleNames: selectedNames.toList(),
                      description: widget.description,
                      emoji: widget.emoji,
                      payer: widget.payer,
                      date: widget.date,
                      transactionId: widget.transactionId,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB5E5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(9),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Continue',
                  style: GoogleFonts.plusJakartaSans(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingMemberCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 0.75),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Container(
              height: 14,
              decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 20,
            height: 20,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEEEEEE)),
          ),
        ],
      ),
    );
  }
}

class SplitExpenseDialog extends StatefulWidget {
  final String totalAmount;
  final List<String> selectedPeopleNames;
  final String description;
  final String emoji;
  final String payer;
  final String date;
  final String transactionId;

  const SplitExpenseDialog({
    super.key,
    required this.totalAmount,
    required this.selectedPeopleNames,
    required this.description,
    required this.emoji,
    required this.payer,
    required this.date,
    required this.transactionId,
  });

  @override
  State<SplitExpenseDialog> createState() => _SplitExpenseDialogState();
}

class _SplitExpenseDialogState extends State<SplitExpenseDialog> {
  bool splitEqually = true;
  late Map<String, TextEditingController> controllers;
  bool _isLoading = true;
  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    controllers = {};
    for (var name in widget.selectedPeopleNames) {
      controllers[name] = TextEditingController();
    }
    _recalculateSplits();
    _fetchMembers();
  }

  Future<void> _fetchMembers() async {
    try {
      final members = await PaymentRepository().getTripMembers();
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

  void _recalculateSplits() {
    if (!splitEqually) return;

    double total = double.tryParse(widget.totalAmount) ?? 0.0;
    int divisor = widget.selectedPeopleNames.length;
    double splitVal = divisor > 0 ? total / divisor : 0.0;

    for (var name in widget.selectedPeopleNames) {
      if (controllers.containsKey(name)) {
        controllers[name]!.text = splitVal.toStringAsFixed(0);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final activeMembers = _members
        .where((m) => widget.selectedPeopleNames.contains(m.name))
        .toList();

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
                  onTap: () {
                    Navigator.pop(context);
                    showDialog(
                      context: context,
                      builder: (context) => SelectPeopleDialog(
                        totalAmount: widget.totalAmount,
                        description: widget.description,
                        emoji: widget.emoji,
                        payer: widget.payer,
                        date: widget.date,
                        transactionId: widget.transactionId,
                      ),
                    );
                  },
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
                  'Split Expense',
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
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFCFAF8),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Amount',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                  Text(
                    '₹${widget.totalAmount}',
                    style: GoogleFonts.plusJakartaSans(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: const Color(0xFF38332E),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(Icons.people_outline, size: 16, color: Color(0xFF8A8075)),
                    const SizedBox(width: 8),
                    Text(
                      'Split equally',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.w500,
                        fontSize: 12,
                        color: const Color(0xFF38332E),
                      ),
                    ),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      splitEqually = !splitEqually;
                      if (splitEqually) _recalculateSplits();
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 20,
                    decoration: BoxDecoration(
                      color: splitEqually ? const Color(0xFF9FDFCA) : const Color(0xFFEBE7E0),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: AnimatedAlign(
                      duration: const Duration(milliseconds: 200),
                      alignment: splitEqually ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                        width: 16,
                        height: 16,
                        decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300, // Fixed height for scrollable area
              child: _isLoading
                ? ListView.builder(
                    itemCount: 3,
                    itemBuilder: (context, index) => _buildLoadingSplitCard(),
                  )
                : ListView.builder(
                    itemCount: activeMembers.length,
                    itemBuilder: (context, index) {
                      final member = activeMembers[index];
                      final controller = controllers[member.name]!;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: _buildFinalPersonCard(
                          member: member,
                          controller: controller,
                          onManualEdit: () {
                            if (splitEqually) {
                              setState(() {
                                splitEqually = false;
                              });
                            }
                          },
                        ),
                      );
                    },
                  ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                onPressed: () async {
                  // BACKEND NOTE: This is where we call PaymentService.createExpense().
                  final body = {
                    'amount': widget.totalAmount,
                    'description': widget.description,
                    'emoji': widget.emoji,
                    'payer': widget.payer,
                    'date': widget.date,
                    'transaction_id': widget.transactionId,
                    'splits': controllers.entries.map((e) => {'name': e.key, 'amount': e.value.text}).toList(),
                  };

                  try {
                    await PaymentService().createExpense(body);
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Expense added successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error adding expense: $e')),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF9FDFCA),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check, size: 16, color: Color(0xFF339977)),
                    const SizedBox(width: 8),
                    Text(
                      'Add Expense',
                      style: GoogleFonts.plusJakartaSans(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: const Color(0xFF339977),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFinalPersonCard({
    required MemberModel member,
    required TextEditingController controller,
    required VoidCallback onManualEdit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 0.75),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFEEECE8),
              border: Border.all(color: member.avatarColor, width: 2),
            ),
            child: Center(
              child: Text(
                member.initials,
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 10.5, color: const Color(0xFF38332E)),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              member.name,
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 12, color: const Color(0xFF38332E)),
            ),
          ),
          SizedBox(
            width: 90,
            height: 32,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => onManualEdit(),
              decoration: InputDecoration(
                filled: true,
                fillColor: const Color(0xFFFCFAF8),
                prefixText: '₹ ',
                prefixStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF8A8075)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75)),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1)),
              ),
              style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 11, color: const Color(0xFF8A8075)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingSplitCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFDFDFB),
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: const Color.fromRGBO(235, 231, 224, 0.5), width: 0.75),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEEEEEE)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              height: 12,
              decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(4)),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 90,
            height: 32,
            decoration: BoxDecoration(color: const Color(0xFFEEEEEE), borderRadius: BorderRadius.circular(12)),
          ),
        ],
      ),
    );
  }
}

class SettleBalanceDialog extends StatelessWidget {
  const SettleBalanceDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E))),
                ),
                const SizedBox(width: 8),
                Text('Settle Balance', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF38332E), letterSpacing: -0.3)),
              ],
            ),
            const SizedBox(height: 32),
            Container(width: 72, height: 72, decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFFEEECE8)), child: Center(child: Text('AS', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 24, color: const Color(0xFF38332E))))),
            const SizedBox(height: 16),
            Text('You owe Ashish', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 14, color: const Color(0xFF8A8075))),
            const SizedBox(height: 4),
            Text('₹500', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 32, color: const Color(0xFFD1475E))),
            const SizedBox(height: 32),
            _buildOptionCard(context: context, icon: Icons.phone_android, title: 'Pay via UPI', subtitle: 'Use Google Pay, PhonePe, Paytm, etc.', onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const PayViaUPIDialog());
            }),
            const SizedBox(height: 16),
            _buildOptionCard(context: context, icon: Icons.payments_outlined, title: 'Mark as Paid', subtitle: 'Already paid? Use this if you paid by cash or another method', onTap: () {
              Navigator.pop(context);
              showDialog(context: context, builder: (context) => const MarkAsPaidDialog());
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildOptionCard({required BuildContext context, required IconData icon, required String title, required String subtitle, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: const Color(0xFFFCFAF8), borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75)),
        child: Row(
          children: [
            Container(width: 48, height: 48, decoration: BoxDecoration(color: const Color(0xFFEAF4FB), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: const Color(0xFF6BB5E5))),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF38332E))),
                  const SizedBox(height: 4),
                  Text(subtitle, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF8A8075))),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.arrow_forward, color: Color(0xFF8A8075), size: 20),
          ],
        ),
      ),
    );
  }
}

class PayViaUPIDialog extends StatelessWidget {
  const PayViaUPIDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 24),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                InkWell(onTap: () { Navigator.pop(context); showDialog(context: context, builder: (context) => const SettleBalanceDialog()); }, child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)))),
                const SizedBox(width: 8),
                Text('Pay Via UPI', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF38332E), letterSpacing: -0.3)),
              ],
            ),
            const SizedBox(height: 32),
            RichText(text: TextSpan(style: GoogleFonts.plusJakartaSans(fontSize: 14, color: const Color(0xFF8A8075)), children: [const TextSpan(text: "You're paying "), TextSpan(text: '₹500', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFFD1475E))), const TextSpan(text: ' to '), TextSpan(text: 'Ashish', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, color: const Color(0xFF8A8075)))])),
            const SizedBox(height: 24),
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFEAF4FB), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.phone_android, color: Color(0xFF6BB5E5), size: 28)), const SizedBox(width: 16), const Icon(Icons.arrow_forward, color: Color(0xFF8A8075), size: 24), const SizedBox(width: 16), Container(width: 56, height: 56, decoration: BoxDecoration(color: const Color(0xFFEAF4FB), borderRadius: BorderRadius.circular(12)), child: const Icon(Icons.currency_rupee, color: Color(0xFF6BB5E5), size: 28))]),
            const SizedBox(height: 24),
            Text('Complete the payment in your UPI app\nOnce done, come back and confirm below', textAlign: TextAlign.center, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 13, color: const Color(0xFF8A8075), height: 1.4)),
            const SizedBox(height: 32),
            SizedBox(width: double.infinity, height: 48, child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.open_in_new, color: Color(0xFF1B75D0), size: 18), label: Text('Open UPI App to Pay', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: const Color(0xFF1B75D0))), style: OutlinedButton.styleFrom(side: const BorderSide(color: Color(0xFFEBE7E0), width: 1), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9))))),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, height: 48, child: ElevatedButton(onPressed: () { Navigator.pop(context); showDialog(context: context, builder: (context) => const MarkAsPaidDialog()); }, style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF6BB5E5), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), elevation: 0), child: Text('Mark as Paid', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)))),
          ],
        ),
      ),
    );
  }
}

class MarkAsPaidDialog extends StatefulWidget {
  const MarkAsPaidDialog({super.key});

  @override
  State<MarkAsPaidDialog> createState() => _MarkAsPaidDialogState();
}

class _MarkAsPaidDialogState extends State<MarkAsPaidDialog> {
  final TextEditingController txnController = TextEditingController();
  final TextEditingController dateController = TextEditingController(text: '31 Jan 2026, 03:02 am');
  final TextEditingController notesController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    txnController.dispose();
    dateController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _submitForApproval() async {
    setState(() => _isLoading = true);

    final body = {
      'transaction_id': txnController.text,
      'date_time': dateController.text,
      'notes': notesController.text,
      'status': 'pending_approval',
    };

    try {
      // Backend friendly code: calling the post request
      await PaymentService().markAsPaid(body);
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Payment submitted for approval')),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: const Color(0xFFFCFAF8),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12), side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.75)),
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
                  onTap: () { 
                    Navigator.pop(context); 
                    showDialog(context: context, builder: (context) => const SettleBalanceDialog()); 
                  }, 
                  child: const Padding(padding: EdgeInsets.all(4.0), child: Icon(Icons.arrow_back, size: 20, color: Color(0xFF38332E)))
                ),
                const SizedBox(width: 8),
                Text('Mark as Paid', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF38332E), letterSpacing: -0.3)),
              ],
            ),
            const SizedBox(height: 24),
            Center(child: Container(width: 72, height: 72, decoration: BoxDecoration(color: const Color(0xFF9FDFCA).withValues(alpha: 0.2), shape: BoxShape.circle), child: const Icon(Icons.check, color: Color(0xFF45B08C), size: 40))),
            const SizedBox(height: 16),
            Center(child: Text('Payment Completed?', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16, color: const Color(0xFF38332E)))),
            const SizedBox(height: 4),
            Center(child: Text('Confirm the details below', style: GoogleFonts.plusJakartaSans(fontSize: 13, color: const Color(0xFF8A8075)))),
            const SizedBox(height: 24),
            _buildLabel('Transaction ID', optional: true),
            const SizedBox(height: 8),
            _buildTextField(hintText: 'e.g., UPI123456789', controller: txnController),
            const SizedBox(height: 16),
            _buildLabel('Date & Time'),
            const SizedBox(height: 8),
            _buildTextField(hintText: '31 Jan 2026, 03:02 am', filledColor: const Color(0xFFF3F2F0), controller: dateController),
            const SizedBox(height: 16),
            _buildLabel('Notes', optional: true),
            const SizedBox(height: 8),
            _buildTextArea(hintText: 'Any additional notes...', controller: notesController),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity, 
              height: 48, 
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitForApproval, 
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF6BB5E5), 
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)), 
                  elevation: 0
                ), 
                child: _isLoading 
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('Submit for Approval', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white))
              )
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text, {bool optional = false}) {
    return RichText(text: TextSpan(style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12, color: const Color(0xFF38332E)), children: [TextSpan(text: text), if (optional) TextSpan(text: ' (optional)', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, color: const Color(0xFF8A8075)))]));
  }

  Widget _buildTextField({required String hintText, Color? filledColor, TextEditingController? controller}) {
    return SizedBox(height: 42, child: TextField(controller: controller, decoration: InputDecoration(filled: true, fillColor: filledColor ?? const Color(0xFFFCFAF8), hintText: hintText, hintStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 14, color: const Color(0xFF8A8075)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1)))));
  }

  Widget _buildTextArea({required String hintText, TextEditingController? controller}) {
    return TextField(controller: controller, maxLines: 3, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFFCFAF8), hintText: hintText, hintStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.normal, fontSize: 14, color: const Color(0xFF8A8075)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFFEBE7E0), width: 0.75)), focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(9), borderSide: const BorderSide(color: Color(0xFF6BB5E5), width: 1))));
  }
}
