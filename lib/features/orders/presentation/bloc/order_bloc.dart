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
  const PlaceOrder({
    required this.items,
    required this.totalAmount,
    required this.remarks,
  });
  @override
  List<Object?> get props => [items, totalAmount, remarks];
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
    on(_onOrdersUpdated);
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
      final user = await authRepository.getCurrentUser();
      if (user == null) {
        emit(
          const OrderOperationError('User session expired. Pls login again.'),
        );
        return;
      }

      final orderId =
          'ORD-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      final newOrder = OrderModel(
        id: orderId,
        employeeId: user.uid,
        employeeName: user.name,
        items: event.items,
        totalAmount: event.totalAmount,
        status: 'pending',
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
