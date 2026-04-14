import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/route_constants.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/trips_provider.dart';

class JoinTripScreen extends StatefulWidget {
  const JoinTripScreen({super.key});

  @override
  State<JoinTripScreen> createState() => _JoinTripScreenState();
}

class _JoinTripScreenState extends State<JoinTripScreen> {
  late final TextEditingController _inviteController;
  late final TextEditingController _participantNameController;
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _inviteController = TextEditingController();
    _participantNameController = TextEditingController();
    _inviteController.addListener(_tryPrefillParticipantNameFromInvite);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final currentUserName = context.read<AuthProvider>().user?.name?.trim();
    if ((_participantNameController.text).trim().isEmpty &&
        currentUserName != null &&
        currentUserName.isNotEmpty) {
      _participantNameController.text = currentUserName;
    }
  }

  @override
  void dispose() {
    _inviteController.removeListener(_tryPrefillParticipantNameFromInvite);
    _inviteController.dispose();
    _participantNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Join Trip',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            fontFamily: 'Nunito',
            color: Color(0xFF212022),
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFE6E8ED)),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Use an invite link from a trip member',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Nunito',
                        color: Color(0xFF1F242E),
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Paste the invite link or invite code you received. If the trip creator added you as a pending member, use the same participant name that was shared with the invite.',
                      style: TextStyle(
                        fontSize: 13,
                        fontFamily: 'Nunito',
                        color: Color(0xFF737B8C),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              _buildLabel('Invite Link'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _inviteController,
                minLines: 3,
                maxLines: 5,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Color(0xFF1F242E),
                ),
                decoration: _inputDecoration(
                  hintText: 'Paste invite link, URI, or raw invite code',
                  icon: Icons.link_outlined,
                ),
                validator: (value) {
                  final extracted = _extractInviteLink(value ?? '');
                  if (extracted == null || extracted.isEmpty) {
                    return 'Enter a valid invite link or code';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              _buildLabel('Participant Name'),
              const SizedBox(height: 8),
              TextFormField(
                controller: _participantNameController,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  color: Color(0xFF1F242E),
                ),
                decoration: _inputDecoration(
                  hintText: 'Enter the participant name from the invite',
                  icon: Icons.person_outline,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Participant name is required';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 28),
              Consumer<TripsProvider>(
                builder: (context, tripsProvider, _) {
                  return ElevatedButton(
                    onPressed: tripsProvider.isLoading ? null : _handleJoinTrip,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CB4E6),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: tripsProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Join Trip',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              color: Colors.white,
                            ),
                          ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        fontFamily: 'Nunito',
        color: Color(0xFF737B8C),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 13,
        color: Color(0xFF98A1B2),
      ),
      prefixIcon: Icon(icon, size: 20, color: const Color(0xFF8B8893)),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E4E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E4E9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF6CB4E6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1475E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFD1475E)),
      ),
    );
  }

  Future<void> _handleJoinTrip() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final inviteLink = _extractInviteLink(_inviteController.text.trim());
    final participantName = _participantNameController.text.trim();

    if (inviteLink == null || inviteLink.isEmpty) {
      _showSnackBar('Enter a valid invite link or code', isError: true);
      return;
    }

    try {
      final result = await context.read<TripsProvider>().joinTrip(
            inviteLink: inviteLink,
            participantName: participantName,
          );

      if (!mounted) return;

      final groupId = result['groupId'] as String?;
      _showSnackBar('Trip joined successfully', isError: false);

      if (groupId == null || groupId.isEmpty) {
        Navigator.of(context).pushNamedAndRemoveUntil(
          RouteConstants.trips,
          (route) => false,
        );
        return;
      }

      Navigator.of(context).pushNamedAndRemoveUntil(
        RouteConstants.dashboard,
        (route) => false,
        arguments: {'tripId': groupId},
      );
    } catch (error) {
      if (!mounted) return;
      _showSnackBar(_formatError(error), isError: true);
    }
  }

  String? _extractInviteLink(String rawValue) {
    final value = rawValue.trim();
    if (value.isEmpty) {
      return null;
    }

    final tokenMatch = RegExp(r'(invite-[A-Za-z0-9-]+)').firstMatch(value);
    if (tokenMatch != null) {
      return tokenMatch.group(1);
    }

    final parsedUri = Uri.tryParse(value);
    final inviteQuery = parsedUri?.queryParameters['inviteLink'];
    if (inviteQuery != null && inviteQuery.trim().isNotEmpty) {
      return inviteQuery.trim();
    }

    return null;
  }

  void _tryPrefillParticipantNameFromInvite() {
    final parsedUri = Uri.tryParse(_inviteController.text.trim());
    final participantName = parsedUri?.queryParameters['participantName'];
    if (participantName != null && participantName.trim().isNotEmpty) {
      _participantNameController.text = participantName.trim();
    }
  }

  String _formatError(Object error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }
    message = message.replaceFirst('Failed to join trip: ', '');

    final apiExceptionMatch = RegExp(r'ApiException\(\d+\):\s*(.*)').firstMatch(message);
    if (apiExceptionMatch != null) {
      return apiExceptionMatch.group(1) ?? message;
    }

    return message;
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Nunito')),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFD1475E) : const Color(0xFF2EB867),
      ),
    );
  }
}
