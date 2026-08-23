import 'package:flutter/material.dart';
import '../database/db_helper.dart' as db;
import '../models/member.dart';
import 'add_member_screen.dart';
import 'member_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Member> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  Future<void> _loadMembers() async {
    setState(() => _isLoading = true);
    final members = await db.DataService.instance.readAllMembers();
    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  void _navigateToAddMember() async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddMemberScreen()),
    );
    _loadMembers();
  }

  void _navigateToMemberDetail(Member member) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => MemberDetailScreen(memberId: member.id!),
      ),
    );
    _loadMembers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('会员管理'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(
                  child: Text('暂无会员\n点击右下角 + 添加', textAlign: TextAlign.center),
                )
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    return ListTile(
                      leading: CircleAvatar(
                        child: Text(member.name[0]),
                      ),
                      title: Text(member.name),
                      subtitle: Text(
                        '余额: ¥${member.balance.toStringAsFixed(2)} | 积分: ${member.points}',
                      ),
                      trailing: member.phone != null ? Text(member.phone!) : null,
                      onTap: () => _navigateToMemberDetail(member),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMember,
        child: const Icon(Icons.add),
      ),
    );
  }
}
