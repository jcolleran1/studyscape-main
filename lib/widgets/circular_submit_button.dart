import 'package:flutter/material.dart';

/// Circular submit button with frosted circle and orange arrow, used on auth screens.
class CircularSubmitButton extends StatelessWidget {
  const CircularSubmitButton({
    super.key,
    required this.onPressed,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final bool loading;

  static const Color _arrowOrange = Color(0xFFC8854A);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: loading ? null : onPressed,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Center(
            child: loading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: const AlwaysStoppedAnimation<Color>(_arrowOrange),
                        ),
                      )
                    : const Icon(
                        Icons.arrow_forward,
                        color: _arrowOrange,
                        size: 28,
                      ),
          ),
        ),
      ),
    );
  }
}
