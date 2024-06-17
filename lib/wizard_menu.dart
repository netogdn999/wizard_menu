import 'dart:async';

import 'package:flutter/material.dart';

enum WizardMenuControllerSteps {
  next,
  previous,
}

class WizardMenuController {
  int currentStep;
  final int countSteps;
  final StreamController<(WizardMenuControllerSteps, int)> _controller = StreamController();

  WizardMenuController({required this.countSteps, this.currentStep = 1}) 
  : assert(countSteps <= 9 && countSteps >=1, "The amount of steps must be more than 0 and less then 10"),
    assert(currentStep <= 9 && currentStep >=1, "The current step must be more than 0 and less then 10"),
    assert(currentStep <= countSteps, "The current step must be less or equal than countSteps");

  void nextStep() {
    if (currentStep == countSteps) {
      return;
    }
    _controller.add((WizardMenuControllerSteps.next, currentStep));
    currentStep++;
  }

  void previousStep() {
    if (currentStep <= 1) {
      return;
    }
    currentStep --;
    _controller.add((WizardMenuControllerSteps.previous, currentStep));
  }

  void listen(void Function((WizardMenuControllerSteps action, int currentStep)) action) {
    if (!_controller.hasListener) {
      _controller.stream.listen(action);
    }
  }
}

class WizardMenu extends StatelessWidget {
  final Color backgroundColor;
  final Color backgroundChecked;
  final List<AnimationController> _animationsCircle = [];
  final List<AnimationController> _animationsBar = [];
  final WizardMenuController controller;
  final Widget? stepChecked;

  WizardMenu({
    super.key,
    required this.backgroundColor,
    required this.controller,
    required this.backgroundChecked,
    this.stepChecked
  }) {
    controller.listen((value) {
      final (action, stepValue) = value;
      if (action == WizardMenuControllerSteps.next) {
        _animationsBar[stepValue -1].forward().then((_) {
          _animationsCircle[stepValue].forward();
        });
      }
      if (action == WizardMenuControllerSteps.previous) {
        _animationsCircle[stepValue].reverse().then((_) {
          _animationsBar[stepValue -1].reverse();
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 2.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: () {
          final List<Widget> steps = [];
          for (int i = 1, j = 1; j <= controller.countSteps; i ++) {
            if (i %2 == 0) {
              steps.add(Expanded(
                child: _WizardBarAnimated(
                  backgroundColor: backgroundColor,
                  backgroundChecked: backgroundChecked,
                  isChecked: j <= controller.currentStep,
                  getController: (controller) {
                    _animationsBar.add(controller);
                  },
                ),
              ));
              continue;
            }
            steps.add(_WizardCircleAnimated(
              step: j,
              backgroundColor: backgroundColor,
              backgroundChecked: backgroundChecked,
              isChecked: j <= controller.currentStep,
              stepChecked: stepChecked,
              getController: (controller) {
                _animationsCircle.add(controller);
              },
            ));
            j++;
          }
          return steps;
        }.call(),
      ),
    );
  }
}

class _WizardBarAnimated extends StatefulWidget {
  final Color backgroundColor;
  final Color backgroundChecked;
  final bool isChecked;
  final void Function(AnimationController)? getController;

  const _WizardBarAnimated({
    required this.backgroundColor,
    required this.backgroundChecked,
    required this.isChecked,
    this.getController,
  });

  @override
  State<_WizardBarAnimated> createState() => _WizardBarAnimatedState();
}

class _WizardBarAnimatedState extends State<_WizardBarAnimated> with SingleTickerProviderStateMixin {
  late final AnimationController _wizardBarController;
  late final Animation<Offset> _wizardBarAnimation;

  final Duration _duration = const Duration(seconds: 1);

  @override
  void initState() {
    super.initState();
    
    _wizardBarController = AnimationController(
      value: widget.isChecked ? 1 : 0,
      duration: _duration,
      vsync: this,
    );

    _wizardBarAnimation = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(1, 0),
    ).animate(CurvedAnimation(
      parent: _wizardBarController, 
      curve: Curves.decelerate,
    ));

    widget.getController?.call(_wizardBarController);
  }

  @override
  void dispose() {
    super.dispose();
    _wizardBarController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          height: 2.0,
          margin: const EdgeInsets.only(left: 2.0),
          decoration: BoxDecoration(
            color: widget.backgroundChecked
          ),
        ),
        AnimatedBuilder(
          animation: _wizardBarAnimation,
          builder: (_, child) {
            return ClipRect(
              child: SlideTransition(
                position: _wizardBarAnimation,
                child: child,
              ),
            );
          },
          child: Container(
            height: 2.0,
            margin: const EdgeInsets.only(left: 2.0),
            decoration: BoxDecoration(
              color: widget.backgroundColor
            ),
          ),
        )
      ],
    );
  }
}

