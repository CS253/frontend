import 'dart:io';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/core/constants/route_constants.dart';
import 'package:travelly/features/auth/presentation/providers/auth_provider.dart';
import 'package:travelly/features/trips/presentation/providers/trips_provider.dart';

import 'package:travelly/features/account_settings/presentation/widgets/setting_item.dart';
import 'package:travelly/features/account_settings/presentation/widgets/settings_group.dart';
import 'package:travelly/core/widgets/glass_back_button.dart';
import '../../../../features/dashboard/presentation/providers/dashboard_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/trip_settings_provider.dart';
import 'manage_members_screen.dart';


class TripSettingsScreen extends StatefulWidget {
  final String? tripId;

  const TripSettingsScreen({
    super.key,
    this.tripId,
  });

  @override
  State<TripSettingsScreen> createState() => _TripSettingsScreenState();
}

class _TripSettingsScreenState extends State<TripSettingsScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripId = widget.tripId ?? context.read<DashboardProvider>().currentTrip?.id;
      if (tripId != null && tripId.isNotEmpty) {
        context.read<TripSettingsProvider>().init(tripId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Consumer<TripSettingsProvider>(
            builder: (context, provider, child) {
              // Build the switch state optimistically based on provider values
              final simplifyDebts = provider.tripSettings?.simplifyDebts ?? true;

              return SingleChildScrollView(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 100,
                  bottom: 120, // space for navbar
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 12),
                      _buildTripCard(context, provider),
                      const SizedBox(height: 32),
                      _buildSectionHeader('TRIP OPTIONS'),
                      const SizedBox(height: 12),
                      SettingsGroup(
                        children: [
                          SettingItem(
                            title: 'Manage Members',
                            subtitle: 'Add/Remove Members',
                            icon: Icons.person_outline,
                            iconBgColor: const Color(0xFFD9F0FC),
                            iconColor: const Color(0xFF5AB6EE),
                            onTap: () {
                              final tripId =
                                  widget.tripId ?? context.read<DashboardProvider>().currentTrip?.id;
                              if (tripId == null || tripId.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('No trip selected right now.'),
                                  ),
                                );
                                return;
                              }

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ManageMembersScreen(tripId: tripId),
                                ),
                              );
                            },
                          ),
                          const Divider(
                            height: 1,
                            color: Color(0xFFEDEDED),
                            indent: 16,
                            endIndent: 16,
                          ),
                          SettingItem(
                            title: 'Simplify Debts',
                            subtitle: 'Reduce the number of transactions',
                            icon: Icons.account_tree_outlined,
                            iconBgColor: const Color(0xFFD9F2EA),
                            iconColor: const Color(0xFF57C2A1),
                            trailing: provider.isLoadingTripSettings
                                ? const SizedBox(
                                    width: 44,
                                    height: 44,
                                    child: Center(
                                      child: CupertinoActivityIndicator(radius: 8),
                                    ),
                                  )
                                : _buildSwitch(
                                    simplifyDebts,
                                    (value) {
                                      provider.updateTripSetting('simplify_debts', value);
                                      context.read<DashboardProvider>().updateSimplifyDebts(value);
                                    },
                                  ),
                            showChevron: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          const Icon(
                            Icons.warning_amber_rounded,
                            color: Color(0xFFD74242),
                            size: 14,
                          ),
                          const SizedBox(width: 4),
                          const Text(
                            'DANGER ZONE',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              fontFamily: 'Nunito',
                              color: Color(0xFFD74242),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      SettingsGroup(
                        children: [
                          SettingItem(
                            title: 'Leave Trip',
                            titleColor: const Color(0xFFD74242),
                            subtitle: 'Leave this trip and its shared data',
                            icon: Icons.delete_outline,
                            iconBgColor: const Color(0xFFFDE8E8),
                            iconColor: const Color(0xFFD74242),
                            onTap: _handleLeaveTrip,
                          ),
                        ],
                      ),
                      const SizedBox(height: 48),
                    ],
                  ),
                ),
              );
            },
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: _buildHeader(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              GlassBackButton(onPressed: () => Navigator.pop(context)),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Trip Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF212022),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w600,
        fontFamily: 'Nunito',
        color: Color(0xFF8B8893),
        letterSpacing: 0.5,
      ),
    );
  }

  Widget _buildTripCard(BuildContext context, TripSettingsProvider provider) {
    final token = Provider.of<AuthProvider>(context, listen: false).token;
    final dashboardProvider = context.watch<DashboardProvider>();
    final trip = dashboardProvider.currentTrip;
    
    if (trip == null) {
      return Container(
        height: 140,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.grey.withValues(alpha: 0.2),
        ),
        child: const Center(child: CircularProgressIndicator()),
      );
    }

    Widget backgroundImage;
    if (trip.coverImage != null && trip.coverImage!.isNotEmpty) {
      if (trip.coverImage!.startsWith('http')) {
        backgroundImage = CachedNetworkImage(
          imageUrl: trip.coverImage!,
          httpHeaders: token != null ? {'Authorization': 'Bearer $token'} : null,
          fit: BoxFit.cover,
          errorWidget: (context, url, error) => _buildStockFallback(trip.tripType),
        );
      } else {
        backgroundImage = Image.file(
          File(trip.coverImage!),
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildStockFallback(trip.tripType),
        );
      }
    } else {
      backgroundImage = _buildStockFallback(trip.tripType);
    }

    return Container(
      height: 140,
      width: double.infinity,
      clipBehavior: Clip.hardEdge,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF262F40).withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          backgroundImage,
          // Dark gradient overlay for text readability
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                stops: const [0.0, 0.4, 1.0],
                colors: [
                  Colors.black.withValues(alpha: 0.2),
                  Colors.black.withValues(alpha: 0.1),
                  Colors.black.withValues(alpha: 0.7),
                ],
              ),
            ),
          ),
          // Trip Name
          Positioned(
            left: 16,
            bottom: 16,
            right: 16,
            child: Text(
              trip.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                letterSpacing: -0.5,
                shadows: [
                  Shadow(color: Color(0x66000000), blurRadius: 8, offset: Offset(0, 2)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockFallback(String tripType) {
    String stockAsset;
    switch (tripType) {
      case 'Beach':
        stockAsset = 'assets/images/Beach.png';
        break;
      case 'Mountain':
        stockAsset = 'assets/images/Mountain.png';
        break;
      case 'City':
        stockAsset = 'assets/images/City.png';
        break;
      case 'Nature':
        stockAsset = 'assets/images/Nature.png';
        break;
      case 'Island':
        stockAsset = 'assets/images/Island.png';
        break;
      default:
        stockAsset = 'assets/images/Other.png';
    }
    return Image.asset(
      stockAsset,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(color: const Color(0xFF90CAF9)),
    );
  }

  Widget _buildSwitch(bool value, Function(bool) onChanged) {
    return Transform.scale(
      scale: 0.7,
      child: CupertinoSwitch(
        value: value,
        activeTrackColor: const Color(0xFF6BB5E5),
        onChanged: onChanged,
      ),
    );
  }

  Future<void> _handleLeaveTrip() async {
    final tripId = widget.tripId ?? context.read<DashboardProvider>().currentTrip?.id;
    final userId = context.read<AuthProvider>().user?.id;

    if (tripId == null || tripId.isEmpty || userId == null || userId.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to leave this trip right now.'),
        ),
      );
      return;
    }

    final shouldLeave = await showDialog<bool>(
          context: context,
          builder: (dialogContext) => AlertDialog(
            title: const Text(
              'Leave Trip?',
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
            content: const Text(
              'If you are the trip creator, this will delete the trip for every member. Otherwise, only you will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext, false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(dialogContext, true),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFD74242),
                ),
                child: const Text('Leave'),
              ),
            ],
          ),
        ) ??
        false;

    if (!shouldLeave || !mounted) {
      return;
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6BB5E5)),
        ),
      ),
    );

    try {
      final result = await context.read<TripsProvider>().leaveTrip(
            tripId: tripId,
            userId: userId,
          );

      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      final deletedTrip = result['deletedTrip'] == true;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            deletedTrip
                ? 'Trip deleted for all members.'
                : 'You left the trip successfully.',
          ),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF2EB867),
        ),
      );

      Navigator.of(context, rootNavigator: true).pushNamedAndRemoveUntil(
        RouteConstants.trips,
        (route) => false,
      );
    } catch (error) {
      if (!mounted) return;

      Navigator.of(context, rootNavigator: true).pop();

      var message = error.toString();
      if (message.startsWith('Exception: ')) {
        message = message.substring('Exception: '.length);
      }
      message = message.replaceFirst('Failed to leave trip: ', '');
      final apiExceptionMatch = RegExp(r'ApiException\(\d+\):\s*(.*)').firstMatch(message);
      if (apiExceptionMatch != null) {
        message = apiExceptionMatch.group(1) ?? message;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFFD74242),
        ),
      );
    }
  }
}

