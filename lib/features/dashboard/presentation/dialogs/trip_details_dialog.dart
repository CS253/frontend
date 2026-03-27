// =============================================================================
// Trip Details Dialog — Edit trip details from the dashboard.
//
// Opens when the user taps the trip info card (ParticipantRow).
// Uses the exact same fields as the Create Trip dialog (Step 1):
//   • Trip Name *       — Required, min 2 characters
//   • Destination *     — Required
//   • Start Date *      — Required
//   • End Date *        — Required, must be after start date
//   • Trip Type *       — Required (Beach/Mountain/City/Nature/Island/Other)
//   • Cover Photo       — Optional, upload from device via file_picker
//
// Architecture:
//   Dialog → DashboardProvider.updateTrip()
//     → DashboardRepository → DashboardService → ApiClient
//     → PUT /trips/:id
//
// BACKEND CALL: PUT /trips/:id
//   • JSON body: { name, destination, startDate, endDate, tripType, emoji }
//   • TODO: When cover photo is changed, use multipart/form-data
//
// Data Flow:
//   User edits fields → _saveChanges() → DashboardProvider.updateTrip()
//   → Repository → Service → PUT /trips/:id → re-fetch dashboard
// =============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:travelly/features/dashboard/data/models/trip_model.dart';
import 'package:travelly/features/dashboard/data/models/participant_model.dart';
import 'package:travelly/features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:travelly/core/utils/helpers.dart';
import 'package:travelly/core/utils/validators.dart';

