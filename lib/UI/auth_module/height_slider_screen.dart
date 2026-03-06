import 'dart:ui';

import 'package:fitness_zone_2/values/my_imgs.dart';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:syncfusion_flutter_sliders/sliders.dart';

class HeightSliderScreen extends StatefulWidget {
  double minValue;
  double maxValue;
  double interval;
  double majorTickInterval;
  Function(dynamic value) updateValue;
  double value;
  String toolString;

  HeightSliderScreen(
      {required this.maxValue,
      required this.minValue,
      this.interval = 10,
      this.majorTickInterval = 1,
      required this.value,
      required this.toolString,
      required this.updateValue});
  @override
  State<HeightSliderScreen> createState() => _HeightSliderScreenState();
}

class _HeightSliderScreenState extends State<HeightSliderScreen> {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Image.asset(
          MyImgs.girlH,
          scale: 3,
        ),
        Stack(
          alignment: Alignment.centerRight,
          children: [
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: SfLinearGauge(
                orientation: LinearGaugeOrientation.vertical,
                isMirrored: true,
                minimum: widget.minValue,
                maximum: widget.maxValue,
                interval: widget.majorTickInterval,
                minorTicksPerInterval: widget.interval.toInt(),
                markerPointers: [
                  LinearShapePointer(
                    value: widget.value, // Set to the current height value
                    color: Colors.green, // Replace with your custom color
                    shapeType: LinearShapePointerType.invertedTriangle,
                    position: LinearElementPosition.inside,
                  ),
                ],
                axisTrackStyle: LinearAxisTrackStyle(
                  thickness: 2,
                  color: Colors.grey.shade300,
                ),
                majorTickStyle: const LinearTickStyle(
                  length: 70,
                  color: Color(0xffBABABA),
                ),
                minorTickStyle: const LinearTickStyle(
                  length: 25,
                  color: Color(0xffBABABA),
                ),
              ),
            ),
            SizedBox(
              height: 430,
              // color: Colors.amber,
              child: Theme(
                data: ThemeData(
                    tooltipTheme: const TooltipThemeData(
                        textStyle: TextStyle(color: Colors.black))),
                child: SfSlider.vertical(
                  min: widget.minValue,
                  max: widget.maxValue,
                  value: widget.value,
                  interval: widget.interval,
                  inactiveColor: Colors.transparent,
                  showTicks: true,
                  showLabels: false,
                  tickShape: SfTickShape(),
                  enableTooltip: true,
                  showDividers: true,
                  shouldAlwaysShowTooltip: true,
                  activeColor: Colors.transparent,
                  minorTicksPerInterval: 1,
                  onChanged: (dynamic value) {
                    setState(() {
                      widget.value = value;

                    });
                    widget.updateValue(value);
                  },
                  tooltipTextFormatterCallback:
                      (dynamic actualValue, String formattedText) {
                    return '$formattedText ${widget.toolString}'; // Customize tooltip text
                  },
                ),
              ),
            ),
          ],
        ),

        // Add a Slider to control the value
      ],
    );
  }
}
