import 'dart:async';

import 'package:flutter/material.dart';

class Debouncer {
  Debouncer({required this.delay});

  final Duration delay;
  Timer? _timer;

  void call(VoidCallback action) {
    _timer?.cancel();

    _timer = Timer(delay, action);
  }

  void dispose() {
    _timer?.cancel();
  }
}
