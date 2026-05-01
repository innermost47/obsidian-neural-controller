import 'package:flutter/material.dart';
import '../theme.dart';
import '../../services/haptic.dart';

class CrossfaderPanel extends StatelessWidget {
  final List<double> pairValues;
  final int curveMode;
  final ValueChanged<int>? onCurveChanged;
  final void Function(int pairIndex, double value)? onPairChanged;
  final List<Color>? trackColours;

  const CrossfaderPanel({
    super.key,
    required this.pairValues,
    required this.curveMode,
    this.onCurveChanged,
    this.onPairChanged,
    this.trackColours,
  });

  Color _colourFor(int slot) {
    if (trackColours != null && slot < trackColours!.length) {
      return trackColours![slot];
    }
    return ObsidianTheme.primary;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 280,
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: ObsidianTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: ObsidianTheme.border),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 2, bottom: 8),
              child: Text(
                'XFADER',
                style: ObsidianTheme.labelTiny.copyWith(
                  color: ObsidianTheme.textMuted,
                  letterSpacing: 1.2,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (int i = 0; i < 4; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: _PairRow(
                    leftLabel: 'T${i + 1}',
                    rightLabel: 'T${i + 5}',
                    leftColour: _colourFor(i),
                    rightColour: _colourFor(i + 4),
                    value: pairValues[i],
                    onChanged: (v) => onPairChanged?.call(i, v),
                  ),
                ),
              ),
            const SizedBox(height: 12),
            _CurveSegmented(
              mode: curveMode,
              onChanged: onCurveChanged,
            ),
          ],
        ),
      ),
    );
  }
}

class _PairRow extends StatelessWidget {
  final String leftLabel;
  final String rightLabel;
  final Color leftColour;
  final Color rightColour;
  final double value;
  final ValueChanged<double>? onChanged;

  const _PairRow({
    required this.leftLabel,
    required this.rightLabel,
    required this.leftColour,
    required this.rightColour,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final morphed = Color.lerp(leftColour, rightColour, value) ?? leftColour;
    final leftIntensity = 1.0 - value;
    final rightIntensity = value;

    return Row(
      children: [
        _LedDot(colour: leftColour, intensity: leftIntensity),
        const SizedBox(width: 4),
        SizedBox(
          width: 16,
          child: Text(
            leftLabel,
            style: ObsidianTheme.labelTiny.copyWith(
              color: ObsidianTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ),
        Expanded(
          child: _HSlider(
            value: value,
            thumbColour: morphed,
            onChanged: onChanged,
          ),
        ),
        SizedBox(
          width: 16,
          child: Text(
            rightLabel,
            textAlign: TextAlign.right,
            style: ObsidianTheme.labelTiny.copyWith(
              color: ObsidianTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 9,
            ),
          ),
        ),
        const SizedBox(width: 4),
        _LedDot(colour: rightColour, intensity: rightIntensity),
      ],
    );
  }
}

class _LedDot extends StatelessWidget {
  final Color colour;
  final double intensity;

  const _LedDot({required this.colour, required this.intensity});

  @override
  Widget build(BuildContext context) {
    final i = intensity.clamp(0.0, 1.0);
    final lit = i > 0.05;
    return SizedBox(
      width: 14,
      height: 14,
      child: Stack(
        alignment: Alignment.center,
        children: [
          if (lit)
            Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: colour.withOpacity(0.5 * i),
                    blurRadius: 8,
                    spreadRadius: 1,
                  ),
                ],
              ),
            ),
          Container(
            width: 11,
            height: 11,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  ObsidianTheme.cardBg,
                  ObsidianTheme.border,
                ],
              ),
            ),
          ),
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: lit
                  ? Color.lerp(colour, Colors.white, 0.15 * i)
                  : colour.withOpacity(0.25),
              boxShadow: lit
                  ? [
                      BoxShadow(
                        color: colour.withOpacity(0.8 * i),
                        blurRadius: 3,
                      ),
                    ]
                  : null,
            ),
          ),
        ],
      ),
    );
  }
}

class _HSlider extends StatefulWidget {
  final double value;
  final Color thumbColour;
  final bool ticks;
  final ValueChanged<double>? onChanged;

  const _HSlider({
    required this.value,
    required this.thumbColour,
    this.ticks = false,
    required this.onChanged,
  });

  @override
  State<_HSlider> createState() => _HSliderState();
}

class _HSliderState extends State<_HSlider> {
  int _lastHapticBucket = -1;
  final double _thumbW = 26.0;

