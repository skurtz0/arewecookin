import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthState {
  final UserProfile user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    required this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    bool clearError = false,
    bool clearSuccess = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
    );
  }
}

final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

class AuthNotifier extends Notifier<AuthState> {
  AuthService get _authService => ref.read(authServiceProvider);

  @override
  AuthState build() {
    return AuthState(user: _authService.currentUser);
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _authService.signInWithGoogle();
      state = state.copyWith(
        user: user,
        isLoading: false,
        successMessage: 'Google ile başarıyla giriş yapıldı.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Google ile giriş başarısız: $e',
      );
    }
  }

  Future<void> signInWithEmail(String email, String password) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _authService.signInWithEmail(email: email, password: password);
      state = state.copyWith(
        user: user,
        isLoading: false,
        successMessage: 'Başarıyla giriş yapıldı.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> registerWithEmail(String email, String password, String displayName) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _authService.registerWithEmail(
        email: email,
        password: password,
        displayName: displayName,
      );
      state = state.copyWith(
        user: user,
        isLoading: false,
        successMessage: 'Hesabınız başarıyla oluşturuldu.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> signOut() async {
    state = state.copyWith(isLoading: true);
    await _authService.signOut();
    state = AuthState(
      user: UserProfile.guest,
      isLoading: false,
      successMessage: 'Çıkış yapıldı.',
    );
  }
}

final authProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
