import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:travelly/core/constants/currency.dart';
import 'package:travelly/features/payments/data/models/expense_model.dart';
import 'package:travelly/features/payments/data/models/member_model.dart';
import 'package:travelly/features/payments/data/services/payment_service.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_amount_field.dart';
import 'package:travelly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:travelly/features/payments/presentation/dialogs/expense_details/edit_split_dialog.dart';
import 'package:provider/provider.dart';

/// Dialog showing full details for a specific expense with inline edit support.
class PaymentDetailsDialog extends StatefulWidget {
  final String expenseId;
  final String groupId;
  final VoidCallback? onUpdated;

  const PaymentDetailsDialog({
    super.key,
    required this.expenseId,
    required this.groupId,
    this.onUpdated,
  });

  @override
  State<PaymentDetailsDialog> createState() => _PaymentDetailsDialogState();
}

class _PaymentDetailsDialogState extends State<PaymentDetailsDialog> {
  late Future<Map<String, dynamic>> _detailsFuture;
  late final PaymentService _service;

  bool _isEditing = false;
  bool _isSaving = false;

  // Edit controllers
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  final _notesController = TextEditingController();
  final _dateController = TextEditingController();
  String _selectedCurrency = AppCurrency.code;
  String? _selectedPayerId;
  DateTime? _selectedDate;

  // Splits properties
  bool _splitEqually = true;
  List<String> _selectedPeopleIds = [];
  Map<String, double> _customSplitAmounts = {};

  // Original expense data for resetting
  ExpenseModel? _loadedExpense;
  List<MemberModel> _members = [];

