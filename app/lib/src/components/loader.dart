import 'package:flutter/material.dart';

class Loader extends StatelessWidget {
  const Loader({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox.square(
      dimension: 40,
      child: CircularProgressIndicator(
        strokeWidth: 2,
      ),
    );
  }

}