final _emailPattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]{2,}$');

/// A loose e-mail shape check (something@domain.tld). The server is the real judge; this only catches typos
/// before a round trip.
bool isValidEmail(String value) => _emailPattern.hasMatch(value.trim());
