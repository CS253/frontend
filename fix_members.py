import re

with open("lib/features/trip_settings/presentation/screens/manage_members_screen.dart", "r") as f:
    content = f.read()

# 1. Add Member struct and change to StatefulWidget
header_replacement = """import 'package:flutter/material.dart';

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
  Widget build(BuildContext context) {"""

content = re.sub(r"import 'package:flutter/material\.dart';\s*class ManageMembersScreen extends StatelessWidget \{\s*const ManageMembersScreen\(\{super\.key\}\);\s*@override\s*Widget build\(BuildContext context\) \{", header_replacement, content)

# 2. Replace the hardcoded body list with mapping over members list
children_start = content.find("_buildMembersHeader(context),")
children_end = content.find("const SizedBox(height: 80),", children_start)

new_children = """_buildMembersHeader(context),
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
              )).toList(),
              """
content = content[:children_start] + new_children + content[children_end:]


# Update members count text
content = re.sub(r"'MEMBERS \(5\)'", r"'MEMBERS (${members.length})'", content)

# 3. Add `member` param to widget builders
content = content.replace("Widget _buildAdminCard({", "Widget _buildAdminCard({\n    required Member member,")
content = content.replace("Widget _buildMemberCard({", "Widget _buildMemberCard({\n    required Member member,")

# Update onPressed of `Icon(Icons.more_vert)`
content = re.sub(r"onPressed: \(\) => _showMemberOptions\(context\),", r"onPressed: () => _showMemberOptions(context, member),", content)

# 4. _showMemberOptions updates
content = content.replace("void _showMemberOptions(BuildContext context) {", "void _showMemberOptions(BuildContext context, Member member) {")
content = content.replace("_showPendingPaymentsAlert(context);", "_showPendingPaymentsAlert(context, member);")

# 5. _showPendingPaymentsAlert updates
content = content.replace("void _showPendingPaymentsAlert(BuildContext context) {", "void _showPendingPaymentsAlert(BuildContext context, Member member) {")

# 6. Remove the Owes 2,450 text entirely and use member.name/imageUrl
content = re.sub(
    r"const CircleAvatar\(\s*radius: 16,\s*backgroundImage: NetworkImage\(\s*'https://ui-avatars\.com/api/\?name=Marcus\+Johnson&background=8E8E8E&color=fff',\s*\),\s*\),",
    r"CircleAvatar(radius: 16, backgroundImage: NetworkImage(member.imageUrl)),",
    content
)

content = re.sub(
    r"Text\(\s*'Marcus Johnson',\s*style: TextStyle\(\s*fontSize: 13,\s*fontWeight: FontWeight\.bold,\s*fontFamily: 'Nunito',\s*color: Color\(0xFF1F242E\),\s*\),\s*\),",
    r"Text(member.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold, fontFamily: 'Nunito', color: Color(0xFF1F242E))),",
    content
)

# Remove the entire Text.rich block for 'Owes 2,450'
# We will just remove it using a regex or simple split.
text_rich_regex = r"Text\.rich\(\s*TextSpan\(\s*text: 'Owes '.*?\]\s*,\s*\)\s*,\s*\),"
content = re.sub(text_rich_regex, "", content, flags=re.DOTALL)

# Replace 'Remove Anyway' functionality
remove_anyway_btn = r"onPressed: \(\) => Navigator\.pop\(context\),\s*icon: const Icon\(\s*Icons\.delete_outline,\s*color: Color\(0xFFD1475E\),\s*size: 16,\s*\),\s*label: const Text\(\s*'Remove Anyway'"

handle_remove_str = r"""onPressed: () => _handleRemoveMember(member),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFD1475E),
                      size: 16,
                    ),
                    label: const Text(
                      'Remove Anyway'"""
content = re.sub(remove_anyway_btn, handle_remove_str, content)

# Remove enum MemberStatusType at the bottom (we added it to top)
content = re.sub(r"enum MemberStatusType \{ settled, owes, gets \}", "", content)

# Add _handleRemoveMember to the class
handle_remove_method = """  Future<void> _handleRemoveMember(Member member) async {
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
      Navigator.pop(context); // close pending payments alert
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
"""
content = content[:content.rfind("}")] + handle_remove_method

with open("lib/features/trip_settings/presentation/screens/manage_members_screen.dart", "w") as f:
    f.write(content)

