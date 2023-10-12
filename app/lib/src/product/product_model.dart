import 'package:app/src/api/provider.dart';

enum Category {
  alcohol,
  softDrink;

  String getDutchName() {
    switch(this) {
      case Category.alcohol: return "Alcohol";
      case Category.softDrink: return "Frisdrank";
    }
  }
}

class Product {
  final String name;
  final List<int>? photo;
  final double price;
  final Category category;

  const Product({required this.name, required this.price, required this.category, this.photo});
}

class ProductApiProvider implements DataProvider<Product> {
  @override
  Future<Product?> get(String ident) async {
    // TODO: implement get
    throw UnimplementedError();
  }

  @override
  Future<List<Product>> list(String? parent) async {
    if(parent == null) {
      throw ArgumentError.notNull("parent");
    }

    return [
      const Product(name: "Grolsch 0.33", price: 0.90, category: Category.alcohol),
      const Product(name: "Hertog Jan 0.33", price: 1.00, category: Category.alcohol),
      const Product(name: "Coca Cola 0.33", price: 1.05, category: Category.softDrink),
    ];
  }
}
