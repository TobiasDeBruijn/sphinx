import 'package:app/src/api/provider.dart';

class Group {
  final String id;
  final String name;
  final List<int>? icon;
  final List<int> pinCode;

  const Group({required this.id, required this.name, this.icon, required this.pinCode});
}

class GroupApiProvider implements DataProvider<Group> {
  @override
  Future<Group?> get(String ident) {
    // TODO: implement list
    throw UnimplementedError();
  }

  @override
  Future<List<Group>> list(String? parent) async {
    return [
      const Group(id: "id", name: "Bierzee", pinCode: [9, 0, 4, 8]),
      const Group(id: "id", name: "KFC", pinCode: [9, 0, 4, 8]),
      const Group(id: "id", name: "McDonalds", pinCode: [9, 0, 4, 8]),
    ];
  }
}

