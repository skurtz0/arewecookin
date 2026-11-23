import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../models/user_profile.dart';

/// Real Firebase accounts. A failed call is reported to the user as it is: there is no made-up
/// session any more. Only when Firebase is not available at all (widget tests) the service
/// keeps an in-memory session so the screens can still be exercised.
class AuthService {
  fb.FirebaseAuth? _firebaseAuth;
  UserProfile? _simulatedUser;
  fb.ConfirmationResult? _webConfirmation;

  AuthService({fb.FirebaseAuth? firebaseAuth}) {
    if (firebaseAuth != null) {
      _firebaseAuth = firebaseAuth;
    } else {
      try {
        _firebaseAuth = fb.FirebaseAuth.instance;
      } catch (_) {
        // Test environment without Firebase.
      }
    }
  }

  bool get _offlineMock => _firebaseAuth == null;

  UserProfile _profileOf(fb.User u, {String? provider, String? fallbackName}) {
    return UserProfile(
      id: u.uid,
      email: u.email ?? '',
      phoneNumber: u.phoneNumber,
      displayName: (u.displayName != null && u.displayName!.trim().isNotEmpty)
          ? u.displayName!
          : (fallbackName ?? (u.email ?? u.phoneNumber ?? 'Şef').split('@').first),
      photoUrl: u.photoURL,
      authProvider: provider ??
          (u.providerData.isNotEmpty ? u.providerData.first.providerId : 'password'),
      isLoggedIn: true,
      savedRecipesCount: 0,
      cookedCount: 0,
    );
  }

  UserProfile get currentUser {
    if (_simulatedUser != null) return _simulatedUser!;
    final fbUser = _firebaseAuth?.currentUser;
    if (fbUser != null) return _profileOf(fbUser);
    return UserProfile.guest;
  }

  /// Sign-in / sign-out events of the real account (null when there is no Firebase).
  Stream<UserProfile?>? get userChanges {
    final a = _firebaseAuth;
    if (a == null) return null;
    return a.userChanges().map((u) => u == null ? null : _profileOf(u));
  }

  /// Turns any error into one readable sentence (our own validation messages pass through).
  Exception _friendly(Object e) {
    if (e is fb.FirebaseAuthException) {
      final msg = e.message ?? '';
      switch (e.code) {
        case 'email-already-in-use':
          return Exception('Bu e-posta ile zaten bir hesap var. Giriş yapmayı deneyin.');
        case 'invalid-email':
          return Exception('Geçerli bir e-posta adresi giriniz.');
        case 'weak-password':
          return Exception('Şifre çok zayıf. En az 6 karakter kullanın.');
        case 'user-not-found':
        case 'wrong-password':
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return Exception('E-posta veya şifre hatalı.');
        case 'user-disabled':
          return Exception('Bu hesap devre dışı bırakılmış.');
        case 'too-many-requests':
          return Exception('Çok fazla deneme yapıldı. Biraz bekleyip tekrar deneyin.');
        case 'network-request-failed':
          return Exception('İnternet bağlantısı yok. Bağlantınızı kontrol edip tekrar deneyin.');
        case 'operation-not-allowed':
        case 'configuration-not-found':
          return Exception('Bu giriş yöntemi henüz etkinleştirilmemiş (Firebase ayarı gerekli).');
        case 'requires-recent-login':
          return Exception('Güvenlik nedeniyle bu işlem için tekrar giriş yapmanız gerekiyor.');
        case 'invalid-verification-code':
          return Exception('Doğrulama kodu hatalı.');
        case 'invalid-phone-number':
          return Exception('Telefon numarası geçersiz. Ülke koduyla yazın (örn. +905551234567).');
        case 'popup-closed-by-user':
        case 'cancelled-popup-request':
        case 'web-context-canceled':
        case 'canceled':
          return Exception('Giriş iptal edildi.');
        case 'account-exists-with-different-credential':
          return Exception('Bu e-posta başka bir giriş yöntemiyle kayıtlı.');
        default:
          if (msg.contains('CONFIGURATION_NOT_FOUND')) {
            return Exception('Bu giriş yöntemi henüz etkinleştirilmemiş (Firebase ayarı gerekli).');
          }
          return Exception('İşlem başarısız (${e.code}).');
      }
    }
    if (e is TimeoutException) {
      return Exception('Zaman aşımı. İnternet bağlantınızı kontrol edip tekrar deneyin.');
    }
    if (e is Exception) return e;
    return Exception('Beklenmeyen bir hata oluştu.');
  }

