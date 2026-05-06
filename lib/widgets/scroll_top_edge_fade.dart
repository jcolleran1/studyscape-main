import 'package:flutter/material.dart';

/// Placed as a sibling above [SingleChildScrollView] inside a [Stack] (same
/// [Expanded] region). Fades scroll content under the pinned header so there
/// is no harsh horizontal seam.
class ScrollTopEdgeFade extends StatelessWidget {
  const ScrollTopEdgeFade({
    super.key,
    required this.fadeColor,
    this.height = 14,
  });

  final Color fadeColor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: IgnorePointer(
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.38, 0.78, 1.0],
              colors: [
                fadeColor,
                fadeColor.withValues(alpha: 0.9),
                fadeColor.withValues(alpha: 0.22),
                fadeColor.withValues(alpha: 0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
