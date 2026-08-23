enum TransactionType {
  recharge,
  consume,
  pointsExchange,
}

class AppTransaction {
  final int? id;
  final int memberId;
  final TransactionType type;
  final double amount;
  final int pointsChange;
  final String? remark;
  final DateTime createdAt;

  AppTransaction({
    this.id,
    required this.memberId,
    required this.type,
    required this.amount,
    this.pointsChange = 0,
    this.remark,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memberId': memberId,
      'type': type.index,
      'amount': amount,
      'pointsChange': pointsChange,
      'remark': remark,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory AppTransaction.fromMap(Map<String, dynamic> map) {
    return AppTransaction(
      id: map['id'] as int?,
      memberId: map['memberId'] as int,
      type: TransactionType.values[map['type'] as int],
      amount: map['amount'] as double,
      pointsChange: map['pointsChange'] as int,
      remark: map['remark'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
    );
  }

  String get typeText {
    switch (type) {
      case TransactionType.recharge:
        return '充值';
      case TransactionType.consume:
        return '消费';
      case TransactionType.pointsExchange:
        return '积分兑换';
    }
  }
}
