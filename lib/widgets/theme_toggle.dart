import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/app_colors.dart';

/// One tap switches between the light and the dark theme.
class ThemeToggleButton extends ConsumerWidget {
  /// Shows the label next to the icon (used in the wide side menu).
  final bool withLabel;
  const ThemeToggleButton({super.key, this.withLabel = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final strings = ref.watch(appStringsProvider);
    final dark = isDark(ref.watch(themeModeProvider));
    final label = dark ? strings.themeLight : strings.themeDark;
    final icon = Icon(dark ? Icons.light_mode_rounded : Icons.dark_mode_rounded, size: 20, color: AppColors.slate(500));
    void toggle() => ref.read(themeModeProvider.notifier).toggle();
    if (withLabel) {
      return TextButton.icon(
        key: const Key('theme_toggle'),
        onPressed: toggle,
        icon: icon,
        label: Text(label, style: TextStyle(color: AppColors.slate(500), fontSize: 13)),
      );
    }
    return IconButton(
      key: const Key('theme_toggle'),
      tooltip: label,
      onPressed: toggle,
      icon: icon,
      padding: EdgeInsets.zero,
      constraints: const BoxConstraints(minWidth: 40, minHeight: 24),
      style: IconButton.styleFrom(tapTargetSize: MaterialTapTargetSize.shrinkWrap),
    );
  }
}
