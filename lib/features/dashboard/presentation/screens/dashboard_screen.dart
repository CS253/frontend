import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/trip_header.dart';
import '../widgets/participant_row.dart';
import '../widgets/explore_grid.dart';
import '../widgets/activity_list.dart';
import '../dialogs/trip_details_dialog.dart';

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
///   • Navigates to feature screens via the [onNavigate] callback
///
/// The [onNavigate] callback is provided by [MainScreen] to switch
/// the bottom navigation tab, maintaining the existing IndexedStack
/// navigation pattern.
class DashboardScreen extends StatefulWidget {
  /// Callback to switch the bottom navigation tab in [MainScreen].
  /// The [int] parameter is the target tab index:
  ///   0 = Home, 1 = Payments, 2 = Plan, 3 = Gallery, 4 = Documents
  final void Function(int tabIndex)? onNavigate;

  const DashboardScreen({super.key, this.onNavigate});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Fetch dashboard data when the screen is first mounted.
    // Using addPostFrameCallback to ensure the widget tree is built
    // before the provider triggers notifyListeners().
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().fetchDashboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Watch the provider so this widget rebuilds on state changes.
    final provider = context.watch<DashboardProvider>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(bottom: false, child: _buildBody(provider)),
    );
  }

  /// Builds the appropriate body based on provider state.
  ///
  /// State machine:
  ///   isLoading → loading indicator
  ///   errorMessage.isNotEmpty → error message with retry
  ///   hasData → full dashboard content
  ///   else → empty state (shouldn't normally occur)
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
                onPressed: () => provider.fetchDashboard(),
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
            const SizedBox(height: 16),

            // ── Trip header with trip name ────────────────────────
            TripHeader(
              tripName: provider.currentTrip?.name ?? 'My Trip',
              onBackPressed: () => Navigator.of(context, rootNavigator: true).pop(),
            ),
            const SizedBox(height: 24),

            // ── Trip info card with participant avatars ───────────
            // Tapping opens the Trip Details floating dialog
            // (mirrors the payments feature Add Payment dialog flow)
            if (provider.currentTrip != null)
              ParticipantRow(
                trip: provider.currentTrip!,
                participants: provider.participants,
                onTap: () => TripDetailsDialog.show(
                  context,
                  provider.currentTrip!,
                  provider.participants,
                ),
              ),
            const SizedBox(height: 24),

            // ── Explore navigation grid ──────────────────────────
            ExploreGrid(onNavigate: widget.onNavigate),
            const SizedBox(height: 24),

            // ── Recent activity feed ─────────────────────────────
            ActivityList(activities: provider.activities),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
