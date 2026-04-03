// =============================================================================
// Create Trip Dialog — 3-step trip creation wizard.
//
// VALIDATION (Step 1 — Trip Details):
//   • Trip Name *       — Required, min 2 characters
//   • Destination *     — Required
//   • Start Date *      — Required
//   • End Date *        — Required, must be after start date
//   • Trip Type *       — Required (pre-selected)
//   • Cover Photo *     — Optional but labeled with (*)
//   • Continue button BLOCKED if validation fails
//
// VALIDATION (Step 2 — Add Members):
//   • Member Name *     — Required
//   • Phone Number *    — Required, valid phone
//   • Add Member button BLOCKED if fields empty
//
//   Step 1 (Trip Details): Trip Name, Destination, Dates, Type
//
// BACKEND CALL: TripsProvider.createTrip() → TripsRepository → TripsService
//   • Triggers POST /groups
//   • TODO: Replace mock data once backend API is connected
//
// Data Flow:
//   Step 1: updateTripDetails() → TripsProvider (local state)
//   Step 2: addMemberToNewTrip() → TripsProvider (local state)
//   Step 3: createTrip() → TripsProvider → TripsRepository → TripsService → API
// =============================================================================

import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/core/utils/helpers.dart';
import 'package:travelly/core/utils/validators.dart';
import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelly/features/trips/presentation/providers/trips_provider.dart';
import 'package:travelly/features/trips/data/services/destination_service.dart';
import '../../../trips/data/models/member_model.dart';

class CreateTripDialog extends StatefulWidget {
  const CreateTripDialog({super.key});

  @override
  State<CreateTripDialog> createState() => _CreateTripDialogState();
}

class _CreateTripDialogState extends State<CreateTripDialog> {
  final PageController _pageController = PageController();
  int _currentStep = 0;

  /// Form keys for multi-step validation.
  /// Step 1 and Step 2 each have their own form key.
  final _step1FormKey = GlobalKey<FormState>();
  final _step2FormKey = GlobalKey<FormState>();

  // Step 1 controllers
  final _tripNameController = TextEditingController();
  final _destinationController = TextEditingController();
  String _selectedTripType = 'Beach';
  DateTime? _fromDate;
  DateTime? _toDate;

  // Step 1 — date validation error displayed inline
  String? _dateError;
  bool _isSearching = false;
  Timer? _debounce;

