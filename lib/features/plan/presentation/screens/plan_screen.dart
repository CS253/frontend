import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/route_planner_widgets.dart';
import '../providers/plan_provider.dart';
import '../../data/models/route_model.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool _isOptimized = true;
  String _departureTime = "11:00";
  
  // Start location
  Location _startLocation = Location(
    name: 'Connaught Place, Delhi',
    lat: 28.6315,
    lng: 77.2167,
  );

  // Destinations list
  final List<Location> _destinations = [
    Location(name: 'India Gate, Delhi', lat: 28.6129, lng: 77.2295),
    Location(name: 'Z Square Mall, Kanpur', lat: 26.4499, lng: 80.3319),
  ];

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

  Future<void> _planRoute() async {
    final provider = Provider.of<PlanProvider>(context, listen: false);
    final request = RouteRequest(
      departureTime: _departureTime,
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
        _departureTime = "${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final planProvider = Provider.of<PlanProvider>(context);
    final routeResponse = planProvider.routeResponse;

    return Scaffold(
      backgroundColor: const Color(0xFFFAFAFA),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: planProvider.isLoading ? null : _planRoute,
        backgroundColor: const Color(0xFFFFCC33),
        elevation: 4,
        highlightElevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        icon: planProvider.isLoading 
          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Color(0xFF212022), strokeWidth: 2))
          : const Icon(Icons.auto_fix_high, color: Color(0xFF212022)),
        label: const Text(
          'Plan My Route',
          style: TextStyle(
            fontWeight: FontWeight.w800, 
            fontFamily: 'Inter',
            color: Color(0xFF212022),
            fontSize: 15,
          ),
        ),
      ),
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
                          const Icon(Icons.access_time_filled, color: Color(0xFF6BB5E5), size: 20),
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
                          const Icon(Icons.arrow_drop_down, color: Color(0xFF8B8893)),
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

              // Start Location
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: LocationCard(
                    location: _startLocation,
                    index: 0,
                    isFirst: true,
                    onDelete: () {},
                  ),
                ),
              ),

              // Destinations List (Reorderable)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverReorderableList(
                  itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
                    key: ValueKey(_destinations[index].name + index.toString()),
                    index: index,
                    child: LocationCard(
                      location: _destinations[index],
                      index: index + 1,
                      isFirst: false,
                      onDelete: () => _deleteStop(index),
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
                        _destinations.add(Location(name: 'New Destination', lat: 0, lng: 0));
                      });
                    },
                    icon: const Icon(Icons.add_circle_outline, size: 22, color: Color(0xFF6BB5E5)),
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
                          value: routeResponse.totalDistanceKm,
                          icon: Icons.directions_car_outlined,
                          iconColor: const Color(0xFF6BB5E5),
                        ),
                        const SizedBox(width: 16),
                        SummaryCard(
                          label: 'Travel Time',
                          value: routeResponse.totalDurationMinutes,
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
                    padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 24),
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
              onMap: () {
                // Future Map Feature
              },
            ),
          ),
        ],
      ),
    );
  }
}
