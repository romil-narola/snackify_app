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
  StreamSubscription? _snackSubscription;
  StreamSubscription? _orderSubscription;
  String? _currentUserId;

  DashboardBloc({required this.snackRepository, required this.orderRepository})
    : super(DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  void _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) {
    emit(DashboardLoading());
    _currentUserId = event.userId;

    _snackSubscription?.cancel();
    _orderSubscription?.cancel();

    // Setup streams to load dashboard data interactively
    _snackSubscription = snackRepository.getSnacks().listen((snacks) {
      _orderSubscription = orderRepository
          .getOrders(employeeId: _currentUserId)
          .listen((orders) {
            // Compute lists
            final popular = snacks
                .where((s) => s.rating >= 4.7 && s.available)
                .toList();
            final recommended = snacks.where((s) => s.available).toList()
              ..shuffle();
            final recent = orders.take(3).toList();

            if (!isClosed) {
              add(
                _DashboardDataUpdated(
                  popular: popular,
                  recommended: recommended.take(4).toList(),
                  recent: recent,
                ),
              );
            }
          });
    });

    on<_DashboardDataUpdated>((event, emit) {
      emit(
        DashboardLoaded(
          popularSnacks: event.popular,
          recommendedSnacks: event.recommended,
          recentOrders: event.recent,
        ),
      );
    });
  }

  @override
  Future<void> close() {
    _snackSubscription?.cancel();
    _orderSubscription?.cancel();
    return super.close();
  }
}

// Internal private event to feed updates from streams
class _DashboardDataUpdated extends DashboardEvent {
  final List<SnackModel> popular;
  final List<SnackModel> recommended;
  final List<OrderModel> recent;

  const _DashboardDataUpdated({
    required this.popular,
    required this.recommended,
    required this.recent,
  });

  @override
  List<Object?> get props => [popular, recommended, recent];
}