  // Step 2 controllers
  final _memberNameController = TextEditingController();
  final _memberPhoneController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _tripNameController.dispose();
    _destinationController.dispose();
    _memberNameController.dispose();
    _memberPhoneController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  /// Validates Step 1 fields including date validation:
  /// - End date must be after start date
  bool _validateStep1() {
    bool isValid = _step1FormKey.currentState?.validate() ?? false;

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

  /// Moves to the next step, saving data to the provider at each step.
  void _nextStep() {
    if (_currentStep == 0) {
      // Validate Step 1 — Trip details
      if (!_validateStep1()) return;

      // Save trip details to provider
      final tripsProvider = context.read<TripsProvider>();
      tripsProvider.updateTripDetails(
        name: _tripNameController.text,
        destination: _destinationController.text,
        startDate: _fromDate,
        endDate: _toDate,
        tripType: _selectedTripType,
      );
    }

    if (_currentStep < 2) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep++;
      });
    } else {
      // Final step — create the trip via provider
      _handleCreateTrip();
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentStep--;
      });
    } else {
      context.read<TripsProvider>().cancelCreation();
      Navigator.pop(context);
    }
  }

  /// Handles the final trip creation via TripsProvider.
  ///
  /// BACKEND CALL: Sends trip creation request to server
  /// POST /groups with trip details in JSON
  /// TODO: Replace mock data once backend API is connected
  Future<void> _handleCreateTrip() async {
    final userId = context.read<AuthProvider>().user?.id;
    if (userId == null || userId.isEmpty) {
      Helpers.showErrorSnackbar(
        context,
        'Please log in again to create a trip.',
      );
      return;
    }

    final tripsProvider = context.read<TripsProvider>();
    await tripsProvider.createTrip();

    if (!mounted) return;

    if (tripsProvider.errorMessage != null) {
      Helpers.showErrorSnackbar(context, tripsProvider.errorMessage!);
    } else {
      Navigator.pop(context);
      Helpers.showSuccessSnackbar(context, 'Trip created successfully!');
    }
  }

  /// Handles adding a member with validation.
  ///
  /// VALIDATION:
  ///   • Member Name * — Required
  ///   • Phone Number * — Required, valid phone format
  ///   • Cannot add member if fields are empty
  void _handleAddMember() {
    // Validate Step 2 form
    if (!(_step2FormKey.currentState?.validate() ?? false)) return;

    final name = _memberNameController.text.trim();
    final phone = _memberPhoneController.text.trim();

    final member = MemberModel(
      id: 'temp-${DateTime.now().millisecondsSinceEpoch}',
      name: name,
      phone: phone.isNotEmpty ? phone : null,
    );

    context.read<TripsProvider>().addMemberToNewTrip(member);
    _memberNameController.clear();
    _memberPhoneController.clear();

    // Reset form validation state after adding
    _step2FormKey.currentState?.reset();
  }

  /// Builds a required field label with a red asterisk (*) using RichText + TextSpan.
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

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      backgroundColor: Colors.white,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: 520,
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      if (_currentStep > 0)
                        GestureDetector(
                          onTap: _previousStep,
                          child: const Padding(
                            padding: EdgeInsets.only(right: 8.0),
                            child: Icon(
                              Icons.arrow_back_ios,
                              size: 18,
                              color: Color(0xFF5A7184),
                            ),
                          ),
                        ),
                      Text(
                        _currentStep == 0
                            ? 'New Trip'
                            : _currentStep == 1
                            ? 'Add Members'
                            : 'Review Trip',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () {
                      context.read<TripsProvider>().cancelCreation();
                      Navigator.pop(context);
                    },
                    child: const Icon(
                      Icons.close,
                      size: 24,
                      color: Color(0xFF5A7184),
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE5EAF4)),

            // Progress Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 12.0,
              ),
              child: Row(
                children: List.generate(3, (index) {
                  return Expanded(
                    child: Container(
                      margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentStep
                            ? const Color(0xFF6BB5E5)
                            : const Color(0xFFF3F3F3),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Pages
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _buildStep1Details(),
                  _buildStep2Members(),
                  _buildStep3Review(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Step 1 — Trip Details (with Form validation)
  // ===========================================================================
  Widget _buildStep1Details() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Form(
        key: _step1FormKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Trip Name * — Required, min 2 characters
            _buildRequiredLabel('Trip Name'),
            TextFormField(
              controller: _tripNameController,
              validator: Validators.validateTripName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
              decoration: _inputDecoration('Enter trip name'),
            ),
            const SizedBox(height: 16),

            // Destination * — Required
            _buildRequiredLabel(
              'Destination',
              icon: Icons.location_on_outlined,
            ),

            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.length < 2) {
                  return const Iterable<String>.empty();
                }

                // Debouncing to avoid excessive API calls
                final completer = Completer<Iterable<String>>();
                _debounce?.cancel();
                _debounce = Timer(const Duration(milliseconds: 500), () async {
                  if (mounted) setState(() => _isSearching = true);
                  try {
                    final results = await DestinationService.searchCities(
                      textEditingValue.text,
                    );
                    completer.complete(results);
                  } finally {
                    if (mounted) setState(() => _isSearching = false);
                  }
                });

                return completer.future;
              },
              onSelected: (String selection) {
                _destinationController.text = selection;
              },
              fieldViewBuilder:
                  (context, controller, focusNode, onFieldSubmitted) {
                    // Sync main controller with autocomplete internal controller
                    if (_destinationController.text.isNotEmpty &&
                        controller.text.isEmpty) {
                      controller.text = _destinationController.text;
                    }

                    controller.addListener(() {
                      _destinationController.text = controller.text;
                    });

                    return TextFormField(
                      controller: controller,
                      focusNode: focusNode,
                      onFieldSubmitted: (value) => onFieldSubmitted(),
                      validator: Validators.validateDestination,
                      autovalidateMode: AutovalidateMode.onUserInteraction,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                      decoration: _inputDecoration('Enter destination')
                          .copyWith(
                            suffixIcon: _isSearching
                                ? const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: SizedBox(
                                      width: 16,
                                      height: 16,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Color(0xFF6BB5E5),
                                      ),
                                    ),
                                  )
                                : const Icon(
                                    Icons.search,
                                    size: 20,
                                    color: Color(0xFF5A7184),
                                  ),
                          ),
                    );
                  },
              optionsViewBuilder: (context, onSelected, options) {
                if (options.isEmpty) {
                  return const SizedBox.shrink();
                }

                return Align(
                  alignment: Alignment.topLeft,
                  child: Material(
                    elevation: 8.0,
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.white,
                    child: Container(
                      width: MediaQuery.of(context).size.width - 64,
                      constraints: const BoxConstraints(maxHeight: 250),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFF3F3F3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.separated(
                        padding: EdgeInsets.zero,
                        shrinkWrap: true,
                        itemCount: options.length,
                        separatorBuilder: (context, index) =>
                            const Divider(height: 1, color: Color(0xFFF3F3F3)),
                        itemBuilder: (BuildContext context, int index) {
                          final String option = options.elementAt(index);
                          return InkWell(
                            onTap: () => onSelected(option),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16.0,
                                vertical: 12.0,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.location_on_outlined,
                                    size: 16,
                                    color: Color(0xFF5A7184),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      option,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        color: Color(0xFF333333),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),

            // Dates — Start Date * and End Date *
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRequiredLabel(
                        'Start Date',
                        icon: Icons.calendar_today_outlined,
                      ),
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

            // Date validation error — "End date must be after start date"
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

            // Trip Type * — Required (pre-selected)
            _buildRequiredLabel('Trip Type'),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTypeChip('Beach', '🏖️', _selectedTripType == 'Beach'),
                _buildTypeChip(
                  'Mountain',
                  '⛰️',
                  _selectedTripType == 'Mountain',
                ),
                _buildTypeChip('City', '🏙️', _selectedTripType == 'City'),
                _buildTypeChip('Nature', '🌿', _selectedTripType == 'Nature'),
                _buildTypeChip('Island', '🏝️', _selectedTripType == 'Island'),
                _buildTypeChip('Other', '🌍', _selectedTripType == 'Other'),
              ],
            ),
            const SizedBox(height: 16),

            const SizedBox(height: 32),
            _buildPrimaryButton('Continue', _nextStep),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // Step 2 — Add Members (with Form validation)
  // ===========================================================================
  Widget _buildStep2Members() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Form(
            key: _step2FormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Member Name * — Required
                _buildRequiredLabel('Name'),
                TextFormField(
                  controller: _memberNameController,
                  validator: Validators.validateMemberName,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                  decoration: _inputDecoration('Enter member name'),
                ),
                const SizedBox(height: 16),

                // Phone Number * — Required, valid phone
                _buildRequiredLabel('Phone Number'),
                TextFormField(
                  controller: _memberPhoneController,
                  keyboardType: TextInputType.phone,
                  validator: Validators.validatePhone,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 14),
                  decoration: _inputDecoration('Enter phone number'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Add Member Button — BLOCKED if validation fails
          SizedBox(
            width: double.infinity,
            height: 40,
            child: OutlinedButton.icon(
              onPressed: _handleAddMember,
              icon: const Icon(Icons.add, size: 18, color: Color(0xFF6BB5E5)),
              label: const Text(
                'Add Member',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Color(0xFF6BB5E5),
                ),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Color(0xFF6BB5E5)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          const SizedBox(height: 24),

          // Members list from provider
          Consumer<TripsProvider>(
            builder: (context, tripsProvider, _) {
              if (tripsProvider.newTripMembers.isEmpty) {
                return const Center(
                  child: Column(
                    children: [
                      SizedBox(height: 24),
                      Icon(
                        Icons.people_outline,
                        size: 48,
                        color: Color(0xFFB0B0B0),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'No members added yet',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14,
                          color: Color(0xFF828282),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'You can always add them later',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Color(0xFFB0B0B0),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${tripsProvider.newTripMembers.length} member(s) added',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Color(0xFF828282),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...tripsProvider.newTripMembers.map(
                    (member) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF7F7F7),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.person_outline,
                              size: 18,
                              color: Color(0xFF6BB5E5),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    member.name,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  if (member.phone != null)
                                    Text(
                                      member.phone!,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 11,
                                        color: Color(0xFF828282),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => tripsProvider
                                  .removeMemberFromNewTrip(member.id),
                              child: const Icon(
                                Icons.close,
                                size: 16,
                                color: Color(0xFF828282),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),

          const SizedBox(height: 24),
          _buildPrimaryButton('Continue', _nextStep),
        ],
      ),
    );
  }

  // ===========================================================================
  // Step 3 — Review & Create
  // ===========================================================================
  Widget _buildStep3Review() {
    return Consumer<TripsProvider>(
      builder: (context, tripsProvider, _) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Banner Image Card — shows data from provider
              Container(
                clipBehavior: Clip.hardEdge,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFFF3F3F3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Show uploaded cover image or emoji placeholder
                    Container(
                      height: 120,
                      width: double.infinity,
                      color: const Color(0xFFFAF1ED),
                      child: Center(
                        child: Text(
                          _getEmojiForTripType(tripsProvider.newTripType),
                          style: const TextStyle(fontSize: 32),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tripsProvider.newTripName ?? 'Untitled Trip',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF282828),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(
                                Icons.location_on_outlined,
                                size: 14,
                                color: Color(0xFF828282),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                tripsProvider.newTripDestination ??
                                    'No destination',
                                style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Color(0xFF828282),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Row(
                                children: [
                                  const Icon(
                                    Icons.calendar_today_outlined,
                                    size: 14,
                                    color: Color(0xFF828282),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    _formatDateRange(
                                      tripsProvider.newTripStartDate,
                                      tripsProvider.newTripEndDate,
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Color(0xFF828282),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(width: 16),
                              Row(
                                children: [
                                  const Icon(
                                    Icons.people_outline,
                                    size: 14,
                                    color: Color(0xFF828282),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${tripsProvider.newTripMembers.length} members',
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      color: Color(0xFF828282),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildChecklistItem(
                'Trip details',
                tripsProvider.newTripName != null,
              ),
              const SizedBox(height: 8),
              _buildChecklistItem(
                'Dates set',
                tripsProvider.newTripStartDate != null,
              ),
              const SizedBox(height: 8),
              _buildChecklistItem('Trip type selected', true),
              const SizedBox(height: 8),
              _buildChecklistItem(
                'Members invited',
                tripsProvider.newTripMembers.isNotEmpty,
              ),

              const SizedBox(height: 32),

              // Create Trip button with loading state
              // BACKEND CALL: Sends POST /groups
              tripsProvider.isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF6BB5E5),
                        ),
                      ),
                    )
                  : _buildPrimaryButton('Create Trip', _nextStep),
            ],
          ),
        );
      },
    );
  }

  // ===========================================================================
  // Helper Widgets
  // ===========================================================================

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 14,
        color: Color(0xFF828282),
      ),
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

  String _formatDateRange(DateTime? start, DateTime? end) {
    if (start == null || end == null) return 'Not set';
    return Helpers.formatDateRange(start, end);
  }

  Widget _buildChecklistItem(String title, bool isComplete) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isComplete ? const Color(0xFFEBF6F0) : const Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            isComplete ? Icons.check_circle : Icons.radio_button_unchecked,
            color: isComplete
                ? const Color(0xFF20B95B)
                : const Color(0xFFB0B0B0),
            size: 20,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: isComplete
                  ? const Color(0xFF4A4A4A)
                  : const Color(0xFFB0B0B0),
            ),
          ),
        ],
      ),
    );
  }

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

  Widget _buildDateField({required bool isFrom}) {
    final date = isFrom ? _fromDate : _toDate;
    final hasError = _dateError != null;

    // Date constraints
    final now = DateTime.now();
    final firstDate = isFrom ? DateTime(2000) : (_fromDate ?? DateTime(2000));
    final initialDate = date ?? (isFrom ? now : (_fromDate ?? now));

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: initialDate,
          firstDate: firstDate,
          lastDate: DateTime(2100),
          // Disable end dates before selected start date visually in the picker
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
              // If start date moves past end date, clear end date
              if (_toDate != null && _toDate!.isBefore(_fromDate!)) {
                _toDate = null;
              }
            } else {
              _toDate = picked;
            }
            // Clear date error when user picks a new date
            _dateError = null;
          });
        }
      },
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: hasError ? Colors.red : const Color(0xFFF3F3F3),
          ),
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

  Widget _buildPrimaryButton(String text, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6BB5E5),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
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
}

// =============================================================================
// Custom Painter — Dashed border for image upload area
// =============================================================================
class DashedRectPainter extends CustomPainter {
  final Color color;
  DashedRectPainter({required this.color});

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
