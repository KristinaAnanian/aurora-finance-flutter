import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Slow, continuous loop with moving radial gradients. This repaints only the
/// card's clipped canvas, not the labels and controls drawn over it.
class AuroraCard extends StatefulWidget {
  const AuroraCard({
    required this.child,
    this.height = 164,
    this.radius = 18,
    super.key,
  });

  final Widget child;
  final double height;
  final double radius;

  @override
  State<AuroraCard> createState() => _AuroraCardState();
}

class _AuroraCardState extends State<AuroraCard> with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 42),
    );
    if (!WidgetsBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _motion.repeat();
    }
  }

  @override
  void dispose() {
    _motion.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(widget.radius),
        child: SizedBox(
          height: widget.height,
          width: double.infinity,
          child: Stack(
            fit: StackFit.expand,
            children: [
              CustomPaint(painter: AuroraPainter(_motion)),
              widget.child,
            ],
          ),
        ),
      );
}

class AuroraPainter extends CustomPainter {
  AuroraPainter(this.motion) : super(repaint: motion);
  final Animation<double> motion;

  @override
  void paint(Canvas canvas, Size size) {
    final full = Offset.zero & size;
    final base = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [Color(0xFFA6B0EA), Color(0xFF8997D9), Color(0xFFC5B1D5)],
      ).createShader(full);
    canvas.drawRect(full, base);
    final t = motion.value * math.pi * 2;
    _blob(canvas, size, const Color(0xFFA5CBBA), .86, .19, .25, .13, t, 0.0);
    _blob(canvas, size, const Color(0xFF5E75E8), .23, .65, .20, .17, t, 1.7);
    _blob(canvas, size, const Color(0xFFEBA58A), .63, .75, .19, .13, t, 2.4);
    _blob(canvas, size, const Color(0xFFCEAFE7), .45, .34, .15, .18, t, 3.5);
    _blob(canvas, size, const Color(0xFF79A0C1), .92, .78, .14, .15, t, 4.4);
    _blob(canvas, size, const Color(0xFFCCD6FF), .14, .15, .16, .12, t, 5.2);
  }

  void _blob(Canvas canvas, Size size, Color color, double x, double y,
      double motionX, double motionY, double t, double phase) {
    final center = Offset(
      size.width * (x + motionX * math.sin(t + phase)),
      size.height * (y + motionY * math.cos(t + phase)),
    );
    final radius = size.longestSide * .64;
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [color.withValues(alpha: .9), color.withValues(alpha: .38), color.withValues(alpha: 0)],
        stops: const [0, .42, 1],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, paint);
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) => oldDelegate.motion != motion;
}
