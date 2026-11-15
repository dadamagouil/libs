import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

import 'appearance.dart';

/// Round badge of a vehicle, group or profile: the chosen icon on the chosen colour.
/// Without an icon it shows [initial] (profiles) or [fallbackIcon].
class AppearanceAvatar extends StatelessWidget {
  const AppearanceAvatar({
    super.key,
    required this.appearance,
    required this.fallbackIcon,
    this.initial,
    this.radius = 20,
  });

  final Appearance appearance;

  /// Icon when nothing is chosen and there is no initial.
  final IconData fallbackIcon;

  /// Initial of the name, shown when no icon is chosen.
  final String? initial;
  final double radius;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final chosenColor = appearance.color == null ? null : colorFromHex(appearance.color);
    final showInitial = appearance.icon == null && initial != null && initial!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: chosenColor ?? scheme.secondaryContainer,
      foregroundColor: chosenColor == null ? scheme.onSecondaryContainer : Colors.white,
      child: showInitial
          ? Text(
              initialsOf(initial!).substring(0, 1),
              style: TextStyle(fontSize: radius * 0.9, fontWeight: FontWeight.w600),
            )
          : Icon(appearanceIcon(appearance.icon, fallback: fallbackIcon), size: radius * 1.1),
    );
  }
}

/// Texts of the appearance picker and dialog (the package owns no text).
class AppearanceLabels {
  const AppearanceLabels({
    required this.icon,
    required this.color,
    required this.save,
    required this.cancel,
    this.noIcon,
  });

  final String icon;
  final String color;
  final String save;
  final String cancel;

  /// Label of the "no icon" choice (usually "initial"); null hides that choice.
  final String? noIcon;
}

/// Choice of an icon (among [icons]) and of a colour (among [appearancePalette]).
/// With [AppearanceLabels.noIcon] a first "no icon" option is offered (null icon).
class AppearancePicker extends StatelessWidget {
  const AppearancePicker({
    super.key,
    required this.icons,
    required this.icon,
    required this.color,
    required this.onIconChanged,
    required this.onColorChanged,
    required this.labels,
  });

  final List<String> icons;
  final String? icon;
  final String? color;
  final ValueChanged<String?> onIconChanged;
  final ValueChanged<String> onColorChanged;
  final AppearanceLabels labels;

  @override
  Widget build(BuildContext context) {
    final labelStyle = Theme.of(context).textTheme.labelLarge;
    final noIcon = labels.noIcon;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(labels.icon, style: labelStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            if (noIcon != null)
              ChoiceChip(
                key: const Key('icon-none'),
                label: Text(noIcon),
                selected: icon == null,
                onSelected: (_) => onIconChanged(null),
              ),
            for (final name in icons)
              ChoiceChip(
                key: Key('icon-$name'),
                label: Icon(appearanceIcon(name, fallback: Icons.label), size: 20),
                selected: name == icon,
                onSelected: (_) => onIconChanged(name),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Text(labels.color, style: labelStyle),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final hex in appearancePalette)
              InkWell(
                key: Key('color-$hex'),
                customBorder: const CircleBorder(),
                onTap: () => onColorChanged(hex),
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: colorFromHex(hex),
                  child:
                      hex == color ? const Icon(Icons.check, size: 18, color: Colors.white) : null,
                ),
              ),
          ],
        ),
      ],
    );
  }
}

/// "Icon and colour" dialog: a preview on top, the choices below.
/// Returns the choice, or null on cancel. With [allowNoIcon] the icon may stay empty (the initial is shown).
Future<Appearance?> showAppearanceDialog(
  BuildContext context, {
  required String title,
  required List<String> icons,
  required Appearance initial,
  required IconData fallbackIcon,
  required AppearanceLabels labels,
  String? initialLetter,
  bool allowNoIcon = false,
}) {
  return showDialog<Appearance>(
    context: context,
    builder: (_) => _AppearanceDialog(
      title: title,
      icons: icons,
      initial: initial,
      fallbackIcon: fallbackIcon,
      initialLetter: initialLetter,
      labels: AppearanceLabels(
        icon: labels.icon,
        color: labels.color,
        save: labels.save,
        cancel: labels.cancel,
        noIcon: allowNoIcon ? labels.noIcon : null,
      ),
    ),
  );
}

class _AppearanceDialog extends StatefulWidget {
  const _AppearanceDialog({
    required this.title,
    required this.icons,
    required this.initial,
    required this.fallbackIcon,
    required this.initialLetter,
    required this.labels,
  });

  final String title;
  final List<String> icons;
  final Appearance initial;
  final IconData fallbackIcon;
  final String? initialLetter;
  final AppearanceLabels labels;

  @override
  State<_AppearanceDialog> createState() => _AppearanceDialogState();
}

class _AppearanceDialogState extends State<_AppearanceDialog> {
  late String? _icon = widget.initial.icon;
  late String? _color = widget.initial.color ?? appearancePalette.first;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppearanceAvatar(
              key: const Key('appearance-preview'),
              appearance: Appearance(icon: _icon, color: _color),
              fallbackIcon: widget.fallbackIcon,
              initial: widget.initialLetter,
              radius: 32,
            ),
            const SizedBox(height: 16),
            AppearancePicker(
              icons: widget.icons,
              icon: _icon,
              color: _color,
              onIconChanged: (name) => setState(() => _icon = name),
              onColorChanged: (hex) => setState(() => _color = hex),
              labels: widget.labels,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(widget.labels.cancel),
        ),
        FilledButton(
          key: const Key('appearance-save'),
          onPressed: () => Navigator.pop(context, Appearance(icon: _icon, color: _color)),
          child: Text(widget.labels.save),
        ),
      ],
    );
  }
}
