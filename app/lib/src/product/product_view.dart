import 'package:app/src/group/group_model.dart';
import 'package:app/src/user/user_model.dart';
import 'package:flutter/material.dart';

class SelectProductView extends StatefulWidget {
  final Group group;
  final User user;

  const SelectProductView({super.key, required this.group, required this.user});

  @override
  State<SelectProductView> createState() => _SelectProductViewState();
}

class _SelectProductViewState extends State<SelectProductView> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}