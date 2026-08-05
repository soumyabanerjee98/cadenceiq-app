import 'package:flutter/material.dart';

class AppLoading extends StatelessWidget {
  final String label;
  const AppLoading({super.key, this.label = "Loading..."});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        spacing: 12,
        children: [const CircularProgressIndicator(), Text(label)],
      ),
    );
  }
}
