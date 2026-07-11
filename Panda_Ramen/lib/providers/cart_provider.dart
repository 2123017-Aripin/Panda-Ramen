import 'package:flutter/material.dart';

class CartItem {
  final String name;
  final String price;
  final String image;
  final String noodleSize;
  final String noodleDoneness;
  final String spicyLevel;
  int quantity;

  CartItem({
    required this.name,
    required this.price,
    required this.image,
    required this.noodleSize,
    required this.noodleDoneness,
    required this.spicyLevel,
    this.quantity = 1,
  });

  int get priceValue {
    final cleaned = price.replaceAll(RegExp(r'[^0-9]'), '');
    return int.tryParse(cleaned) ?? 0;
  }
  int get subtotal => priceValue * quantity;

  String get subtotalFormatted {
    return 'IDR ${_formatNumber(subtotal)}';
  }

  static String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }
}

class CartProvider extends ChangeNotifier {
  final List<CartItem> _items = [];

  List<CartItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get totalPrice => _items.fold(0, (sum, item) => sum + item.subtotal);

  String get totalPriceFormatted {
    final str = totalPrice.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return 'IDR ${buffer.toString()}';
  }

  void addItem(CartItem item) {
    // Cek apakah item yang sama sudah ada (nama + semua opsi sama)
    final existing = _items.where((e) =>
        e.name == item.name &&
        e.noodleSize == item.noodleSize &&
        e.noodleDoneness == item.noodleDoneness &&
        e.spicyLevel == item.spicyLevel);

    if (existing.isNotEmpty) {
      existing.first.quantity += item.quantity;
    } else {
      _items.add(item);
    }
    notifyListeners();
  }

  void removeItem(int index) {
    _items.removeAt(index);
    notifyListeners();
  }

  void increaseQuantity(int index) {
    _items[index].quantity++;
    notifyListeners();
  }

  void decreaseQuantity(int index) {
    if (_items[index].quantity > 1) {
      _items[index].quantity--;
    } else {
      _items.removeAt(index);
    }
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}
