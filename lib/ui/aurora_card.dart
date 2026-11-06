import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Color field tuned to the original HTML prototype. The animated paint sits
/// behind its child, so text/buttons never translate or blur with the colors.
/// All animation is local to the card and requires no network or image assets.
class AuroraCard extends StatefulWidget {
  const AuroraCard({
    required this.child,
    this.height = 174,
    this.radius = 14,
    super.key,
  });

  final Widget child;
  final double height;
  final double radius;

  @override
  State<AuroraCard> createState() => _AuroraCardState();
}

class _AuroraCardState extends State<AuroraCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _motion;

  @override
  void initState() {
    super.initState();
    _motion = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 52),
    );
    if (!WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
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
              RepaintBoundary(
                child: CustomPaint(painter: AuroraPainter(_motion)),
              ),
              widget.child,
            ],
          ),
        ),
      );
}

/// Soft elliptical color pools rather than a single linear gradient.
/// The glows move along different slow paths to keep the effect organic.
class AuroraPainter extends CustomPainter {
  AuroraPainter(this.motion) : super(repaint: motion);
  final Animation<double> motion;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(rect, Paint()..color = const Color(0xFFA6A9DC));
    final t = motion.value * 2 * math.pi;

    _glow(canvas, size,
        color: const Color(0xFF4863C7),
        x: .08, y: .83, rx: .65, ry: .79,
        mx: .09, my: .12, t: t, phase: .1, alpha: .97);
    _glow(canvas, size,
        color: const Color(0xFF7F9BEA),
        x: .13, y: .20, rx: .78, ry: .71,
        mx: .14, my: .07, t: t, phase: 1.3, alpha: .96);
    _glow(canvas, size,
        color: const Color(0xFF80BEA9),
        x: .93, y: .07, rx: .71, ry: .69,
        mx: .13, my: .14, t: t, phase: 2.4, alpha: .93);
    _glow(canvas, size,
        color: const Color(0xFFF2A27D),
        x: .61, y: .83, rx: .57, ry: .73,
        mx: .16, my: .12, t: t, phase: 4.1, alpha: .97);
    _glow(canvas, size,
        color: const Color(0xFFC6A1D7),
        x: .54, y: .35, rx: .58, ry: .68,
        mx: .13, my: .09, t: t, phase: 5.1, alpha: .82);
    _glow(canvas, size,
        color: const Color(0xFF3978A1),
        x: .94, y: .70, rx: .47, ry: .78,
        mx: .08, my: .14, t: t, phase: 3.2, alpha: .54);

    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0x12FFFFFF), Color(0x00191840), Color(0x153F3B76)],
          stops: [0, .44, 1],
        ).createShader(rect),
    );
  }

  void _glow(
    Canvas canvas,
    Size size, {
    required Color color,
    required double x,
    required double y,
    required double rx,
    required double ry,
    required double mx,
    required double my,
    required double t,
    required double phase,
    required double alpha,
  }) {
    final cx = size.width * (x + mx * math.sin(t + phase));
    final cy = size.height * (y + my * math.cos(t * .85 + phase));
    canvas.save();
    canvas.translate(cx, cy);
    canvas.scale(size.width * rx, size.height * ry);
    final shader = RadialGradient(
      stops: const [0, .26, .57, .83, 1],
      colors: [
        color.withValues(alpha: alpha),
        color.withValues(alpha: alpha * .93),
        color.withValues(alpha: alpha * .60),
        color.withValues(alpha: alpha * .15),
        color.withValues(alpha: 0),
      ],
    ).createShader(Rect.fromCircle(center: Offset.zero, radius: 1));
    canvas.drawCircle(Offset.zero, 1, Paint()..shader = shader);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant AuroraPainter oldDelegate) =>
      oldDelegate.motion != motion;
}

/// A subtle animated aurora beneath the black header. Kept deliberately dark
/// to preserve the reference's visual hierarchy and text readability.
class AuroraHeaderGlow extends StatefulWidget {
  const AuroraHeaderGlow({super.key});

  @override
  State<AuroraHeaderGlow> createState() => _AuroraHeaderGlowState();
}

class _AuroraHeaderGlowState extends State<AuroraHeaderGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 64),
    );
    if (!WidgetsBinding
        .instance.platformDispatcher.accessibilityFeatures.disableAnimations) {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
        child: RepaintBoundary(
          child: CustomPaint(painter: _HeaderPainter(_controller)),
        ),
      );
}

class _HeaderPainter extends CustomPainter {
  _HeaderPainter(this.motion) : super(repaint: motion);
  final Animation<double> motion;

  @override
  void paint(Canvas canvas, Size size) {
    final t = 2 * math.pi * motion.value;
    final fade = Paint()
      ..shader = RadialGradient(
        colors: const [Color(0x244759B0), Color(0x1052B9A1), Color(0x00000000)],
        stops: const [0, .45, 1],
      ).createShader(Rect.fromCircle(
        center: Offset(size.width * (.76 + .11 * math.sin(t)), size.height * .65),
        radius: size.width * .73,
      ));
    canvas.drawRect(Offset.zero & size, fade);
  }

  @override
  bool shouldRepaint(covariant _HeaderPainter oldDelegate) =>
      oldDelegate.motion != motion;
}
