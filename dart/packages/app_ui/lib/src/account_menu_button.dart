import 'package:flutter/material.dart';

/// What the person picked in the account menu.
enum AccountMenuChoice { edit, logOut }

/// Texts of the account menu (the package owns no text).
class AccountMenuLabels {
  const AccountMenuLabels({required this.tooltip, required this.edit, required this.logOut});

  final String tooltip;
  final String edit;
  final String logOut;
}

/// Account picture in the app bar: a tap opens a small menu to edit the account or to log out.
///
/// The first menu line shows who is signed in
/// (read-only), so a shared phone never leaves any doubt. Logging out itself (and its confirmation) is the app's
/// job: the button only reports the choice.
class AccountMenuButton extends StatelessWidget {
  const AccountMenuButton({
    super.key,
    required this.name,
    required this.email,
    required this.avatar,
    required this.labels,
    required this.onSelected,
  });

  final String name;
  final String email;

  /// The round picture (for example an `ImageAvatar`); also shown, bigger, in the menu header.
  final Widget avatar;
  final AccountMenuLabels labels;
  final ValueChanged<AccountMenuChoice> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return PopupMenuButton<AccountMenuChoice>(
      tooltip: labels.tooltip,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      icon: avatar,
      onSelected: onSelected,
      itemBuilder: (_) => [
        // Who is signed in: read-only, not a choice.
        PopupMenuItem<AccountMenuChoice>(
          enabled: false,
          child: Row(
            children: [
              avatar,
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(
                        context,
                      ).textTheme.titleSmall?.copyWith(color: scheme.onSurface),
                    ),
                    Text(
                      email,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: AccountMenuChoice.edit,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.person_outline),
            title: Text(labels.edit),
          ),
        ),
        PopupMenuItem(
          value: AccountMenuChoice.logOut,
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(Icons.logout, color: scheme.error),
            title: Text(labels.logOut, style: TextStyle(color: scheme.error)),
          ),
        ),
      ],
    );
  }
}
