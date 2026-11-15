/// Whether what was typed matches the word that confirms a destructive action ("DELETE"), ignoring case and
/// surrounding spaces.
bool matchesConfirmWord(String typed, String word) =>
    typed.trim().toLowerCase() == word.trim().toLowerCase();
