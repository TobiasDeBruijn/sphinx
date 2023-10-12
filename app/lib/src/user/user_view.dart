import 'dart:async';
import 'dart:typed_data';

import 'package:app/src/components/ScaffoldLoader.dart';
import 'package:app/src/components/pin_dialog.dart';
import 'package:app/src/group/group_model.dart';
import 'package:app/src/group/group_view.dart';
import 'package:app/src/product/product_view.dart';
import 'package:app/src/user/user_model.dart';
import 'package:flutter/material.dart';

class SelectUserView extends StatefulWidget {
  final Group group;
  const SelectUserView({super.key, required this.group});

  @override
  State<SelectUserView> createState() => _SelectUserViewState();
}

class _SelectUserViewState extends State<SelectUserView> {

  List<User> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 2), _loadUsers);
  }

  void _loadUsers() async {
    debugPrint("SelectUserView: Loading users");

    List<User> users = await UserApiProvider().list(widget.group.id);

    setState(() {
      _users = users;
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
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_outlined),
            onPressed: () => _openEnterGroupPinDialog(widget.group),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: GridView.count(
            crossAxisCount: 5,
            children: _users.map((user) => _SelectableUser(
              user: user,
              group: widget.group,
              onTap: _navigateToProductSelect,
            )).toList(),
          ),
        ),
      ),
    );
  }

  void _logoutGroup() async {
    debugPrint("SelectUserView: Logging out of group");

    // TODO Notify API of logout

    _navigateToGroupSelect();
  }

  void _openEnterGroupPinDialog(Group group) {
    showDialog(context: context, builder: (builder) => GroupPinDialog(
      group: group,
      onSuccess: () {
        Navigator.of(context).pop();
        _logoutGroup();
      },
      onFailure: () => {
        Navigator.of(context).pop()
      },
    ));
  }

  void _navigateToGroupSelect() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const SelectGroupView()));
  }

  void _navigateToProductSelect(Group g, User u) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => SelectProductView(group: g, user: u)));
  }
}

class _SelectableUser extends StatelessWidget {
  final User user;
  final Group group;
  final Function(Group g, User u) onTap;

  const _SelectableUser({required this.user, required this.group, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(group, user),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Column(
            children: [
              SizedBox.square(dimension: 200, child: _getIcon()),
              Text(user.name, textAlign: TextAlign.center)
            ]
          ),
        ),
      ),
    );
  }

  Widget _getIcon() {
    if(user.photo != null) {
      return Image.memory(Uint8List.fromList(user.photo!));
    } else {
      return Image.asset("assets/default_user.png");
    }
  }
}