import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// A horizontal strip (chips, stories…) that also scrolls with a mouse wheel and shows
/// arrow buttons on wide screens, so it can be used without touch or a trackpad.
class HStrip extends StatefulWidget {
  final double height;
  final Widget Function(ScrollController controller) builder;
  const HStrip({super.key, required this.height, required this.builder});

  @override
  State<HStrip> createState() => _HStripState();
}

class _HStripState extends State<HStrip> {
  final _controller = ScrollController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _wheel(PointerSignalEvent e) {
    if (e is! PointerScrollEvent || !_controller.hasClients) return;
    final d = e.scrollDelta.dx != 0 ? e.scrollDelta.dx : e.scrollDelta.dy;
    if (d == 0) return;
    final pos = _controller.position;
    if (!pos.hasContentDimensions || pos.maxScrollExtent <= 0) return;
    GestureBinding.instance.pointerSignalResolver.register(e, (_) {
      _controller.jumpTo((pos.pixels + d).clamp(pos.minScrollExtent, pos.maxScrollExtent));
    });
  }

  void _nudge(double dir) {
    if (!_controller.hasClients || !_controller.position.hasContentDimensions) return;
    final pos = _controller.position;
    final step = math.max(160.0, pos.viewportDimension * 0.6) * dir;
    _controller.animateTo((pos.pixels + step).clamp(pos.minScrollExtent, pos.maxScrollExtent),
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
  }

  @override
  Widget build(BuildContext context) {
    final wide = MediaQuery.of(context).size.width >= 600;
    return SizedBox(
      height: widget.height,
      child: Stack(
        children: [
          NotificationListener<ScrollMetricsNotification>(
            onNotification: (_) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                if (mounted) setState(() {});
              });
              return false;
            },
            child: Listener(onPointerSignal: _wheel, child: widget.builder(_controller)),
          ),
          if (wide)
            AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                if (!_controller.hasClients || !_controller.position.hasContentDimensions || _controller.position.maxScrollExtent <= 0) {
                  return const SizedBox.shrink();
                }
                final p = _controller.position;
                final rtl = Directionality.of(context) == TextDirection.rtl;
                Widget arrow(IconData icon, bool show, double dir, String tip) => show
                    ? Material(
                        color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.92),
                        shape: const CircleBorder(),
                        elevation: 2,
                        child: IconButton(
                          tooltip: tip,
                          iconSize: 18,
                          visualDensity: VisualDensity.compact,
                          icon: Icon(icon),
                          onPressed: () => _nudge(dir),
                        ),
                      )
                    : const SizedBox.shrink();
                final canBack = p.pixels > p.minScrollExtent + 1;
                final canFwd = p.pixels < p.maxScrollExtent - 1;
                return Positioned.fill(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      arrow(rtl ? Icons.chevron_right : Icons.chevron_left, canBack, -1, '‹'),
                      arrow(rtl ? Icons.chevron_left : Icons.chevron_right, canFwd, 1, '›'),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
