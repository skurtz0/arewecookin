import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile.dart';
import '../services/auth_service.dart';

class AuthState {
  final UserProfile user;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;
  final String? phoneVerificationId;
  final String? pendingPhoneNumber;

  const AuthState({
    required this.user,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
    this.phoneVerificationId,
    this.pendingPhoneNumber,
  });

  AuthState copyWith({
    UserProfile? user,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
    String? phoneVerificationId,
    String? pendingPhoneNumber,
    bool clearError = false,
    bool clearSuccess = false,
    bool clearPhoneOtp = false,
  }) {
    return AuthState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      successMessage: clearSuccess ? null : (successMessage ?? this.successMessage),
      phoneVerificationId: clearPhoneOtp ? null : (phoneVerificationId ?? this.phoneVerificationId),
      pendingPhoneNumber: clearPhoneOtp ? null : (pendingPhoneNumber ?? this.pendingPhoneNumber),
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

  void clearMessages() {
    state = state.copyWith(clearError: true, clearSuccess: true);
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

  Future<void> sendPhoneOtp(String phoneNumber) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final verificationId = await _authService.sendPhoneVerificationCode(phoneNumber);
      state = state.copyWith(
        isLoading: false,
        phoneVerificationId: verificationId,
        pendingPhoneNumber: phoneNumber,
        successMessage: 'Doğrulama kodu SMS ile gönderildi.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> verifyPhoneOtp(String smsCode) async {
    if (state.phoneVerificationId == null || state.pendingPhoneNumber == null) {
      state = state.copyWith(errorMessage: 'Lütfen önce telefon numaranızı girin.');
      return;
    }

    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final user = await _authService.verifyPhoneOtp(
        verificationId: state.phoneVerificationId!,
        smsCode: smsCode,
        phoneNumber: state.pendingPhoneNumber!,
      );
      state = state.copyWith(
        user: user,
        isLoading: false,
        clearPhoneOtp: true,
        successMessage: 'Telefon ile başarıyla giriş yapıldı.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  void cancelPhoneOtp() {
    state = state.copyWith(clearPhoneOtp: true, clearError: true);
  }

  Future<void> changePassword(String newPassword) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _authService.changePassword(newPassword: newPassword);
      state = state.copyWith(
        isLoading: false,
        successMessage: 'Şifreniz başarıyla değiştirildi.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> changeEmail(String newEmail) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final updatedUser = await _authService.changeEmail(newEmail: newEmail);
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        successMessage: 'E-posta adresiniz güncellendi.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> updateDisplayName(String newName) async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      final updatedUser = await _authService.updateDisplayName(newName);
      state = state.copyWith(
        user: updatedUser,
        isLoading: false,
        successMessage: 'Profil ismi güncellendi.',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  Future<void> deleteAccount() async {
    state = state.copyWith(isLoading: true, clearError: true, clearSuccess: true);
    try {
      await _authService.deleteAccount();
      state = AuthState(
        user: UserProfile.guest,
        isLoading: false,
        successMessage: 'Hesabınız ve verileriniz kalıcı olarak silindi.',
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