  void _emit(double dx, double width) {
    final usableWidth = width - _thumbW;
    double v;
    if (usableWidth <= 0) {
      v = 0;
    } else {
      v = (dx - (_thumbW / 2)) / usableWidth;
    }

    final clamped = v.clamp(0.0, 1.0);
    final bucket = (clamped * 20).round();

    if (bucket != _lastHapticBucket) {
      Haptic.light();
      _lastHapticBucket = bucket;
    }
    widget.onChanged?.call(clamped);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final w = c.maxWidth;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onHorizontalDragStart: (d) {
            _lastHapticBucket = (widget.value * 20).round();
            _emit(d.localPosition.dx, w);
          },
          onHorizontalDragUpdate: (d) {
            _emit(d.localPosition.dx, w);
          },
          onTapDown: (d) {
            _lastHapticBucket = -1;
            _emit(d.localPosition.dx, w);
          },
          onDoubleTap: () {
            Haptic.medium();
            widget.onChanged?.call(0.5);
          },
          child: SizedBox(
            height: double.infinity,
            width: w,
            child: CustomPaint(
              painter: _SliderPainter(
                value: widget.value,
                thumbColour: widget.thumbColour,
                ticks: widget.ticks,
                thumbW: _thumbW,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SliderPainter extends CustomPainter {
  final double value;
  final Color thumbColour;
  final bool ticks;
  final double thumbW;

  _SliderPainter({
    required this.value,
    required this.thumbColour,
    required this.ticks,
    required this.thumbW,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cy = size.height / 2;
    final trackY = cy;
    final trackPaint = Paint()..color = ObsidianTheme.border;

    final padding = thumbW / 2;
    final usableWidth = size.width - thumbW;

    if (ticks) {
      final tickPaint = Paint()
        ..color = ObsidianTheme.textMuted.withOpacity(0.4);
      final majorTickPaint = Paint()
        ..color = ObsidianTheme.textMuted.withOpacity(0.7);
      const numTicks = 9;
      for (int i = 0; i < numTicks; i++) {
        final t = i / (numTicks - 1);
        final x = padding + (t * usableWidth);
        final isEdge = (i == 0 || i == numTicks - 1);
        final isMid = (i == numTicks ~/ 2);
        final isMajor = isEdge || isMid;
        final h = isMajor ? 5.0 : 3.0;
        final p = isMajor ? majorTickPaint : tickPaint;
        canvas.drawRect(
          Rect.fromLTWH(x - 0.5, cy - 8 - h, 1.0, h),
          p,
        );
        canvas.drawRect(
          Rect.fromLTWH(x - 0.5, cy + 8, 1.0, h),
          p,
        );
      }
    }

    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, trackY - 3, size.width, 6),
      const Radius.circular(3),
    );
    canvas.drawRRect(trackRect, trackPaint);

    final thumbX = padding + (value * usableWidth);
    final thumbH = 36.0;

    final thumbRect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(thumbX, cy),
        width: thumbW,
        height: thumbH,
      ),
      const Radius.circular(4),
    );

    canvas.drawRRect(
      thumbRect.shift(const Offset(0, 2.0)),
      Paint()..color = Colors.black.withOpacity(0.4),
    );

    canvas.drawRRect(
      thumbRect,
      Paint()..color = ObsidianTheme.border,
    );

    final markPaint = Paint()
      ..color = thumbColour
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(
      Offset(thumbX, cy - 8),
      Offset(thumbX, cy + 8),
      markPaint,
    );
  }

  @override
  bool shouldRepaint(_SliderPainter old) =>
      old.value != value ||
      old.thumbColour != thumbColour ||
      old.ticks != ticks;
}

class _CurveSegmented extends StatelessWidget {
  final int mode;
  final ValueChanged<int>? onChanged;

  const _CurveSegmented({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ObsidianTheme.bgCream.withOpacity(0.05),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: ObsidianTheme.border.withOpacity(0.5)),
      ),
      padding: const EdgeInsets.all(2),
      child: Row(
        children: [
          _seg('LIN', 0),
          _seg('EQ', 1),
          _seg('DJ', 2),
        ],
      ),
    );
  }

  Widget _seg(String label, int value) {
    final active = mode == value;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          Haptic.light();
          onChanged?.call(value);
        },
        child: Container(
          height: 28,
          decoration: BoxDecoration(
            color: active ? ObsidianTheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(3),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: ObsidianTheme.labelTiny.copyWith(
              color: active
                  ? ObsidianTheme.textOnPrimary
                  : ObsidianTheme.textSecondary,
              fontWeight: FontWeight.w700,
              fontSize: 11,
              letterSpacing: 0.8,
            ),
          ),
        ),
      ),
    );
  }
}
