// =============================================================================
// Trips Provider — State management for all trip operations.
//
// This provider manages:
//   • Trip list state with loading/error handling
//   • Trip creation flow (name, destination, dates, type, members, cover image)
//   • Trip detail view
//   • Member management
//   • Trip list caching (avoids redundant API calls)
//
// BACKEND TRIGGER POINTS (UI Action → Provider Method → API Endpoint):
//   • MyTripsScreen loads     → loadTrips()      → GET /trips
//   • Trip card tap           → loadTripDetail() → GET /trips/{id}
//   • Create Trip button      → createTrip()     → POST /trips (multipart/form-data)
//   • Add Member button       → addMemberToNewTrip() → (local state)
//   • Members loaded          → loadMembers()    → GET /trips/{id}/members
//
// Data Flow: Screen → TripsProvider → TripsRepository → TripsService → API
//
// The UI screens should ONLY interact with this provider.
// They should NEVER make direct API calls.
// =============================================================================

import 'package:flutter/material.dart';
import '../../data/models/trip_model.dart';
import '../../data/models/member_model.dart';
import '../../data/repositories/trips_repository.dart';

class TripsProvider with ChangeNotifier {
  final TripsRepository repository;

  TripsProvider({required this.repository});

  // ---------------------------------------------------------------------------
  // Trip List State
  // ---------------------------------------------------------------------------

  /// Cached list of trips.
  List<TripModel> _trips = [];
  List<TripModel> get trips => _trips;

  /// Whether trips are being loaded.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Error message from the last failed operation.
  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  /// Current pagination page.
  int _currentPage = 1;
  int get currentPage => _currentPage;

  /// Whether there are more trips to load.
  bool _hasMore = true;
  bool get hasMore => _hasMore;

  /// Total trip count (from the badge "5 Trips").
  int get tripCount => _trips.length;

  // ---------------------------------------------------------------------------
  // Trip Detail State
  // ---------------------------------------------------------------------------

  /// Currently selected trip for detail view.
  TripModel? _selectedTrip;
  TripModel? get selectedTrip => _selectedTrip;

  // ---------------------------------------------------------------------------
  // Trip Creation Flow State
  // ---------------------------------------------------------------------------

  /// Temporary data for the trip being created.
  String? _newTripName;
  String? _newTripDestination;
  DateTime? _newTripStartDate;
  DateTime? _newTripEndDate;
  String _newTripType = 'Beach';
  List<MemberModel> _newTripMembers = [];

  // Getters for creation flow
  String? get newTripName => _newTripName;
  String? get newTripDestination => _newTripDestination;
  DateTime? get newTripStartDate => _newTripStartDate;
  DateTime? get newTripEndDate => _newTripEndDate;
  String get newTripType => _newTripType;
  List<MemberModel> get newTripMembers => _newTripMembers;

  // ---------------------------------------------------------------------------
  // Members State
  // ---------------------------------------------------------------------------

  /// Members of the currently selected trip.
  List<MemberModel> _members = [];
  List<MemberModel> get members => _members;
  String? _membersTripId;

  bool _isUpdatingMembers = false;
  bool get isUpdatingMembers => _isUpdatingMembers;

  bool _isLeavingTrip = false;
  bool get isLeavingTrip => _isLeavingTrip;

  // ---------------------------------------------------------------------------
  // Load Trips
  // ---------------------------------------------------------------------------

