import 'package:app/src/group/group_model.dart';
import 'package:flutter/material.dart';
import 'package:collection/collection.dart';

class GroupPinDialog extends StatefulWidget {
  final Group group;
  final Function() onSuccess;
  final void Function() onFailure;

  const GroupPinDialog({super.key, required this.group, required this.onSuccess, required this.onFailure});

  @override
  State<GroupPinDialog> createState() => _GroupPinDialogState();
}

class _GroupPinDialogState extends State<GroupPinDialog> {
  final TextEditingController pinController = TextEditingController();

  String errorText = "";

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("Pincode invoeren"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(errorText),
          TextField(
            controller: pinController,
            autofocus: true,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: widget.onFailure,
          child: const Text("Annuleer"),
        ),
        TextButton(
          onPressed: () => _okOkPressed(context),
          child: const Text("Ok"),
        )
      ],
    );
  }

  void _okOkPressed(BuildContext context) {
    List<int> pin = pinController.text
        .characters
        .map((e) => int.tryParse(e))
        .where((e) => e != null)
        .map((e) => e!)
        .toList();

    if(const ListEquality().equals(pin, widget.group.pinCode)) {
      debugPrint("Pin is correct");
      widget.onSuccess();
    } else {
      debugPrint("Pin is incorrect");
      setState(() {
        errorText = "Pincode is onjuist";
      });
    }
  }
}