import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:travelly/core/utils/initials_util.dart';
import 'package:travelly/features/trips/data/models/member_model.dart';
import 'package:travelly/features/trips/presentation/providers/trips_provider.dart';

class ManageMembersScreen extends StatefulWidget {
  final String tripId;

  const ManageMembersScreen({
    super.key,
    required this.tripId,
  });

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tripsProvider = context.read<TripsProvider>();
      tripsProvider.loadMembers(widget.tripId);
      tripsProvider.loadTripDetail(widget.tripId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF262F40).withValues(alpha: 0.08),
                blurRadius: 15,
                offset: const Offset(0, 3),
                spreadRadius: -3,
              ),
            ],
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back,
              color: Color(0xFF212022),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ),
        title: const Text(
          'Manage Members',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            fontFamily: 'Nunito',
            color: Color(0xFF212022),
          ),
        ),
      ),
      body: SafeArea(
        child: Consumer<TripsProvider>(
          builder: (context, tripsProvider, _) {
            final members = tripsProvider.members;
            final inviteLink = _resolveInviteLink(tripsProvider);
            final showLoadingState = tripsProvider.isLoading && members.isEmpty;
            final hasError = tripsProvider.errorMessage != null && members.isEmpty;

            if (showLoadingState) {
              return const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6CB4E6)),
                ),
              );
            }

            if (hasError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.error_outline,
                        color: Color(0xFFD1475E),
                        size: 42,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        tripsProvider.errorMessage ?? 'Failed to load members',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          fontFamily: 'Nunito',
                          color: Color(0xFF737B8C),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          tripsProvider.loadMembers(widget.tripId);
                          tripsProvider.loadTripDetail(widget.tripId);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6CB4E6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Retry',
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                await tripsProvider.loadMembers(widget.tripId);
                await tripsProvider.loadTripDetail(widget.tripId);
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _buildMembersHeader(context, members.length),
                  const SizedBox(height: 12),
                  if (inviteLink != null && inviteLink.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: _buildInviteCard(inviteLink),
                    ),
                  if (members.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 36),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE2E4E9).withValues(alpha: 0.7),
                        ),
                      ),
                      child: const Column(
                        children: [
                          Icon(
                            Icons.group_outlined,
                            size: 42,
                            color: Color(0xFF8B8893),
                          ),
                          SizedBox(height: 12),
                          Text(
                            'No members added yet',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              fontFamily: 'Nunito',
                              color: Color(0xFF1F242E),
                            ),
                          ),
                          SizedBox(height: 6),
                          Text(
                            'Add a traveller by name and phone number, then share the invite link so they can join the trip.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 13,
                              fontFamily: 'Nunito',
                              color: Color(0xFF737B8C),
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...members.map(
                      (member) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: _buildMemberCard(context, member, inviteLink),
                      ),
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMembersHeader(BuildContext context, int membersCount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            const Icon(
              Icons.group_outlined,
              color: Color(0xFF737B8C),
              size: 14,
            ),
            const SizedBox(width: 6),
            Text(
              'MEMBERS ($membersCount)',
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: Color(0xFF737B8C),
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        TextButton.icon(
          onPressed: () => _showAddMemberSheet(context),
          icon: const Icon(
            Icons.person_add_outlined,
            color: Color(0xFF6CB4E6),
            size: 14,
          ),
          label: const Text(
            'Add',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF6CB4E6),
            ),
          ),
          style: TextButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
        ),
      ],
    );
  }

  Widget _buildInviteCard(String inviteLink) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FBFE),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFDDEAF4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.link_outlined,
                size: 18,
                color: Color(0xFF6CB4E6),
              ),
              SizedBox(width: 8),
              Text(
                'Trip Invite Link',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  fontFamily: 'Nunito',
                  color: Color(0xFF1F242E),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            inviteLink,
            style: const TextStyle(
              fontSize: 12,
              fontFamily: 'Nunito',
              color: Color(0xFF4A5568),
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: () => _copyInviteText(
                  _buildGenericInviteMessage(inviteLink),
                  successMessage: 'Invite link copied',
                ),
                icon: const Icon(Icons.copy_outlined, size: 16),
                label: const Text('Copy'),
              ),
              FilledButton.icon(
                onPressed: () => _shareInvite(_buildGenericInviteMessage(inviteLink)),
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF6CB4E6),
                ),
                icon: const Icon(Icons.share_outlined, size: 16),
                label: const Text('Share'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard(
    BuildContext context,
    MemberModel member,
    String? inviteLink,
  ) {
    final subtitle = member.pending
        ? 'Pending invite${member.phone != null && member.phone!.isNotEmpty ? ' - ${member.phone}' : ''}'
        : member.role == 'admin'
            ? 'Trip admin'
            : (member.phone ?? 'Trip member');

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFE2E4E9).withValues(alpha: 0.5),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: _avatarColorFor(member.id),
            child: Text(
              getInitials(member.name),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontFamily: 'Nunito',
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F242E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: member.pending
                        ? const Color(0xFFCC8B2F)
                        : const Color(0xFF8B8893),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFF8B8893),
              size: 18,
            ),
            onPressed: () => _showMemberOptions(context, member, inviteLink),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    String? nameErrorText;
    String? phoneErrorText;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (sheetContext, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(sheetContext).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            ),
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
            child: SafeArea(
              top: false,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: const Color(0xFFE2E4E9),
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Add New Member',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Nunito',
                      color: Color(0xFF1F242E),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Add the invited traveller\'s name and phone number. Once they are added, share the invite link with them so they can join the trip.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      color: Color(0xFF737B8C),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: nameController,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF1F242E),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        nameErrorText = _validateName(value);
                      });
                    },
                    decoration: _sheetInputDecoration(
                      hintText: 'Participant Name',
                      icon: Icons.person_outline,
                      errorText: nameErrorText,
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF1F242E),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        phoneErrorText = _validatePhone(value);
                      });
                    },
                    decoration: _sheetInputDecoration(
                      hintText: 'Phone Number',
                      icon: Icons.phone_outlined,
                      errorText: phoneErrorText,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<TripsProvider>(
                    builder: (context, tripsProvider, _) {
                      return ElevatedButton(
                        onPressed: tripsProvider.isUpdatingMembers
                            ? null
                            : () async {
                                final name = nameController.text.trim();
                                final phone = phoneController.text.trim();
                                final resolvedNameError = _validateName(name);
                                final resolvedPhoneError = _validatePhone(phone);

                                if (resolvedNameError != null || resolvedPhoneError != null) {
                                  setSheetState(() {
                                    nameErrorText = resolvedNameError;
                                    phoneErrorText = resolvedPhoneError;
                                  });
                                  return;
                                }

                                try {
                                  final createdMember = await context.read<TripsProvider>().addMember(
                                        tripId: widget.tripId,
                                        name: name,
                                        phone: phone,
                                      );

                                  if (!mounted) return;
                                  Navigator.pop(sheetContext);

                                  var inviteLink = _resolveInviteLink(context.read<TripsProvider>());
                                  if ((inviteLink == null || inviteLink.isEmpty) && createdMember.pending) {
                                    await context.read<TripsProvider>().loadTripDetail(widget.tripId);
                                    inviteLink = _resolveInviteLink(context.read<TripsProvider>());
                                  }
                                  if (createdMember.pending && inviteLink != null && inviteLink.isNotEmpty) {
                                    _showInviteActions(member: createdMember, inviteLink: inviteLink);
                                  } else {
                                    _showSnackBar(
                                      createdMember.pending
                                          ? 'Member added. Share the trip invite so they can join.'
                                          : 'Member added successfully',
                                      isError: false,
                                    );
                                  }
                                } catch (error) {
                                  final message = _formatError(error);
                                  setSheetState(() {
                                    if (message.toLowerCase().contains('name')) {
                                      nameErrorText = message;
                                      phoneErrorText = null;
                                    } else {
                                      phoneErrorText = message;
                                    }
                                  });
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6CB4E6),
                          disabledBackgroundColor: const Color(0xFFB8D9EF),
                          minimumSize: const Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 0,
                        ),
                        child: tripsProvider.isUpdatingMembers
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              )
                            : const Text(
                                'Add Member',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'Nunito',
                                  color: Colors.white,
                                ),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMemberOptions(BuildContext context, MemberModel member, String? inviteLink) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: const Color(0xFFE2E4E9),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              if (member.pending && inviteLink != null && inviteLink.isNotEmpty) ...[
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Column(
                    children: [
                      _sheetActionButton(
                        label: 'Copy Invite',
                        icon: Icons.copy_outlined,
                        foregroundColor: const Color(0xFF1F242E),
                        backgroundColor: const Color(0xFFF3F5F7),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _copyInviteText(
                            _buildInviteMessage(inviteLink, member.name),
                            successMessage: 'Invite copied for ${member.name}',
                          );
                        },
                      ),
                      const SizedBox(height: 10),
                      _sheetActionButton(
                        label: 'Share Invite',
                        icon: Icons.share_outlined,
                        foregroundColor: Colors.white,
                        backgroundColor: const Color(0xFF6CB4E6),
                        onTap: () {
                          Navigator.pop(sheetContext);
                          _shareInvite(_buildInviteMessage(inviteLink, member.name));
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              if (member.role == 'admin' && !member.pending)
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    'Trip admins cannot be removed from here.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      fontFamily: 'Nunito',
                      color: Color(0xFF1F242E),
                    ),
                  ),
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _sheetActionButton(
                    label: member.pending ? 'Remove Invite' : 'Remove from Trip',
                    icon: Icons.delete_outline,
                    foregroundColor: const Color(0xFFD1475E),
                    backgroundColor: const Color(0xFFFDE8E8),
                    onTap: () async {
                      Navigator.pop(sheetContext);
                      await _handleRemoveMember(member);
                    },
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sheetActionButton({
    required String label,
    required IconData icon,
    required Color foregroundColor,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, color: foregroundColor, size: 20),
      label: Text(
        label,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.bold,
          fontFamily: 'Nunito',
          color: foregroundColor,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        elevation: 0,
      ),
    );
  }

  Future<void> _handleRemoveMember(MemberModel member) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF6CB4E6)),
        ),
      ),
    );

    try {
      await context.read<TripsProvider>().removeMember(
            tripId: widget.tripId,
            memberId: member.id,
          );
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar(
        member.pending ? 'Invite removed successfully' : 'Member removed successfully',
        isError: false,
      );
    } catch (error) {
      if (!mounted) return;
      Navigator.pop(context);
      _showSnackBar(_formatError(error), isError: true);
    }
  }

  void _showInviteActions({
    required MemberModel member,
    required String inviteLink,
  }) {
    final inviteMessage = _buildInviteMessage(inviteLink, member.name);

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE2E4E9),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Invite ready for ${member.name}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  fontFamily: 'Nunito',
                  color: Color(0xFF1F242E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Share this invite now so the pending member has the trip link and the participant name they should use while joining.',
                style: TextStyle(
                  fontSize: 13,
                  fontFamily: 'Nunito',
                  color: Color(0xFF737B8C),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FBFE),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFDDEAF4)),
                ),
                child: Text(
                  inviteLink,
                  style: const TextStyle(
                    fontSize: 12,
                    fontFamily: 'Nunito',
                    color: Color(0xFF4A5568),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _copyInviteText(
                          inviteMessage,
                          successMessage: 'Invite copied for ${member.name}',
                        );
                      },
                      icon: const Icon(Icons.copy_outlined, size: 16),
                      label: const Text('Copy Invite'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: FilledButton.icon(
                      onPressed: () {
                        Navigator.pop(sheetContext);
                        _shareInvite(inviteMessage);
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF6CB4E6),
                      ),
                      icon: const Icon(Icons.share_outlined, size: 16),
                      label: const Text('Share Invite'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _sheetInputDecoration({
    required String hintText,
    required IconData icon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hintText,
      errorText: errorText,
      errorStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 12,
        color: Color(0xFFD1475E),
      ),
      hintStyle: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 14,
        color: Color(0xFF8B8893),
      ),
      prefixIcon: Icon(
        icon,
        color: const Color(0xFF8B8893),
        size: 20,
      ),
      filled: true,
      fillColor: const Color(0xFFF9FAFB),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E4E9)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE2E4E9)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF6CB4E6)),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1475E)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFD1475E)),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
    );
  }

  String? _resolveInviteLink(TripsProvider provider) {
    if (provider.selectedTrip?.id == widget.tripId &&
        provider.selectedTrip?.inviteLink != null &&
        provider.selectedTrip!.inviteLink!.trim().isNotEmpty) {
      return provider.selectedTrip!.inviteLink!.trim();
    }

    for (final trip in provider.trips) {
      if (trip.id == widget.tripId &&
          trip.inviteLink != null &&
          trip.inviteLink!.trim().isNotEmpty) {
        return trip.inviteLink!.trim();
      }
    }

    return null;
  }

  String _buildInviteMessage(String inviteLink, String participantName) {
    final inviteUri = Uri(
      scheme: 'travelly',
      host: 'join',
      queryParameters: {
        'inviteLink': inviteLink,
        'participantName': participantName,
      },
    ).toString();

    return '''
Join my Travelly trip.

Invite link: $inviteUri
Trip invite code: $inviteLink
Participant name: $participantName

Open Travelly, go to "Join Trip", and paste this invite link or code. Use the participant name above while joining.
''';
  }

  String _buildGenericInviteMessage(String inviteLink) {
    final inviteUri = Uri(
      scheme: 'travelly',
      host: 'join',
      queryParameters: {
        'inviteLink': inviteLink,
      },
    ).toString();

    return '''
Join my Travelly trip.

Invite link: $inviteUri
Trip invite code: $inviteLink

Open Travelly, go to "Join Trip", and paste this invite link or code.
''';
  }

  Future<void> _copyInviteText(
    String inviteText, {
    required String successMessage,
  }) async {
    await Clipboard.setData(ClipboardData(text: inviteText));
    if (!mounted) return;
    _showSnackBar(successMessage, isError: false);
  }

  Future<void> _shareInvite(String inviteText) async {
    try {
      final smsUri = Uri(
        scheme: 'sms',
        queryParameters: {
          'body': inviteText,
        },
      );

      final launched = await launchUrl(smsUri);
      if (launched) {
        return;
      }
    } catch (_) {}

    if (!mounted) return;
    await _copyInviteText(
      inviteText,
      successMessage: 'Invite copied. Share it in any app.',
    );
  }

  String? _validateName(String value) {
    if (value.trim().isEmpty) {
      return 'Participant name is required';
    }
    if (value.trim().length < 2) {
      return 'Enter a valid participant name';
    }
    return null;
  }

  String? _validatePhone(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) {
      return 'Phone number is required';
    }
    if (digits.length < 10 || digits.length > 13) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String _formatError(Object error) {
    var message = error.toString();
    if (message.startsWith('Exception: ')) {
      message = message.substring('Exception: '.length);
    }

    message = message.replaceFirst('Failed to add members: ', '');
    message = message.replaceFirst('Failed to add member: ', '');
    message = message.replaceFirst('Failed to remove member: ', '');
    message = message.replaceFirst('Failed to load trip: ', '');

    final apiExceptionMatch = RegExp(r'ApiException\(\d+\):\s*(.*)').firstMatch(message);
    if (apiExceptionMatch != null) {
      return apiExceptionMatch.group(1) ?? message;
    }

    return message;
  }

  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontFamily: 'Nunito'),
        ),
        behavior: SnackBarBehavior.floating,
        backgroundColor: isError ? const Color(0xFFD1475E) : const Color(0xFF2EB867),
      ),
    );
  }

  Color _avatarColorFor(String seed) {
    const palette = [
      Color(0xFF8E1C2E),
      Color(0xFF4A6670),
      Color(0xFF516A79),
      Color(0xFF3F51B5),
      Color(0xFF2E7D6B),
      Color(0xFF6D4C41),
    ];

    final hash = seed.codeUnits.fold<int>(0, (value, unit) => value + unit);
    return palette[hash % palette.length];
  }
}
