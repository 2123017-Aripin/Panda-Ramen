import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/menu_item_model.dart';

class DatabaseHelper {
  DatabaseHelper._internal();
  static final DatabaseHelper instance = DatabaseHelper._internal();

  // Koneksi ke collection 'menu_items' di Firestore
  final _col = FirebaseFirestore.instance.collection('menu_items');

  Future<List<MenuItem>> getAllItems() async {
    final snap = await _col.orderBy('id').get();
    return snap.docs
        .map((d) => MenuItem.fromMap({...d.data(), 'id': d.data()['id']}))
        .toList();
  }

  Future<int> insertItem(MenuItem item) async {
    final id = DateTime.now().millisecondsSinceEpoch;
    await _col.add({...item.toMap(), 'id': id});
    return id;
  }

  Future<int> updateItem(MenuItem item) async {
    final snap = await _col.where('id', isEqualTo: item.id).get();
    if (snap.docs.isNotEmpty) {
      await snap.docs.first.reference.update(item.toMap());
    }
    return item.id ?? 0;
  }

  Future<int> deleteItem(int id) async {
    final snap = await _col.where('id', isEqualTo: id).get();
    for (final doc in snap.docs) {
      await doc.reference.delete();
    }
    return id;
  }
}