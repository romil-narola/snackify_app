import 'dart:async';
import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class NotificationEvent extends Equatable {
  const NotificationEvent();
  @override
  List<Object?> get props => [];
}

class LoadNotifications extends NotificationEvent {
  final String userId;
  const LoadNotifications(this.userId);
  @override
  List<Object?> get props => [userId];
}

class MarkNotificationAsRead extends NotificationEvent {
  final String id;
  const MarkNotificationAsRead(this.id);
  @override
  List<Object?> get props => [id];
}

class RemoveNotification extends NotificationEvent {
  final String id;
  const RemoveNotification(this.id);
  @override
  List<Object?> get props => [id];
}

// --- States ---
abstract class NotificationState extends Equatable {
  const NotificationState();
  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationsLoaded extends NotificationState {
  final List<NotificationModel> notifications;
  const NotificationsLoaded(this.notifications);
  @override
  List<Object?> get props => [notifications];
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class NotificationBloc extends Bloc<NotificationEvent, NotificationState> {
  final NotificationRepository notificationRepository;
  final AuthRepository authRepository;
  StreamSubscription? _subscription;

  NotificationBloc({
    required this.notificationRepository,
    required this.authRepository,
  }) : super(NotificationInitial()) {
    on<LoadNotifications>(_onLoadNotifications);
    on<MarkNotificationAsRead>(_onMarkNotificationAsRead);
    on<RemoveNotification>(_onRemoveNotification);
    on(_onNotificationsDataReceived);
  }

  void _onLoadNotifications(
    LoadNotifications event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationLoading());
    _subscription?.cancel();
    _subscription = notificationRepository
        .getNotifications(event.userId)
        .listen((notifs) {
          if (!isClosed) {
            add(_NotificationsUpdated(notifs));
          }
        });
  }

  void _onNotificationsDataReceived(
    _NotificationsUpdated event,
    Emitter<NotificationState> emit,
  ) {
    emit(NotificationsLoaded(event.notifications));
  }

  Future<void> _onMarkNotificationAsRead(
    MarkNotificationAsRead event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationRepository.markAsRead(event.id);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  Future<void> _onRemoveNotification(
    RemoveNotification event,
    Emitter<NotificationState> emit,
  ) async {
    try {
      await notificationRepository.deleteNotification(event.id);
    } catch (e) {
      emit(NotificationError(e.toString()));
    }
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}

// Internal private stream update event
class _NotificationsUpdated extends NotificationEvent {
  final List<NotificationModel> notifications;
  const _NotificationsUpdated(this.notifications);
  @override
  List<Object?> get props => [notifications];
}
