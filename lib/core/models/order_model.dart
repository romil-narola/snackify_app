import 'package:equatable/equatable.dart';
import 'snack_model.dart';

class CartItem extends Equatable {
  final SnackModel snack;
  final int quantity;

  const CartItem({required this.snack, required this.quantity});

  CartItem copyWith({SnackModel? snack, int? quantity}) {
    return CartItem(
      snack: snack ?? this.snack,
      quantity: quantity ?? this.quantity,
    );
  }

  double get totalPrice => snack.price * quantity;

  Map<String, dynamic> toMap() {
    return {'snack': snack.toMap(), 'quantity': quantity};
  }

  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      snack: SnackModel.fromMap(map['snack']),
      quantity: map['quantity'] ?? 1,
    );
  }

  @override
  List<Object?> get props => [snack, quantity];
}

class OrderModel extends Equatable {
  final String id;
  final String employeeId;
  final String employeeName;
  final List<CartItem> items;
  final double totalAmount;
  final String
  status; // 'pending', 'approved', 'preparing', 'ready', 'completed', 'rejected'
  final DateTime orderDate;
  final String approvedBy;
  final String remarks;

  const OrderModel({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.items,
    required this.totalAmount,
    required this.status,
    required this.orderDate,
    this.approvedBy = '',
    this.remarks = '',
  });

  OrderModel copyWith({
    String? id,
    String? employeeId,
    String? employeeName,
    List<CartItem>? items,
    double? totalAmount,
    String? status,
    DateTime? orderDate,
    String? approvedBy,
    String? remarks,
  }) {
    return OrderModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeName: employeeName ?? this.employeeName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      orderDate: orderDate ?? this.orderDate,
      approvedBy: approvedBy ?? this.approvedBy,
      remarks: remarks ?? this.remarks,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeName': employeeName,
      'items': items.map((item) => item.toMap()).toList(),
      'totalAmount': totalAmount,
      'status': status,
      'orderDate': orderDate.toIso8601String(),
      'approvedBy': approvedBy,
      'remarks': remarks,
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    return OrderModel(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeName: map['employeeName'] ?? '',
      items:
          (map['items'] as List<dynamic>?)
              ?.map((item) => CartItem.fromMap(item as Map<String, dynamic>))
              .toList() ??
          [],
      totalAmount: (map['totalAmount'] as num?)?.toDouble() ?? 0.0,
      status: map['status'] ?? 'pending',
      orderDate: map['orderDate'] != null
          ? DateTime.parse(map['orderDate'])
          : DateTime.now(),
      approvedBy: map['approvedBy'] ?? '',
      remarks: map['remarks'] ?? '',
    );
  }

  @override
  List<Object?> get props => [
    id,
    employeeId,
    employeeName,
    items,
    totalAmount,
    status,
    orderDate,
    approvedBy,
    remarks,
  ];
}
