import '../core/common_imports.dart';

abstract class AuthRepository {
  Future<UserModel?> login(String email, String password);
  Future<void> logout();
  Future<UserModel?> getCurrentUser();
  Future<void> sendPasswordReset(String email);
  Future<void> changePassword(String currentPassword, String newPassword);
}

abstract class SnackRepository {
  Stream<List<SnackModel>> getSnacks();
  Future<void> addSnack(SnackModel snack);
  Future<void> updateSnack(SnackModel snack);
  Future<void> deleteSnack(String id);
}

abstract class OrderRepository {
  Stream<List<OrderModel>> getOrders({String? employeeId});
  Future<void> createOrder(OrderModel order);
  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    String approvedBy = '',
    String remarks = '',
  });
}

abstract class NotificationRepository {
  Stream<List<NotificationModel>> getNotifications(String userId);
  Future<void> markAsRead(String notificationId);
  Future<void> deleteNotification(String notificationId);
}

abstract class EmployeeRepository {
  Stream<List<UserModel>> getEmployees();
  Future<void> toggleEmployeeActive(String uid, bool isActive);
}
