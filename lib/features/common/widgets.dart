import 'package:budget_engine/budget_engine.dart';
import 'package:flutter/material.dart';

import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/health.dart';
import '../../domain/rupees.dart';

const motionDuration = Duration(milliseconds: 600);

class AnimatedMoney extends StatelessWidget {
  const AnimatedMoney(this.money, {super.key, this.style});

  final Money money;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(end: money.paise.toDouble()),
      duration: motionDuration,
      curve: Curves.easeOutCubic,
      builder: (context, value, _) => Text(Rupees.format(Money(value.round())), style: style),
    );
  }
}

class AnimatedBar extends StatelessWidget {
  const AnimatedBar({super.key, required this.permille, required this.color, this.height = 8});

  final int permille;
  final Color color;
  final double height;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: TweenAnimationBuilder<double>(
          tween: Tween(end: permille / 1000),
          duration: motionDuration,
          curve: Curves.easeOutCubic,
          builder: (context, value, _) => LinearProgressIndicator(
            value: value.clamp(0, 1),
            backgroundColor: palette.track,
            color: color,
            minHeight: height,
          ),
        ),
      ),
    );
  }
}

class HealthTag extends StatelessWidget {
  const HealthTag({super.key, required this.health, this.coveredByFloor = false});

  final HealthState health;
  final bool coveredByFloor;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final color = palette.health(health);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            coveredByFloor ? S.foodCoveredByFloor : S.healthLabel(health),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(color: palette.mutedText),
            overflow: TextOverflow.ellipsis,
            maxLines: 2,
          ),
        ),
      ],
    );
  }
}

class SectionCard extends StatelessWidget {
  const SectionCard({super.key, required this.child, this.padding = const EdgeInsets.all(16), this.onTap});

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(onTap: onTap, child: Padding(padding: padding, child: child)),
    );
  }
}

String formatDate(CivilDate date) {
  const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  return '${date.day} ${months[date.month - 1]}';
}
