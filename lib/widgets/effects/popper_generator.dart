import 'package:flutter/material.dart';
import 'dart:math';

enum PopDirection { forwardX, backwardX }

class FunctionCurve extends Curve {
  const FunctionCurve({required this.func});

  final double Function(double) func;

  @override
  double transform(double t) {
    return func(t);
  }
}

class PopperConfig {
  static const motionCurveX = FunctionCurve(func: _curveX);
  static const motionCurveY = FunctionCurve(func: _curveY);
  
  static double _curveX(double t) {
    // More pronounced whorl with faster frequency
    return (-t * t * 0.1 + t * 0.9) + sin(t * 5) * 0.15;  // Increased frequency and amplitude
  }
  
  static double _curveY(double t) {
    // Faster fall with more pronounced waves
    return (t * t * 0.95 + sin(t * 4) * 0.15);  // Increased coefficients for both terms
  }
  
  static const defaultProps = {
    'numbers': 75,
    'posX': -80.0,
    'posY': 10.0,  // Start higher (was 50.0)
    'pieceHeight': 8.0,
    'pieceWidth': 12.0,
  };
}

class PartyPopperGenerator extends StatefulWidget {
  const PartyPopperGenerator({
    super.key,
    this.numbers = 100,
    required this.posX,
    required this.posY,
    required this.direction,
    required this.motionCurveX,
    required this.motionCurveY,
    required this.controller,
    this.pieceWidth = 15.0,
    this.pieceHeight = 5.0,
  }) : 
  assert(numbers > 0 && numbers < 500),
  assert(pieceWidth > 0),
  assert(pieceHeight > 0);

  // Controls the popping parameters
  final double posX;
  final double posY;
  final PopDirection direction;
  final Curve motionCurveX;
  final Curve motionCurveY;
  final AnimationController controller;

  // Controls the number and size of confetti pieces
  final int numbers;
  final double pieceWidth;
  final double pieceHeight;

  @override
  State<PartyPopperGenerator> createState() => _PartyPopperGeneratorState();
}

class _PartyPopperGeneratorState extends State<PartyPopperGenerator> {
  final randoms = <List<dynamic>>[];
  final colors = [
    Colors.orange[800], 
    Colors.green[800], 
    Colors.red[800], 
    Colors.orange[900], 
    Colors.yellow[800], 
    Colors.green[400], 
    Colors.blue[800], 
    Colors.blue[700], 
    Colors.teal[800],
    Colors.purple,
    Colors.brown,
    Colors.yellow,
    Colors.red[400],
    Colors.pink
  ];

  @override
  void initState() {
    var rng = Random();
    for(int i = 0; i < widget.numbers; i++) {
      // Generate random values for each piece of confetti
      var randHorizontalStartShift = (rng.nextDouble() - 0.5) * 50;     // Initial X offset
      var randVerticalStartShift = (rng.nextDouble() - 0.5) * 150;      // Initial Y offset
      var randHorizontalEndShift = (rng.nextDouble() - 0.5) * 900;      // How far it flies horizontally
      var randVerticalEndShift = 200 + (rng.nextDouble() * 1500);       // How far it flies vertically
      var randRotateCirclesX = rng.nextInt(7) + 1;                      // Number of X-axis rotations
      var randRotateCirclesY = rng.nextInt(7) + 1;                      // Number of Y-axis rotations
      var randRotateCirclesZ = rng.nextInt(5) + 1;                      // Number of Z-axis rotations
      
      randoms.add([
        randHorizontalStartShift, 
        randVerticalStartShift, 
        randHorizontalEndShift, 
        randVerticalEndShift, 
        randRotateCirclesX, 
        randRotateCirclesY, 
        randRotateCirclesZ
      ]);
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder:(context, constraints) {
        return Stack(
          children: [
            for(int i = 0; i < widget.numbers; i++)
              AnimatedBuilder(
                animation: widget.controller,
                builder: (context, child) {
                  // Horizontal movement animation
                  var horizontalAnimation = Tween<double>(
                    begin: (widget.direction == PopDirection.forwardX 
                      ? widget.posX + randoms[i][0]
                      : constraints.maxWidth - widget.posX - randoms[i][0]), 
                    end: (widget.direction == PopDirection.forwardX 
                      ? constraints.maxWidth + randoms[i][2] 
                      : 0.0 - randoms[i][2]),
                  ).animate(
                    CurvedAnimation(
                      parent: widget.controller,
                      curve: widget.motionCurveX,
                    ),
                  );

                  // Vertical movement animation
                  var verticalAnimation = Tween<double>(
                    begin: widget.posY + randoms[i][1], 
                    end: constraints.maxHeight + randoms[i][3]
                  ).animate(
                    CurvedAnimation(
                      parent: widget.controller,
                      curve: widget.motionCurveY,
                    ),
                  );

                  // Rotation animations
                  var rotationXAnimation = Tween<double>(
                    begin: 0, 
                    end: pi * randoms[i][4]
                  ).animate(widget.controller);
                  
                  var rotationYAnimation = Tween<double>(
                    begin: 0, 
                    end: pi * randoms[i][5]
                  ).animate(widget.controller);
                  
                  var rotationZAnimation = Tween<double>(
                    begin: 0, 
                    end: pi * randoms[i][6]
                  ).animate(widget.controller);

                  return Positioned(
                    left: horizontalAnimation.value,
                    width: widget.pieceWidth,
                    top: verticalAnimation.value,
                    height: widget.pieceHeight,
                    child: Transform(
                      transform: Matrix4.rotationX(rotationXAnimation.value)
                        ..rotateY(rotationYAnimation.value)
                        ..rotateZ(rotationZAnimation.value),
                      alignment: Alignment.center,
                      child: child,
                    ),
                  );
                },
                child: Container(
                  width: widget.pieceWidth,
                  height: widget.pieceHeight,
                  color: colors[Random().nextInt(colors.length)]!.withAlpha(Random().nextInt(55) + 200),
                ),
              ),
          ],
        );
      }
    );
  }
}