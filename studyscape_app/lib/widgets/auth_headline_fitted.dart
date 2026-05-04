import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Full-width [FittedBox] headline that scales the same on login and create
/// account: width is fixed to the wider of “create” / “account” at 80px
/// Poppins bold so “login” uses the same scale as each line on create account.
class AuthHeadlineFitted extends StatelessWidget {
  const AuthHeadlineFitted({
    super.key,
    required this.text,
    required this.style,
    this.strutStyle,
    this.textHeightBehavior,
  });

  final String text;
  final TextStyle style;
  final StrutStyle? strutStyle;
  final TextHeightBehavior? textHeightBehavior;

  /// Same horizontal metrics as the headline (80 / w700 / letterSpacing -2).
  static TextStyle _widthProbeStyle() {
    return GoogleFonts.poppins(
      fontSize: 80,
      fontWeight: FontWeight.w700,
      letterSpacing: -2,
    );
  }

  /// Max width of “create” vs “account” — shared by login + create account.
  static double referenceLineWidth(BuildContext context) {
    final probe = _widthProbeStyle();
    final scaler = MediaQuery.textScalerOf(context);
    double measure(String t) {
      final tp = TextPainter(
        text: TextSpan(text: t, style: probe),
        textDirection: TextDirection.ltr,
        textScaler: scaler,
      )..layout();
      return tp.size.width;
    }

    final a = measure('create');
    final b = measure('account');
    return a >= b ? a : b;
  }

  @override
  Widget build(BuildContext context) {
    final refW = referenceLineWidth(context);
    return SizedBox(
      width: double.infinity,
      child: FittedBox(
        fit: BoxFit.fitWidth,
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: refW,
          child: Text(
            text,
            textAlign: TextAlign.left,
            style: style,
            strutStyle: strutStyle,
            textHeightBehavior: textHeightBehavior,
          ),
        ),
      ),
    );
  }
}
