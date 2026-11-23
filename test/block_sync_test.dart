import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:arewecookin/models/user_profile.dart';
import 'package:arewecookin/providers/auth_provider.dart';
import 'package:arewecookin/providers/moderation_provider.dart';
import 'package:arewecookin/services/moderation_service.dart';
import 'helpers/fake_social.dart';

class _FakeBlocks implements BlockSyncService {
  final Map<String, Set<String>> data;
  _FakeBlocks(this.data);
  @override
  Future<Set<String>> load(String uid) async => {...?data[uid]};
  @override
  Future<void> set(String uid, String blockedUid, bool blocked) async {
    final s = data.putIfAbsent(uid, () => {});
    blocked ? s.add(blockedUid) : s.remove(blockedUid);
  }
}

void main() {
  test('signed-in user: account blocks are merged in, local ones uploaded, changes saved to the account', () async {
    SharedPreferences.setMockInitialValues({'social_blocked_v1': ['local1']});
    final blocks = _FakeBlocks({'u1': {'remote1'}});
    final c = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(FakeAuthService(signedInUser)),
      blockSyncServiceProvider.overrideWithValue(blocks),
    ]);
    addTearDown(c.dispose);
    c.read(authProvider);
    c.read(moderationProvider);
    await Future<void>.delayed(const Duration(milliseconds: 50));
    expect(c.read(moderationProvider).blockedAuthors, {'local1', 'remote1'});
    expect(blocks.data['u1'], {'remote1', 'local1'});

    c.read(moderationProvider.notifier).blockAuthor('x');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(blocks.data['u1'], contains('x'));
    c.read(moderationProvider.notifier).unblockAuthor('x');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(blocks.data['u1'], isNot(contains('x')));
  });

  test('guest: blocks stay on the device only', () async {
    SharedPreferences.setMockInitialValues({});
    final blocks = _FakeBlocks({});
    final c = ProviderContainer(overrides: [
      authServiceProvider.overrideWithValue(FakeAuthService(UserProfile.guest)),
      blockSyncServiceProvider.overrideWithValue(blocks),
    ]);
    addTearDown(c.dispose);
    c.read(moderationProvider.notifier).blockAuthor('x');
    await Future<void>.delayed(const Duration(milliseconds: 20));
    expect(blocks.data, isEmpty);
  });
}
