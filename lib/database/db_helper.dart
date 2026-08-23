import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/member.dart';
import '../models/app_transaction.dart';

class DataService {
  static final DataService instance = DataService._init();
  DataService._init();

  static const String _membersKey = 'members';
  static const String _transactionsKey = 'transactions';

  // Member CRUD
  Future<int> createMember(Member member) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await readAllMembers();
    
    int newId = 1;
    if (members.isNotEmpty) {
      newId = members.map((m) => m.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    
    final newMember = member.copyWith(id: newId);
    members.add(newMember);
    
    await prefs.setString(_membersKey, jsonEncode(members.map((m) => m.toMap()).toList()));
    return newId;
  }

  Future<Member?> readMember(int id) async {
    final members = await readAllMembers();
    try {
      return members.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Member>> readAllMembers() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_membersKey);
    
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => Member.fromMap(json)).toList();
  }

  Future<int> updateMember(Member member) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await readAllMembers();
    
    final index = members.indexWhere((m) => m.id == member.id);
    if (index != -1) {
      members[index] = member;
      await prefs.setString(_membersKey, jsonEncode(members.map((m) => m.toMap()).toList()));
    }
    return 1;
  }

  Future<int> deleteMember(int id) async {
    final prefs = await SharedPreferences.getInstance();
    final members = await readAllMembers();
    
    members.removeWhere((m) => m.id == id);
    await prefs.setString(_membersKey, jsonEncode(members.map((m) => m.toMap()).toList()));
    
    // 同时删除相关交易记录
    final transactions = await readAllTransactions();
    transactions.removeWhere((t) => t.memberId == id);
    await prefs.setString(_transactionsKey, jsonEncode(transactions.map((t) => t.toMap()).toList()));
    
    return 1;
  }

  // Transaction CRUD
  Future<int> createTransaction(AppTransaction transaction) async {
    final prefs = await SharedPreferences.getInstance();
    final transactions = await readAllTransactions();
    
    int newId = 1;
    if (transactions.isNotEmpty) {
      newId = transactions.map((t) => t.id ?? 0).reduce((a, b) => a > b ? a : b) + 1;
    }
    
    final newTransaction = AppTransaction(
      id: newId,
      memberId: transaction.memberId,
      type: transaction.type,
      amount: transaction.amount,
      pointsChange: transaction.pointsChange,
      remark: transaction.remark,
      createdAt: transaction.createdAt,
    );
    
    transactions.add(newTransaction);
    await prefs.setString(_transactionsKey, jsonEncode(transactions.map((t) => t.toMap()).toList()));
    return newId;
  }

  Future<List<AppTransaction>> readMemberTransactions(int memberId) async {
    final transactions = await readAllTransactions();
    return transactions.where((t) => t.memberId == memberId).toList();
  }

  Future<List<AppTransaction>> readAllTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final String? data = prefs.getString(_transactionsKey);
    
    if (data == null) return [];
    
    final List<dynamic> jsonList = jsonDecode(data);
    return jsonList.map((json) => AppTransaction.fromMap(json)).toList();
  }

  // 业务操作
  Future<void> recharge(int memberId, double amount, {int pointsRate = 10, String? remark}) async {
    final member = await readMember(memberId);
    if (member == null) return;
    final points = (amount * pointsRate).toInt();
    
    await updateMember(member.copyWith(
      balance: member.balance + amount,
      points: member.points + points,
    ));
    
    await createTransaction(AppTransaction(
      memberId: memberId,
      type: TransactionType.recharge,
      amount: amount,
      pointsChange: points,
      remark: remark,
    ));
  }

  Future<void> consume(int memberId, double amount, {String? remark}) async {
    final member = await readMember(memberId);
    if (member == null) return;
    
    await updateMember(member.copyWith(
      balance: member.balance - amount,
    ));
    
    await createTransaction(AppTransaction(
      memberId: memberId,
      type: TransactionType.consume,
      amount: amount,
      pointsChange: 0,
      remark: remark,
    ));
  }

  Future<void> exchangePoints(int memberId, int points, {String? remark}) async {
    final member = await readMember(memberId);
    if (member == null) return;
    
    await updateMember(member.copyWith(
      points: member.points - points,
    ));
    
    await createTransaction(AppTransaction(
      memberId: memberId,
      type: TransactionType.pointsExchange,
      amount: 0,
      pointsChange: -points,
      remark: remark,
    ));
  }
}
