class MenuItem {
  final int? id;
  final String name;
  final String price;
  final String category;
  final String image;

  MenuItem({
    this.id,
    required this.name,
    required this.price,
    required this.category,
    required this.image,
  });

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'price': price,
      'category': category,
      'image': image,
    };
    if (id != null) map['id'] = id;
    return map;
  }

  factory MenuItem.fromMap(Map<String, dynamic> map) {
    return MenuItem(
      id: map['id'] as int?,
      name: map['name'] as String,
      price: map['price'] as String,
      category: map['category'] as String,
      image: map['image'] as String,
    );
  }

  // Supaya kompatibel dengan widget lama (MenuOptionBottomSheet,
  // OrderCustomizationSheet) yang menerima Map<String, String>.
  Map<String, String> toLegacyMap() {
    return {
      'name': name,
      'price': price,
      'image': image,
    };
  }

  bool get isNetworkImage => image.startsWith('http');

  MenuItem copyWith({
    int? id,
    String? name,
    String? price,
    String? category,
    String? image,
  }) {
    return MenuItem(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      category: category ?? this.category,
      image: image ?? this.image,
    );
  }
}
