import 'package:flutter/material.dart';
import 'original_stepper.dart';

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

class OwnStepperState extends OriginalStepperState {}
