import 'package:flutter/material.dart';
import '../../data/models/user_profile.dart';

class ProfileCard extends StatelessWidget {
  final UserProfile? userProfile;
  final bool isLoading;

  const ProfileCard({
    super.key,
    required this.userProfile,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 24.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF262F40).withValues(alpha: 0.1),
              blurRadius: 23,
              offset: const Offset(0, 6),
              spreadRadius: -6,
            ),
          ],
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    if (userProfile == null) {
      return const SizedBox.shrink(); // Hide if no data is available
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.1),
            blurRadius: 23,
            offset: const Offset(0, 6),
            spreadRadius: -6,
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 74,
                height: 74,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFFD9F2EA), width: 3),
                  image: DecorationImage(
                    image: userProfile!.imageUrl != null
                        ? NetworkImage(userProfile!.imageUrl!) as ImageProvider
                        : const AssetImage(
                            'assets/images/default_avatar.png',
                          ), // Fallback
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: const Color(0xFF353337),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.white,
                      size: 14,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            userProfile!.name,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'Nunito',
              color: Color(0xFF212022),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            userProfile!.email,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.normal,
              fontFamily: 'Nunito',
              color: Color(0xFF8B8893),
            ),
          ),
        ],
      ),
    );
  }
}
