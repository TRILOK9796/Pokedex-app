import 'package:flutter/material.dart';

/// Centered progress state used while loading a screen.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: Color(0xFFEF5350)),
    );
  }
}
