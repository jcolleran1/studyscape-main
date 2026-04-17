import 'dart:ui';
import 'package:flutter/material.dart';

/// Frosted glass text field matching the app's design style.
class FrostedTextField extends StatefulWidget {
  const FrostedTextField({
    super.key,
    required this.controller,
    required this.hintText,
    this.obscureText = false,
    this.useLightSurface = false,
  });

  final TextEditingController controller;
  final String hintText;
  final bool obscureText;

  /// Dark text on a light frosted fill (auth screens with neutral background).
  final bool useLightSurface;

  @override
  State<FrostedTextField> createState() => _FrostedTextFieldState();
}

class _FrostedTextFieldState extends State<FrostedTextField> {
  static const Color _authInk = Color(0xFF212B58);

  @override
  Widget build(BuildContext context) {
    final light = widget.useLightSurface;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: light ? Colors.white.withOpacity(0.78) : Colors.white.withOpacity(0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: light ? const Color(0x1A212B58) : Colors.white.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: widget.controller,
            obscureText: widget.obscureText,
            style: TextStyle(
              color: light ? _authInk : Colors.white,
              fontSize: 16,
            ),
            decoration: InputDecoration(
              hintText: widget.hintText,
              hintStyle: TextStyle(
                color: light ? const Color(0xFF6B7280) : Colors.white.withOpacity(0.5),
                fontSize: 16,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
    );
  }
}
