import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import '../../data/models/user_profile.dart';
import '../../../../core/utils/initials_util.dart';

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
    final token = Provider.of<AuthProvider>(context, listen: false).token;
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

    final String initials = getInitials(userProfile!.name);

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
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFE3F2FD), // Background color for initials
              border: Border.all(color: const Color(0xFFD9F2EA), width: 3),
              image: userProfile!.imageUrl != null
                  ? DecorationImage(
                      image: NetworkImage(
                        userProfile!.imageUrl!,
                        headers: token != null ? {'Authorization': 'Bearer $token'} : null,
                      ),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: userProfile!.imageUrl == null
                ? Center(
                    child: Text(
                      initials,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF6BB5E5),
                        fontFamily: 'Inter',
                      ),
                    ),
                  )
                : null,
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
