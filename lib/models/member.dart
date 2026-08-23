class Member {
  final int? id;
  final String name;
  final String? phone;
  final String? level;
  final double balance;
  final int points;
  final DateTime createdAt;
  final String? remark;

  Member({
    this.id,
    required this.name,
    this.phone,
    this.level,
    this.balance = 0,
    this.points = 0,
    DateTime? createdAt,
    this.remark,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'level': level,
      'balance': balance,
      'points': points,
      'createdAt': createdAt.toIso8601String(),
      'remark': remark,
    };
  }

  factory Member.fromMap(Map<String, dynamic> map) {
    return Member(
      id: map['id'] as int?,
      name: map['name'] as String,
      phone: map['phone'] as String?,
      level: map['level'] as String?,
      balance: map['balance'] as double,
      points: map['points'] as int,
      createdAt: DateTime.parse(map['createdAt'] as String),
      remark: map['remark'] as String?,
    );
  }

  Member copyWith({
    int? id,
    String? name,
    String? phone,
    String? level,
    double? balance,
    int? points,
    DateTime? createdAt,
    String? remark,
  }) {
    return Member(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      level: level ?? this.level,
      balance: balance ?? this.balance,
      points: points ?? this.points,
      createdAt: createdAt ?? this.createdAt,
      remark: remark ?? this.remark,
    );
  }
}
