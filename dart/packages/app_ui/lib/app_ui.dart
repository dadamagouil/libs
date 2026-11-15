/// Widgets, theme builder and persisted preferences shared by the apps.
///
/// Rule of the package: it owns no text. Every label is a parameter, so each app keeps its own translations
/// (`gen-l10n`) and the package stays free of any language.
library;

export 'src/account_menu_button.dart';
export 'src/app_bar_title.dart';
export 'src/appearance.dart';
export 'src/appearance_picker.dart';
export 'src/brand_theme.dart';
export 'src/confirm_by_typing.dart';
export 'src/confirm_destructive.dart';
export 'src/image_avatar.dart';
export 'src/persisted_preference.dart';
export 'src/pie_chart.dart';
export 'src/text_prompt_dialog.dart';
export 'src/undo_snack_bar.dart';
