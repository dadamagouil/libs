import 'package:app_ui/app_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Opens [open] from a button and returns what the dialog answered.
Future<T?> _openFromButton<T>(
  WidgetTester tester,
  Future<T?> Function(BuildContext context) open,
) async {
  T? result;
  await tester.pumpWidget(
    MaterialApp(
      home: Builder(
        builder: (context) => Scaffold(
          body: TextButton(
            onPressed: () async => result = await open(context),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return Future.value(result);
}

void main() {
  group('confirmDestructive', () {
    testWidgets('returns true when the person confirms', (tester) async {
      bool? answer;
      await _openFromButton<bool>(tester, (c) async {
        answer = await confirmDestructive(
          c,
          title: 'Delete?',
          message: 'Gone for good',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
        );
        return answer;
      });
      await tester.tap(find.byKey(const Key('confirm-delete')));
      await tester.pumpAndSettle();
      expect(answer, isTrue);
    });

    testWidgets('returns false on cancel', (tester) async {
      bool? answer;
      await _openFromButton<bool>(tester, (c) async {
        answer = await confirmDestructive(
          c,
          title: 'Delete?',
          message: 'Gone for good',
          confirmLabel: 'Delete',
          cancelLabel: 'Cancel',
        );
        return answer;
      });
      await tester.tap(find.byKey(const Key('confirm-cancel')));
      await tester.pumpAndSettle();
      expect(answer, isFalse);
    });
  });

  group('confirmByTyping', () {
    Future<void> open(WidgetTester tester, void Function(bool) onAnswer) async {
      await _openFromButton<bool>(tester, (c) async {
        final answer = await confirmByTyping(
          c,
          title: 'Delete account',
          body: 'Irreversible',
          actionLabel: 'Delete',
          cancelLabel: 'Cancel',
          word: 'DELETE',
          typeToConfirmLabel: 'Type DELETE',
        );
        onAnswer(answer);
        return answer;
      });
    }

    testWidgets('the action stays disabled until the word is typed', (tester) async {
      await open(tester, (_) {});
      final button = find.byKey(const Key('confirm-typing-action'));
      expect(tester.widget<FilledButton>(button).onPressed, isNull);
      await tester.enterText(find.byKey(const Key('confirm-typing-field')), 'delete');
      await tester.pump();
      expect(tester.widget<FilledButton>(button).onPressed, isNotNull);
    });

    testWidgets('typing the word then pressing the action confirms', (tester) async {
      bool? answer;
      await open(tester, (a) => answer = a);
      await tester.enterText(find.byKey(const Key('confirm-typing-field')), 'DELETE');
      await tester.pump();
      await tester.tap(find.byKey(const Key('confirm-typing-action')));
      await tester.pumpAndSettle();
      expect(answer, isTrue);
    });
  });

  testWidgets('TextPromptDialog pops the trimmed text', (tester) async {
    String? text;
    await _openFromButton<String>(tester, (c) async {
      text = await showDialog<String>(
        context: c,
        builder: (_) => const TextPromptDialog(
          title: 'Name',
          label: 'Name',
          fieldKey: Key('field'),
          submitKey: Key('submit'),
          submitLabel: 'OK',
          cancelLabel: 'Cancel',
        ),
      );
      return text;
    });
    await tester.enterText(find.byKey(const Key('field')), '  Bob  ');
    await tester.tap(find.byKey(const Key('submit')));
    await tester.pumpAndSettle();
    expect(text, 'Bob');
  });

  group('showUndoSnackBar', () {
    testWidgets('closes by itself after its duration', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showUndoSnackBar(
                  ScaffoldMessenger.of(context),
                  message: 'Deleted',
                  undoLabel: 'Undo',
                  onUndo: () {},
                  duration: const Duration(seconds: 2),
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      await tester.pump();
      expect(find.text('Deleted'), findsOneWidget);
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      expect(find.text('Deleted'), findsNothing);
    });

    testWidgets('Undo calls the callback', (tester) async {
      var undone = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showUndoSnackBar(
                  ScaffoldMessenger.of(context),
                  message: 'Deleted',
                  undoLabel: 'Undo',
                  onUndo: () => undone = true,
                ),
                child: const Text('go'),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('go'));
      // Wait for the bar's slide-in animation (it starts on the second pump) before pressing its action.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 750));
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undone, isTrue);
      // Let the bar's own timer end so no timer is left pending.
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();
    });
  });

  group('appearance', () {
    test('colorFromHex reads a valid code and falls back otherwise', () {
      expect(colorFromHex('#3B82F6'), const Color(0xFF3B82F6));
      expect(colorFromHex('#12345', fallback: Colors.red), Colors.red);
      expect(colorFromHex(null), Colors.grey);
    });

    test('appearanceIcon falls back for an unknown name', () {
      expect(appearanceIcon('nope', fallback: Icons.label), Icons.label);
      expect(appearanceIcon('home', fallback: Icons.label), Icons.home);
    });

    test('two appearances with the same values are equal', () {
      expect(const Appearance(icon: 'home', color: '#fff'),
          const Appearance(icon: 'home', color: '#fff'));
    });

    testWidgets('AppearanceAvatar shows the initial when no icon is chosen', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: AppearanceAvatar(
            appearance: Appearance(),
            fallbackIcon: Icons.person,
            initial: 'zoé',
          ),
        ),
      );
      expect(find.text('Z'), findsOneWidget);
    });

    testWidgets('the dialog returns the chosen icon and colour', (tester) async {
      Appearance? answer;
      await _openFromButton<Appearance>(tester, (c) async {
        answer = await showAppearanceDialog(
          c,
          title: 'Look',
          icons: const ['home', 'star'],
          initial: const Appearance(),
          fallbackIcon: Icons.person,
          labels:
              const AppearanceLabels(icon: 'Icon', color: 'Colour', save: 'Save', cancel: 'Cancel'),
        );
        return answer;
      });
      await tester.tap(find.byKey(const Key('icon-star')));
      await tester.tap(find.byKey(const Key('color-#EF4444')));
      await tester.pump();
      await tester.tap(find.byKey(const Key('appearance-save')));
      await tester.pumpAndSettle();
      expect(answer, const Appearance(icon: 'star', color: '#EF4444'));
    });

    testWidgets('the "no icon" choice only appears when a label is given', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppearancePicker(
              icons: const ['home'],
              icon: null,
              color: null,
              onIconChanged: (_) {},
              onColorChanged: (_) {},
              labels: const AppearanceLabels(icon: 'I', color: 'C', save: 'S', cancel: 'X'),
            ),
          ),
        ),
      );
      expect(find.byKey(const Key('icon-none')), findsNothing);
    });
  });

  group('PersistedPreference', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('a remembered filter starts empty then reads the stored value', () async {
      SharedPreferences.setMockInitialValues({'filter:stats-period': '30d'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      expect(container.read(rememberedFilterProvider('stats-period')), isNull);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(rememberedFilterProvider('stats-period')), '30d');
    });

    test('a choice is stored and can be forgotten', () async {
      final container = ProviderContainer();
      addTearDown(container.dispose);
      final notifier = container.read(rememberedFilterProvider('history-vehicle').notifier);
      await notifier.choose('car-1');
      expect((await SharedPreferences.getInstance()).getString('filter:history-vehicle'), 'car-1');
      await notifier.choose(null);
      expect((await SharedPreferences.getInstance()).getString('filter:history-vehicle'), isNull);
    });

    test('a choice made before the stored value is read wins', () async {
      SharedPreferences.setMockInitialValues({'filter:p': 'old'});
      final container = ProviderContainer();
      addTearDown(container.dispose);
      await container.read(rememberedFilterProvider('p').notifier).choose('new');
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(rememberedFilterProvider('p')), 'new');
    });

    test('a stored language the app no longer offers is ignored', () async {
      SharedPreferences.setMockInitialValues({'language': 'es'});
      final provider = languagePreferenceProvider(initial: 'fr', supported: const ['fr', 'en']);
      final container = ProviderContainer();
      addTearDown(container.dispose);
      container.read(provider);
      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(container.read(provider), 'fr');
    });
  });

  group('theme and charts', () {
    const palette = BrandPalette(
      deep: Color(0xFF1B3A57),
      accent: Color(0xFF8CCBEA),
      warm: Color(0xFFF4C28B),
      cream: Color(0xFFF3F9FD),
      warmSoft: Color(0xFFFCE8D2),
      darkSurface: Color(0xFF0F2438),
      darkContainer: Color(0xFF24506F),
    );

    test('the light theme uses the palette background', () {
      expect(buildLightTheme(palette).scaffoldBackgroundColor, palette.cream);
    });

    test('the dark theme uses the palette dark surface', () {
      expect(buildDarkTheme(palette).scaffoldBackgroundColor, palette.darkSurface);
    });

    testWidgets('the pie legend shows each label, value text and percentage', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PieChartView(
              slices: const [PieSlice(label: 'Ann', value: 30), PieSlice(label: 'Bob', value: 10)],
              valueText: (v) => '$v min',
            ),
          ),
        ),
      );
      expect(find.text('Ann'), findsOneWidget);
      expect(find.text('30 min · 75 %'), findsOneWidget);
      expect(find.text('10 min · 25 %'), findsOneWidget);
    });
  });

  group('AccountMenuButton', () {
    Future<void> show(WidgetTester tester, ValueChanged<AccountMenuChoice> onSelected) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            appBar: AppBar(
              actions: [
                AccountMenuButton(
                  name: 'Camille',
                  email: 'camille@example.ch',
                  avatar: const CircleAvatar(child: Text('C')),
                  labels: const AccountMenuLabels(
                    tooltip: 'Account',
                    edit: 'Edit my account',
                    logOut: 'Log out',
                  ),
                  onSelected: onSelected,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.tap(find.byType(PopupMenuButton<AccountMenuChoice>));
      await tester.pumpAndSettle();
    }

    testWidgets('the menu shows who is signed in', (tester) async {
      await show(tester, (_) {});
      expect(find.text('Camille'), findsOneWidget);
      expect(find.text('camille@example.ch'), findsOneWidget);
    });

    testWidgets('choosing log out reports it', (tester) async {
      AccountMenuChoice? choice;
      await show(tester, (c) => choice = c);
      await tester.tap(find.text('Log out'));
      await tester.pumpAndSettle();
      expect(choice, AccountMenuChoice.logOut);
    });

    testWidgets('the identity line is not a choice', (tester) async {
      AccountMenuChoice? choice;
      await show(tester, (c) => choice = c);
      await tester.tap(find.text('camille@example.ch'));
      await tester.pumpAndSettle();
      expect(choice, isNull);
    });
  });
}
