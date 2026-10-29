import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/profile_state.dart';
import '../../app/strings.dart';
import '../../app/theme.dart';
import '../../domain/gear.dart';

class StoredPhoto extends ConsumerWidget {
  const StoredPhoto({super.key, required this.photoId, this.fit = BoxFit.cover, this.fallback});

  final String photoId;
  final BoxFit fit;
  final Widget? fallback;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(photoProvider(photoId)).value;
    if (bytes == null) {
      return fallback ?? const SizedBox.shrink();
    }
    return Image.memory(
      bytes,
      fit: fit,
      gaplessPlayback: true,
      errorBuilder: (context, error, stack) => fallback ?? const SizedBox.shrink(),
    );
  }
}

class GearImage extends StatelessWidget {
  const GearImage({super.key, required this.item, this.size = 72});

  final GearItem item;
  final double size;

  @override
  Widget build(BuildContext context) {
    final palette = context.palette;
    final placeholder = Container(
      color: palette.track,
      alignment: Alignment.center,
      child: Icon(_iconFor(item.kind), color: palette.mutedText, size: size * 0.45, semanticLabel: S.photoPlaceholder),
    );
    final Widget image;
    if (item.photoId != null) {
      image = StoredPhoto(photoId: item.photoId!, fallback: placeholder);
    } else if (item.imageAsset != null) {
      image = ColoredBox(color: Colors.white, child: Image.asset(item.imageAsset!, fit: BoxFit.contain));
    } else {
      image = placeholder;
    }
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(width: size, height: size, child: image),
    );
  }

  static IconData _iconFor(GearKind kind) => switch (kind) {
        GearKind.phone => Icons.smartphone,
        GearKind.laptop => Icons.laptop_mac,
        GearKind.bike => Icons.two_wheeler,
        GearKind.audio => Icons.headphones,
        GearKind.power => Icons.battery_charging_full,
        GearKind.other => Icons.devices_other,
      };
}
