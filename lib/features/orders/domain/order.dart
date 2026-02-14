class Order {
  final String id;
  final String customerName;
  final String status;
  final double total;
  final DateTime createdAt;

  final List<Map<String, dynamic>> items; 
  final List<Map<String, dynamic>> modifiers; 
  final double subtotal;
  final double discount;
  final double tip;
  final String notes;

  Order({
    required this.id,
    required this.customerName,
    required this.status,
    required this.total,
    required this.createdAt,
    this.items = const [],
    this.modifiers = const [],
    this.subtotal = 0.0,
    this.discount = 0.0,
    this.tip = 0.0,
    this.notes = '',
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'customerName': customerName,
        'status': status,
        'total': total,
        'createdAt': createdAt.toIso8601String(),
        'items': items,
        'modifiers': modifiers,
        'subtotal': subtotal,
        'discount': discount,
        'tip': tip,
        'notes': notes,
      };

  factory Order.fromMap(Map<String, dynamic> map) => Order(
        id: map['id'],
        customerName: map['customerName'],
        status: map['status'],
        total: map['total'],
        createdAt: DateTime.parse(map['createdAt']),
        items: List<Map<String, dynamic>>.from(map['items'] ?? []),
        modifiers: List<Map<String, dynamic>>.from(map['modifiers'] ?? []),
        subtotal: (map['subtotal'] ?? 0.0).toDouble(),
        discount: (map['discount'] ?? 0.0).toDouble(),
        tip: (map['tip'] ?? 0.0).toDouble(),
        notes: map['notes'] ?? '',
      );


  Order copyWith({
    String? id,
    String? customerName,
    String? status,
    double? total,
    DateTime? createdAt,
    List<Map<String, dynamic>>? items,
    List<Map<String, dynamic>>? modifiers,
    double? subtotal,
    double? discount,
    double? tip,
    String? notes,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      status: status ?? this.status,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      items: items ?? this.items,
      modifiers: modifiers ?? this.modifiers,
      subtotal: subtotal ?? this.subtotal,
      discount: discount ?? this.discount,
      tip: tip ?? this.tip,
      notes: notes ?? this.notes,
    );
  }
}
