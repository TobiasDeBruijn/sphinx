import 'dart:async';
import 'dart:typed_data';

import 'package:app/src/components/ScaffoldLoader.dart';
import 'package:app/src/group/group_model.dart';
import 'package:app/src/product/product_model.dart';
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

  List<Product> _products = [];
  List<QuantifiedProduct> _productsInCard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    Timer(const Duration(milliseconds: 500), _loadProducts);
  }

  void _loadProducts() async {
    debugPrint("SelectProductView: Loading products");

    List<Product> products = await ProductApiProvider().list(widget.group.id);

    setState(() {
      _products = products;
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text("Selecteer product(en)"),
            Text(widget.user.name),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ProductPageView(
              products: _products,
              onTapProduct: (product) {
                bool productAlreadyInCard = _productsInCard.any((qProduct) => qProduct.product == product);

                if(productAlreadyInCard) {
                  // Replace the item in the card with a new one with an increased quantity.
                  List<QuantifiedProduct> newCard = _productsInCard
                    .map((qProduct) {
                      if(qProduct.product == product) {
                        return QuantifiedProduct(qProduct.product, qProduct.quantity + 1);
                      } else {
                        return qProduct;
                      }
                    }).toList();

                  setState(() {
                    _productsInCard = newCard;
                  });
                } else {
                  setState(() {
                    _productsInCard.add(QuantifiedProduct(product, 1));
                  });
                }
              },
            ),
            ShoppingCardView(
              user: widget.user,
              products: _productsInCard,
              onTapCompletePurchase: (transactionValue) {
                widget.user.updateUserBalance(widget.user.balance - transactionValue);

                for (QuantifiedProduct element in _productsInCard) {
                  element.product.updateStock(element.product.stock - element.quantity);
                }

                debugPrint("SelectProductView: Transaction complete");
                Navigator.of(context).pop();
              },
              onTapProductRemove: (Product product) {
                List<QuantifiedProduct> newCard = _productsInCard.where((element) => element.product != product).toList();
                setState(() {
                  _productsInCard = newCard;
                });
              },
            )
          ],
        )
      ),
    );
  }
}

/// A product with a quantity
class QuantifiedProduct {
  final Product product;
  final int quantity;

  const QuantifiedProduct(this.product, this.quantity);
}

/// The shopping card.
/// Shows products that have been selected along with their quantity,
/// the total price of the order, and displays an order button
class ShoppingCardView extends StatelessWidget {
  final User user;
  final List<QuantifiedProduct> products;
  final Function(double) onTapCompletePurchase;
  final Function(Product) onTapProductRemove;

  const ShoppingCardView({super.key, required this.user, required this.products, required this.onTapCompletePurchase, required this.onTapProductRemove});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SizedBox(
          width: 200,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Winkelwagen", style: TextStyle(fontWeight: FontWeight.bold), textAlign: TextAlign.left),
                  _ShoppingCardItemList(products: products, onTapProductRemove: onTapProductRemove),
                ],
              ),
              Align(
                alignment: Alignment.centerRight,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Totaal: €${_getTotalPrice().toStringAsFixed(2)}", style: const TextStyle(fontWeight: FontWeight.bold)),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text("Saldo na transactie: €${_getBalanceAfterTransaction().toStringAsFixed(2)}"),
                    ),
                    ElevatedButton(
                      onPressed: () => onTapCompletePurchase(_getTotalPrice()),
                      child: const Text("Betalen")
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  double _getBalanceAfterTransaction() {
    return user.balance - _getTotalPrice();
  }

  double _getTotalPrice() {
    if(products.isEmpty) {
      return 0;
    }

    return products
        .map((e) => e.product.price * e.quantity)
        .reduce((value, element) => value + element);
  }
}

class _ShoppingCardItemList extends StatelessWidget {
  final List<QuantifiedProduct> products;
  final Function(Product) onTapProductRemove;

  const _ShoppingCardItemList({required this.products, required this.onTapProductRemove});

  @override
  Widget build(BuildContext context) {
    if(products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: products.map((e) => _ShoppingCardItem(
        onTapProductRemove: onTapProductRemove,
        product: e,
      )).toList(),
    );
  }
}

