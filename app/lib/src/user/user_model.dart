import 'package:app/src/api/provider.dart';

class User {
  final String name;
  final List<int>? photo;
  final double balance;

  const User({required this.name, required this.balance, this.photo});
}

class UserApiProvider implements DataProvider<User> {
  @override
  Future<User?> get(String ident) async {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<User>> list(String? parent) async {
    if(parent == null) {
      throw ArgumentError.notNull("parent");
    }

    return [
      const User(name: "Tobias", balance: 10.00),
      const User(name: "Bas", balance: 30.00),
      const User(name: "Jef", balance: -10.40),
    ];
  }
}