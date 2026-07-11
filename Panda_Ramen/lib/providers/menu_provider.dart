import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../services/database_helper.dart';

export '../models/menu_item_model.dart';

class MenuProvider extends ChangeNotifier {
  final DatabaseHelper _db = DatabaseHelper.instance;

  List<MenuItem> _items = [];
  bool _isLoading = false;

  List<MenuItem> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  // Daftar kategori tetap, dipakai untuk tab menu & dropdown kategori di form admin.
  static const List<String> categories = [
    'Ramen',
    'Mini Ramen',
    'Donburi',
    'A La Carte',
    'Agemono',
    'Desert',
    'Drinks',
    'Extra',
  ];

  List<MenuItem> itemsByCategory(String category) {
    return _items.where((item) => item.category == category).toList();
  }

  Future<void> loadItems() async {
    if (_isLoading) return; 
    _isLoading = true;
    notifyListeners();
    _items = await _db.getAllItems();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addItem(MenuItem item) async {
    await _db.insertItem(item);
    await loadItems();
  }

  Future<void> updateItem(MenuItem item) async {
    await _db.updateItem(item);
    await loadItems();
  }

  Future<void> deleteItem(int id) async {
    await _db.deleteItem(id);
    await loadItems();
  }
}