class _ShoppingCardItem extends StatelessWidget {
  final QuantifiedProduct product;
  final Function(Product) onTapProductRemove;

  const _ShoppingCardItem({required this.product, required this.onTapProductRemove});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
              onPressed: () => onTapProductRemove(product.product),
              icon: const Icon(Icons.remove, color: Colors.redAccent),
            ),
            Text("${product.quantity}x "),
            Text("${product.product.name} "),
            product.product.quantityLiters != null ? Text("${product.product.quantityLiters}L") : const Text(""),
          ],
        ),
        const Divider(),
      ],
    );
  }
}

/// Shows all products in a certain category as a grid.
class CategoryView extends StatelessWidget {
  final List<Product> products;
  final Function(Product) onTapProduct;

  CategoryView({super.key, required this.products, required this.onTapProduct}) {
    // Sort alphabetically
    products
        .sort((a, b) {
          int nameComparison = a.name.compareTo(b.name);

          // Products are named equally
          if(nameComparison == 0 && a.quantityLiters != null && b.quantityLiters != null) {
            // If the products are named the same, sort by volume
            return a.quantityLiters!.compareTo(b.quantityLiters!);
          } else {
            return nameComparison;
          }
    });
  }

  @override
  Widget build(BuildContext context) {
    if(products.isEmpty) {
      return const SizedBox.shrink();
    }

    return Expanded(
      child: GridView.builder(
        itemCount: products.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 5,
        ),
        itemBuilder: (context, idx) {
          if(products[idx].isInStock()) {
            return _SelectableProduct(product: products[idx], onTap: () => onTapProduct(products[idx]));
          } else {
            return _OutOfStockProduct(product: products[idx]);
          }
        }
      ),
    );
  }
}

class _OutOfStockProduct extends StatelessWidget {
  final Product product;

  const _OutOfStockProduct({required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Niet op voorraad")));
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Stack(
            children: [
              const Text("Niet op voorraad."),
              _ProductItem(product: product),
              LayoutBuilder(builder: (context, size) => Icon(Icons.cancel_outlined, color: Colors.redAccent, size: size.maxWidth)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProductItem extends StatelessWidget {
  final Product product;

  const _ProductItem({required this.product});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: [
        SizedBox.square(dimension: 150, child: _getIcon()),
        Expanded(child: Text("${product.name} ${product.quantityLiters != null ? "${product.quantityLiters}L " : ""}€${product.price.toStringAsFixed(2)}")),
      ],
    );
  }

  Widget _getIcon() {
    if(product.photo != null) {
      return Image.memory(Uint8List.fromList(product.photo!));
    } else {
      return Image.asset("assets/default_product.png");
    }
  }
}

/// A product displayed as a clickable card with an icon, name and price.
class _SelectableProduct extends StatelessWidget {
  final Product product;
  final Function() onTap;

  const _SelectableProduct({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: () => onTap(),
        child: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Stack(
            children: [
              Text(product.stock.toString()),
              _ProductItem(product: product),
            ],
          ),
        ),
      ),
    );
  }
}

/// Shows all products, sorted on pages by the product's category.
class ProductPageView extends StatefulWidget {
  final List<Product> products;
  final Function(Product) onTapProduct;

  const ProductPageView({super.key, required this.products, required this.onTapProduct});

  @override
  State<ProductPageView> createState() => _ProductPageViewState();
}

class _ProductPageViewState extends State<ProductPageView> {

  Category _activeCategory = Category.values[0];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width - 300,
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: Category.values.map((category) => ElevatedButton(
              style: category == _activeCategory ? ButtonStyle(
                backgroundColor: MaterialStateProperty.all(darken(Theme.of(context).primaryColor, 0.2)),
              ) : null,
              child: Text(category.getDutchName()),
              onPressed: () => setState(() {
                _activeCategory = category;
              })
            )).toList(),
          ),
          const Divider(),
          CategoryView(
            products: widget.products.where((product) => product.category == _activeCategory).toList(),
            onTapProduct: widget.onTapProduct
          ),
        ],
      ),
    );
  }

  Color darken(Color color, [double amount = .1]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(color);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }
}