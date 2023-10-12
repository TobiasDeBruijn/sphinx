import 'package:app/src/api/provider.dart';

class User {
  final String name;
  final List<int>? photo;

  const User({required this.name, this.photo});
}

class UserApiProvider implements DataProvider<User> {
  @override
  Future<User?> get(String ident) {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<User>> list(String? parent) async {
    if(parent == null) {
      throw ArgumentError.notNull("parent");
    }

    return [
      const User(name: "Tobias"),
      const User(name: "Bas"),
      const User(name: "Jef"),
    ];
  }
}