import 'dart:math';

import 'package:flutter/material.dart';

import 'originalStepper.dart';

class OwnStepper extends OriginalStepper {
  const OwnStepper({
    Key? key,
    required steps,
    physics,
    required type,
    currentStep = 0,
    onStepTapped,
    onStepContinue,
    onStepCancel,
    controlsBuilder,
    elevation,
  }) : super(
            key: key,
            steps: steps,
            physics: physics,
            type: type,
            currentStep: currentStep,
            onStepTapped: onStepTapped,
            onStepContinue: onStepContinue,
            onStepCancel: onStepCancel,
            controlsBuilder: controlsBuilder,
            elevation: elevation);

  @override
  State<OriginalStepper> createState() => OwnStepperState();
}

class OwnStepperState extends OriginalStepperState {

  @override
  Widget _buildVerticalBody(int index) {
    return Stack(
      children: <Widget>[
        PositionedDirectional(
          start: 24.0,
          top: 0.0,
          bottom: 0.0,
          child: SizedBox(
            width: 24.0,
            child: Center(
              child: SizedBox(
                width: super.isLast(index) ? 0.0 : 1.0,
                child: Container(
                  color: Colors.red.shade900,
                ),
              ),
            ),
          ),
        ),
        AnimatedCrossFade(
          firstChild: Container(height: 0.0),
          secondChild: Container(
            margin: const EdgeInsetsDirectional.only(
              start: 60.0,
              end: 24.0,
              bottom: 24.0,
            ),
            child: Column(
              children: <Widget>[
                widget.steps[index].content,
                super.buildVerticalControls(),
              ],
            ),
          ),
          firstCurve: const Interval(0.0, 0.6, curve: Curves.fastOutSlowIn),
          secondCurve: const Interval(0.4, 1.0, curve: Curves.fastOutSlowIn),
          sizeCurve: Curves.fastOutSlowIn,
          crossFadeState: super.isCurrent(index) ? CrossFadeState.showSecond : CrossFadeState.showFirst,
          duration: kThemeAnimationDuration,
        ),
      ],
    );
  }
}
