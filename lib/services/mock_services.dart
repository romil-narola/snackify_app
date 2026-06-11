import 'dart:async';
import '../core/common_imports.dart';

class MockAuthService implements AuthRepository {
  final MockDatabase _db = MockDatabase();

  @override
  Future<UserModel?> login(String email, String password) async {
    await Future.delayed(const Duration(milliseconds: 600)); // Simulate latency

    // Find matching user
    final user = _db.users.firstWhere(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
      orElse: () => throw Exception('User not found'),
    );

    if (password != 'password123') {
      throw Exception('Invalid password');
    }

    if (!user.isActive) {
      throw Exception('Account deactivated. Contact Admin.');
    }

    _db.currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    _db.currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _db.currentUser;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final exists = _db.users.any(
      (u) => u.email.toLowerCase() == email.toLowerCase(),
    );
    if (!exists) {
      throw Exception('Email address not registered');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    await Future.delayed(const Duration(milliseconds: 400));
    if (currentPassword != 'password123') {
      throw Exception('Incorrect current password');
    }
  }
}

class MockSnackService implements SnackRepository {
  final MockDatabase _db = MockDatabase();
  final _controller = StreamController<List<SnackModel>>.broadcast();

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_db.snacks));
    }
  }

  @override
  Stream<List<SnackModel>> getSnacks() {
    // Re-emit immediately so new subscribers never miss the current state
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> addSnack(SnackModel snack) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.snacks.add(snack);
    _emit();
  }

  @override
  Future<void> updateSnack(SnackModel snack) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _db.snacks.indexWhere((s) => s.id == snack.id);
    if (index != -1) {
      _db.snacks[index] = snack;
      _emit();
    }
  }

  @override
  Future<void> deleteSnack(String id) async {
    await Future.delayed(const Duration(milliseconds: 300));
    _db.snacks.removeWhere((s) => s.id == id);
    _emit();
  }
}

class MockOrderService implements OrderRepository {
  final MockDatabase _db = MockDatabase();
  final _controller = StreamController<List<OrderModel>>.broadcast();

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_db.orders));
    }
  }

  @override
  Stream<List<OrderModel>> getOrders({String? employeeId}) {
    // Re-emit immediately so new subscribers never miss the current state
    Future.microtask(_emit);
    if (employeeId != null) {
      return _controller.stream.map((list) {
        final filtered = list.where((o) => o.employeeId == employeeId).toList();
        filtered.sort((a, b) => b.orderDate.compareTo(a.orderDate));
        return filtered;
      });
    }
    return _controller.stream.map((list) {
      final sorted = List<OrderModel>.from(list);
      sorted.sort((a, b) => b.orderDate.compareTo(a.orderDate));
      return sorted;
    });
  }

  @override
  Future<void> createOrder(OrderModel order) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _db.orders.insert(0, order);
    _emit();

    // Auto-create a mock notification for the employee
    final isDraft = order.status.toLowerCase() == 'draft';
    final isCompleted = order.status.toLowerCase() == 'completed';
    final notification = NotificationModel(
      id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
      userId: order.employeeId,
      title: isDraft
          ? 'Draft Saved 📝'
          : isCompleted
              ? 'Order Completed! 🎉'
              : 'Order Placed Successfully!',
      message: isDraft
          ? 'Your order request has been saved as a draft.'
          : isCompleted
              ? 'Your order was successfully completed directly.'
              : 'Your order has been placed. Status: Pending approval.',
      isRead: false,
      createdAt: DateTime.now(),
    );
    _db.notifications.insert(0, notification);
    MockNotificationService.instance?.notify(notification);
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    String approvedBy = '',
    String remarks = '',
  }) async {
    await Future.delayed(const Duration(milliseconds: 400));
    final index = _db.orders.indexWhere((o) => o.id == orderId);
    if (index != -1) {
      final oldOrder = _db.orders[index];
      final newOrder = oldOrder.copyWith(
        status: status,
        approvedBy: approvedBy,
        remarks: remarks,
      );
      _db.orders[index] = newOrder;
      _emit();

      // Trigger user notification
      final notification = NotificationModel(
        id: 'notif-${DateTime.now().millisecondsSinceEpoch}',
        userId: oldOrder.employeeId,
        title: 'Order Status Update',
        message: 'Your order ${oldOrder.id} is now "$status".',
        isRead: false,
        createdAt: DateTime.now(),
      );
      _db.notifications.insert(0, notification);
      MockNotificationService.instance?.notify(notification);
    }
  }
}

class MockNotificationService implements NotificationRepository {
  final MockDatabase _db = MockDatabase();
  final _controller = StreamController<List<NotificationModel>>.broadcast();
  static MockNotificationService? instance;

  MockNotificationService() {
    instance = this;
  }

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_db.notifications));
    }
  }

  void notify(NotificationModel notif) {
    _emit();
  }

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    // Re-emit immediately so new subscribers never miss the current state
    Future.microtask(_emit);
    return _controller.stream.map(
      (list) => list.where((n) => n.userId == userId).toList(),
    );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final index = _db.notifications.indexWhere((n) => n.id == notificationId);
    if (index != -1) {
      _db.notifications[index] = _db.notifications[index].copyWith(
        isRead: true,
      );
      _emit();
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    _db.notifications.removeWhere((n) => n.id == notificationId);
    _emit();
  }
}

class MockEmployeeService implements EmployeeRepository {
  final MockDatabase _db = MockDatabase();
  final _controller = StreamController<List<UserModel>>.broadcast();

  void _emit() {
    if (!_controller.isClosed) {
      _controller.add(List.unmodifiable(_db.users));
    }
  }

  @override
  Stream<List<UserModel>> getEmployees() {
    // Re-emit immediately so new subscribers never miss the current state
    Future.microtask(_emit);
    return _controller.stream;
  }

  @override
  Future<void> toggleEmployeeActive(String uid, bool isActive) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final index = _db.users.indexWhere((u) => u.uid == uid);
    if (index != -1) {
      _db.users[index] = _db.users[index].copyWith(isActive: isActive);
      _emit();
    }
  }
}
