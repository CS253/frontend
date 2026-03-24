import 'package:flutter/material.dart';

enum MemberStatusType { settled, owes, gets }

class Member {
  final String name;
  final String imageUrl;
  final String? statusText;
  final MemberStatusType statusType;
  final bool isSettled;
  final bool isAdmin;

  Member({
    required this.name,
    required this.imageUrl,
    this.statusText,
    required this.statusType,
    this.isSettled = false,
    this.isAdmin = false,
  });
}

class ManageMembersScreen extends StatefulWidget {
  const ManageMembersScreen({super.key});

  @override
  State<ManageMembersScreen> createState() => _ManageMembersScreenState();
}

class _ManageMembersScreenState extends State<ManageMembersScreen> {
  List<Member> members = [
    Member(
      name: 'Sarah Chen',
      imageUrl: 'https://ui-avatars.com/api/?name=Sarah+Chen&background=8E1C2E&color=fff',
      isSettled: true,
      statusType: MemberStatusType.settled,
      isAdmin: true,
    ),
    Member(
      name: 'Marcus Johnson',
      imageUrl: 'https://ui-avatars.com/api/?name=Marcus+Johnson&background=8E8E8E&color=fff',
      statusText: 'Owes ₹600',
      statusType: MemberStatusType.owes,
    ),
    Member(
      name: 'Sanket',
      imageUrl: 'https://ui-avatars.com/api/?name=Sanket&background=4A6670&color=fff',
      statusText: 'Gets ₹1,200',
      statusType: MemberStatusType.gets,
    ),
    Member(
      name: 'David Park',
      imageUrl: 'https://ui-avatars.com/api/?name=David+Park&background=516A79&color=fff',
      isSettled: true,
      statusType: MemberStatusType.settled,
    ),
    Member(
      name: 'Priya Sharma',
      imageUrl: 'https://ui-avatars.com/api/?name=Priya+Sharma&background=3F51B5&color=fff',
      statusText: 'Owes ₹200',
      statusType: MemberStatusType.owes,
    ),
    Member(
      name: 'Ronit Kumar',
      imageUrl: 'https://ui-avatars.com/api/?name=Ronit+Kumar&background=3F51B5&color=fff',
      statusText: 'Owes ₹400',
      statusType: MemberStatusType.owes,
    ),
  ];

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildMembersHeader(context),
              const SizedBox(height: 12),
              ...members.map((m) => Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: m.isAdmin
                    ? _buildAdminCard(
                        context: context,
                        name: m.name,
                        imageUrl: m.imageUrl,
                        isSettled: m.isSettled,
                        member: m,
                      )
                    : _buildMemberCard(
                        context: context,
                        name: m.name,
                        imageUrl: m.imageUrl,
                        statusText: m.statusText,
                        statusType: m.statusType,
                        isSettled: m.isSettled,
                        member: m,
                      ),
              )),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMembersHeader(BuildContext context) {
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
              'MEMBERS (${members.length})',
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

  Widget _buildAdminCard({
    required Member member,
    required BuildContext context,
    required String name,
    required String imageUrl,
    required bool isSettled,
  }) {
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
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F242E),
              ),
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

  Widget _buildMemberCard({
    required Member member,
    required BuildContext context,
    required String name,
    required String imageUrl,
    String? statusText,
    bool isSettled = false,
    required MemberStatusType statusType,
  }) {
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
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1F242E),
              ),
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
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
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
                    maxLength: 10,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: Color(0xFF1F242E),
                    ),
                    onChanged: (value) {
                      setSheetState(() {
                        if (value.isNotEmpty &&
                            !RegExp(r'^\d+$').hasMatch(value)) {
                          errorText = 'Invalid number';
                        } else if (value.length > 10) {
                          errorText = 'Invalid number';
                        } else {
                          errorText = null;
                        }
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Phone Number',
                      counterText: '',
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
                  ElevatedButton(
                    onPressed: () {
                      final phone = phoneController.text.trim();
                      if (phone.isEmpty ||
                          !RegExp(r'^\d{10}$').hasMatch(phone)) {
                        setSheetState(() {
                          errorText = 'Invalid number';
                        });
                        return;
                      }
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Member added successfully',
                            style: TextStyle(fontFamily: 'Nunito'),
                          ),
                          behavior: SnackBarBehavior.floating,
                          backgroundColor: Color(0xFF2EB867),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CB4E6),
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Add Member',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
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

  void _showMemberOptions(BuildContext context, Member member) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
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
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _handleRemoveMember(member);
                  },
                  icon: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFFD1475E),
                    size: 20,
                  ),
                  label: const Text(
                    'Remove from Trip',
                    style: TextStyle(
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
              const SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleRemoveMember(Member member) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    await Future.delayed(const Duration(seconds: 1));
    if (!mounted) return;
    Navigator.pop(context); // close loading indicator

    if (member.statusType == MemberStatusType.settled) {
      setState(() {
        members.removeWhere((m) => m.name == member.name);
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Member removed successfully', style: TextStyle(fontFamily: 'Nunito')),
          backgroundColor: Color(0xFF2EB867),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } else {
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cannot remove. Total owes must be 0.', style: TextStyle(fontFamily: 'Nunito')),
          backgroundColor: Color(0xFFD1475E),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
