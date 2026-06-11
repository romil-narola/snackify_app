import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class OrderEvent extends Equatable {
  const OrderEvent();
  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  final String userId;
  const LoadOrders(this.userId);
  @override
  List<Object?> get props => [userId];
}

class PlaceOrder extends OrderEvent {
  final List<CartItem> items;
  final double totalAmount;
  final String remarks;
  final String? status;
  const PlaceOrder({
    required this.items,
    required this.totalAmount,
    required this.remarks,
    this.status,
  });
  @override
  List<Object?> get props => [items, totalAmount, remarks, status];
}

class SubmitDraftOrder extends OrderEvent {
  final String orderId;
  const SubmitDraftOrder(this.orderId);
  @override
  List<Object?> get props => [orderId];
}

// --- States ---
abstract class OrderState extends Equatable {
  const OrderState();
  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrdersLoaded extends OrderState {
  final List<OrderModel> orders;
  const OrdersLoaded(this.orders);
  @override
  List<Object?> get props => [orders];
}

class OrderPlaceSuccess extends OrderState {}

class OrderOperationError extends OrderState {
  final String message;
  const OrderOperationError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository orderRepository;
  final AuthRepository authRepository;
  StreamSubscription? _orderSubscription;

  OrderBloc({required this.orderRepository, required this.authRepository})
    : super(OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<PlaceOrder>(_onPlaceOrder);
    on<SubmitDraftOrder>(_onSubmitDraftOrder);
    on<_OrdersDataReceived>(_onOrdersUpdated);
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) {
    emit(OrderLoading());
    _orderSubscription?.cancel();
    _orderSubscription = orderRepository
        .getOrders(employeeId: event.userId)
        .listen((orders) {
          if (!isClosed) {
            add(_OrdersDataReceived(orders));
          }
        });
  }

  void _onOrdersUpdated(_OrdersDataReceived event, Emitter<OrderState> emit) {
    emit(OrdersLoaded(event.orders));
  }

  Future<void> _onPlaceOrder(PlaceOrder event, Emitter<OrderState> emit) async {
    emit(OrderLoading());
    try {
      final db = MockDatabase();
      if (!db.isOrderingOpen()) {
        emit(
          OrderOperationError(
            'Ordering is closed. Ordering hours: ${db.orderStartTime} to ${db.orderCutoffTime}.',
          ),
        );
        return;
      }
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(
          const OrderOperationError('User session expired. Pls login again.'),
        );
        return;
      }

      final orderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final status = event.status ?? (db.isStatusWise ? 'pending' : 'completed');
      final newOrder = OrderModel(
        id: orderId,
        employeeId: user.uid,
        employeeName: user.name,
        items: event.items,
        totalAmount: event.totalAmount,
        status: status,
        orderDate: DateTime.now(),
        remarks: event.remarks,
      );

      await orderRepository.createOrder(newOrder);
      emit(OrderPlaceSuccess());

      // Reload orders
      add(LoadOrders(user.uid));
    } catch (e) {
      emit(OrderOperationError(e.toString()));
    }
  }

  Future<void> _onSubmitDraftOrder(
    SubmitDraftOrder event,
    Emitter<OrderState> emit,
  ) async {
    emit(OrderLoading());
    try {
      final db = MockDatabase();
      final targetStatus = db.isStatusWise ? 'pending' : 'completed';
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(
          const OrderOperationError('User session expired. Pls login again.'),
        );
        return;
      }
      await orderRepository.updateOrderStatus(
        event.orderId,
        targetStatus,
        approvedBy: db.isStatusWise ? '' : 'System Auto-Approval',
        remarks: 'Submitted from draft.',
      );
      emit(OrderPlaceSuccess());
      add(LoadOrders(user.uid));
    } catch (e) {
      emit(OrderOperationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }
}

// Internal action to feed stream updates
class _OrdersDataReceived extends OrderEvent {
  final List<OrderModel> orders;
  const _OrdersDataReceived(this.orders);
  @override
  List<Object?> get props => [orders];
}
