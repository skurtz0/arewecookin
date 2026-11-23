import 'package:arewecookin/services/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:flutter_test/flutter_test.dart';

/// A Firebase that refuses everything with the given error code.
class _FailingAuth implements fb.FirebaseAuth {
  final String code;
  _FailingAuth(this.code);

  @override
  fb.User? get currentUser => null;

  @override
  Future<fb.UserCredential> createUserWithEmailAndPassword({required String email, required String password}) =>
      Future.error(fb.FirebaseAuthException(code: code));

  @override
  Future<fb.UserCredential> signInWithEmailAndPassword({required String email, required String password}) =>
      Future.error(fb.FirebaseAuthException(code: code));

  @override
  Future<void> sendPasswordResetEmail({required String email, fb.ActionCodeSettings? actionCodeSettings}) =>
      Future.error(fb.FirebaseAuthException(code: code));

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError(invocation.memberName.toString());
}

void main() {
  Future<String> messageOf(Future<void> Function() f) async {
    try {
      await f();
    } catch (e) {
      return e.toString().replaceFirst('Exception: ', '');
    }
    return 'NO ERROR';
  }

  test('registering with a taken e-mail fails with a clear message and no fake session', () async {
    final s = AuthService(firebaseAuth: _FailingAuth('email-already-in-use'));
    final m = await messageOf(() => s.registerWithEmail(email: 'a@b.com', password: 'secret1', displayName: 'A'));
    expect(m, contains('zaten bir hesap'));
    expect(s.currentUser.isLoggedIn, isFalse);
  });

  test('a wrong password does not open a session', () async {
    final s = AuthService(firebaseAuth: _FailingAuth('invalid-credential'));
    final m = await messageOf(() => s.signInWithEmail(email: 'a@b.com', password: 'secret1'));
    expect(m, 'E-posta veya şifre hatalı.');
    expect(s.currentUser.isLoggedIn, isFalse);
  });

  test('Authentication not enabled in the Firebase project is reported, not hidden', () async {
    final s = AuthService(firebaseAuth: _FailingAuth('configuration-not-found'));
    final m = await messageOf(() => s.registerWithEmail(email: 'a@b.com', password: 'secret1', displayName: ''));
    expect(m, contains('etkinleştirilmemiş'));
    expect(s.currentUser.isLoggedIn, isFalse);
  });

  test('no network is reported', () async {
    final s = AuthService(firebaseAuth: _FailingAuth('network-request-failed'));
    final m = await messageOf(() => s.signInWithEmail(email: 'a@b.com', password: 'secret1'));
    expect(m, contains('İnternet'));
  });

  test('password reset errors surface', () async {
    final s = AuthService(firebaseAuth: _FailingAuth('user-not-found'));
    final m = await messageOf(() => s.sendPasswordReset('a@b.com'));
    expect(m, 'E-posta veya şifre hatalı.');
  });

  test('bad input is rejected before any request', () async {
    final s = AuthService(firebaseAuth: _FailingAuth('x'));
    expect(await messageOf(() => s.signInWithEmail(email: 'nope', password: 'secret1')), contains('Geçerli bir e-posta'));
    expect(await messageOf(() => s.registerWithEmail(email: 'a@b.com', password: '123', displayName: '')), contains('en az 6'));
    expect(await messageOf(() => s.sendPhoneVerificationCode('5551234567')), contains('ülke koduyla'));
  });
}
