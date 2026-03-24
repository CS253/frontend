import 'package:flutter/material.dart';
import '../widgets/route_planner_widgets.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  bool _isOptimized = true;
  
  // Mock data for stops
  final List<String> _stops = [
    'Connaught Place',
    'Z square mall',
    'Kanpur Central',
    'IIT Kanpur',
    'Lulu mall Lucknow',
  ];

  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final item = _stops.removeAt(oldIndex);
      _stops.insert(newIndex, item);
    });
  }

  void _deleteStop(int index) {
    setState(() {
      _stops.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
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

              // Stops List (Reorderable)
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                sliver: SliverReorderableList(
                  itemBuilder: (context, index) => ReorderableDelayedDragStartListener(
                    key: ValueKey(_stops[index]),
                    index: index,
                    child: LocationCard(
                      location: _stops[index],
                      index: index,
                      isFirst: index == 0,
                      onDelete: () => _deleteStop(index),
                    ),
                  ),
                  itemCount: _stops.length,
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
                        _stops.add('New Destination');
                      });
                    },
                    icon: const Icon(Icons.add, size: 18, color: Color(0xFF6BB5E5)),
                    label: const Text(
                      'Add Stop',
                      style: TextStyle(
                        color: Color(0xFF6BB5E5),
                        fontWeight: FontWeight.w600,
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 32)),

              // Summary Cards
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  child: Row(
                    children: const [
                      SummaryCard(
                        label: 'Total Distance',
                        value: '24.5 km',
                        icon: Icons.directions_car_outlined,
                        iconColor: Color(0xFF6BB5E5),
                      ),
                      SizedBox(width: 16),
                      SummaryCard(
                        label: 'Est. Time',
                        value: '2h 10m',
                        icon: Icons.access_time,
                        iconColor: Color(0xFF4DB6AC),
                      ),
                    ],
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 40)),

              // Itinerary Timeline Header
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 16),
                  child: Text(
                    'Trip Itinerary',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF212022),
                      fontFamily: 'Nunito',
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
                      title: _stops[index],
                      distance: index < _stops.length - 1 ? '${(index + 2) * 2.1} km' : '',
                      isLast: index == _stops.length - 1,
                    ),
                    childCount: _stops.length,
                  ),
                ),
              ),

              const SliverToBoxAdapter(child: SizedBox(height: 100)),
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
