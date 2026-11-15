import 'package:app_core/app_core.dart';
import 'package:test/test.dart';

void main() {
  group('PasswordPolicy', () {
    const policy = PasswordPolicy();

    test('a strong password has no issue', () {
      expect(policy.issues('Abcdefgh1!'), isEmpty);
    });

    test('a short password is reported as too short', () {
      expect(policy.issues('Ab1!'), [PasswordIssue.tooShort]);
    });

    test('every missing character class is reported', () {
      expect(policy.issues('abcdefghijk'), [
        PasswordIssue.noUppercase,
        PasswordIssue.noDigit,
        PasswordIssue.noSpecial,
      ]);
    });

    test('accented letters count as letters', () {
      expect(policy.issues('éÉ12345678!'), isEmpty);
    });

    test('lengthOnly accepts any password of the minimum length', () {
      expect(const PasswordPolicy.lengthOnly(8).isValid('abcdefgh'), isTrue);
      expect(const PasswordPolicy.lengthOnly(8).isValid('abcdefg'), isFalse);
    });
  });

  group('isValidEmail', () {
    test('accepts a normal address, ignoring surrounding spaces', () {
      expect(isValidEmail(' a@b.ch '), isTrue);
    });
    test('rejects a missing domain suffix', () {
      expect(isValidEmail('a@b'), isFalse);
    });
  });

  group('auth links', () {
    test('a code in the query is an auth link', () {
      expect(isAuthLink(Uri.parse('https://x.ch/app/?code=abc')), isTrue);
    });
    test('an access token in the fragment is an auth link', () {
      expect(isAuthLink(Uri.parse('https://x.ch/app/#access_token=abc&type=signup')), isTrue);
    });
    test('a plain address is not an auth link', () {
      expect(isAuthLink(Uri.parse('https://x.ch/app/#/history')), isFalse);
    });
    test('recovery token is read only with type=recovery', () {
      expect(recoveryTokenHash(Uri.parse('https://x.ch/?token_hash=h&type=recovery')), 'h');
      expect(recoveryTokenHash(Uri.parse('https://x.ch/?token_hash=h&type=signup')), isNull);
      expect(recoveryTokenHash(Uri.parse('https://x.ch/')), isNull);
    });
    test('a reset e-mail is recent for two hours', () {
      final now = DateTime.utc(2026, 1, 1, 12);
      expect(isRecentRecovery('2026-01-01T11:00:00Z', now), isTrue);
      expect(isRecentRecovery('2026-01-01T09:00:00Z', now), isFalse);
      expect(isRecentRecovery('2026-01-01T13:00:00Z', now), isFalse);
      expect(isRecentRecovery(null, now), isFalse);
    });
  });

  group('money', () {
    test('keypad builds a number digit by digit', () {
      var text = '';
      for (final key in ['4', '5', '.', '5']) {
        text = keypadPress(text, key);
      }
      expect(text, '45.5');
    });
    test('keypad keeps at most two decimals', () {
      expect(keypadPress('1.25', '9'), '1.25');
    });
    test('keypad starts a decimal with 0.', () {
      expect(keypadPress('', '.'), '0.');
    });
    test('keypad erases the last character', () {
      expect(keypadPress('12', '<'), '1');
    });
    test('parseMinor converts to minor units', () {
      expect(parseMinor('45.5'), 4550);
      expect(parseMinor('.5'), 50);
      expect(parseMinor(''), isNull);
    });
    test('minorToInput drops useless zeros', () {
      expect(minorToInput(4550), '45.5');
      expect(minorToInput(4500), '45');
      expect(minorToInput(5), '0.05');
    });
    test('parseRate accepts a comma and rejects zero', () {
      expect(parseRate('0,93'), 0.93);
      expect(parseRate('0'), isNull);
      expect(parseRate('abc'), isNull);
    });
  });

  group('durations', () {
    test('formatClock pads each part', () {
      expect(formatClock(const Duration(hours: 1, minutes: 5, seconds: 9)), '01:05:09');
    });
    test('formatShortDuration picks the largest unit', () {
      expect(formatShortDuration(7500), '2 h 5 min');
      expect(formatShortDuration(720), '12 min');
      expect(formatShortDuration(40), '40 s');
    });
  });

  group('csv', () {
    test('a formula-looking text is neutralised', () {
      expect(csvCell('=SUM(A1)'), "'=SUM(A1)");
    });
    test('a cell with the separator is quoted', () {
      expect(csvCell('a;b'), '"a;b"');
    });
    test('quotes are doubled', () {
      expect(csvCell('say "hi"'), '"say ""hi"""');
    });
    test('toCsv writes the header then one line per row', () {
      expect(
        toCsv('a;b', [
          [1, 'x'],
          [2, null],
        ]),
        'a;b\n1;x\n2;',
      );
    });
    test('csvDateTime of null is empty', () {
      expect(csvDateTime(null), '');
    });
  });

  group('misc', () {
    test('shareFractions sums to one', () {
      expect(shareFractions([1, 1, 2]), [0.25, 0.25, 0.5]);
    });
    test('shareFractions of a zero total is all zeros', () {
      expect(shareFractions([0, 0]), [0, 0]);
    });
    test('confirm word ignores case and spaces', () {
      expect(matchesConfirmWord(' delete ', 'DELETE'), isTrue);
      expect(matchesConfirmWord('del', 'DELETE'), isFalse);
    });
    test('parseHexColor reads six digits with or without #', () {
      expect(parseHexColor('#3B82F6'), 0xFF3B82F6);
      expect(parseHexColor('3B82F6'), 0xFF3B82F6);
    });
    test('parseHexColor rejects a wrong length', () {
      expect(parseHexColor('#12345'), isNull);
      expect(parseHexColor(null), isNull);
    });
    test('initialsOf takes two words at most', () {
      expect(initialsOf('anne claire martin'), 'AC');
      expect(initialsOf('   '), '?');
    });
    test('LanguageSupport falls back for an unknown code', () {
      const support = LanguageSupport(codes: ['fr', 'en'], fallback: 'fr');
      expect(support.normalize('EN'), 'en');
      expect(support.normalize('es'), 'fr');
      expect(support.normalize(null), 'fr');
    });
  });
}
