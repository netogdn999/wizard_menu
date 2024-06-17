import 'package:flutter/material.dart';
import 'package:wizard_menu/wizard_menu.dart';

void main() {
  runApp(MainApp());
}

class MainApp extends StatelessWidget {
  final WizardMenuController _controller = WizardMenuController(
    currentStep: 3,
    countSteps: 3
  );

  MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton(
                onPressed: () {
                  _controller.nextStep();
                },
                child: const Text("foward"),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _controller.previousStep();
                },
                child: const Text("reverse"),
              ),
              const SizedBox(height: 16),
              WizardMenu(
                backgroundColor: Colors.red,
                backgroundChecked: Colors.green,
                controller: _controller,
                // stepChecked: const Icon(Icons.check, color: Colors.green),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