  /// Loads the trip list from the backend (or mock).
  ///
  /// BACKEND CALL: MyTripsScreen loads → TripsProvider.loadTrips()
  ///   → TripsRepository.getTrips() → TripsService.getTrips()
  ///   → GET /trips?page=1&limit=10
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<void> loadTrips({required String userId, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _hasMore = true;
      _trips = [];
    }

    // Don't load if already loading or no more data
    if (_isLoading || (!_hasMore && !refresh)) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final newTrips = await repository.getTrips(
        userId: userId,
        page: _currentPage,
        limit: 10,
      );

      if (newTrips.isEmpty) {
        _hasMore = false;
      } else {
        _trips.addAll(newTrips);
        _currentPage++;
      }
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Load Trip Detail
  // ---------------------------------------------------------------------------

  /// Loads a specific trip by ID.
  ///
  /// BACKEND CALL: Trip card tap → TripsProvider.loadTripDetail()
  ///   → TripsRepository.getTripById() → TripsService.getTripById()
  ///   → GET /trips/{tripId}
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<void> loadTripDetail(String tripId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _selectedTrip = await repository.getTripById(tripId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Trip Creation Flow
  // ---------------------------------------------------------------------------

  /// Updates trip creation details (Step 1).
  void updateTripDetails({
    String? name,
    String? destination,
    DateTime? startDate,
    DateTime? endDate,
    String? tripType,
  }) {
    if (name != null) _newTripName = name;
    if (destination != null) _newTripDestination = destination;
    if (startDate != null) _newTripStartDate = startDate;
    if (endDate != null) _newTripEndDate = endDate;
    if (tripType != null) _newTripType = tripType;
    notifyListeners();
  }

  /// Adds a member to the trip being created (Step 2).
  void addMemberToNewTrip(MemberModel member) {
    _newTripMembers.add(member);
    notifyListeners();
  }

  /// Removes a member from the trip being created.
  void removeMemberFromNewTrip(String memberId) {
    _newTripMembers.removeWhere((m) => m.id == memberId);
    notifyListeners();
  }

  /// Creates the trip (Step 3 — Review & Create).
  ///
  /// BACKEND CALL: Create Trip button → TripsProvider.createTrip()
  ///   → TripsRepository.createTrip() → TripsService.createTrip()
  ///   → POST /trips (multipart/form-data with coverImage file)
  ///
  /// After this succeeds, the trip is added to the local list and
  /// the creation state is reset.
  ///
  /// TODO: Replace mock data once backend API is connected
  Future<void> createTrip({required String createdBy}) async {
    if (_newTripName == null || _newTripDestination == null ||
        _newTripStartDate == null || _newTripEndDate == null) {
      _errorMessage = 'Please fill in all trip details';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final trip = await repository.createTrip(
        name: _newTripName!,
        destination: _newTripDestination!,
        startDate: _newTripStartDate!,
        endDate: _newTripEndDate!,
        tripType: _newTripType,
        createdBy: createdBy,
      );

      // Add members if any were added during creation
      var tripWithMembers = trip;
      if (_newTripMembers.isNotEmpty) {
        final memberData = _newTripMembers
            .map((m) => {'name': m.name, 'phone': m.phone ?? ''})
            .toList();
        final addedMembers = await repository.addMembers(
          tripId: trip.id,
          members: memberData,
        );
        tripWithMembers = trip.copyWith(
          membersCount: trip.membersCount + addedMembers.length,
        );
      }

      // Add the new trip to the local cache
      _trips.insert(0, tripWithMembers);

      // Reset creation state
      _resetCreationState();
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Resets the trip creation flow state.
  void _resetCreationState() {
    _newTripName = null;
    _newTripDestination = null;
    _newTripStartDate = null;
    _newTripEndDate = null;
    _newTripType = 'Beach';
    _newTripMembers = [];
  }

  /// Cancels trip creation and resets the state.
  void cancelCreation() {
    _resetCreationState();
    notifyListeners();
  }

  // ---------------------------------------------------------------------------
  // Load Members
  // ---------------------------------------------------------------------------

  /// Loads members for a specific trip.
  Future<void> loadMembers(String tripId) async {
    if (_membersTripId != tripId) {
      _members = [];
      _membersTripId = tripId;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _members = await repository.getMembers(tripId);
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addMember({
    required String tripId,
    required String phone,
    String? name,
  }) async {
    _isUpdatingMembers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final members = await repository.addMembers(
        tripId: tripId,
        members: [
          {
            if (name != null && name.trim().isNotEmpty) 'name': name.trim(),
            'phone': phone.trim(),
          },
        ],
      );

      _members = [..._members, ...members];
      _syncTripMemberCount(tripId, _members.length);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isUpdatingMembers = false;
      notifyListeners();
    }
  }

  Future<void> removeMember({
    required String tripId,
    required String memberId,
  }) async {
    _isUpdatingMembers = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await repository.removeMember(
        tripId: tripId,
        memberId: memberId,
      );

      _members = _members.where((member) => member.id != memberId).toList();
      _syncTripMemberCount(tripId, _members.length);
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isUpdatingMembers = false;
      notifyListeners();
    }
  }

  Future<Map<String, dynamic>> leaveTrip({
    required String tripId,
    required String userId,
  }) async {
    _isLeavingTrip = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final result = await repository.leaveTrip(
        tripId: tripId,
        userId: userId,
      );

      _trips = _trips.where((trip) => trip.id != tripId).toList();
      if (_selectedTrip?.id == tripId) {
        _selectedTrip = null;
      }
      if (_membersTripId == tripId) {
        _membersTripId = null;
        _members = [];
      }

      return result;
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    } finally {
      _isLeavingTrip = false;
      notifyListeners();
    }
  }

  // ---------------------------------------------------------------------------
  // Helpers
  // ---------------------------------------------------------------------------

  /// Clears the current error message.
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Clears all cached data (e.g., on logout).
  void clearCache() {
    _trips = [];
    _members = [];
    _membersTripId = null;
    _selectedTrip = null;
    _currentPage = 1;
    _hasMore = true;
    _resetCreationState();
    notifyListeners();
  }

  void _syncTripMemberCount(String tripId, int membersCount) {
    final tripIndex = _trips.indexWhere((trip) => trip.id == tripId);
    if (tripIndex >= 0) {
      _trips[tripIndex] = _trips[tripIndex].copyWith(membersCount: membersCount);
    }

    if (_selectedTrip?.id == tripId) {
      _selectedTrip = _selectedTrip!.copyWith(membersCount: membersCount);
    }
  }
}
