import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../theme.dart';
import '../../services/haptic.dart';

enum ActionState { idle, pending, active }

class ObsidianActionButton extends StatefulWidget {
  final IconData idleIcon;
  final IconData activeIcon;
  final IconData? pendingIcon;
  final ActionState state;
  final VoidCallback onTap;
  final Color? activeColor;
  final double size;
  final String? tooltip;

  const ObsidianActionButton({
    super.key,
    required this.idleIcon,
    required this.activeIcon,
    this.pendingIcon,
    required this.state,
    required this.onTap,
    this.activeColor,
    this.size = 32,
    this.tooltip,
  });

  @override
  State<ObsidianActionButton> createState() => _ObsidianActionButtonState();
}

class _ObsidianActionButtonState extends State<ObsidianActionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _pulse = Tween(begin: 0.4, end: 1.0).animate(_ctrl);
  }

  @override
  void didUpdateWidget(covariant ObsidianActionButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state == ActionState.pending) {
      _ctrl.repeat(reverse: true);
    } else {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.activeColor ?? ObsidianTheme.primary;
    final isActive = widget.state == ActionState.active;
    final isPending = widget.state == ActionState.pending;

    final icon = isPending
        ? (widget.pendingIcon ?? widget.idleIcon)
        : isActive
            ? widget.activeIcon
            : widget.idleIcon;

    return GestureDetector(
      onTapDown: (_) {
        Haptic.light();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _pulse,
        builder: (context, child) {
          Color bgColor;
          if (isPending) {
            bgColor = Color.lerp(ObsidianTheme.cardBg, color, _pulse.value)!;
          } else if (isActive) {
            bgColor = color;
          } else {
            bgColor = ObsidianTheme.cardBg;
          }

          return AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: (isActive || isPending) ? color : ObsidianTheme.border,
              ),
            ),
            child: Icon(
              icon,
              size: widget.size * 0.5,
              color: (isActive || isPending)
                  ? ObsidianTheme.textOnPrimary
                  : ObsidianTheme.textSecondary,
            ),
          );
        },
      ),
    );
  }
}

class ObsidianKnob extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double size;
  final String label;
  final Color accentColor;

  const ObsidianKnob({
    super.key,
    required this.value,
    required this.onChanged,
    this.size = 44,
    this.label = '',
    this.accentColor = ObsidianTheme.primary,
  });

  @override
  State<ObsidianKnob> createState() => _ObsidianKnobState();
}

class _ObsidianKnobState extends State<ObsidianKnob> {
  double _dragStart = 0;
  double _valueStart = 0;
  int _lastHapticValue = -1;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onVerticalDragStart: (d) {
            _dragStart = d.localPosition.dy;
            _valueStart = widget.value;
            _lastHapticValue = (widget.value * 10).round();
            HapticFeedback.selectionClick();
          },
          onVerticalDragUpdate: (d) {
            final delta = (_dragStart - d.localPosition.dy) / 150;
            final newValue = (_valueStart + delta).clamp(0.0, 1.0);

            final currentVal = (newValue * 10).round();
            if (currentVal != _lastHapticValue) {
              Haptic.light();
              _lastHapticValue = currentVal;
            }

            widget.onChanged(newValue);
          },
          child: CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _KnobPainter(
              value: widget.value,
              accentColor: widget.accentColor,
            ),
          ),
        ),
        if (widget.label.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(widget.label, style: ObsidianTheme.labelTiny),
        ],
      ],
    );
  }
}

class _KnobPainter extends CustomPainter {
  final double value;
  final Color accentColor;

  _KnobPainter({required this.value, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;
    final radius = size.width / 2 - 4;
    final strokeW = 3.0;
    final rect = Rect.fromCircle(center: Offset(cx, cy), radius: radius);

    canvas.drawArc(
      rect,
      _degToRad(135),
      _degToRad(270),
      false,
      Paint()
        ..color = ObsidianTheme.border
        ..strokeWidth = strokeW
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    if (value > 0) {
      canvas.drawArc(
        rect,
        _degToRad(135),
        _degToRad(270 * value),
        false,
        Paint()
          ..color = accentColor
          ..strokeWidth = strokeW
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round,
      );
    }

    canvas.drawCircle(
      Offset(cx, cy),
      radius - strokeW - 2,
      Paint()..color = ObsidianTheme.cardBg,
    );

    final angle = _degToRad(135 + 270 * value);
    final innerR = radius - strokeW - 8.0;
    final outerR = radius - strokeW - 2.0;
    canvas.drawLine(
      Offset(cx + innerR * cos(angle), cy + innerR * sin(angle)),
      Offset(cx + outerR * cos(angle), cy + outerR * sin(angle)),
      Paint()
        ..color = accentColor
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );
  }

  double _degToRad(double deg) => deg * pi / 180;

  @override
  bool shouldRepaint(_KnobPainter old) => old.value != value;
}

class ObsidianFader extends StatefulWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final double height;
  final String label;
  final Color accentColor;

  const ObsidianFader({
    super.key,
    required this.value,
    required this.onChanged,
    this.height = 100,
    this.label = '',
    this.accentColor = ObsidianTheme.primary,
  });

  @override
  State<ObsidianFader> createState() => _ObsidianFaderState();
}

class _ObsidianFaderState extends State<ObsidianFader> {
  double _dragStart = 0;
  double _valueStart = 0;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.label.isNotEmpty) ...[
          Text(widget.label, style: ObsidianTheme.labelTiny),
          const SizedBox(height: 3),
        ],
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final h = constraints.maxHeight;

