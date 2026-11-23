import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_doc.dart';
import '../providers/auth_provider.dart';
import '../providers/locale_provider.dart';
import '../providers/profile_provider.dart';
import '../providers/social_provider.dart';

/// Round profile picture; falls back to the first letter of the name.
class ProfileAvatar extends ConsumerWidget {
  final String uid;
  final String name;
  final double radius;
  const ProfileAvatar({super.key, required this.uid, required this.name, this.radius = 20});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final photo = uid.isEmpty ? null : ref.watch(profileProvider(uid)).asData?.value?.photoUrl;
    final initial = name.trim().isEmpty ? '?' : name.trim().characters.first.toUpperCase();
    return ExcludeSemantics(
      child: CircleAvatar(
        radius: radius,
        backgroundImage: photo == null ? null : NetworkImage(photo),
        onBackgroundImageError: photo == null ? null : (_, _) {},
        child: photo == null ? Text(initial, style: TextStyle(fontSize: radius * 0.8)) : null,
      ),
    );
  }
}

/// Bottom sheet to change the name, bio and picture of the signed-in user's profile.
class EditProfileSheet extends ConsumerStatefulWidget {
  final ProfileDoc? current;
  const EditProfileSheet({super.key, required this.current});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final _name = TextEditingController(text: widget.current?.displayName.isNotEmpty == true ? widget.current!.displayName : ref.read(authProvider).user.displayName);
  late final _bio = TextEditingController(text: widget.current?.bio ?? '');
  (dynamic, String)? _newPhoto;
  bool _busy = false;

  @override
  void dispose() {
    _name.dispose();
    _bio.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final x = await ref.read(photoPickerProvider)();
      if (x != null && mounted) setState(() => _newPhoto = (x.$1, x.$2));
    } catch (_) {}
  }

  Future<void> _save() async {
    final uid = ref.read(authProvider).user.id;
    if (_busy || _name.text.trim().isEmpty) return;
    setState(() => _busy = true);
    try {
      String? url;
      if (_newPhoto != null) {
        url = await ref.read(photoUploaderProvider).upload(_newPhoto!.$1, _newPhoto!.$2);
        if (url == null) throw Exception('upload');
      }
      await ref.read(profileServiceProvider).saveProfile(uid, displayName: _name.text.trim(), bio: _bio.text.trim(), photoUrl: url);
      if (mounted) Navigator.of(context).pop();
    } catch (_) {
      if (!mounted) return;
      setState(() => _busy = false);
      final tr = ref.read(appStringsProvider).isTurkish;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(tr ? 'Profil kaydedilemedi.' : 'Could not save the profile.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final tr = ref.watch(appStringsProvider).isTurkish;
    final user = ref.watch(authProvider).user;
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(16, 16, 16, 16 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(children: [
            if (_newPhoto != null)
              CircleAvatar(radius: 32, backgroundImage: MemoryImage(_newPhoto!.$1))
            else
              ProfileAvatar(uid: user.id, name: _name.text, radius: 32),
            const SizedBox(width: 12),
            Flexible(
              child: TextButton.icon(
                key: const Key('profile_pick_photo'),
                onPressed: _busy ? null : _pick,
                icon: const Icon(Icons.add_photo_alternate_outlined),
                label: Text(tr ? 'Profil fotoğrafını değiştir' : 'Change profile photo'),
              ),
            ),
          ]),
          TextField(
            key: const Key('profile_name'),
            controller: _name,
            maxLength: ProfileDoc.maxName,
            decoration: InputDecoration(labelText: tr ? 'Ad' : 'Name'),
          ),
          TextField(
            key: const Key('profile_bio'),
            controller: _bio,
            maxLength: ProfileDoc.maxBio,
            maxLines: 3,
            decoration: InputDecoration(labelText: tr ? 'Biyografi' : 'Bio'),
          ),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton(
              key: const Key('profile_save'),
              onPressed: _busy ? null : _save,
              child: Text(tr ? 'Kaydet' : 'Save'),
            ),
          ),
        ],
      ),
    );
  }
}
