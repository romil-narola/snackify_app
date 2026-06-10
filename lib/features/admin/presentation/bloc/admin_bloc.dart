import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class AdminEvent extends Equatable {
  const AdminEvent();
  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminEvent {}

class AdminAddSnack extends AdminEvent {
  final SnackModel snack;
  const AdminAddSnack(this.snack);
  @override
  List<Object?> get props => [snack];
}

class AdminUpdateSnack extends AdminEvent {
  final SnackModel snack;
  const AdminUpdateSnack(this.snack);
  @override
  List<Object?> get props => [snack];
}

class AdminDeleteSnack extends AdminEvent {
  final String id;
  const AdminDeleteSnack(this.id);
  @override
  List<Object?> get props => [id];
}

class AdminUpdateOrderStatus extends AdminEvent {
  final String orderId;
  final String status;
  final String remarks;
  const AdminUpdateOrderStatus({
    required this.orderId,
    required this.status,
    this.remarks = '',
  });
  @override
  List<Object?> get props => [orderId, status, remarks];
}

class AdminToggleEmployeeActive extends AdminEvent {
  final String uid;
  final bool isActive;
  const AdminToggleEmployeeActive(this.uid, this.isActive);
  @override
  List<Object?> get props => [uid, isActive];
}

class LoadReports extends AdminEvent {
  final String range; // 'daily', 'weekly', 'monthly'
  const LoadReports(this.range);
  @override
  List<Object?> get props => [range];
}

// --- States ---
abstract class AdminState extends Equatable {
  const AdminState();
  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {}

class AdminLoading extends AdminState {}

class AdminDashboardLoaded extends AdminState {
  final List<SnackModel> snacks;
  final List<OrderModel> orders;
  final List<UserModel> employees;
  final double totalRevenue;
  final int pendingOrdersCount;
  final int completedOrdersCount;

  const AdminDashboardLoaded({
    required this.snacks,
    required this.orders,
    required this.employees,
    required this.totalRevenue,
    required this.pendingOrdersCount,
    required this.completedOrdersCount,
  });

  @override
  List<Object?> get props => [
    snacks,
    orders,
    employees,
    totalRevenue,
    pendingOrdersCount,
    completedOrdersCount,
  ];
}

class ReportLoaded extends AdminState {
  final String range;
  final List<double> chartData;
  final Map<String, double> categorySales;
  final int totalOrdersCount;
  final double totalSalesAmount;

  const ReportLoaded({
    required this.range,
    required this.chartData,
    required this.categorySales,
    required this.totalOrdersCount,
    required this.totalSalesAmount,
  });

  @override
  List<Object?> get props => [
    range,
    chartData,
    categorySales,
    totalOrdersCount,
    totalSalesAmount,
  ];
}

class AdminActionSuccess extends AdminState {}

class AdminError extends AdminState {
  final String message;
  const AdminError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final SnackRepository snackRepository;
  final OrderRepository orderRepository;
  final EmployeeRepository employeeRepository;

  StreamSubscription? _snackSub;
  StreamSubscription? _orderSub;
  StreamSubscription? _employeeSub;

  List<SnackModel> _cachedSnacks = [];
  List<OrderModel> _cachedOrders = [];
  List<UserModel> _cachedEmployees = [];

  AdminBloc({
    required this.snackRepository,
    required this.orderRepository,
    required this.employeeRepository,
  }) : super(AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadAdminDashboard);
    on<AdminAddSnack>(_onAdminAddSnack);
    on<AdminUpdateSnack>(_onAdminUpdateSnack);
    on<AdminDeleteSnack>(_onAdminDeleteSnack);
    on<AdminUpdateOrderStatus>(_onAdminUpdateOrderStatus);
    on<AdminToggleEmployeeActive>(_onAdminToggleEmployeeActive);
    on<LoadReports>(_onLoadReports);
    on(_onDashboardDataRefreshed);
  }

  void _onLoadAdminDashboard(
    LoadAdminDashboard event,
    Emitter<AdminState> emit,
  ) {
    emit(AdminLoading());
    _snackSub?.cancel();
    _orderSub?.cancel();
    _employeeSub?.cancel();

    // Set up synchronized reactive streams for real time admin panels
    _snackSub = snackRepository.getSnacks().listen((snacks) {
      _cachedSnacks = snacks;
      _checkAndEmitDashboard();
    });

    _orderSub = orderRepository.getOrders().listen((orders) {
      _cachedOrders = orders;
      _checkAndEmitDashboard();
    });

    _employeeSub = employeeRepository.getEmployees().listen((employees) {
      _cachedEmployees = employees;
      _checkAndEmitDashboard();
    });
  }

  void _checkAndEmitDashboard() {
    if (!isClosed) {
      add(
        _AdminDashboardUpdated(
          snacks: _cachedSnacks,
          orders: _cachedOrders,
          employees: _cachedEmployees,
        ),
      );
    }
  }

  void _onDashboardDataRefreshed(
    _AdminDashboardUpdated event,
    Emitter<AdminState> emit,
  ) {
    double revenue = 0.0;
    int pending = 0;
    int completed = 0;

    for (var o in event.orders) {
      if (o.status == 'completed') {
        revenue += o.totalAmount;
        completed++;
      } else if (o.status == 'pending') {
        pending++;
      }
    }

    emit(
      AdminDashboardLoaded(
        snacks: event.snacks,
        orders: event.orders,
        employees: event.employees,
        totalRevenue: revenue,
        pendingOrdersCount: pending,
        completedOrdersCount: completed,
      ),
    );
  }

  Future<void> _onAdminAddSnack(
    AdminAddSnack event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await snackRepository.addSnack(event.snack);
      emit(AdminActionSuccess());
      add(LoadAdminDashboard());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAdminUpdateSnack(
    AdminUpdateSnack event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await snackRepository.updateSnack(event.snack);
      emit(AdminActionSuccess());
      add(LoadAdminDashboard());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAdminDeleteSnack(
    AdminDeleteSnack event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await snackRepository.deleteSnack(event.id);
      emit(AdminActionSuccess());
      add(LoadAdminDashboard());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAdminUpdateOrderStatus(
    AdminUpdateOrderStatus event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await orderRepository.updateOrderStatus(
        event.orderId,
        event.status,
        approvedBy: 'Admin',
        remarks: event.remarks,
      );
      emit(AdminActionSuccess());
      add(LoadAdminDashboard());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  Future<void> _onAdminToggleEmployeeActive(
    AdminToggleEmployeeActive event,
    Emitter<AdminState> emit,
  ) async {
    emit(AdminLoading());
    try {
      await employeeRepository.toggleEmployeeActive(event.uid, event.isActive);
      emit(AdminActionSuccess());
      add(LoadAdminDashboard());
    } catch (e) {
      emit(AdminError(e.toString()));
    }
  }

  void _onLoadReports(LoadReports event, Emitter<AdminState> emit) {
    emit(AdminLoading());
    // Simulate analytics values based on range selection
    int salesCount = _cachedOrders.where((o) => o.status == 'completed').length;
    double salesAmt = 0.0;
    for (var o in _cachedOrders) {
      if (o.status == 'completed') salesAmt += o.totalAmount;
    }

    List<double> chartValues = [];
    Map<String, double> categorySales = {};

    if (event.range == 'daily') {
      chartValues = [12, 19, 3, 5, 2, 3, 10]; // Sales hours
      categorySales = {
        'Tea': 12.0,
        'Coffee': 28.5,
        'Snacks': 18.0,
        'Sandwiches': 45.0,
      };
    } else if (event.range == 'weekly') {
      chartValues = [120, 150, 180, 220, 190, 240, 290]; // Sales per day
      categorySales = {
        'Tea': 98.0,
        'Coffee': 210.0,
        'Snacks': 140.0,
        'Sandwiches': 310.0,
        'Beverages': 75.0,
      };
    } else {
      chartValues = [800, 1200, 1400, 1800, 2200, 2600]; // Sales per month
      categorySales = {
        'Tea': 450.0,
        'Coffee': 980.0,
        'Snacks': 620.0,
        'Sandwiches': 1200.0,
        'Beverages': 340.0,
        'Desserts': 510.0,
      };
    }

    emit(
      ReportLoaded(
        range: event.range,
        chartData: chartValues,
        categorySales: categorySales,
        totalOrdersCount: salesCount == 0 ? 15 : salesCount,
        totalSalesAmount: salesAmt == 0 ? 128.50 : salesAmt,
      ),
    );
  }

  @override
  Future<void> close() {
    _snackSub?.cancel();
    _orderSub?.cancel();
    _employeeSub?.cancel();
    return super.close();
  }
}

// Internal dashboard streams update notifier
class _AdminDashboardUpdated extends AdminEvent {
  final List<SnackModel> snacks;
  final List<OrderModel> orders;
  final List<UserModel> employees;

  const _AdminDashboardUpdated({
    required this.snacks,
    required this.orders,
    required this.employees,
  });

  @override
  List<Object?> get props => [snacks, orders, employees];
}
