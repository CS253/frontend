import 'package:flutter/material.dart';

class ManageMembersScreen extends StatelessWidget {
  const ManageMembersScreen({super.key});

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
              _buildAdminCard(
                context: context,
                name: 'Sarah Chen',
                imageUrl:
                    'https://ui-avatars.com/api/?name=Sarah+Chen&background=8E1C2E&color=fff',
                isSettled: true,
              ),
              const SizedBox(height: 8),
              _buildMemberCard(
                context: context,
                name: 'Marcus Johnson',
                imageUrl:
                    'https://ui-avatars.com/api/?name=Marcus+Johnson&background=8E8E8E&color=fff',
                statusText: 'Owes ₹600',
                statusType: MemberStatusType.owes,
              ),
              const SizedBox(height: 8),
              _buildMemberCard(
                context: context,
                name: 'Sanket',
                imageUrl:
                    'https://ui-avatars.com/api/?name=Sanket&background=4A6670&color=fff',
                statusText: 'Gets ₹1,200',
                statusType: MemberStatusType.gets,
              ),
              const SizedBox(height: 8),
              _buildMemberCard(
                context: context,
                name: 'David Park',
                imageUrl:
                    'https://ui-avatars.com/api/?name=David+Park&background=516A79&color=fff',
                isSettled: true,
                statusType: MemberStatusType.settled,
              ),
              const SizedBox(height: 8),
              _buildMemberCard(
                context: context,
                name: 'Priya Sharma',
                imageUrl:
                    'https://ui-avatars.com/api/?name=Priya+Sharma&background=3F51B5&color=fff',
                statusText: 'Owes ₹200',
                statusType: MemberStatusType.owes,
              ),
              const SizedBox(height: 8),
              _buildMemberCard(
                context: context,
                name: 'Ronit Kumar',
                imageUrl:
                    'https://ui-avatars.com/api/?name=Ronit+Kumar&background=3F51B5&color=fff',
                statusText: 'Owes ₹400',
                statusType: MemberStatusType.owes,
              ),
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
            const Text(
              'MEMBERS (5)',
              style: TextStyle(
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
    required BuildContext context,
    required String name,
    required String imageUrl,
    required bool isSettled,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF6CB4E6).withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6CB4E6).withValues(alpha: 0.2),
          width: 0.8,
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(radius: 18, backgroundImage: NetworkImage(imageUrl)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1F242E),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6CB4E6).withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_user_outlined,
                            color: Color(0xFF6CB4E6),
                            size: 10,
                          ),
                          const SizedBox(width: 2),
                          const Text(
                            'Admin',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6CB4E6),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                if (isSettled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBFAF1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Settled',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2EB867),
                      ),
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
            onPressed: () => _showMemberOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  Widget _buildMemberCard({
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F242E),
                  ),
                ),
                const SizedBox(height: 4),
                if (statusType == MemberStatusType.settled)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEBFAF1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      'Settled',
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF2EB867),
                      ),
                    ),
                  )
                else
                  Row(
                    children: [
                      if (statusType == MemberStatusType.owes)
                        const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFD1475E),
                          size: 12,
                        ),
                      if (statusType == MemberStatusType.owes)
                        const SizedBox(width: 4),
                      Text(
                        statusText ?? '',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusType == MemberStatusType.owes
                              ? const Color(0xFFD1475E)
                              : const Color(0xFF2EB867),
                        ),
                      ),
                    ],
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
            onPressed: () => _showMemberOptions(context),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }

  void _showAddMemberSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Padding(
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
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    color: Color(0xFF1F242E),
                  ),
                  decoration: InputDecoration(
                    hintText: 'Phone Number',
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
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
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
    );
  }

  void _showMemberOptions(BuildContext context) {
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
                  _showPendingPaymentsAlert(context);
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

  void _showPendingPaymentsAlert(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.8),
      builder: (context) => Dialog(
        backgroundColor: const Color(0xFFFBFAF9),
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFFE5E7EB), width: 0.8),
        ),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF4E7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.warning_amber_rounded,
                          color: Color(0xFFF4A02A),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pending Payments Alert',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Nunito',
                                color: Color(0xFF1F242E),
                              ),
                            ),
                            Text(
                              'This member has unsettled expenses',
                              style: TextStyle(
                                fontSize: 11,
                                fontFamily: 'Nunito',
                                color: Color(0xFF737B8C),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F2F4).withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const CircleAvatar(
                              radius: 16,
                              backgroundImage: NetworkImage(
                                'https://ui-avatars.com/api/?name=Marcus+Johnson&background=8E8E8E&color=fff',
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Marcus Johnson',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.bold,
                                      fontFamily: 'Nunito',
                                      color: Color(0xFF1F242E),
                                    ),
                                  ),
                                  Text.rich(
                                    TextSpan(
                                      text: 'Owes ',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontFamily: 'Nunito',
                                        color: Color(0xFF737B8C),
                                      ),
                                      children: [
                                        TextSpan(
                                          text: '₹2,450',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xFFD1475E),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const Divider(height: 1, color: Color(0xFFE2E4E9)),
                        const SizedBox(height: 10),
                        const Text(
                          'Pending with:',
                          style: TextStyle(
                            fontSize: 10,
                            fontFamily: 'Nunito',
                            color: Color(0xFF737B8C),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            _buildPendingWithChip('Sarah Chen'),
                            const SizedBox(width: 8),
                            _buildPendingWithChip('Emma Wilson'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.sync, color: Colors.white, size: 16),
                    label: const Text(
                      'Settle Payments',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Colors.white,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6CB4E6),
                      minimumSize: const Size(double.infinity, 36),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                      elevation: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  OutlinedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD1475E),
                      size: 16,
                    ),
                    label: const Text(
                      'Remove Anyway',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Color(0xFFD1475E),
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 36),
                      side: const BorderSide(color: Color(0xFFFDE8E8)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(11),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Nunito',
                        color: Color(0xFF1F242E),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              top: 12,
              right: 12,
              child: IconButton(
                icon: const Icon(
                  Icons.close,
                  color: Color(0xFF737B8C),
                  size: 16,
                ),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPendingWithChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E4E9), width: 0.8),
      ),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 11,
          fontFamily: 'Nunito',
          color: Color(0xFF1F242E),
        ),
      ),
    );
  }
}

enum MemberStatusType { settled, owes, gets }
