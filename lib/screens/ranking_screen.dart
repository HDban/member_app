import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart' as db;
import '../models/member.dart';
import 'member_detail_screen.dart';

class RankingScreen extends StatefulWidget {
  const RankingScreen({super.key});

  @override
  State<RankingScreen> createState() => _RankingScreenState();
}

class _RankingScreenState extends State<RankingScreen> {
  List<Member> _members = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  Future<void> _loadRanking() async {
    setState(() => _isLoading = true);
    final members = await db.DataService.instance.readAllMembers();
    // 按积分降序排列
    members.sort((a, b) => b.points.compareTo(a.points));
    setState(() {
      _members = members;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('积分排名'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _members.isEmpty
              ? const Center(child: Text('暂无会员数据'))
              : ListView.builder(
                  itemCount: _members.length,
                  itemBuilder: (context, index) {
                    final member = _members[index];
                    final rank = index + 1;
                    
                    // 前三名特殊样式
                    Color? medalColor;
                    IconData? medalIcon;
                    if (rank == 1) {
                      medalColor = Colors.amber;
                      medalIcon = Icons.emoji_events;
                    } else if (rank == 2) {
                      medalColor = Colors.grey;
                      medalIcon = Icons.emoji_events;
                    } else if (rank == 3) {
                      medalColor = Colors.brown;
                      medalIcon = Icons.emoji_events;
                    }

                    return ListTile(
                      leading: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: medalColor?.withOpacity(0.2) ?? Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: medalIcon != null
                              ? Icon(medalIcon, color: medalColor, size: 24)
                              : Text(
                                  '$rank',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue[700],
                                  ),
                                ),
                        ),
                      ),
                      title: Text(member.name),
                      subtitle: Text('余额: ¥${member.balance.toStringAsFixed(2)}'),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${member.points}',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                          const Text('积分', style: TextStyle(fontSize: 12, color: Colors.grey)),
                        ],
                      ),
                      onTap: () async {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MemberDetailScreen(memberId: member.id!),
                          ),
                        );
                        _loadRanking();
                      },
                    );
                  },
                ),
    );
  }
}
