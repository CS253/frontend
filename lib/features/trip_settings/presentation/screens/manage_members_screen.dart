import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:travelly/features/trips/data/models/member_model.dart';
import 'package:travelly/features/trips/presentation/providers/trips_provider.dart';
import 'package:travelly/core/utils/initials_util.dart';


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
      context.read<TripsProvider>().loadMembers(widget.tripId);
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
                        onPressed: () => tripsProvider.loadMembers(widget.tripId),
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
              onRefresh: () => tripsProvider.loadMembers(widget.tripId),
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                children: [
                  _buildMembersHeader(context, members.length),
                  const SizedBox(height: 12),
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
                            'Add a traveller by phone number to bring them into this trip.',
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
                        child: _buildMemberCard(context, member),
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

  Widget _buildMemberCard(BuildContext context, MemberModel member) {
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
            onPressed: () => _showMemberOptions(context, member),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    final phoneController = TextEditingController();
    String? errorText;

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
                    'Enter the phone number of the person you want to add to this trip.',
                    style: TextStyle(
                      fontSize: 13,
                      fontFamily: 'Nunito',
                      color: Color(0xFF737B8C),
                    ),
                  ),
                  const SizedBox(height: 20),
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
                        errorText = _validatePhone(value);
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
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
                      prefixIcon: const Icon(
                        Icons.phone_outlined,
                        color: Color(0xFF8B8893),
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
                    ),
                  ),
                  const SizedBox(height: 24),
                  Consumer<TripsProvider>(
                    builder: (context, tripsProvider, _) {
                      return ElevatedButton(
                        onPressed: tripsProvider.isUpdatingMembers
                            ? null
                            : () async {
                                final phone = phoneController.text.trim();
                                final validation = _validatePhone(phone);
                                if (validation != null) {
                                  setSheetState(() {
                                    errorText = validation;
                                  });
                                  return;
                                }

                                try {
                                  await context.read<TripsProvider>().addMember(
                                        tripId: widget.tripId,
                                        phone: phone,
                                      );

                                  if (!mounted) return;
                                  // ignore: use_build_context_synchronously
                                  Navigator.pop(sheetContext);
                                  _showSnackBar(
                                    'Member added successfully',
                                    isError: false,
                                  );
                                } catch (error) {
                                  setSheetState(() {
                                    errorText = _formatError(error);
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

  void _showMemberOptions(BuildContext context, MemberModel member) {
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
              const SizedBox(height: 28),
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
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      Navigator.pop(sheetContext);
                      await _handleRemoveMember(member);
                    },
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD1475E),
                      size: 20,
                    ),
                    label: Text(
                      member.pending ? 'Remove Invite' : 'Remove from Trip',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Color(0xFFD1475E),
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFDE8E8),
                      minimumSize: const Size(double.infinity, 64),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 0,
                    ),
                  ),
                ),
              const SizedBox(height: 40),
            ],
          ),
        ),
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
