import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

/// Look (icon + colour) of a vehicle, a group or a profile.
///
/// Both fields are optional: without a value the app shows a fallback (a default icon, or the initial of a name).
@immutable
class Appearance {
  const Appearance({this.icon, this.color});

  /// Icon name (a key of [appearanceIcons]).
  final String? icon;

  /// Colour as `#RRGGBB`.
  final String? color;

  @override
  bool operator ==(Object other) =>
      other is Appearance && other.icon == icon && other.color == color;

  @override
  int get hashCode => Object.hash(icon, color);
}

/// Colours offered when choosing an appearance.
const appearancePalette = <String>[
  '#F59E0B',
  '#EF4444',
  '#10B981',
  '#3B82F6',
  '#6366F1',
  '#EC4899',
  '#14B8A6',
  '#8B5CF6',
  '#84CC16',
  '#6B7280',
];

/// Icons that can be stored by name.
///
/// Why a constant map of `Icons.x` (not icon codes): the build only keeps the glyphs that are actually cited
/// (icon tree shaking). Apps pick which names they offer; the name is what is stored in the database.
const appearanceIcons = <String, IconData>{
  'directions_car': Icons.directions_car,
  'electric_car': Icons.electric_car,
  'local_taxi': Icons.local_taxi,
  'airport_shuttle': Icons.airport_shuttle,
  'local_shipping': Icons.local_shipping,
  'directions_bus': Icons.directions_bus,
  'two_wheeler': Icons.two_wheeler,
  'moped': Icons.moped,
  'pedal_bike': Icons.pedal_bike,
  'agriculture': Icons.agriculture,
  'sailing': Icons.sailing,
  'rv_hookup': Icons.rv_hookup,
  'groups': Icons.groups,
  'family_restroom': Icons.family_restroom,
  'home': Icons.home,
  'business': Icons.business,
  'work': Icons.work,
  'apartment': Icons.apartment,
  'storefront': Icons.storefront,
  'handyman': Icons.handyman,
  'star': Icons.star,
  'favorite': Icons.favorite,
  'person': Icons.person,
  'face': Icons.face,
  'emoji_emotions': Icons.emoji_emotions,
  'pets': Icons.pets,
  'sports_motorsports': Icons.sports_motorsports,
  'bolt': Icons.bolt,
};

/// Icon of the given name; [fallback] if the name is absent or unknown (for instance a list extended by a
/// newer app version).
IconData appearanceIcon(String? name, {required IconData fallback}) =>
    name == null ? fallback : (appearanceIcons[name] ?? fallback);

/// Colour of a `#RRGGBB` code; [fallback] if absent or unreadable.
Color colorFromHex(String? hex, {Color fallback = Colors.grey}) {
  final argb = parseHexColor(hex);
  return argb == null ? fallback : Color(argb);
}
