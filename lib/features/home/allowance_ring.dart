import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/budget_snapshot.dart';
import '../../domain/rupees.dart';
import '../common/widgets.dart';

class AllowanceRing extends StatelessWidget {
  const AllowanceRing({super.key, required this.snapshot, this.size = 196});

  final BudgetSnapshot snapshot;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final allowance = snapshot.allowance;
    final remaining = allowance.remainingToday;
    final over = remaining.isNegative;
    final color = palette.health(snapshot.ringHealth);
    final textTheme = Theme.of(context).textTheme;
    return SizedBox(
      width: size,
      height: size,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1 - snapshot.ringSpentPermille / 1000),
        duration: motionDuration,
        curve: Curves.easeOutCubic,
        builder: (context, fraction, child) => CustomPaint(
          painter: _RingPainter(fraction: fraction, color: color, track: palette.track),
          child: child,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedMoney(
                over ? -remaining : remaining,
                key: const Key('ring-amount'),
                style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700, color: palette.text),
              ),
              Text(over ? S.overToday : S.leftToday, style: textTheme.bodySmall?.copyWith(color: palette.mutedText)),
              const SizedBox(height: 4),
              Text(
                S.healthLabel(snapshot.ringHealth),
                style: textTheme.labelSmall?.copyWith(color: color),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({required this.fraction, required this.color, required this.track});

  final double fraction;
  final Color color;
  final Color track;

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 14.0;
    final rect = Offset.zero & size;
    final arcRect = rect.deflate(stroke / 2);
    final base = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    canvas.drawArc(arcRect, 0, math.pi * 2, false, base);
    final clamped = fraction.clamp(0.0, 1.0);
    if (clamped > 0) {
      final arc = Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = stroke;
      canvas.drawArc(arcRect, -math.pi / 2, math.pi * 2 * clamped, false, arc);
    }
  }

  @override
  bool shouldRepaint(_RingPainter oldDelegate) =>
      oldDelegate.fraction != fraction || oldDelegate.color != color || oldDelegate.track != track;
}

class RingSideBlock extends StatelessWidget {
  const RingSideBlock({super.key, required this.snapshot, required this.onMoveBanked});

  final BudgetSnapshot snapshot;
  final VoidCallback onMoveBanked;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final textTheme = Theme.of(context).textTheme;
    final banked = snapshot.allowance.banked;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(S.pool, style: textTheme.labelMedium?.copyWith(color: palette.mutedText)),
        AnimatedMoney(snapshot.pool, key: const Key('pool-amount'), style: textTheme.titleLarge?.copyWith(color: palette.text)),
        if (banked.isPositive) ...[
          const SizedBox(height: 12),
          Text(S.banked, style: textTheme.labelMedium?.copyWith(color: palette.mutedText)),
          Text(Rupees.format(banked), style: textTheme.titleMedium?.copyWith(color: palette.accent)),
          Text(S.bankedHint, style: textTheme.labelSmall?.copyWith(color: palette.mutedText)),
          TextButton(onPressed: onMoveBanked, child: const Text(S.moveBanked)),
        ],
      ],
    );
  }
}
