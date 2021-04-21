import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wowtalent/model/theme.dart';

class StarThumb extends SliderComponentShape {
  final double thumbRadius;
  final int min;
  final int max;

  const StarThumb({
    @required this.thumbRadius,
    this.min = 0,
    this.max = 5,
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    Animation<double> activationAnimation,
    Animation<double> enableAnimation,
    bool isDiscrete,
    TextPainter labelPainter,
    RenderBox parentBox,
    SliderThemeData sliderTheme,
    TextDirection textDirection,
    double value,
    double textScaleFactor,
    Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    // Thumb colors
    final paint = Paint()
      ..color = AppTheme.secondaryColor
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;
    // Thumb text style
    TextSpan span = TextSpan(
      style: TextStyle(
        fontSize: thumbRadius * .6,
        fontWeight: FontWeight.w700,
        color: AppTheme.pureBlackColor,
      ),
      text: getValue(value) == "0" ? "" : getValue(value),
    );

    //Thumb text paint
    TextPainter tp = TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter = Offset(
        (center.dx - (tp.width / 2) * 0.8 + (value < 0.6 ? 0 : value * 1.4)),
        (center.dy - (tp.height / 2) * 1.1));

    //Thumb shape paint
    final innerCirclePoints = 5; //how many edges you need?
    final innerRadius = thumbRadius * 0.45 * (0.2 + value * 0.25) * 2.5;
    final outerRadius = thumbRadius * 0.85 * (0.2 + value * 0.25) * 2.5;

    List<Map> points = calcStarPoints(center.dx * 1.01, center.dy * 0.995,
        innerCirclePoints, innerRadius, outerRadius);
    var star = Path()..moveTo(points[0]['x'], points[0]['y']);
    points.forEach((point) {
      star.lineTo(point['x'], point['y']);
    });

    canvas.drawPath(
      Path.combine(
        PathOperation.union,
        Path()..addOval(Rect.fromCircle(center: textCenter, radius: 0)),
        star,
      ),
      paint,
    );
    tp.paint(canvas, textCenter);
  }

  List<Map> calcStarPoints(
      centerX, centerY, innerCirclePoints, innerRadius, outerRadius) {
    final angle = ((math.pi) / innerCirclePoints);
    var angleOffsetToCenterStar = 0.91;

    var totalPoints = innerCirclePoints * 2; // 10 in a 5-points star
    List<Map> points = [];
    for (int i = 0; i < totalPoints; i++) {
      bool isEvenIndex = i % 2 == 0;
      var r = isEvenIndex ? outerRadius : innerRadius;

      var currY =
          centerY + math.cos(i * angle + angleOffsetToCenterStar - 0.3) * r;
      var currX =
          centerX + math.sin(i * angle + angleOffsetToCenterStar - 0.3) * r;
      points.add({'x': currX, 'y': currY});
    }
    return points;
  }

  String getValue(double value) {
    return (min + (max - min) * value).round().toString();
  }
}
