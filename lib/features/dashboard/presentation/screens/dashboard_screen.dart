import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/trip_header.dart';
import '../widgets/participant_row.dart';
import '../widgets/explore_grid.dart';
import '../widgets/activity_list.dart';
import '../dialogs/trip_details_dialog.dart';
import 'package:travelly/features/payments/data/repositories/payment_repository.dart';
import 'package:travelly/core/services/user_identity_service.dart';

/// The main dashboard screen — central navigation hub of the Travelly app.
///
/// Architecture role:
///   **Screen** → Provider → Repository → Service → ApiClient
///
/// This screen:
///   • Watches [DashboardProvider] for reactive state updates
///   • Delegates all data fetching to the provider (no API calls here)
///   • Composes extracted widgets for each UI section
///   • Handles loading, error, and data states
class DashboardScreen extends StatefulWidget {
  final String tripId;

  const DashboardScreen({super.key, required this.tripId});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the screen is first mounted.
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      context.read<DashboardProvider>().fetchDashboard(widget.tripId);
      
      // Prefetch payments data seamlessly in the background
      final paymentRepo = context.read<PaymentRepository>();
      final userId = await UserIdentityService.instance.getBackendUserId(widget.tripId, paymentRepo);
      paymentRepo.prefetchAll(widget.tripId, userId: userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider so this widget rebuilds on state changes.
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            _buildBody(provider),
            const Positioned(
              top: 0,
              left: 0,
              child: GlassBackButton(),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the appropriate body based on provider state.
  Widget _buildBody(DashboardProvider provider) {
    // ── Loading state ──────────────────────────────────────────────
    if (provider.isLoading && !provider.hasData) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF00A2FF)),
      );
    }

    // ── Error state ────────────────────────────────────────────────
    if (provider.errorMessage.isNotEmpty && !provider.hasData) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 48,
                color: Color(0xFF8B8893),
              ),
              const SizedBox(height: 16),
              Text(
                provider.errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF8B8893),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => provider.fetchDashboard(widget.tripId),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00A2FF),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    // ── Data state — full dashboard content ────────────────────────
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 24), // Extra space for back button

            // ── Trip header with trip name ────────────────────────
            TripHeader(
              tripName: provider.currentTrip?.name ?? 'My Trip',
            ),
            const SizedBox(height: 24),

            // ── Trip info card with participant avatars ───────────
            // Tapping opens the Trip Details floating dialog
            // (mirrors the payments feature Add Payment dialog flow)
            if (provider.currentTrip != null)
              ParticipantRow(
                trip: provider.currentTrip!,
                participants: provider.participants,
                memberCountOverride: provider.memberCount,
                onTap: () => TripDetailsDialog.show(
                  context,
                  provider.currentTrip!,
                  provider.participants,
                ),
              ),
            const SizedBox(height: 24),

            // ── Explore navigation grid ──────────────────────────
            ExploreGrid(tripId: provider.currentTrip?.id ?? ''),
            const SizedBox(height: 24),

            // ── Recent activity feed (shows loading until history arrives) ─
            if (provider.isActivitiesLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF00A2FF),
                  ),
                ),
              )
            else
              ActivityList(activities: provider.activities),
            const SizedBox(height: 100), // Extra space for floating navbar
          ],
        ),
      ),
    );
  }
}
