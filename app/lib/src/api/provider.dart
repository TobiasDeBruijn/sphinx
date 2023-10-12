abstract class DataProvider<T> {
  Future<List<T>> list(String? parent);
  Future<T?> get(String ident);
}