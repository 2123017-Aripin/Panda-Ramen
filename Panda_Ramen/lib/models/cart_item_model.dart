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

  String get subtotalFormatted => 'IDR ${_formatNumber(subtotal)}';

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
