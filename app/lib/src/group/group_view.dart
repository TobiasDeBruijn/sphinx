import 'dart:async';
import 'dart:typed_data';
import 'package:app/src/components/ScaffoldLoader.dart';
import 'package:app/src/components/pin_dialog.dart';

import 'package:app/src/group/group_model.dart';
import 'package:app/src/user/user_view.dart';
import 'package:flutter/material.dart';


class SelectGroupView extends StatefulWidget {
  const SelectGroupView({super.key});

  @override
  State<SelectGroupView> createState() => _SelectGroupViewState();
}

class _SelectGroupViewState extends State<SelectGroupView> {
  List<Group> _groups = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _loadGroups);
  }

  void _loadGroups() async {
    debugPrint("SelectGroupView: Loading groups");

    List<Group> groups = await GroupApiProvider().list(null);

    setState(() {
      _groups = groups;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if(_isLoading) {
      return const ScaffoldLoader();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text("Selecteer groep"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: GridView.count(
            crossAxisCount: 5,
            children: _groups.map((e) => _SelectableGroup(
              group: e,
              onTap: _openEnterGroupPinDialog,
            )).toList(),
          )
        ),
      ),
    );
  }

  void _openEnterGroupPinDialog(Group group) {
    showDialog(context: context, builder: (builder) => GroupPinDialog(
      group: group,
      onSuccess: () {
        Navigator.of(context).pop();
        _navigateToUserSelection(group);
      },
      onFailure: () => {
        Navigator.of(context).pop()
      },
    ));
  }

  void _navigateToUserSelection(Group g) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => SelectUserView(group: g)));
  }
}

class _SelectableGroup extends StatelessWidget {
  final Group group;
  final Function(Group g) onTap;

  const _SelectableGroup({required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(group),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox.square(dimension: 200, child: _getIcon()),
              Text(group.name, textAlign: TextAlign.center)
            ]
          ),
        ),
      ),
    );
  }

  Widget _getIcon() {
    if(group.icon != null) {
      return Image.memory(Uint8List.fromList(group.icon!));
    } else {
      return Image.asset("assets/default_group.png");
    }
  }
}