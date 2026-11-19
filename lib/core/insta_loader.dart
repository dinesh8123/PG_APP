import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Instagram-style loading spinner: a thin ring with a gap that keeps
/// rotating, with rounded ends.
class InstaLoader extends StatefulWidget {
  const InstaLoader({
    super.key,
    this.size = 32,
    this.strokeWidth,
    this.color,
  });

  final double size;
  final double? strokeWidth;
  final Color? color;

  @override
  State<InstaLoader> createState() => _InstaLoaderState();
}

class _InstaLoaderState extends State<InstaLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? Theme.of(context).colorScheme.onSurface;

    return RepaintBoundary(
      child: SizedBox(
        width: widget.size,
        height: widget.size,
        child: AnimatedBuilder(
          animation: _controller,
          builder: (_, __) => CustomPaint(
            painter: _RingPainter(
              progress: _controller.value,
              color: color,
              strokeWidth: widget.strokeWidth ?? widget.size / 11,
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
  });

  final double progress;
  final Color color;
  final double strokeWidth;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final inset = strokeWidth / 2;
    final arcRect = rect.deflate(inset);

    // Faint full track.
    canvas.drawArc(
      arcRect,
      0,
      math.pi * 2,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..color = color.withValues(alpha: 0.15),
    );

    // Bright rotating arc with a fading tail.
    final start = progress * math.pi * 2;
    canvas.drawArc(
      arcRect,
      start,
      math.pi * 1.5,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = strokeWidth
        ..shader = SweepGradient(
          startAngle: 0,
          endAngle: math.pi * 1.5,
          colors: [color.withValues(alpha: 0.0), color],
          transform: GradientRotation(start),
        ).createShader(arcRect),
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.progress != progress ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
