import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:travelly/core/widgets/emoji_picker_dialog.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/dialog_primary_button.dart';
import 'package:travelly/features/payments/presentation/dialogs/widgets/payment_amount_field.dart';

/// Floating dialog for viewing and editing trip details.
///
/// Opens when the user taps the trip info card (ParticipantRow).
/// Follows the exact same dialog pattern as the Payments feature
/// (PaymentDetailsDialog) for consistency.
///
/// Features:
///   • Edit trip name
///   • Edit start date
///   • Change trip emoji (via shared emoji picker)
///   • View all trip participants
///   • Save changes via DashboardProvider → Service → API
///
/// Architecture:
///   Dialog → DashboardProvider.updateTrip() → Repository → Service → ApiClient
class TripDetailsDialog extends StatefulWidget {
  /// Current trip data to pre-populate the form fields.
  final TripModel trip;

  /// List of all trip participants to display.
  final List<ParticipantModel> participants;

  const TripDetailsDialog({
    super.key,
    required this.trip,
    required this.participants,
  });

  /// Convenience method to show this dialog, matching the payments flow pattern.
  ///
  /// Wraps in [KeyboardSafeDialog] for keyboard-safe behavior, identical
  /// to how [AddPaymentFlow] shows [PaymentDetailsDialog].
  static void show(BuildContext context, TripModel trip, List<ParticipantModel> participants) {
    showDialog(
      context: context,
      builder: (context) => _KeyboardSafeWrapper(
        child: TripDetailsDialog(
          trip: trip,
          participants: participants,
        ),
      ),
    );
  }

  @override
  State<TripDetailsDialog> createState() => _TripDetailsDialogState();
}

class _TripDetailsDialogState extends State<TripDetailsDialog> {
  late String _selectedEmoji;
  late TextEditingController _nameController;
  late TextEditingController _dateController;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _selectedEmoji = widget.trip.emoji;
    _nameController = TextEditingController(text: widget.trip.name);
    _dateController = TextEditingController(text: widget.trip.startDate);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Saves the updated trip details via the DashboardProvider.
  Future<void> _saveChanges() async {
    setState(() => _isSaving = true);

    try {
      final provider = context.read<DashboardProvider>();
      await provider.updateTrip(
        name: _nameController.text,
        startDate: _dateController.text,
        emoji: _selectedEmoji,
      );

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // ── Dialog container — identical shape/style to PaymentDetailsDialog ──
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
            // ── Header row (back button + title) ─────────────────────
            _buildHeader(),
            const SizedBox(height: 24),

            // ── Trip emoji + name row ────────────────────────────────
            _buildEmojiAndNameRow(),
            const SizedBox(height: 16),

            // ── Start date field ─────────────────────────────────────
            PaymentAmountField(
              label: 'Start Date',
              hintText: 'YYYY-MM-DD',
              controller: _dateController,
            ),
            const SizedBox(height: 20),

            // ── Participants section ─────────────────────────────────
            _buildParticipantsSection(),
            const SizedBox(height: 24),

            // ── Save button ──────────────────────────────────────────
            DialogPrimaryButton(
              text: 'Save Changes',
              onPressed: _saveChanges,
              isLoading: _isSaving,
            ),
          ],
        ),
      ),
    );
  }

  /// Header with back arrow and dialog title — mirrors PaymentDetailsDialog.
  Widget _buildHeader() {
    return Row(
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
          'Trip Details',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: const Color(0xFF38332E),
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  /// Emoji picker button + trip name input — mirrors PaymentDetailsDialog's
  /// emoji + description row layout.
  Widget _buildEmojiAndNameRow() {
    return Row(
      children: [
        // ── Tappable emoji picker ────────────────────────────────
        GestureDetector(
          onTap: () async {
            final emoji = await showEmojiPicker(context);
            if (emoji != null) {
              setState(() => _selectedEmoji = emoji);
            }
          },
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
              child: Text(
                _selectedEmoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        // ── Trip name text field ──────────────────────────────────
        Expanded(
          child: PaymentAmountField(
            label: 'Trip Name',
            hintText: 'e.g., The Lyaari Trip',
            controller: _nameController,
          ),
        ),
      ],
    );
  }

  /// Displays all trip participants in a scrollable grid.
  Widget _buildParticipantsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ── Section label ────────────────────────────────────────
        Text(
          'Participants (${widget.participants.length})',
          style: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: 13,
            color: const Color(0xFF38332E),
          ),
        ),
        const SizedBox(height: 12),

        // ── Participant list ─────────────────────────────────────
        if (widget.participants.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              'No participants yet',
              style: GoogleFonts.plusJakartaSans(
                fontSize: 12,
                color: const Color(0xFF8A8075),
              ),
            ),
          )
        else
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: widget.participants.length,
              separatorBuilder: (context, index) => const Divider(
                height: 1,
                color: Color(0xFFEBE7E0),
              ),
              itemBuilder: (context, index) {
                final participant = widget.participants[index];
                return _buildParticipantTile(participant);
              },
            ),
          ),
      ],
    );
  }

  /// Individual participant row — matches PaymentUserTile style.
  Widget _buildParticipantTile(ParticipantModel participant) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // ── Avatar circle with emoji ────────────────────────────
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: const Color(0xFFD9F0FC),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Center(
              child: Text(
                participant.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ),
          ),
          const SizedBox(width: 12),
          // ── Name ────────────────────────────────────────────────
          Expanded(
            child: Text(
              participant.name,
              style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w500,
                fontSize: 14,
                color: const Color(0xFF38332E),
              ),
            ),
          ),
          // ── Trailing indicator ──────────────────────────────────
          const Icon(
            Icons.person_outline,
            size: 16,
            color: Color(0xFF8A8075),
          ),
        ],
      ),
    );
  }
}

/// Keyboard-safe dialog wrapper — reuses the same pattern as
/// [KeyboardSafeDialog] from core/widgets but kept here to avoid
/// coupling the dashboard to core's specific implementation.
///
/// Mirrors the exact behavior from the payments feature:
///   • Dismisses keyboard on outside tap
///   • Adjusts for keyboard insets
///   • Limits height to 85% screen
///   • Scrollable content
class _KeyboardSafeWrapper extends StatelessWidget {
  final Widget child;

  const _KeyboardSafeWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        FocusScope.of(context).unfocus();
        Navigator.of(context).pop();
      },
      child: Material(
        color: Colors.transparent,
        child: Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Catch clicks inside — dismiss keyboard only.
                FocusScope.of(context).unfocus();
              },
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.85,
                ),
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
