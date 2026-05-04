import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Large bottom-aligned titles with a translucent “glass” look: soft gradient fill,
/// bright top-left edge, and depth shadow (inspired by frosted display typography).
class GlassBottomHeading extends StatelessWidget {
  const GlassBottomHeading({
    super.key,
    required this.lines,
    this.secondLineIndent = 0,
    this.horizontalPadding = 28,
  });

  final List<String> lines;
  final double secondLineIndent;
  final double horizontalPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(horizontalPadding, 0, horizontalPadding, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 2),
            _GlassLine(
              text: lines[i],
              leftIndent: i == 1 ? secondLineIndent : 0,
            ),
          ],
        ],
      ),
    );
  }
}

class _GlassLine extends StatelessWidget {
  const _GlassLine({
    required this.text,
    this.leftIndent = 0,
  });

  final String text;
  final double leftIndent;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: leftIndent),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: ShaderMask(
          blendMode: BlendMode.srcIn,
          shaderCallback: (bounds) => const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xE6FFFFFF),
              Color(0x6EFFFFFF),
            ],
          ).createShader(bounds),
          child: Text(
            text,
            style: GoogleFonts.poppins(
              color: Colors.white,
              fontSize: 54,
              fontWeight: FontWeight.w800,
              height: 0.94,
              letterSpacing: -1,
              shadows: const [
                Shadow(
                  offset: Offset(-1.25, -1.25),
                  blurRadius: 0,
                  color: Color(0xD0FFFFFF),
                ),
                Shadow(
                  offset: Offset(-0.5, -0.5),
                  blurRadius: 4,
                  color: Color(0x55FFFFFF),
                ),
                Shadow(
                  offset: Offset(2.5, 3.5),
                  blurRadius: 14,
                  color: Color(0x48000000),
                ),
                Shadow(
                  offset: Offset(0, 8),
                  blurRadius: 22,
                  color: Color(0x28000000),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
