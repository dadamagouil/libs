import 'package:flutter/material.dart';

/// Round picture (profile photo, group image) with a fallback shown when there is no picture or it fails to load.
///
/// Why the fallback stays underneath: the network image is a *foreground*, so a failed download leaves the
/// initials / icon visible instead of an empty circle.
class ImageAvatar extends StatelessWidget {
  const ImageAvatar({super.key, required this.fallback, this.imageUrl, this.radius = 20});

  /// Initials or icon shown without picture.
  final Widget fallback;
  final String? imageUrl;
  final double radius;

  /// Fallback made of the given text, in the avatar's colours.
  static Widget initials(BuildContext context, String text, double radius) => Text(
        text,
        style: TextStyle(
          fontSize: radius * 0.8,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onPrimaryContainer,
        ),
      );

  @override
  Widget build(BuildContext context) {
    final url = imageUrl;
    return CircleAvatar(
      radius: radius,
      backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      foregroundImage: url == null ? null : NetworkImage(url),
      onForegroundImageError: url == null ? null : (error, stackTrace) {},
      child: fallback,
    );
  }
}