/// Floating dialog for viewing and editing trip details.
///
/// Opens when the user taps the trip info card (ParticipantRow).
/// Displays the same fields as the "New Trip" creation dialog:
///   Trip Name, Destination, Start/End Dates, Trip Type, Cover Photo.
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

  /// Convenience method to show this dialog.
  ///
  /// Wraps in [_KeyboardSafeWrapper] for keyboard-safe behavior.
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
  final _formKey = GlobalKey<FormState>();

  // ── Form controllers ──────────────────────────────────────────────
  late TextEditingController _nameController;
  late TextEditingController _destinationController;
  String _selectedTripType = 'Other';
  DateTime? _fromDate;
  DateTime? _toDate;
  String? _coverImagePath;
  Uint8List? _coverImageBytes;
  bool _isSaving = false;

  /// Date validation error displayed inline.
  String? _dateError;

  @override
  void initState() {
    super.initState();

    // Pre-populate fields from current trip data
    _nameController = TextEditingController(text: widget.trip.name);
    _destinationController = TextEditingController(text: widget.trip.destination);
    _selectedTripType = widget.trip.tripType.isNotEmpty ? widget.trip.tripType : 'Other';

    // Parse start/end dates from ISO-8601 strings
    if (widget.trip.startDate.isNotEmpty) {
      _fromDate = DateTime.tryParse(widget.trip.startDate);
    }
    if (widget.trip.endDate.isNotEmpty) {
      _toDate = DateTime.tryParse(widget.trip.endDate);
    }

    // Cover image — only set if it's a network URL (local paths won't persist)
    _coverImagePath = widget.trip.coverImage;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  // ── Validation ──────────────────────────────────────────────────────

  /// Validates all fields including date validation.
  bool _validateForm() {
    bool isValid = _formKey.currentState?.validate() ?? false;

    // Date validation
    String? dateErr;
    if (_fromDate == null) {
      dateErr = 'Start date is required';
    } else if (_toDate == null) {
      dateErr = 'End date is required';
    } else if (!_toDate!.isAfter(_fromDate!)) {
      dateErr = 'End date must be after start date';
    }

    setState(() {
      _dateError = dateErr;
    });

    return isValid && dateErr == null;
  }

  // ── Save changes ────────────────────────────────────────────────────

  /// Saves the updated trip details via the DashboardProvider.
  ///
  /// BACKEND CALL: PUT /trips/:id
  /// Sends: name, destination, startDate, endDate, tripType, emoji
  /// TODO: When coverImagePath changes, use multipart/form-data upload
  Future<void> _saveChanges() async {
    if (!_validateForm()) return;

    setState(() => _isSaving = true);

    try {
      final provider = context.read<DashboardProvider>();
      await provider.updateTrip(
        name: _nameController.text.trim(),
        destination: _destinationController.text.trim(),
        startDate: _fromDate!.toIso8601String().split('T').first,
        endDate: _toDate!.toIso8601String().split('T').first,
        tripType: _selectedTripType,
        emoji: _getEmojiForTripType(_selectedTripType),
        coverImagePath: _coverImagePath,
      );

      if (mounted) {
        Navigator.pop(context);
        Helpers.showSuccessSnackbar(context, 'Trip updated successfully!');
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isSaving = false);
        Helpers.showErrorSnackbar(context, 'Failed to save changes.');
      }
    }
  }

  // ── Cover image picker ──────────────────────────────────────────────

  /// Opens file picker to select a cover image.
  ///
  /// Rules:
  ///   • Allowed types: jpg, jpeg, png
  ///   • Max size: 5 MB
  Future<void> _pickCoverImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final platformFile = result.files.first;
        final extension = platformFile.extension?.toLowerCase();
        final sizeInBytes = platformFile.size;

        // 1. Validate file type
        final allowedExtensions = ['jpg', 'jpeg', 'png'];
        if (extension == null || !allowedExtensions.contains(extension)) {
          if (!mounted) return;
          Helpers.showErrorSnackbar(context, 'Invalid file type. Allowed: jpg, jpeg, png');
          return;
        }

        // 2. Validate file size (5 MB limit)
        const int maxBytes = 5 * 1024 * 1024;
        if (sizeInBytes > maxBytes) {
          if (!mounted) return;
          Helpers.showErrorSnackbar(context, 'File too large. Max size: 5 MB');
          return;
        }

        setState(() {
          _coverImagePath = platformFile.path; // Might be null on web
          _coverImageBytes = platformFile.bytes;
        });
      }
    } catch (e) {
      if (mounted) {
        Helpers.showErrorSnackbar(context, 'Error picking image: $e');
      }
    }
  }

  // ── Helper: trip type → emoji mapping ───────────────────────────────

  String _getEmojiForTripType(String type) {
    switch (type) {
      case 'Beach':
        return '🏖️';
      case 'Mountain':
        return '⛰️';
      case 'City':
        return '🏙️';
      case 'Nature':
        return '🌿';
      case 'Island':
        return '🏝️';
      default:
        return '🌍';
    }
  }

  // ── Build ───────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 620,
        child: Column(
          children: [
            // ── Header ──────────────────────────────────────────────
            _buildHeader(),
            const Divider(height: 1, color: Color(0xFFE5EAF4)),

            // ── Scrollable form ─────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Trip Name *
                      _buildRequiredLabel('Trip Name'),
                      TextFormField(
                        controller: _nameController,
                        validator: Validators.validateTripName,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        decoration: _inputDecoration('Enter trip name'),
                      ),
                      const SizedBox(height: 16),

                      // Destination *
                      _buildRequiredLabel('Destination', icon: Icons.location_on_outlined),
                      TextFormField(
                        controller: _destinationController,
                        validator: Validators.validateDestination,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                        decoration: _inputDecoration('Enter destination'),
                      ),
                      const SizedBox(height: 16),

                      // Start Date * and End Date *
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequiredLabel('Start Date', icon: Icons.calendar_today_outlined),
                                _buildDateField(isFrom: true),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildRequiredLabel('End Date'),
                                _buildDateField(isFrom: false),
                              ],
                            ),
                          ),
                        ],
                      ),

                      // Date validation error
                      if (_dateError != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 6.0),
                          child: Text(
                            _dateError!,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              color: Colors.red,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),

                      // Trip Type *
                      _buildRequiredLabel('Trip Type'),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _buildTypeChip('Beach', '🏖️', _selectedTripType == 'Beach'),
                          _buildTypeChip('Mountain', '⛰️', _selectedTripType == 'Mountain'),
                          _buildTypeChip('City', '🏙️', _selectedTripType == 'City'),
                          _buildTypeChip('Nature', '🌿', _selectedTripType == 'Nature'),
                          _buildTypeChip('Island', '🏝️', _selectedTripType == 'Island'),
                          _buildTypeChip('Other', '🌍', _selectedTripType == 'Other'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Cover Photo
                      _buildRequiredLabel('Cover Photo', icon: Icons.camera_alt_outlined),
                      const SizedBox(height: 8),
                      _buildCoverPhotoUpload(),
                      const SizedBox(height: 16),

                      // Participants section (read-only)
                      _buildParticipantsSection(),
                      const SizedBox(height: 24),

                      // Save Changes button
                      _isSaving
                          ? const Center(
                              child: CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6BB5E5)),
                              ),
                            )
                          : _buildPrimaryButton('Save Changes', _saveChanges),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Sub-widgets
  // ===========================================================================

  /// Dialog header with back button, title, and close button.
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.arrow_back_ios, size: 18, color: Color(0xFF5A7184)),
                ),
              ),
              const Text(
                'Trip Details',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Cover photo upload area with preview and replace functionality.
  Widget _buildCoverPhotoUpload() {
    return GestureDetector(
      onTap: _pickCoverImage,
      child: Container(
        height: 120,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFFFCFCFC),
          borderRadius: BorderRadius.circular(12),
        ),
        child: _coverImagePath != null
            ? _buildCoverImagePreview()
            : _buildUploadPlaceholder(),
      ),
    );
  }

  /// Shows the selected/existing cover image with a replace button.
  Widget _buildCoverImagePreview() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: _coverImageBytes != null
              ? Image.memory(
                  _coverImageBytes!,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                )
              : (_coverImagePath != null && _coverImagePath!.startsWith('http'))
                  ? Image.network(
                      _coverImagePath!,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => _buildUploadPlaceholder(),
                    )
                  : (_coverImagePath != null && !kIsWeb)
                      ? Image.file(
                          File(_coverImagePath!),
                          height: 120,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        )
                      : _buildUploadPlaceholder(),
        ),
        // Replace image button
        Positioned(
          top: 8,
          right: 8,
          child: GestureDetector(
            onTap: _pickCoverImage,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.swap_horiz,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Upload placeholder with dashed border (matches create_trip_dialog).
  Widget _buildUploadPlaceholder() {
    return Stack(
      children: [
        Positioned.fill(
          child: CustomPaint(
            painter: _DashedRectPainter(color: const Color(0xFFE0E0E0)),
          ),
        ),
        const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.upload_outlined, color: Color(0xFF828282)),
              SizedBox(height: 8),
              Text(
                'Tap to upload',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: Color(0xFF828282),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Read-only participants section showing trip members.
  Widget _buildParticipantsSection() {
    if (widget.participants.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Participants (${widget.participants.length})',
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Color(0xFF5A7184),
          ),
        ),
        const SizedBox(height: 8),
        ...widget.participants.map((participant) => Padding(
              padding: const EdgeInsets.only(bottom: 6.0),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: const Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    // Avatar circle with initials
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9F0FC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white, width: 1.5),
                      ),
                      child: Center(
                        child: Text(
                          _initialsFor(participant.name),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Nunito',
                            color: Color(0xFF074066),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        participant.name,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )),
      ],
    );
  }

  // ===========================================================================
  // Shared helper widgets (matching create_trip_dialog.dart style)
  // ===========================================================================

  /// Builds a required field label with a red asterisk (*).
  Widget _buildRequiredLabel(String label, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: const Color(0xFF6BB5E5)),
            const SizedBox(width: 6),
          ],
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: label,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF5A7184),
                  ),
                ),
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Standard input decoration matching create_trip_dialog.dart.
  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontFamily: 'Inter', fontSize: 14, color: Color(0xFF828282)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFF3F3F3)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6BB5E5)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red),
      ),
    );
  }

  /// Date picker field matching create_trip_dialog.dart.
  Widget _buildDateField({required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    final hasError = _dateError != null;

    final now = DateTime.now();
    final firstDate = isFrom ? now : (_fromDate ?? now);
    final initialDate = date ?? (isFrom ? now : (_fromDate ?? now));

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: DateTime(2100),
          selectableDayPredicate: (DateTime day) {
            if (!isFrom && _fromDate != null) {
              return !day.isBefore(_fromDate!);
            }
            return true;
          },
        );
        if (picked != null) {
          setState(() {
            if (isFrom) {
              _fromDate = picked;
              if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
                _toDate = null;
              }
            } else {
              _toDate = picked;
            }
            _dateError = null;
          });
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(color: hasError ? Colors.red : const Color(0xFFF3F3F3)),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Align(
          alignment: Alignment.centerLeft,
          child: Text(
            date != null
                ? Helpers.formatDisplayDate(date)
                : isFrom
                    ? 'Start date'
                    : 'End date',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              color: date != null ? Colors.black : const Color(0xFF828282),
            ),
          ),
        ),
      ),
    );
  }

  /// Trip type chip selector matching create_trip_dialog.dart.
  Widget _buildTypeChip(String label, String emoji, bool isSelected) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTripType = label;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6BB5E5) : const Color(0xFFF7F7F7),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: isSelected ? Colors.white : const Color(0xFF6A6A6A),
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Primary action button matching create_trip_dialog.dart style.
  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6BB5E5),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  String _initialsFor(String name) {
    final parts = name.trim().split(RegExp(r'\s+')).where((part) => part.isNotEmpty).toList();
    if (parts.isEmpty) {
      return '?';
    }
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first.substring(0, 1)}${parts.last.substring(0, 1)}'.toUpperCase();
  }
}

// =============================================================================
// Keyboard-safe dialog wrapper — dismisses keyboard on outside tap
// =============================================================================
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

// =============================================================================
// Custom Painter — Dashed border for image upload area
// =============================================================================
class _DashedRectPainter extends CustomPainter {
  final Color color;
  _DashedRectPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    final RRect rrect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      const Radius.circular(12),
    );

    Path path = Path()..addRRect(rrect);
    Path dashPath = Path();

    double defaultDashLength = 6.0;
    double defaultDashSpace = 6.0;
    double distance = 0.0;

    for (PathMetric pathMetric in path.computeMetrics()) {
      while (distance < pathMetric.length) {
        dashPath.addPath(
          pathMetric.extractPath(distance, distance + defaultDashLength),
          Offset.zero,
        );
        distance += defaultDashLength + defaultDashSpace;
      }
      distance = 0.0;
    }

    canvas.drawPath(dashPath, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
