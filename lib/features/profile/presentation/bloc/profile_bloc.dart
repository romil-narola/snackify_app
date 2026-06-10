import 'package:equatable/equatable.dart';
import '../../../../core/common_imports.dart';
import '../../../../core/mock/mock_database.dart';

// --- Events ---
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {}

class ToggleTheme extends ProfileEvent {}

class UpdateProfileDetails extends ProfileEvent {
  final String name;
  final String phone;
  const UpdateProfileDetails({required this.name, required this.phone});
  @override
  List<Object?> get props => [name, phone];
}

// --- States ---
class ProfileState extends Equatable {
  final bool isDark;
  final bool isLoading;
  final UserModel? user;
  final String? error;
  final bool updateSuccess;

  const ProfileState({
    this.isDark = false,
    this.isLoading = false,
    this.user,
    this.error,
    this.updateSuccess = false,
  });

  ProfileState copyWith({
    bool? isDark,
    bool? isLoading,
    UserModel? user,
    String? error,
    bool? updateSuccess,
  }) {
    return ProfileState(
      isDark: isDark ?? this.isDark,
      isLoading: isLoading ?? this.isLoading,
      user: user ?? this.user,
      error: error ?? this.error,
      updateSuccess: updateSuccess ?? this.updateSuccess,
    );
  }

  @override
  List<Object?> get props => [isDark, isLoading, user, error, updateSuccess];
}

// --- BLoC ---
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  final AuthRepository authRepository;
  final MockDatabase _db =
      MockDatabase(); // To persist theme preference locally in mock mode

  ProfileBloc({required this.authRepository}) : super(const ProfileState()) {
    on<LoadProfile>(_onLoadProfile);
    on<ToggleTheme>(_onToggleTheme);
    on<UpdateProfileDetails>(_onUpdateProfileDetails);
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    final user = await authRepository.getCurrentUser();
    emit(state.copyWith(isLoading: false, user: user, isDark: _db.isDarkTheme));
  }

  void _onToggleTheme(ToggleTheme event, Emitter<ProfileState> emit) {
    _db.isDarkTheme = !_db.isDarkTheme;
    emit(state.copyWith(isDark: _db.isDarkTheme));
  }

  Future<void> _onUpdateProfileDetails(
    UpdateProfileDetails event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, updateSuccess: false));
    try {
      final user = await authRepository.getCurrentUser();
      if (user != null) {
        // Update user properties in database
        final updatedUser = user.copyWith(name: event.name, phone: event.phone);

        // In local mock mode, we modify in memory
        final mockDbIndex = _db.users.indexWhere((u) => u.uid == user.uid);
        if (mockDbIndex != -1) {
          _db.users[mockDbIndex] = updatedUser;
        }
        _db.currentUser = updatedUser;

        emit(
          state.copyWith(
            isLoading: false,
            user: updatedUser,
            updateSuccess: true,
          ),
        );
      } else {
        emit(state.copyWith(isLoading: false, error: 'User session invalid'));
      }
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