class _WizardCircleAnimated extends StatefulWidget {
  final Color backgroundColor;
  final Color backgroundChecked;
  final double size = 20.0;
  final bool isChecked;
  final int step;
  final Widget? stepChecked;
  final void Function(AnimationController)? getController;

  const _WizardCircleAnimated({
    required this.backgroundColor,
    required this.backgroundChecked,
    required this.step,
    required this.isChecked,
    this.stepChecked,
    this.getController,
  }) : assert(step <= 9);

  @override
  State<_WizardCircleAnimated> createState() => _WizardCircleAnimatedState();
}

class _WizardCircleAnimatedState extends State<_WizardCircleAnimated> with SingleTickerProviderStateMixin {
  late final AnimationController _wizardCircleController;
  late final Animation<Color?> _wizardCircleAnimation;

  late Widget innerChild;

  final Duration _duration = const Duration(seconds: 1);

  bool get hasStepCheked => widget.stepChecked != null;

  @override
  void initState() {
    super.initState();

    if (!hasStepCheked) {
      innerChild = Center(
        key: ValueKey("WizardCircleAnimatedText ${widget.step}"),
        child: Text(widget.step.toString()),
      );
    } else {
      innerChild = widget.isChecked
      ? Center(
          key: ValueKey("WizardCircleAnimatedIcon ${widget.step}"),
          child: widget.stepChecked,
        )
      : Center(
        key: ValueKey("WizardCircleAnimatedText ${widget.step}"),
        child: Text(widget.step.toString()),
      );
    }
    
    _wizardCircleController = AnimationController(
      value: widget.isChecked ? 1 : 0,
      duration: _duration,
      vsync: this,
    );

    _wizardCircleAnimation = ColorTween(
      begin: widget.backgroundColor,
      end: widget.backgroundChecked,
    ).animate(CurvedAnimation(
      parent: _wizardCircleController, 
      curve: Curves.easeInOutExpo,
    ));

    _wizardCircleController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.forward) {
        if (hasStepCheked) {
          switchFowardChild();
        }
      }
      if (status == AnimationStatus.reverse) {
        if (hasStepCheked) {
          switchReverseChild();
        }
      }
    });

    widget.getController?.call(_wizardCircleController);
  }
  
  @override
  void dispose() {
    super.dispose();
    _wizardCircleController.dispose();
  }

  void switchFowardChild() {
    setState(() {
      innerChild = Center(
        key: ValueKey("WizardCircleAnimatedIcon ${widget.step}"),
        child: Icon(Icons.check, color: widget.backgroundChecked),
      );
    });
  }
  
  void switchReverseChild() {
    setState(() {
      innerChild = Center(
        key: ValueKey("WizardCircleAnimatedText ${widget.step}"),
        child: Text(widget.step.toString()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _wizardCircleAnimation,
      builder: (_, child) {
        return Container(
          height: widget.size,
          width: widget.size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              width: 2.0,
              color: _wizardCircleAnimation.value!,
              strokeAlign: BorderSide.strokeAlignOutside
            ),
          ),
          child: child,
        );
      },
      child: hasStepCheked
      ? AnimatedSwitcher(
        duration: _duration,
        switchInCurve: Curves.easeInExpo,
        child: innerChild,
      )
      : innerChild,
    );
  }
}