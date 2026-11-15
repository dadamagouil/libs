/// Share of each value in the total (they sum to 1; all 0 when the total is not positive).
///
/// Used for pie charts, so the drawing code only deals with fractions.
List<double> shareFractions(List<num> values) {
  final total = values.fold<num>(0, (sum, value) => sum + value);
  if (total <= 0) return List.filled(values.length, 0);
  return [for (final value in values) value / total];
}
