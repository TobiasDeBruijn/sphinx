import 'package:app/src/components/loader.dart';
import 'package:flutter/material.dart';

class ScaffoldLoader extends StatelessWidget {
  const ScaffoldLoader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Align(
            alignment: Alignment.bottomCenter,
            child: Loader()
        ),
      ),
    );
  }
}