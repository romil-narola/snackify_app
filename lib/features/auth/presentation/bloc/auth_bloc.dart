import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';

// --- Events ---
abstract class AuthEvent extends Equatable {
  const AuthEvent();
  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {}

class LoginSubmitted extends AuthEvent {
  final String email;
  final String password;
  const LoginSubmitted(this.email, this.password);
  @override
  List<Object?> get props => [email, password];
}

class LogoutRequested extends AuthEvent {}

class PasswordResetRequested extends AuthEvent {
  final String email;
  const PasswordResetRequested(this.email);
  @override
  List<Object?> get props => [email];
}

class PasswordChangeRequested extends AuthEvent {
  final String currentPassword;
  final String newPassword;
  const PasswordChangeRequested(this.currentPassword, this.newPassword);
  @override
  List<Object?> get props => [currentPassword, newPassword];
}

// --- States ---
abstract class AuthState extends Equatable {
  const AuthState();
  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class Authenticated extends AuthState {
  final UserModel user;
  const Authenticated(this.user);
  @override
  List<Object?> get props => [user];
}

class Unauthenticated extends AuthState {}

class AuthFailure extends AuthState {
  final String message;
  const AuthFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordResetSuccess extends AuthState {}

class PasswordResetFailure extends AuthState {
  final String message;
  const PasswordResetFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class PasswordChangeSuccess extends AuthState {}

class PasswordChangeFailure extends AuthState {
  final String message;
  const PasswordChangeFailure(this.message);
  @override
  List<Object?> get props => [message];
}

// --- BLoC ---
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;

  AuthBloc({required this.authRepository}) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LogoutRequested>(_onLogoutRequested);
    on<PasswordResetRequested>(_onPasswordResetRequested);
    on<PasswordChangeRequested>(_onPasswordChangeRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(Unauthenticated());
      }
    } catch (_) {
      emit(Unauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final user = await authRepository.login(event.email, event.password);
      if (user != null) {
        emit(Authenticated(user));
      } else {
        emit(const AuthFailure('Authentication failed.'));
      }
    } catch (e) {
      emit(AuthFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    await authRepository.logout();
    emit(Unauthenticated());
  }

  Future<void> _onPasswordResetRequested(
    PasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.sendPasswordReset(event.email);
      emit(PasswordResetSuccess());
    } catch (e) {
      emit(PasswordResetFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }

  Future<void> _onPasswordChangeRequested(
    PasswordChangeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      await authRepository.changePassword(
        event.currentPassword,
        event.newPassword,
      );
      emit(PasswordChangeSuccess());
      // Re-fetch current user to maintain state
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        emit(Authenticated(user));
      }
    } catch (e) {
      emit(PasswordChangeFailure(e.toString().replaceAll('Exception: ', '')));
    }
  }
}
