import 'package:app/src/group/group_view.dart';
import 'package:flutter/material.dart';

class SphinxApp extends StatelessWidget {
  const SphinxApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: "Sphinx",
      color: Colors.blue,
      home: SelectGroupView(),
    );
  }
}
