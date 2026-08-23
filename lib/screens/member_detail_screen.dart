import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart' as db;
import '../models/member.dart';
import '../models/app_transaction.dart';

class MemberDetailScreen extends StatefulWidget {
  final int memberId;

  const MemberDetailScreen({super.key, required this.memberId});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  Member? _member;
  List<AppTransaction> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final member = await db.DataService.instance.readMember(widget.memberId);
      final transactions = await db.DataService.instance.readMemberTransactions(widget.memberId);
      setState(() {
        _member = member;
        _transactions = transactions;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _showRechargeDialog() async {
    final amountController = TextEditingController();
    final remarkController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('充值'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '充值金额'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('确认')),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text) ?? 0;
      final remark = remarkController.text.isEmpty ? null : remarkController.text;

      if (amount > 0) {
        await db.DataService.instance.recharge(widget.memberId, amount, pointsRate: 1, remark: remark);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('充值成功')),
          );
        }
      }
    }
  }

  Future<void> _showConsumeDialog() async {
    final amountController = TextEditingController();
    final remarkController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('消费'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: amountController,
              decoration: const InputDecoration(labelText: '消费金额'),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
            ),
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('确认')),
        ],
      ),
    );

    if (result == true) {
      final amount = double.tryParse(amountController.text) ?? 0;
      final remark = remarkController.text.isEmpty ? null : remarkController.text;

      if (amount > 0) {
        await db.DataService.instance.consume(widget.memberId, amount, remark: remark);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('消费记录成功')),
          );
        }
      }
    }
  }

  Future<void> _showExchangeDialog() async {
    final pointsController = TextEditingController();
    final remarkController = TextEditingController();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('积分兑换'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('当前积分: ${_member?.points ?? 0}'),
            TextField(
              controller: pointsController,
              decoration: const InputDecoration(labelText: '兑换积分'),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: remarkController,
              decoration: const InputDecoration(labelText: '备注'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('确认')),
        ],
      ),
    );

    if (result == true) {
      final points = int.tryParse(pointsController.text) ?? 0;
      final remark = remarkController.text.isEmpty ? null : remarkController.text;

      if (points > 0 && points <= (_member?.points ?? 0)) {
        await db.DataService.instance.exchangePoints(widget.memberId, points, remark: remark);
        _loadData();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('积分兑换成功')),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('积分不足')),
          );
        }
      }
    }
  }

  Future<void> _deleteMember() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除会员 "${_member?.name}" 吗？'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('取消')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('删除'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await db.DataService.instance.deleteMember(widget.memberId);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('会员已删除')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_member?.name ?? '会员详情'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(icon: const Icon(Icons.delete), onPressed: _deleteMember),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _member == null
              ? const Center(child: Text('会员不存在'))
              : Column(
                  children: [
                    Card(
                      margin: const EdgeInsets.all(16),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 30,
                                  child: Text(_member!.name[0], style: const TextStyle(fontSize: 24)),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(_member!.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                                      if (_member!.phone != null)
                                        Text(_member!.phone!, style: const TextStyle(color: Colors.grey)),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Divider(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Column(
                                  children: [
                                    const Text('余额', style: TextStyle(color: Colors.grey)),
                                    Text('¥${_member!.balance.toStringAsFixed(2)}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.green)),
                                  ],
                                ),
                                Column(
                                  children: [
                                    const Text('积分', style: TextStyle(color: Colors.grey)),
                                    Text('${_member!.points}',
                                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.orange)),
                                  ],
                                ),
                              ],
                            ),
                            if (_member!.remark != null) ...[
                              const Divider(height: 24),
                              Text('备注: ${_member!.remark}'),
                            ],
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showRechargeDialog,
                              icon: const Icon(Icons.add),
                              label: const Text('充值'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showConsumeDialog,
                              icon: const Icon(Icons.remove),
                              label: const Text('消费'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.orange),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: _showExchangeDialog,
                              icon: const Icon(Icons.card_giftcard),
                              label: const Text('兑换'),
                              style: ElevatedButton.styleFrom(backgroundColor: Colors.purple),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    Expanded(
                      child: _transactions.isEmpty
                          ? const Center(child: Text('暂无交易记录'))
                          : ListView.builder(
                              itemCount: _transactions.length,
                              itemBuilder: (context, index) {
                                final t = _transactions[index];
                                Color color;
                                switch (t.type) {
                                  case TransactionType.recharge:
                                    color = Colors.green;
                                    break;
                                  case TransactionType.consume:
                                    color = Colors.red;
                                    break;
                                  case TransactionType.pointsExchange:
                                    color = Colors.purple;
                                    break;
                                }
                                return ListTile(
                                  leading: CircleAvatar(
                                    backgroundColor: color.withOpacity(0.2),
                                    child: Icon(
                                      t.type == TransactionType.recharge
                                          ? Icons.add
                                          : t.type == TransactionType.consume
                                              ? Icons.remove
                                              : Icons.card_giftcard,
                                      color: color,
                                    ),
                                  ),
                                  title: Text(t.typeText),
                                  subtitle: Text(DateFormat('yyyy-MM-dd HH:mm').format(t.createdAt)),
                                  trailing: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('¥${t.amount.toStringAsFixed(2)}',
                                          style: TextStyle(color: color, fontWeight: FontWeight.bold)),
                                      if (t.pointsChange != 0)
                                        Text('积分 ${t.pointsChange > 0 ? '+' : ''}${t.pointsChange}',
                                            style: const TextStyle(fontSize: 12)),
                                    ],
                                  ),
                                );
                              },
                            ),
                    ),
                  ],
                ),
    );
  }
}