  @override
  void initState() {
    super.initState();
    _service = context.read<PaymentService>();
    _detailsFuture = _service.fetchExpenseDetails(
      widget.groupId,
      widget.expenseId,
    );

    final participants = context.read<DashboardProvider>().participants;
    _members = participants
        .map(
          (p) => MemberModel(
            id: p.id,
            userId: p.id,
            name: p.name,
            avatarColor: const Color(0xFFD9F0FC),
          ),
        )
        .toList();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  void _populateControllers(ExpenseModel expense) {
    _titleController.text = expense.title;
    _amountController.text = expense.amount.toStringAsFixed(2);
    _notesController.text = expense.notes ?? '';
    _selectedCurrency = expense.currency;
    _selectedPayerId = expense.paidBy;
    _selectedDate = expense.date;
    _dateController.text = expense.formattedDate.isNotEmpty
        ? expense.formattedDate
        : '';

    _splitEqually = expense.splitType == 'EQUAL';
    _selectedPeopleIds = expense.splits.map((s) => s.userId).toList();
    _customSplitAmounts = {
      for (var s in expense.splits) s.userId: s.amount
    };
  }

  String _currencySymbol(String code) {
    switch (code) {
      case 'INR':
        return '₹';
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      default:
        return AppCurrency.symbol;
    }
  }

  Future<void> _saveChanges() async {
    final title = _titleController.text.trim();
    final amountText = _amountController.text.trim();

    if (title.isEmpty) {
      _showSnackbar('Please enter a title');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      _showSnackbar('Please enter a valid amount');
      return;
    }

    if (_selectedPayerId == null) {
      _showSnackbar('Please select who paid');
      return;
    }

    if (_selectedPeopleIds.isEmpty) {
      _showSnackbar('Please select at least one person to split with');
      return;
    }

    setState(() => _isSaving = true);

    final body = <String, dynamic>{
      'title': title,
      'amount': amount,
      'paidBy': _selectedPayerId,
      'currency': _selectedCurrency,
      'notes': _notesController.text.trim(),
      'split': {
        'type': _splitEqually ? 'EQUAL' : 'CUSTOM',
        'participants': _selectedPeopleIds,
        'splits': _splitEqually
            ? [] 
            : _customSplitAmounts.entries.map((e) => {
                'userId': e.key,
                'amount': e.value,
              }).toList(),
      }
    };

    if (_selectedDate != null) {
      body['date'] = _selectedDate!.toIso8601String();
    }

    try {
      await _service.updateExpense(widget.groupId, widget.expenseId, body);
      if (mounted) {
        setState(() {
          _isEditing = false;
          _isSaving = false;
          _detailsFuture = _service.fetchExpenseDetails(
            widget.groupId,
            widget.expenseId,
          );
        });
        _showSnackbar('Expense updated successfully');
        widget.onUpdated?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        _showSnackbar('Failed to update: $e');
      }
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _detailsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            width: 320,
            height: 200,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Container(
            width: 320,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFFCFAF8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(child: Text('Error: ${snapshot.error}')),
          );
        }

        final data = snapshot.data?['data'] as Map<String, dynamic>? ?? {};
        final expense = ExpenseModel.fromJson(data);
        
        if (_loadedExpense?.id != expense.id) {
           _loadedExpense = expense;
        }

        if (!_isEditing && _titleController.text.isEmpty) {
          _populateControllers(expense);
        }

        final cs = _currencySymbol(_isEditing ? _selectedCurrency : expense.currency);

        return Container(
          width: 340,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFFFCFAF8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 0.75),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(expense),
              const SizedBox(height: 20),
              if (_isEditing)
                _buildEditMode(cs)
              else
                _buildViewMode(cs, expense),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEditMode(String cs) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        PaymentAmountField(
          label: 'Title *',
          hintText: 'Enter title',
          controller: _titleController,
        ),
        const SizedBox(height: 16),
        PaymentAmountField(
          label: 'Amount *',
          hintText: '0.00',
          controller: _amountController, 
          isNumber: true,
          prefixIcon: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedCurrency,
                isDense: true,
                items: ['INR', 'USD', 'EUR', 'GBP'].map((String val) {
                  return DropdownMenuItem<String>(
                    value: val,
                    child: Text('${_currencySymbol(val)} $val', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 13)),
                  );
                }).toList(),
                onChanged: (val) { if (val != null) setState(() => _selectedCurrency = val); },
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        _buildLabel('Paid by *'),
        const SizedBox(height: 8),
        _buildPayerDropdown(),
        const SizedBox(height: 16),
        PaymentAmountField(
          label: 'Date',
          hintText: 'Select date',
          controller: _dateController,
          readOnly: true,
          onTap: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime(2000),
              lastDate: DateTime(2100),
            );
            if (picked != null) {
              _selectedDate = picked;
              setState(() => _dateController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}");
            }
          },
        ),
        const SizedBox(height: 16),
        PaymentAmountField(
          label: 'Notes',
          hintText: 'Add a note',
          controller: _notesController,
          maxLines: 3,
        ),
        const SizedBox(height: 16),
        _buildSplitInfo(cs),
        const SizedBox(height: 24),
        DialogPrimaryButton(
          text: 'Save Changes',
          isLoading: _isSaving,
          onPressed: _saveChanges,
          backgroundColor: const Color(0xFF9FDFCA),
          textColor: const Color(0xFF339977),
          icon: Icons.check,
        ),
      ],
    );
  }

  Widget _buildSplitInfo(String cs) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F5F2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Split: ${_splitEqually ? 'Equally' : 'Custom'}',
                style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 12),
              ),
              TextButton.icon(
                onPressed: () async {
                  final result = await showDialog<Map<String, dynamic>>(
                    context: context,
                    builder: (ctx) => EditSplitDialog(
                      groupId: widget.groupId,
                      totalAmount: double.tryParse(_amountController.text) ?? 1.0,
                      currencySymbol: cs,
                      initialSplitEqually: _splitEqually,
                      initialSelectedPeopleIds: _selectedPeopleIds,
                      initialCustomAmounts: _customSplitAmounts,
                      allMembers: _members,
                    ),
                  );
                  if (result != null) {
                    setState(() {
                      _splitEqually = result['splitEqually'];
                      _selectedPeopleIds = result['selectedPeopleIds'];
                      _customSplitAmounts = result['customAmounts'];
                    });
                  }
                },
                icon: const Icon(Icons.edit, size: 14),
                label: const Text('Edit Split'),
              ),
            ],
          ),
          Text(
            ' among ${_selectedPeopleIds.length} people',
            style: GoogleFonts.plusJakartaSans(fontSize: 11, color: const Color(0xFF8A8075)),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(ExpenseModel expense) {
    return Row(
      children: [
        GestureDetector(
          onTap: () { if (_isEditing) setState(() { _isEditing = false; _populateControllers(expense); }); else Navigator.pop(context); },
          child: Icon(_isEditing ? Icons.close : Icons.arrow_back, size: 20),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(_isEditing ? 'Edit Expense' : expense.title, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 16))),
        if (!_isEditing) GestureDetector(onTap: () { _populateControllers(expense); setState(() => _isEditing = true); }, child: const Icon(Icons.edit_outlined, size: 20, color: Color(0xFF6BB5E5))),
      ],
    );
  }

  Widget _buildViewMode(String cs, ExpenseModel expense) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildInfoRow('Amount', '$cs${expense.amount.toStringAsFixed(2)}'),
        _buildInfoRow('Paid by', expense.payerName ?? 'Unknown'),
        _buildInfoRow('Date', expense.formattedDate.isNotEmpty ? expense.formattedDate : 'N/A'),
        if (expense.notes?.isNotEmpty ?? false) _buildInfoRow('Notes', expense.notes!),
        const SizedBox(height: 12),
        const Divider(),
        const SizedBox(height: 8),
        Text('Splits (${expense.splits.length})', style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold, fontSize: 14)),
        ...expense.splits.map((s) => Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(s.userName ?? 'User'), Text('$cs${s.amount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold))]),
        )),
      ],
    );
  }

  Widget _buildLabel(String text) => Text(text, style: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w500, fontSize: 12));
  
  Widget _buildPayerDropdown() => Container(
    height: 42,
    decoration: BoxDecoration(color: const Color(0xFFFCFAF8), borderRadius: BorderRadius.circular(9), border: Border.all(color: const Color(0xFFEBE7E0), width: 0.75)),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _members.any((m) => m.userId == _selectedPayerId) ? _selectedPayerId : null,
        isExpanded: true,
        items: _members.map((m) => DropdownMenuItem(value: m.userId, child: Text(m.name))).toList(),
        onChanged: (v) => setState(() => _selectedPayerId = v),
      ),
    ),
  );

  Widget _buildInfoRow(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text(label, style: GoogleFonts.plusJakartaSans(fontSize: 12, color: const Color(0xFF8A8075))), Text(value, style: const TextStyle(fontWeight: FontWeight.bold))]),
  );
}
