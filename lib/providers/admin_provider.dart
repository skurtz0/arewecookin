import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/moderation_service.dart';
import 'auth_provider.dart';

final adminServiceProvider = Provider<ModerationService>((ref) => FirestoreModerationService());

/// True only for a signed-in user who has an `admins/<uid>` document.
final isAdminProvider = FutureProvider<bool>((ref) async {
  final user = ref.watch(authProvider).user;
  if (user.authProvider == 'guest') return false;
  return ref.watch(adminServiceProvider).isAdmin(user.id);
});

final reportsProvider = StreamProvider.autoDispose<List<ModerationReport>>(
  (ref) => ref.watch(adminServiceProvider).watchReports(),
);
