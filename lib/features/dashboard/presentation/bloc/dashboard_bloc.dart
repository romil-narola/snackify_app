import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class DashboardEvent extends Equatable {
  const DashboardEvent();
  @override
  List<Object?> get props => [];
}

class LoadDashboard extends DashboardEvent {
  final String userId;
  const LoadDashboard(this.userId);
  @override
  List<Object?> get props => [userId];
}

// --- States ---
abstract class DashboardState extends Equatable {
  const DashboardState();
  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {}

class DashboardLoading extends DashboardState {}

class DashboardLoaded extends DashboardState {
  final List<SnackModel> popularSnacks;
  final List<SnackModel> recommendedSnacks;
  final List<OrderModel> recentOrders;

  const DashboardLoaded({
    required this.popularSnacks,
    required this.recommendedSnacks,
    required this.recentOrders,
  });

  @override
  List<Object?> get props => [popularSnacks, recommendedSnacks, recentOrders];
}

class DashboardError extends DashboardState {
  final String message;
  const DashboardError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final SnackRepository snackRepository;
  final OrderRepository orderRepository;

  DashboardBloc({required this.snackRepository, required this.orderRepository})
    : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<DashboardState> emit,
  ) async {
    emit(DashboardLoading());

    try {
      // Fetch snacks once as a future by taking the first emission
      final snacks = await snackRepository.getSnacks().first;

      // Compute popular and recommended from the snack list
      final popular = snacks.where((s) => s.rating >= 4.7 && s.available).toList();
      final recommended = snacks.where((s) => s.available).toList()..shuffle();

      // Now listen to the orders stream and emit state on every update
      await emit.forEach<List<OrderModel>>(
        orderRepository.getOrders(employeeId: event.userId),
        onData: (orders) {
          final recent = orders.take(3).toList();
          return DashboardLoaded(
            popularSnacks: popular,
            recommendedSnacks: recommended.take(4).toList(),
            recentOrders: recent,
          );
        },
        onError: (error, stackTrace) {
          return DashboardError(error.toString());
        },
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
