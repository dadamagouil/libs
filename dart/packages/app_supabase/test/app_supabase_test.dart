import 'package:app_supabase/app_supabase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() {
  group('authFailureFrom', () {
    test('invalid credentials code is recognised', () {
      final failure = authFailureFrom(const AuthException('x', code: 'invalid_credentials'));
      expect(failure.kind, AuthFailureKind.invalidCredentials);
    });

    test('both "already exists" codes mean the e-mail is taken', () {
      for (final code in ['user_already_exists', 'email_exists']) {
        expect(authFailureFrom(AuthException('x', code: code)).kind, AuthFailureKind.emailTaken);
      }
    });

    test('rate limit codes are grouped', () {
      expect(
        authFailureFrom(const AuthException('x', code: 'over_email_send_rate_limit')).kind,
        AuthFailureKind.rateLimited,
      );
    });

    test('an unknown code keeps its technical detail', () {
      final failure = authFailureFrom(const AuthException('boom', code: 'weird'));
      expect(failure.kind, AuthFailureKind.other);
      expect(failure.detail, contains('weird'));
    });

    test('a socket error is a network failure', () {
      expect(authFailureFrom(Exception('SocketException: no route')).kind, AuthFailureKind.network);
    });

    test('a very long unknown error is cut to 200 characters', () {
      expect(authFailureFrom(Exception('x' * 500)).detail!.length, 200);
    });
  });

  group('AuthStatus', () {
    test('two statuses with the same values are equal', () {
      expect(const AuthStatus(userId: 'a'), const AuthStatus(userId: 'a'));
    });
    test('recovering differs', () {
      expect(const AuthStatus(userId: 'a') == const AuthStatus(userId: 'a', recovering: true),
          isFalse);
    });
    test('no user means signed out', () {
      expect(const AuthStatus().signedIn, isFalse);
    });
  });

  group('error messages', () {
    test('errorDetail adds the code of a database error', () {
      expect(errorDetail(const PostgrestException(message: 'nope', code: '42501')), 'nope (42501)');
    });
    test('hintCodeOf reads the code after the prefix', () {
      const error = PostgrestException(message: 'limit', hint: 'PLAN_LIMIT:members');
      expect(hintCodeOf(error, 'PLAN_LIMIT:'), 'members');
    });
    test('hintCodeOf ignores another hint', () {
      const error = PostgrestException(message: 'limit', hint: 'OTHER');
      expect(hintCodeOf(error, 'PLAN_LIMIT:'), isNull);
    });
    test('hintCodeOf ignores errors that are not database errors', () {
      expect(hintCodeOf(Exception('x'), 'PLAN_LIMIT:'), isNull);
    });
  });

  test('without dart-define the config is not configured and diagnostics are on', () {
    expect(AppConfig.isConfigured, isFalse);
    expect(devDiagnosticsEnabled, isTrue);
  });
}
