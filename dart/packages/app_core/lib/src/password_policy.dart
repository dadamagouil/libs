// Sign-up password rules, returned as codes so the app translates them (this package knows no language).

/// One rule a password can break.
enum PasswordIssue { tooShort, noLowercase, noUppercase, noDigit, noSpecial }

/// Password rules applied at sign-up.
///
/// Why sign-in is not checked: an account created before the rules existed must still be able to sign in,
/// otherwise the rules would lock people out.
class PasswordPolicy {
  const PasswordPolicy({
    this.minLength = 10,
    this.requireMixedCase = true,
    this.requireDigit = true,
    this.requireSpecial = true,
  });

  /// Only a minimum length (the lightest policy).
  const PasswordPolicy.lengthOnly([int minLength = 8])
      : this(
          minLength: minLength,
          requireMixedCase: false,
          requireDigit: false,
          requireSpecial: false,
        );

  final int minLength;
  final bool requireMixedCase;
  final bool requireDigit;
  final bool requireSpecial;

  // Accented letters count as letters (the apps are used in French, German and Italian).
  static final _lower = RegExp('[a-zà-ÿ]');
  static final _upper = RegExp('[A-ZÀ-Þ]');
  static final _digit = RegExp('[0-9]');
  static final _special = RegExp(r'[^A-Za-zÀ-ÿ0-9\s]');

  /// Rules the password does not respect; empty when it is valid.
  List<PasswordIssue> issues(String password) => [
        if (password.length < minLength) PasswordIssue.tooShort,
        if (requireMixedCase && !_lower.hasMatch(password)) PasswordIssue.noLowercase,
        if (requireMixedCase && !_upper.hasMatch(password)) PasswordIssue.noUppercase,
        if (requireDigit && !_digit.hasMatch(password)) PasswordIssue.noDigit,
        if (requireSpecial && !_special.hasMatch(password)) PasswordIssue.noSpecial,
      ];

  bool isValid(String password) => issues(password).isEmpty;
}
