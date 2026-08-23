import 'package:flutter/material.dart';
import 'package:csv/csv.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';
import '../database/db_helper.dart';
import '../models/member.dart';
import '../models/app_transaction.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({super.key});

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  bool _exportMembers = true;
  bool _exportTransactions = true;
  bool _isExporting = false;

  Future<void> _exportData() async {
    if (!_exportMembers && !_exportTransactions) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请至少选择一个导出项')),
      );
      return;
    }

    setState(() => _isExporting = true);

    try {
      final dataService = DataService.instance;
      final dateFormat = DateFormat('yyyy-MM-dd HH:mm:ss');
      final now = DateTime.now();
      final fileName = 'member_data_${DateFormat('yyyyMMdd_HHmmss').format(now)}';

      String csvContent = '';

      // 导出会员数据
      if (_exportMembers) {
        final members = await dataService.readAllMembers();
        csvContent += '===== 会员数据 =====\n';
        csvContent += const ListToCsvConverter().convert([
          ['ID', '姓名', '手机号', '余额', '积分', '创建时间', '备注'],
          ...members.map((m) => [
            m.id,
            m.name,
            m.phone ?? '',
            m.balance.toStringAsFixed(2),
            m.points,
            dateFormat.format(m.createdAt),
            m.remark ?? '',
          ]),
        ]);
        csvContent += '\n\n';
      }

      // 导出交易数据
      if (_exportTransactions) {
        final transactions = await dataService.readAllTransactions();
        final members = await dataService.readAllMembers();
        
        // 创建会员ID到姓名的映射
        final memberMap = {for (var m in members) m.id: m.name};
        
        csvContent += '===== 交易记录 =====\n';
        csvContent += const ListToCsvConverter().convert([
          ['ID', '会员ID', '会员姓名', '类型', '金额', '积分变化', '备注', '时间'],
          ...transactions.map((t) => [
            t.id,
            t.memberId,
            memberMap[t.memberId] ?? '未知',
            _getTypeName(t.type),
            t.amount > 0 ? t.amount.toStringAsFixed(2) : '',
            t.pointsChange != 0 ? t.pointsChange.toString() : '',
            t.remark ?? '',
            dateFormat.format(t.createdAt),
          ]),
        ]);
        csvContent += '\n\n';
      }

      // 添加统计汇总
      csvContent += '===== 数据汇总 =====\n';
      final members = await dataService.readAllMembers();
      final transactions = await dataService.readAllTransactions();
      
      final totalBalance = members.fold<double>(0, (sum, m) => sum + m.balance);
      final totalPoints = members.fold<int>(0, (sum, m) => sum + m.points);
      final totalRecharge = transactions
          .where((t) => t.type == TransactionType.recharge)
          .fold<double>(0, (sum, t) => sum + t.amount);
      final totalConsume = transactions
          .where((t) => t.type == TransactionType.consume)
          .fold<double>(0, (sum, t) => sum + t.amount);
      
      csvContent += const ListToCsvConverter().convert([
        ['总会员数', members.length.toString()],
        ['总余额', totalBalance.toStringAsFixed(2)],
        ['总积分', totalPoints.toString()],
        ['总充值', totalRecharge.toStringAsFixed(2)],
        ['总消费', totalConsume.toStringAsFixed(2)],
        ['导出时间', dateFormat.format(now)],
      ]);

      // 分享文件
      await Share.share(
        '$csvContent\n\n---\n导出时间: ${dateFormat.format(now)}',
        subject: '$fileName.csv',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('导出成功！')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('导出失败: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isExporting = false);
      }
    }
  }

  String _getTypeName(TransactionType type) {
    switch (type) {
      case TransactionType.recharge:
        return '充值';
      case TransactionType.consume:
        return '消费';
      case TransactionType.pointsExchange:
        return '积分兑换';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('数据导出'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '选择要导出的数据',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    title: const Text('会员数据'),
                    subtitle: const Text('包含所有会员的基本信息'),
                    value: _exportMembers,
                    onChanged: (value) {
                      setState(() => _exportMembers = value ?? false);
                    },
                  ),
                  const Divider(height: 1),
                  CheckboxListTile(
                    title: const Text('交易记录'),
                    subtitle: const Text('包含所有充值、消费、积分兑换记录'),
                    value: _exportTransactions,
                    onChanged: (value) {
                      setState(() => _exportTransactions = value ?? false);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '💡 导出说明',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('• 导出格式为CSV，可用Excel直接打开'),
                  Text('• 包含数据汇总统计'),
                  Text('• 导出后可分享到微信/邮件/文件'),
                  Text('• 交易记录会关联显示会员姓名'),
                ],
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                onPressed: _isExporting ? null : _exportData,
                icon: _isExporting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.download),
                label: Text(_isExporting ? '导出中...' : '导出数据'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).primaryColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
