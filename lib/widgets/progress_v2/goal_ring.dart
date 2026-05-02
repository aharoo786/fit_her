import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

/// Phase C primitive — circular progress ring used 5x on the Progress hub
/// (hero goal ring + 4 glance rings: classes, sleep, water, goal).
///
/// Stand-alone: takes everything via props, no controller / repository
/// dependency. Renders correctly inside any [Container] with finite size.
///
/// Sizing: defaults to 80x80 logical px. Pass [size] to grow it (the hero
/// ring uses 140). The track + pointer + center text scale automatically
/// from the value passed.
///
/// Why Syncfusion: `syncfusion_flutter_gauges: ^27.1.56` is already in
/// pubspec.yaml. The brief explicitly forbids new deps. SfRadialGauge gives
/// us a single radial axis with a coloured range pointer (the actual
/// progress) and a transparent track underneath — exactly the two-layer
/// look the mockup uses.
class GoalRing extends StatelessWidget {
  /// Progress as a fraction 0.0..1.0. Values outside that range are clamped.
  /// `null` is treated as "no data" — the ring renders the track only with
  /// a muted center label ("—").
  final double? progress;

  /// Filled portion colour. Track is automatically derived as a 12% alpha
  /// of this colour so call sites don't have to hand-pick a paired colour.
  final Color color;

  /// Central text. Use the formatted display ("42%", "16/20", "6.5h").
  /// Empty string renders no center label.
  final String centerText;

  /// Optional secondary label rendered under [centerText] in a smaller
  /// muted weight. Use for ring-name labels like "Classes" or "Sleep".
  final String? labelText;

  /// Outer diameter of the ring in logical px. Default 80.
  final double size;

  /// Track + filled-arc thickness as a fraction of the radius. Default 0.18
  /// matches the mockup's chunky rings; pass 0.10 for thinner gauge-style
  /// rings if needed elsewhere.
  final double thicknessFactor;

  /// Optional override for the track colour. Defaults to a 12% alpha of
  /// [color] so the ring reads as one continuous shape.
  final Color? trackColor;

  /// Optional override for the center text style. The widget computes a
  /// reasonable default from [size] when null.
  final TextStyle? centerTextStyle;

  /// Optional override for the label text style. Same fallback rules.
  final TextStyle? labelTextStyle;

  const GoalRing({
    Key? key,
    required this.progress,
    required this.color,
    required this.centerText,
    this.labelText,
    this.size = 80,
    this.thicknessFactor = 0.18,
    this.trackColor,
    this.centerTextStyle,
    this.labelTextStyle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final clamped = progress == null ? 0.0 : progress!.clamp(0.0, 1.0);
    final hasData = progress != null;

    final track = trackColor ?? color.withOpacity(0.12);
    // Thickness is given to Syncfusion as a fraction-of-radius string. We
    // expose it as a unit double so callers don't have to know that detail.
    final thicknessFactorClamped =
        thicknessFactor.clamp(0.04, 0.4).toStringAsFixed(2);

    final defaultCenterStyle = TextStyle(
      fontSize: size * 0.22,
      fontWeight: FontWeight.w700,
      color: hasData ? const Color(0xFF163220) : const Color(0xFF9AB09A),
      height: 1.0,
    );
    final defaultLabelStyle = TextStyle(
      fontSize: size * 0.11,
      fontWeight: FontWeight.w500,
      color: const Color(0xFF9AB09A),
      height: 1.1,
    );

    return SizedBox(
      width: size,
      height: size,
      child: SfRadialGauge(
        axes: <RadialAxis>[
          RadialAxis(
            minimum: 0,
            maximum: 1,
            // Start at 12 o'clock and sweep clockwise like every other ring
            // chart in the app.
            startAngle: 270,
            endAngle: 270,
            showLabels: false,
            showTicks: false,
            radiusFactor: 1.0,
            axisLineStyle: AxisLineStyle(
              thickness: double.parse(thicknessFactorClamped),
              thicknessUnit: GaugeSizeUnit.factor,
              color: track,
            ),
            pointers: <GaugePointer>[
              RangePointer(
                value: hasData ? clamped : 0.0,
                width: double.parse(thicknessFactorClamped),
                sizeUnit: GaugeSizeUnit.factor,
                cornerStyle: CornerStyle.bothCurve,
                color: color,
              ),
            ],
            annotations: <GaugeAnnotation>[
              GaugeAnnotation(
                positionFactor: 0,
                angle: 90,
                widget: _CenterStack(
                  centerText: hasData ? centerText : '—',
                  labelText: labelText,
                  centerStyle: centerTextStyle ?? defaultCenterStyle,
                  labelStyle: labelTextStyle ?? defaultLabelStyle,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CenterStack extends StatelessWidget {
  final String centerText;
  final String? labelText;
  final TextStyle centerStyle;
  final TextStyle labelStyle;

  const _CenterStack({
    required this.centerText,
    required this.labelText,
    required this.centerStyle,
    required this.labelStyle,
  });

  @override
  Widget build(BuildContext context) {
    final hasLabel = labelText != null && labelText!.isNotEmpty;
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (centerText.isNotEmpty)
          Text(centerText, style: centerStyle, textAlign: TextAlign.center),
        if (hasLabel)
          Padding(
            padding: const EdgeInsets.only(top: 2),
            child: Text(
              labelText!,
              style: labelStyle,
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }
}
