import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/route_planner_widgets.dart';
import '../providers/plan_provider.dart';
import '../../data/models/route_model.dart';
import '../../../../core/widgets/primary_button.dart';
import '../../../../core/services/geocoding_service.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool _isOptimized = true;
  String _departureTime = "";

  @override
  void initState() {
    super.initState();
    // Initialize with current time
    final now = TimeOfDay.now();
    _departureTime =
        "${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}";
  }

  // Start location initial state (Empty)
  Location _startLocation = Location(name: '', lat: 0, lng: 0);

  // Destinations list (Empty)
  final List<Location> _destinations = [];

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _destinations.removeAt(oldIndex);
      _destinations.insert(newIndex, item);
    });
  }

  void _deleteStop(int index) {
    setState(() {
      _destinations.removeAt(index);
    });
  }

  Future<void> _editLocation(int index, bool isStart) async {
    final Location loc = isStart ? _startLocation : _destinations[index];
    final TextEditingController controller = TextEditingController(
      text: loc.name,
    );

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          loc.name.isEmpty
              ? (isStart ? 'Enter Start Location' : 'Enter Stop Location')
              : (isStart ? 'Edit Start Location' : 'Edit Stop Location'),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF212022),
            fontFamily: 'Inter',
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(
            hintText: isStart ? 'e.g. Connaught Place' : 'e.g. India Gate',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: Color(0xFF8B8893)),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final name = controller.text;
              // Close dialog first to show loading if needed, or just proceed
              Navigator.pop(context);

              // Fetch coordinates
              final coords = await GeocodingService.getCoordinates(name);

              setState(() {
                if (isStart) {
                  _startLocation = _startLocation.copyWith(
                    name: name,
                    lat: coords?['lat'] ?? 0.0,
                    lng: coords?['lng'] ?? 0.0,
                  );
                } else {
                  _destinations[index] = _destinations[index].copyWith(
                    name: name,
                    lat: coords?['lat'] ?? 0.0,
                    lng: coords?['lng'] ?? 0.0,
                  );
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF6BB5E5),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _planRoute() async {
    final provider = Provider.of<PlanProvider>(context, listen: false);
    final request = RouteRequest(
      departureTime: _departureTime,
      optimized: _isOptimized,
      start: _startLocation,
      destinations: _destinations,
    );
    await provider.planRoute(request);
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        _departureTime =
            "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final routeResponse = planProvider.routeResponse;

    final bool canPlan =
        _startLocation.name.isNotEmpty &&
        _destinations.any((d) => d.name.isNotEmpty);
    final String subtitle = _destinations.isEmpty
        ? 'Add destinations to start'
        : '${_destinations.length} Stops Added';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      body: Stack(
        children: [
          // Main Content
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Spacing for Header
              const SliverToBoxAdapter(child: SizedBox(height: 120)),

              // Departure Time Picker
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: InkWell(
                    onTap: _selectTime,
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: const Color(0xFFF2F2F2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.access_time_filled,
                            color: Color(0xFF6BB5E5),
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Departure Time',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF8B8893),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const Spacer(),
                          Text(
                            _departureTime,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF212022),
                              fontFamily: 'Inter',
                            ),
                          ),
                          const Icon(
                            Icons.arrow_drop_down,
                            color: Color(0xFF8B8893),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 16)),

              // Mode Toggle
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: ModeToggle(
                    isOptimized: _isOptimized,
                    onChanged: (value) => setState(() => _isOptimized = value),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 24)),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: LocationCard(
                    location: _startLocation,
                    index: 0,
                    isFirst: true,
                    onDelete: () {},
                    onEdit: () => _editLocation(0, true),
                  ),
                ),
              ),

              // Destinations List (Reorderable)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverReorderableList(
                  itemBuilder: (context, index) =>
                      ReorderableDelayedDragStartListener(
                        key: ValueKey(
                          _destinations[index].name + index.toString(),
                        ),
                        index: index,
                        child: LocationCard(
                          location: _destinations[index],
                          index: index + 1,
                          isFirst: false,
                          onDelete: () => _deleteStop(index),
                          onEdit: () => _editLocation(index, false),
                        ),
                      ),
                  itemCount: _destinations.length,
                  onReorder: _onReorder,
                ),
              ),

              // Add Stop Button
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() {
                        _destinations.add(Location(name: '', lat: 0, lng: 0));
                      });
                    },
                    icon: const Icon(
                      Icons.add_circle_outline,
                      size: 22,
                      color: Color(0xFF6BB5E5),
                    ),
                    label: const Text(
                      'Add Stop',
                      style: TextStyle(
                        color: Color(0xFF6BB5E5),
                        fontWeight: FontWeight.w800,
                        fontFamily: 'Inter',
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ),

              if (planProvider.errorMessage != null)
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red.withAlpha(15),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Text(
                        planProvider.errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ),

              if (routeResponse != null) ...[
                const SliverToBoxAdapter(child: SizedBox(height: 32)),

                // Summary Cards
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Row(
                      children: [
                        SummaryCard(
                          label: 'Total Distance',
                          value: '${routeResponse.totalDistanceKm} km',
                          icon: Icons.directions_car_outlined,
                          iconColor: const Color(0xFF6BB5E5),
                        ),
                        const SizedBox(width: 16),
                        SummaryCard(
                          label: 'Travel Time',
                          value: '${routeResponse.totalDurationMinutes} mins',
                          icon: Icons.timer_outlined,
                          iconColor: const Color(0xFF4CAF50),
                        ),
                      ],
                    ),
                  ),
                ),

                const SliverToBoxAdapter(child: SizedBox(height: 40)),

                // Itinerary Timeline Header
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 24,
                    ),
                    child: Text(
                      'Optimized Itinerary',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF212022),
                        fontFamily: 'Inter',
                      ),
                    ),
                  ),
                ),

                // Itinerary Timeline List
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) => TimelineStop(
                        stop: routeResponse.stops[index],
                        index: index,
                        isLast: index == routeResponse.stops.length - 1,
                      ),
                      childCount: routeResponse.stops.length,
                    ),
                  ),
                ),
              ],

              const SliverToBoxAdapter(child: SizedBox(height: 120)),
            ],
          ),

          // Sticky Header
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: PlanHeader(
              onBack: () => Navigator.pop(context),
              subtitle: subtitle,
            ),
          ),

          // Primary Action Button (Matches Documents Screen)
          Positioned(
            bottom: 70,
            left: 0,
            right: 0,
            child: Center(
              child: planProvider.isLoading
                  ? const CircularProgressIndicator(color: Color(0xFF6BB5E5))
                  : PrimaryFabButton(
                      label: 'Plan My Route',
                      icon: Icons.auto_fix_high,
                      backgroundColor: canPlan
                          ? const Color(0xFF6BB5E5)
                          : const Color(0xFFE0E0E0),
                      foregroundColor: canPlan
                          ? Colors.white
                          : const Color(0xFF9E9E9E),
                      onPressed: canPlan ? _planRoute : () {},
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
