import 'package:app/src/api/provider.dart';

class User {
  final String name;
  final int id;
  final List<int>? photo;
  final double balance;

  const User({required this.id, required this.name, required this.balance, this.photo});

  Future<User> updateUserBalance(double newBalance) async {
    // TODO;

    return User(id: id, name: name, balance: newBalance, photo: photo);
  }
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
      const User(id: 1, name: "Tobias", balance: 10.00),
      const User(id: 2, name: "Bas", balance: 30.00),
      const User(id: 3, name: "Jef", balance: -10.40),
    ];
  }
}