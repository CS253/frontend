import 'package:flutter/material.dart';
import '../../../../features/documents/presentation/screens/documents_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        bottom: false,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 16), // Top spacing for header
                _buildHeader(),
                const SizedBox(height: 24),
                // Trip Info Card
                _buildTripInfoCard(),
                const SizedBox(height: 24),
                // Explore Section
                _buildExploreSection(),
                const SizedBox(height: 24),
                // Recent Activity Section
                _buildRecentActivitySection(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Stack(
      alignment: Alignment.center,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
              icon: const Icon(Icons.arrow_back, color: Color(0xFF212022)),
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
            IconButton(
              icon: const Icon(
                Icons.more_horiz,
                color: Color(0xFF212022),
              ), // Adjusted back to more_horiz for options
              onPressed: () {},
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.location_on_outlined,
                  size: 14,
                  color: Color(0xFF8B8893),
                ),
                const SizedBox(width: 4),
                const Text(
                  'Current Trip',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF8B8893), // Adjusted color to match gray
                  ),
                ),
              ],
            ),
            const SizedBox(height: 2),
            const Text(
              'The Lyaari Trip',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF212022),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTripInfoCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFC1EAFF), Color(0xFFD9F0FC)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 13.6,
            offset: const Offset(0, 4),
            spreadRadius: -6,
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Trip starts in',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: Color(0x99212022),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      '5 Days',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF212022),
                      ),
                    ),
                  ],
                ),
              ),
              // Spade emoji in circle
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF262F40).withValues(alpha: 0.08),
                      blurRadius: 16,
                      offset: const Offset(0, 3),
                      spreadRadius: -3,
                    ),
                  ],
                ),
                child: const Center(
                  child: Text('♠️', style: TextStyle(fontSize: 24)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Align(widthFactor: 0.7, child: _buildEmojiAvatar('😊')),
              Align(widthFactor: 0.7, child: _buildEmojiAvatar('😎')),
              Align(widthFactor: 0.7, child: _buildEmojiAvatar('🤗')),
              _buildEmojiAvatar('😄'),
              const SizedBox(width: 8),
              const Text(
                '+2 travelers',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                  color: Color(0xB3212022),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmojiAvatar(String emoji) {
    return Container(
      width: 26,
      height: 26,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: Colors.white, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.08),
            blurRadius: 16,
            offset: const Offset(0, 3),
            spreadRadius: -3,
          ),
        ],
      ),
      child: Center(child: Text(emoji, style: const TextStyle(fontSize: 11))),
    );
  }

  Widget _buildExploreSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Explore',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212022),
          ),
        ),
        const SizedBox(height: 12),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
          childAspectRatio: 172 / 112, // Aspect ratio from Figma (w/h)
          children: [
            _buildExploreCard(
              title: 'Payments',
              subtitle: 'Split & Settle',
              icon: Icons.account_balance_wallet_outlined,
              iconBgColor: const Color(0xFF7EF1CB),
              cardBgColor: const Color(0xFFE5F8F1),
            ),
            _buildExploreCard(
              title: 'Gallery',
              subtitle: 'Shared Album',
              icon: Icons.image_outlined,
              iconBgColor: const Color(0xFFFFCA9B),
              cardBgColor: const Color(0xFFFFF0DD),
            ),
            _buildExploreCard(
              title: 'Plan',
              subtitle: 'Customize your route',
              icon: Icons.map_outlined,
              iconBgColor: const Color(0xFF7DD2ED),
              cardBgColor: const Color(0xFFE7F8FA),
            ),
            GestureDetector(
              onTap: () {
                // Handled structurally now
              },
              child: _buildExploreCard(
                title: 'Documents',
                subtitle: 'All your file',
                icon: Icons.description_outlined,
                iconBgColor: const Color(0xFFFFE591),
                cardBgColor: const Color(0xFFFEF9EA),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildExploreCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconBgColor,
    required Color cardBgColor,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardBgColor,
        borderRadius: BorderRadius.circular(19.16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.17),
            blurRadius: 13.6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.only(left: 13, top: 9, right: 10, bottom: 9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 46,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(15.97),
            ),
            child: Center(child: Icon(icon, size: 24, color: Colors.white)),
          ),
          const Spacer(),
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: Color(0xCC212022),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w500,
              fontFamily: 'Nunito',
              color: Color(0x99212022),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Recent Activity',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF212022),
          ),
        ),
        const SizedBox(height: 12),
        _buildActivityItem('💵', 'Ronit added ₹10000 for Hotel', '2h ago'),
        const SizedBox(height: 12),
        _buildActivityItem('📷', 'Sarim shared 12 photos', '5h ago'),
        const SizedBox(height: 12),
        _buildActivityItem('📄', 'Rigved uploaded Flight Tickets', '1d ago'),
      ],
    );
  }

  Widget _buildActivityItem(String emoji, String title, String time) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 24,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFD9F0FC),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(emoji, style: const TextStyle(fontSize: 24)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: Color(0xFF212022),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 9.5,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF8B8893),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
