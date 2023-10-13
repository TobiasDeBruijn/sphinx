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
  final double? quantityLiters;
  final int stock;
  final List<int>? photo;
  final double price;
  final Category category;

  const Product({required this.name, required this.price, required this.category, required this.stock, this.photo, this.quantityLiters});

  bool isInStock() => stock > 0;

  Future<Product> updateStock(int newStock) async {
    // TODO
    return Product(name: name, price: price, category: category, stock: newStock, photo: photo, quantityLiters: quantityLiters);
  }
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
      const Product(name: "Grolsch", price: 0.90, stock: 10, category: Category.alcohol, quantityLiters: 0.33),
      const Product(name: "Hertog Jan", price: 1.00, stock: 15, category: Category.alcohol, quantityLiters: 0.33),
      const Product(name: "Hertog Jan", price: 1.00, stock: 30, category: Category.alcohol, quantityLiters: 0.5),
      const Product(name: "Coca Cola", price: 1.05, stock: 0, category: Category.softDrink),
    ];
  }
}
