import 'package:flutter/material.dart';

/// Title of the main pages (tabs): the app icon, then the page name.
///
/// [iconAsset] is an asset of the app (for example its web icon), so there is no second copy of the icon to
/// keep up to date.
class AppBarTitle extends StatelessWidget {
  const AppBarTitle(this.text, {super.key, required this.iconAsset});

  final String text;
  final String iconAsset;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: Image.asset(iconAsset, width: 28, height: 28),
        ),
        const SizedBox(width: 12),
        Flexible(child: Text(text, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}