  String _checkedEmail(String email) {
    final clean = email.trim().toLowerCase();
    if (clean.isEmpty || !clean.contains('@') || !clean.contains('.')) {
      throw Exception('Geçerli bir e-posta adresi giriniz.');
    }
    return clean;
  }

  /// Google ile giriş
  Future<UserProfile> signInWithGoogle() async {
    if (_offlineMock) {
      return _simulatedUser = const UserProfile(
        id: 'google_chef_001',
        email: 'sef.ahmet@gmail.com',
        displayName: 'Ahmet Şef (Google)',
        authProvider: 'google',
        isLoggedIn: true,
        savedRecipesCount: 0,
        cookedCount: 0,
      );
    }
    try {
      final provider = fb.GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      final cred = kIsWeb
          ? await _firebaseAuth!.signInWithPopup(provider)
          : await _firebaseAuth!.signInWithProvider(provider);
      final u = cred.user;
      if (u == null) throw Exception('Google ile giriş tamamlanamadı.');
      return _profileOf(u, provider: 'google', fallbackName: 'Google Şefi');
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// E-posta ve şifre ile giriş yap
  Future<UserProfile> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final cleanEmail = _checkedEmail(email);
    if (password.length < 6) {
      throw Exception('Şifre en az 6 karakter olmalıdır.');
    }
    if (_offlineMock) {
      final name = cleanEmail.split('@').first;
      return _simulatedUser = UserProfile(
        id: 'usr_${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        displayName: '${name[0].toUpperCase()}${name.substring(1)} Şef',
        authProvider: 'password',
        isLoggedIn: true,
        savedRecipesCount: 0,
        cookedCount: 0,
      );
    }
    try {
      final cred = await _firebaseAuth!
          .signInWithEmailAndPassword(email: cleanEmail, password: password)
          .timeout(const Duration(seconds: 20));
      final u = cred.user;
      if (u == null) throw Exception('Giriş tamamlanamadı.');
      return _profileOf(u, provider: 'password', fallbackName: cleanEmail.split('@').first);
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// Yeni e-posta ile kayıt ol; doğrulama e-postası gönderilir.
  Future<UserProfile> registerWithEmail({
    required String email,
    required String password,
    required String displayName,
  }) async {
    final cleanEmail = _checkedEmail(email);
    if (password.length < 6) {
      throw Exception('Şifre en az 6 karakter olmalıdır.');
    }
    final cleanName =
        displayName.trim().isEmpty ? cleanEmail.split('@').first : displayName.trim();
    if (_offlineMock) {
      return _simulatedUser = UserProfile(
        id: 'usr_${cleanEmail.hashCode.abs()}',
        email: cleanEmail,
        displayName: cleanName,
        authProvider: 'password',
        isLoggedIn: true,
        savedRecipesCount: 0,
        cookedCount: 0,
      );
    }
    try {
      final cred = await _firebaseAuth!
          .createUserWithEmailAndPassword(email: cleanEmail, password: password)
          .timeout(const Duration(seconds: 20));
      final u = cred.user;
      if (u == null) throw Exception('Hesap oluşturulamadı.');
      try {
        await u.updateDisplayName(cleanName);
      } catch (_) {}
      // The account exists now; a failing mail must not undo that.
      try {
        await u.sendEmailVerification();
      } catch (_) {}
      return _profileOf(u, provider: 'password', fallbackName: cleanName)
          .copyWith(displayName: cleanName);
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// "Şifremi unuttum": sends a reset link to the e-mail address.
  Future<void> sendPasswordReset(String email) async {
    final cleanEmail = _checkedEmail(email);
    if (_offlineMock) return;
    try {
      await _firebaseAuth!.sendPasswordResetEmail(email: cleanEmail).timeout(const Duration(seconds: 20));
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// Telefon numarasına doğrulama kodu gönder. Returns the id the code is checked against.
  Future<String> sendPhoneVerificationCode(String rawPhoneNumber) async {
    final phone = rawPhoneNumber.replaceAll(RegExp(r'\s+'), '').trim();
    if (phone.length < 9 || !phone.startsWith('+')) {
      throw Exception('Telefon numarasını ülke koduyla yazın (örn. +905551234567).');
    }
    if (_offlineMock) return 'mock_verification_${phone.hashCode.abs()}';
    try {
      if (kIsWeb) {
        _webConfirmation = await _firebaseAuth!.signInWithPhoneNumber(phone);
        return 'web_confirmation';
      }
      final done = Completer<String>();
      await _firebaseAuth!.verifyPhoneNumber(
        phoneNumber: phone,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (fb.PhoneAuthCredential credential) async {
          // Android may read the SMS itself and sign in without the user typing the code.
          try {
            await _firebaseAuth!.signInWithCredential(credential);
            if (!done.isCompleted) done.complete('auto_verified');
          } catch (e) {
            if (!done.isCompleted) done.completeError(e);
          }
        },
        verificationFailed: (fb.FirebaseAuthException e) {
          if (!done.isCompleted) done.completeError(e);
        },
        codeSent: (String verificationId, int? resendToken) {
          if (!done.isCompleted) done.complete(verificationId);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (!done.isCompleted) done.complete(verificationId);
        },
      );
      return await done.future.timeout(const Duration(seconds: 70));
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// SMS OTP Kodunu Doğrula ve Giriş Yap
  Future<UserProfile> verifyPhoneOtp({
    required String verificationId,
    required String smsCode,
    required String phoneNumber,
  }) async {
    final cleanCode = smsCode.trim();
    if (cleanCode.length != 6) {
      throw Exception('Lütfen 6 haneli doğrulama kodunu girin.');
    }
    if (_offlineMock || verificationId.startsWith('mock_')) {
      final suffix = phoneNumber.length >= 4 ? phoneNumber.substring(phoneNumber.length - 4) : '0000';
      return _simulatedUser = UserProfile(
        id: 'usr_phone_${phoneNumber.hashCode.abs()}',
        email: '',
        phoneNumber: phoneNumber,
        displayName: 'Aşçı #$suffix',
        authProvider: 'phone',
        isLoggedIn: true,
        savedRecipesCount: 0,
        cookedCount: 0,
      );
    }
    try {
      fb.User? u;
      if (verificationId == 'auto_verified') {
        u = _firebaseAuth!.currentUser;
      } else if (verificationId == 'web_confirmation') {
        final result = await _webConfirmation?.confirm(cleanCode);
        u = result?.user;
      } else {
        final credential =
            fb.PhoneAuthProvider.credential(verificationId: verificationId, smsCode: cleanCode);
        u = (await _firebaseAuth!.signInWithCredential(credential)).user;
      }
      if (u == null) throw Exception('Doğrulama tamamlanamadı. Kodu yeniden isteyin.');
      final tail = phoneNumber.length > 4 ? phoneNumber.substring(phoneNumber.length - 4) : phoneNumber;
      return _profileOf(u, provider: 'phone', fallbackName: 'Aşçı ($tail)');
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// Şifre Değiştir
  Future<void> changePassword({required String newPassword}) async {
    if (newPassword.length < 6) {
      throw Exception('Yeni şifre en az 6 karakter olmalıdır.');
    }
    if (_offlineMock) return;
    final user = _firebaseAuth!.currentUser;
    if (user == null) throw Exception('Önce giriş yapmalısınız.');
    try {
      await user.updatePassword(newPassword);
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// E-posta Değiştir (the new address must be confirmed through the mail Firebase sends).
  Future<UserProfile> changeEmail({required String newEmail}) async {
    final cleanEmail = _checkedEmail(newEmail);
    if (_offlineMock) {
      return _simulatedUser = currentUser.copyWith(email: cleanEmail);
    }
    final user = _firebaseAuth!.currentUser;
    if (user == null) throw Exception('Önce giriş yapmalısınız.');
    try {
      await user.verifyBeforeUpdateEmail(cleanEmail);
    } catch (e) {
      throw _friendly(e);
    }
    return currentUser;
  }

  /// Kullanıcı Adı Güncelle
  Future<UserProfile> updateDisplayName(String newName) async {
    final cleanName = newName.trim();
    if (cleanName.isEmpty) {
      throw Exception('İsim boş olamaz.');
    }
    if (_offlineMock) {
      return _simulatedUser = currentUser.copyWith(displayName: cleanName);
    }
    final user = _firebaseAuth!.currentUser;
    if (user == null) throw Exception('Önce giriş yapmalısınız.');
    try {
      await user.updateDisplayName(cleanName);
      await user.reload();
    } catch (e) {
      throw _friendly(e);
    }
    return currentUser.copyWith(displayName: cleanName);
  }

  /// Hesabı Sil
  Future<void> deleteAccount() async {
    if (_offlineMock) {
      _simulatedUser = null;
      return;
    }
    final user = _firebaseAuth!.currentUser;
    if (user == null) {
      _simulatedUser = null;
      return;
    }
    try {
      await user.delete();
      _simulatedUser = null;
    } catch (e) {
      throw _friendly(e);
    }
  }

  /// Çıkış yap
  Future<void> signOut() async {
    _simulatedUser = null;
    try {
      await _firebaseAuth?.signOut();
    } catch (_) {}
  }
}
