import 'dart:math' as math;

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

/// Default slice colours: a soft brand-neutral series, then complementary hues.
const defaultPieColors = [
  Color(0xFF8FD9BC),
  Color(0xFFFFB49E),
  Color(0xFF8B5CF6),
  Color(0xFFF59E0B),
  Color(0xFF10B981),
  Color(0xFF3B82F6),
  Color(0xFF84CC16),
  Color(0xFFF97316),
];

/// One slice: its legend label and its value (the slice size is relative to the total of all values).
@immutable
class PieSlice {
  const PieSlice({required this.label, required this.value});

  final String label;
  final num value;
}

/// Pie chart with its legend (label, value text, percentage).
///
/// [valueText] writes the value in the legend (for example "2 h 5 min"), so the chart works for durations,
/// amounts or counts alike.
class PieChartView extends StatelessWidget {
  const PieChartView({
    super.key,
    required this.slices,
    required this.valueText,
    this.colors = defaultPieColors,
    this.size = 180,
  });

  final List<PieSlice> slices;
  final String Function(num value) valueText;
  final List<Color> colors;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fractions = shareFractions([for (final slice in slices) slice.value]);
    return Column(
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CustomPaint(painter: _PiePainter(fractions, colors)),
        ),
        const SizedBox(height: 12),
        for (var i = 0; i < slices.length; i++)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 3),
            child: Row(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  decoration:
                      BoxDecoration(color: colors[i % colors.length], shape: BoxShape.circle),
                ),
                const SizedBox(width: 8),
                Expanded(child: Text(slices[i].label)),
                Text('${valueText(slices[i].value)} · ${(fractions[i] * 100).round()} %'),
              ],
            ),
          ),
      ],
    );
  }
}

class _PiePainter extends CustomPainter {
  _PiePainter(this.fractions, this.colors);

  final List<double> fractions;
  final List<Color> colors;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final fill = Paint()..style = PaintingStyle.fill;
    // Thin white separators between the slices.
    final border = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white;
    var start = -math.pi / 2;
    for (var i = 0; i < fractions.length; i++) {
      final sweep = fractions[i] * 2 * math.pi;
      if (sweep <= 0) continue;
      canvas.drawArc(rect, start, sweep, true, fill..color = colors[i % colors.length]);
      canvas.drawArc(rect, start, sweep, true, border);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(_PiePainter old) => old.fractions != fractions || old.colors != colors;
}
