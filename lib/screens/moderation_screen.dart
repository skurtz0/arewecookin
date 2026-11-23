import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/social_post.dart';
import '../providers/admin_provider.dart';
import '../providers/locale_provider.dart';
import '../services/moderation_service.dart';
import '../widgets/readable_width.dart';

/// Admin-only list of community complaints. Open ones first.
class ModerationScreen extends ConsumerWidget {
  const ModerationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tr = ref.watch(appStringsProvider).isTurkish;
    final reports = ref.watch(reportsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(tr ? 'Şikâyetler' : 'Reports')),
      body: ReadableWidth(
        child: reports.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(tr ? 'Şikâyetler okunamadı (yetki yok?).' : 'Could not read reports (no permission?).'),
            ),
          ),
          data: (list) {
            if (list.isEmpty) {
              return Center(child: Text(tr ? 'Şikâyet yok.' : 'No reports.'));
            }
            final sorted = [...list]..sort((a, b) {
                if (a.isOpen != b.isOpen) return a.isOpen ? -1 : 1;
                return b.createdAtMs.compareTo(a.createdAtMs);
              });
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: sorted.length,
              itemBuilder: (_, i) => _ReportCard(report: sorted[i], tr: tr),
            );
          },
        ),
      ),
    );
  }
}

class _ReportCard extends ConsumerWidget {
  final ModerationReport report;
  final bool tr;
  const _ReportCard({required this.report, required this.tr});

  Future<void> _run(BuildContext context, Future<void> Function() action) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await action();
    } catch (_) {
      messenger.showSnackBar(SnackBar(content: Text(tr ? 'İşlem başarısız.' : 'Action failed.')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final service = ref.watch(adminServiceProvider);
    final statusLabel = switch (report.status) {
      'removed' => tr ? 'Kaldırıldı' : 'Removed',
      'dismissed' => tr ? 'Reddedildi' : 'Dismissed',
      _ => tr ? 'Açık' : 'Open',
    };
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(
                  '${tr ? 'Sebep' : 'Reason'}: ${report.reason == 'report' ? (tr ? 'Kullanıcı şikâyeti' : 'User report') : report.reason}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 8),
              Text(statusLabel),
            ]),
            const SizedBox(height: 8),
            if (report.commentId != null)
              FutureBuilder<SocialComment?>(
                future: service.getComment(report.postId, report.commentId!),
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const SizedBox(height: 20, child: LinearProgressIndicator());
                  }
                  final c = snap.data;
                  if (c == null) return Text(tr ? 'Yorum artık yok.' : 'Comment no longer exists.');
                  return Text('${tr ? 'Yorum' : 'Comment'} - ${c.authorName}: ${c.text}', maxLines: 4, overflow: TextOverflow.ellipsis);
                },
              )
            else
              FutureBuilder<SocialPost?>(
                future: service.getPost(report.postId),
                builder: (_, snap) {
                  if (snap.connectionState != ConnectionState.done) {
                    return const SizedBox(height: 20, child: LinearProgressIndicator());
                  }
                  final post = snap.data;
                  if (post == null) {
                    return Text(tr ? 'Gönderi artık yok.' : 'Post no longer exists.');
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${post.authorName}: ${post.title}', maxLines: 2, overflow: TextOverflow.ellipsis),
                      if (post.text.isNotEmpty) Text(post.text, maxLines: 4, overflow: TextOverflow.ellipsis),
                    ],
                  );
                },
              ),
            if (report.isOpen) ...[
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: [
                FilledButton.tonal(
                  onPressed: () => _run(context, () => service.removePost(report)),
                  child: Text(report.commentId != null ? (tr ? 'Yorumu kaldır' : 'Remove comment') : (tr ? 'Gönderiyi kaldır' : 'Remove post')),
                ),
                OutlinedButton(
                  onPressed: () => _run(context, () => service.dismissReport(report)),
                  child: Text(tr ? 'Reddet' : 'Dismiss'),
                ),
              ]),
            ],
          ],
        ),
      ),
    );
  }
}
