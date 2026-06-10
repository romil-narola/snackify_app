import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../core/common_imports.dart';

class FirebaseAuthService implements AuthRepository {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<UserModel?> login(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (credential.user != null) {
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      if (doc.exists) {
        final user = UserModel.fromMap(doc.data()!);
        if (!user.isActive) {
          await logout();
          throw Exception('Account is deactivated. Contact Admin.');
        }
        return user;
      }
    }
    return null;
  }

  @override
  Future<void> logout() async {
    await _auth.signOut();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
    }
    return null;
  }

  @override
  Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    final user = _auth.currentUser;
    if (user != null && user.email != null) {
      // Re-authenticate
      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(newPassword);
    }
  }
}

class FirebaseSnackService implements SnackRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<SnackModel>> getSnacks() {
    return _firestore
        .collection('snacks')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => SnackModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> addSnack(SnackModel snack) async {
    await _firestore.collection('snacks').doc(snack.id).set(snack.toMap());
  }

  @override
  Future<void> updateSnack(SnackModel snack) async {
    await _firestore.collection('snacks').doc(snack.id).update(snack.toMap());
  }

  @override
  Future<void> deleteSnack(String id) async {
    await _firestore.collection('snacks').doc(id).delete();
  }
}

class FirebaseOrderService implements OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<OrderModel>> getOrders({String? employeeId}) {
    Query query = _firestore
        .collection('orders')
        .orderBy('orderDate', descending: true);
    if (employeeId != null) {
      query = query.where('employeeId', isEqualTo: employeeId);
    }
    return query.snapshots().map(
      (snapshot) => snapshot.docs
          .map((doc) => OrderModel.fromMap(doc.data() as Map<String, dynamic>))
          .toList(),
    );
  }

  @override
  Future<void> createOrder(OrderModel order) async {
    await _firestore.collection('orders').doc(order.id).set(order.toMap());
  }

  @override
  Future<void> updateOrderStatus(
    String orderId,
    String status, {
    String approvedBy = '',
    String remarks = '',
  }) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'approvedBy': approvedBy,
      'remarks': remarks,
    });
  }
}

class FirebaseNotificationService implements NotificationRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).update({
      'isRead': true,
    });
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await _firestore.collection('notifications').doc(notificationId).delete();
  }
}

class FirebaseEmployeeService implements EmployeeRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Stream<List<UserModel>> getEmployees() {
    return _firestore
        .collection('users')
        .where('role', isEqualTo: 'employee')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => UserModel.fromMap(doc.data()))
              .toList(),
        );
  }

  @override
  Future<void> toggleEmployeeActive(String uid, bool isActive) async {
    await _firestore.collection('users').doc(uid).update({
      'isActive': isActive,
    });
  }
}
