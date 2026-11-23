import 'package:flutter/material.dart';

/// Keeps a page's content at a comfortable reading width on wide screens
/// (centred); on phones it changes nothing.
class ReadableWidth extends StatelessWidget {
  final Widget child;
  final double maxWidth;
  const ReadableWidth({super.key, required this.child, this.maxWidth = 900});

  @override
  Widget build(BuildContext context) => Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(constraints: BoxConstraints(maxWidth: maxWidth), child: child),
      );
}