              return GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragStart: (d) {
                  _dragStart = d.localPosition.dy;
                  _valueStart = widget.value;
                  HapticFeedback.selectionClick();
                },
                onVerticalDragUpdate: (d) {
                  final delta = (_dragStart - d.localPosition.dy) / h;
                  widget.onChanged((_valueStart + delta).clamp(0.0, 1.0));
                },
                child: SizedBox(
                  width: 44,
                  height: h,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: 3,
                        height: h,
                        decoration: BoxDecoration(
                          color: ObsidianTheme.border,
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          width: 3,
                          height: h * widget.value,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                widget.accentColor,
                                ObsidianTheme.vuYellow
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: (h * widget.value).clamp(0.0, h) - 5,
                        child: Container(
                          width: 22,
                          height: 10,
                          decoration: BoxDecoration(
                            color: widget.accentColor,
                            borderRadius: BorderRadius.circular(3),
                            boxShadow: [
                              BoxShadow(
                                color: widget.accentColor.withOpacity(0.5),
                                blurRadius: 6,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class ObsidianPill extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;
  final double size;
  final TextStyle? textStyle;

  const ObsidianPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.activeColor,
    this.size = 28,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? ObsidianTheme.primary;
    return GestureDetector(
      onTapDown: (_) {
        Haptic.light();
        onTap();
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: active ? color : ObsidianTheme.cardBg,
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: active ? color : ObsidianTheme.border),
        ),
        child: Center(
          child: Text(
            label,
            style: (textStyle ?? ObsidianTheme.labelTiny).copyWith(
              color: active
                  ? ObsidianTheme.textOnPrimary
                  : ObsidianTheme.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }
}

class ObsidianIconBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  final Color? activeColor;
  final double size;
  final String? tooltip;

  const ObsidianIconBtn({
    super.key,
    required this.icon,
    required this.active,
    required this.onTap,
    this.activeColor,
    this.size = 32,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final btn = GestureDetector(
      onTapDown: (_) => Haptic.light(),
      onTapUp: (_) => onTap(),
      onTapCancel: () {},
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 120),
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: ObsidianTheme.cardBg,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: ObsidianTheme.border),
        ),
        child: Icon(
          icon,
          size: size * 0.45,
          color: ObsidianTheme.textSecondary,
        ),
      ),
    );
    return tooltip != null ? Tooltip(message: tooltip!, child: btn) : btn;
  }
}

class GenerateButton extends StatefulWidget {
  final bool isGenerating;
  final bool isDisabled;
  final VoidCallback onTap;

  const GenerateButton({
    super.key,
    required this.isGenerating,
    required this.onTap,
    this.isDisabled = false,
  });

  @override
  State<GenerateButton> createState() => _GenerateButtonState();
}

class _GenerateButtonState extends State<GenerateButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glow = Tween(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    if (widget.isGenerating) {
      _ctrl.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(covariant GenerateButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isGenerating && !oldWidget.isGenerating) {
      _ctrl.repeat(reverse: true);
    } else if (!widget.isGenerating && oldWidget.isGenerating) {
      _ctrl.stop();
      _ctrl.reset();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const colorA = Color(0xFF7B5EA7);
    const colorB = Color(0xFF9B7FC7);

    return GestureDetector(
      onTapDown: (_) {
        if (widget.isDisabled || widget.isGenerating) return;
        Haptic.medium();
        widget.onTap();
      },
      child: AnimatedBuilder(
        animation: _glow,
        builder: (_, __) {
          final Color bgColor;
          final Color borderColor;
          final Color textColor;

          if (widget.isDisabled) {
            bgColor = ObsidianTheme.cardBg;
            borderColor = ObsidianTheme.border;
            textColor = ObsidianTheme.textSecondary.withOpacity(0.4);
          } else if (widget.isGenerating) {
            bgColor = Color.lerp(colorA, colorB, _glow.value)!;
            borderColor = colorB.withOpacity(0.6 + _glow.value * 0.4);
            textColor = ObsidianTheme.textOnPrimary;
          } else {
            bgColor = colorA;
            borderColor = colorA.withOpacity(0.6);
            textColor = ObsidianTheme.textOnPrimary;
          }

          return Container(
            height: 30,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: borderColor),
            ),
            child: Center(
              child: Text(
                widget.isGenerating ? 'GEN…' : 'GEN',
                style: ObsidianTheme.labelBold.copyWith(color: textColor),
              ),
            ),
          );
        },
      ),
    );
  }
}

class ConnectionBadge extends StatefulWidget {
  final bool isConnected;
  final String deviceName;

  const ConnectionBadge({
    super.key,
    required this.isConnected,
    required this.deviceName,
  });

  @override
  State<ConnectionBadge> createState() => _ConnectionBadgeState();
}

class _ConnectionBadgeState extends State<ConnectionBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 900),
      vsync: this,
    )..repeat(reverse: true);
    _pulse = Tween(begin: 0.3, end: 1.0).animate(_ctrl);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ObsidianTheme.cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ObsidianTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulse,
            builder: (_, __) => Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: widget.isConnected
                    ? ObsidianTheme.vuGreen
                    : ObsidianTheme.primary.withOpacity(
                        widget.isConnected ? 1 : _pulse.value,
                      ),
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            widget.isConnected
                ? widget.deviceName.substring(
                    0,
                    widget.deviceName.length.clamp(0, 20),
                  )
                : 'Scanning…',
            style: ObsidianTheme.labelTiny,
          ),
        ],
      ),
    );
  }
}
