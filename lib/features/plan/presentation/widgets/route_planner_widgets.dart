import 'dart:ui';
import 'package:flutter/material.dart';
import '../../../../core/widgets/glass_back_button.dart';

class PlanHeader extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback onMap;

  const PlanHeader({
    super.key,
    required this.onBack,
    required this.onMap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(128),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withAlpha(153), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(13),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GlassBackButton(onPressed: onBack),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Route Planner',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212022),
                        fontFamily: 'Nunito',
                      ),
                    ),
                    Text(
                      'Plan your journey efficiently',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF8B8893),
                        fontFamily: 'Nunito',
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.map_outlined, color: Color(0xFF212022)),
                onPressed: onMap,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ModeToggle extends StatelessWidget {
  final bool isOptimized;
  final ValueChanged<bool> onChanged;

  const ModeToggle({
    super.key,
    required this.isOptimized,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F2F2),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          _buildToggleItem(
            label: 'Optimized',
            icon: Icons.flash_on,
            isActive: isOptimized,
            onTap: () => onChanged(true),
          ),
          _buildToggleItem(
            label: 'Manual',
            icon: Icons.pan_tool_outlined,
            isActive: !isOptimized,
            onTap: () => onChanged(false),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleItem({
    required String label,
    required IconData icon,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: isActive ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(20),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: Colors.black.withAlpha(13),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                size: 18,
                color: isActive ? const Color(0xFF6BB5E5) : const Color(0xFF8B8893),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                  color: isActive ? const Color(0xFF212022) : const Color(0xFF8B8893),
                  fontFamily: 'Nunito',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class LocationCard extends StatelessWidget {
  final String location;
  final int index;
  final VoidCallback onDelete;
  final bool isFirst;

  const LocationCard({
    super.key,
    required this.location,
    required this.index,
    required this.onDelete,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF2F2F2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.drag_indicator, color: Color(0xFFD1D1D6), size: 20),
          const SizedBox(width: 12),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: (isFirst ? const Color(0xFFE8F5E9) : const Color(0xFFFFF3E0)),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.location_on,
              size: 16,
              color: isFirst ? const Color(0xFF4CAF50) : const Color(0xFFFF9800),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF212022),
                fontFamily: 'Nunito',
              ),
            ),
          ),
          if (!isFirst)
            IconButton(
              icon: const Icon(Icons.close, size: 18, color: Color(0xFF8B8893)),
              onPressed: onDelete,
              constraints: const BoxConstraints(),
              padding: EdgeInsets.zero,
            ),
        ],
      ),
    );
  }
}

class SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color iconColor;

  const SummaryCard({
    super.key,
    required this.label,
    required this.value,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFF8FBFF),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 24),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF8B8893),
                    fontFamily: 'Nunito',
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF212022),
                    fontFamily: 'Nunito',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class TimelineStop extends StatelessWidget {
  final String title;
  final String distance;
  final bool isLast;

  const TimelineStop({
    super.key,
    required this.title,
    this.distance = '',
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimelineLine(),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: const Color(0xFFF2F2F2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF212022),
                              fontFamily: 'Nunito',
                            ),
                          ),
                          const Text(
                            '#1',
                            style: TextStyle(
                              fontSize: 12,
                              color: Color(0xFFBDBDBD),
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: Color(0xFF8B8893)),
                          SizedBox(width: 4),
                          Text(
                            'Opening/Closing time Not Available',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF8B8893),
                              fontFamily: 'Nunito',
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineLine() {
    return Column(
      children: [
        Container(
          width: 24,
          height: 24,
          decoration: BoxDecoration(
            color: const Color(0xFF6BB5E5).withAlpha(26),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFF6BB5E5),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ),
        if (!isLast)
          Expanded(
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 2,
                  color: const Color(0xFF6BB5E5).withAlpha(51),
                ),
                if (distance.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6BB5E5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: RotatedBox(
                      quarterTurns: 3,
                      child: Text(
                        distance,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
      ],
    );
  }
}
