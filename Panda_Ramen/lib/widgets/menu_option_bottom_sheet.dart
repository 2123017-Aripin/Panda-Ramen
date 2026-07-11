import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import 'image_helper.dart';

class MenuOptionBottomSheet extends StatelessWidget {
  final Map<String, String> item;

  const MenuOptionBottomSheet({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: buildMenuImage(item['image']!, width: 80, height: 80),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item['name']!,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item['price']!,
                      style: const TextStyle(
                        fontSize: 14,
                        color: Color(0xFF1ABC9C),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showDetailSheet(context);
                  },
                  icon: const Icon(Icons.info_outline, size: 20),
                  label: const Text('Detail Menu'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.black,
                    side: const BorderSide(color: Colors.black),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    _showOrderSheet(context);
                  },
                  icon: const Icon(Icons.add_shopping_cart, size: 20),
                  label: const Text('+ Pesanan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => MenuDetailSheet(item: item),
    );
  }

  void _showOrderSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => OrderCustomizationSheet(item: item),
    );
  }
}

// ── DETAIL MENU SHEET ────────────────────────────────────────
class MenuDetailSheet extends StatelessWidget {
  final Map<String, String> item;

  const MenuDetailSheet({super.key, required this.item});

  String _getDescription(String name) {
    if (name.contains('Abura Soba')) {
      return 'Ramen tanpa kuah dengan saus spesial berbasis kecap dan minyak wijen. Disajikan dengan topping pilihan yang kaya rasa.';
    } else if (name.contains('Mazesoba')) {
      return 'Ramen campur tanpa kuah dengan bumbu rempah khas Jepang. Cocok untuk pencinta rasa yang bold dan kuat.';
    } else if (name.contains('Tori Shio')) {
      return 'Ramen berbasis kaldu ayam bening dengan bumbu shio (garam) yang ringan namun gurih. Salah satu menu andalan kami.';
    } else if (name.contains('Takano')) {
      return 'Ramen dengan kaldu khas Takano yang kaya umami. Pilihan sempurna untuk pengalaman ramen autentik.';
    } else if (name.contains('Creamy')) {
      return 'Ramen dengan kuah creamy yang lembut dan gurih. Menggunakan perpaduan kaldu spesial yang memanjakan lidah.';
    } else if (name.contains('Komakura')) {
      return 'Ramen premium dengan kaldu kaya rasa, terinspirasi dari ramen gaya Kamakura, Jepang.';
    } else if (name.contains('Kara Miso')) {
      return 'Ramen pedas dengan kuah miso yang kuat dan bold. Bagi pencinta pedas sejati!';
    } else if (name.contains('Don')) {
      return 'Semangkuk nasi putih hangat dengan topping pilihan yang lezat dan mengenyangkan.';
    } else if (name.contains('Gyoza')) {
      return 'Pangsit panggang khas Jepang dengan isi daging dan sayuran, disajikan dengan saus cocolan.';
    } else if (name.contains('Kakiage')) {
      return 'Tempura campuran sayuran dan seafood yang renyah dan gurih.';
    } else if (name.contains('Purin')) {
      return 'Puding susu lembut dengan rasa manis yang pas. Dessert klasik Jepang favorit semua kalangan.';
    } else if (name.contains('Ice Cream')) {
      return 'Soft ice cream lembut dengan pilihan rasa matcha dan vanilla yang segar.';
    } else if (name.contains('Cheesecake')) {
      return 'Basque burnt cheesecake dengan tekstur creamy di dalam dan sedikit gosong di luar yang khas.';
    } else if (name.contains('Crepes')) {
      return 'Crepes tipis dengan isian creme brulee matcha yang harum dan sedikit karamel.';
    }
    return 'Menu spesial pilihan dari dapur Panda Ramen, dibuat dengan bahan-bahan segar berkualitas tinggi.';
  }

  String _getToppings(String name) {
    if (name.contains('Regular')) return 'Chashu, Telur Rebus, Nori, Daun Bawang';
    if (name.contains('Special') && !name.contains('Tamtam')) {
      return 'Chashu x2, Telur Rebus, Nori, Daun Bawang, Corn';
    }
    if (name.contains('Tamtam')) {
      return 'Chashu x3, Telur Rebus x2, Nori x2, Daun Bawang, Corn, Bamboo Shoot';
    }
    return '-';
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.9,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.all(24),
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: buildMenuImage(item['image']!,
                        width: double.infinity, height: 200),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    item['name']!,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1ABC9C),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      item['price']!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Deskripsi',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getDescription(item['name']!),
                    style: TextStyle(
                        fontSize: 14, color: Colors.grey[700], height: 1.6),
                  ),
                  const SizedBox(height: 16),
                  if (_getToppings(item['name']!) != '-') ...[
                    const Text(
                      'Topping',
                      style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _getToppings(item['name']!),
                      style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                          height: 1.6),
                    ),
                    const SizedBox(height: 24),
                  ],
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => OrderCustomizationSheet(item: item),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Tambah ke Pesanan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── ORDER CUSTOMIZATION SHEET ────────────────────────────────
class OrderCustomizationSheet extends StatefulWidget {
  final Map<String, String> item;

  const OrderCustomizationSheet({super.key, required this.item});

  @override
  State<OrderCustomizationSheet> createState() =>
      _OrderCustomizationSheetState();
}

class _OrderCustomizationSheetState extends State<OrderCustomizationSheet> {
  String _noodleSize = 'Regular';
  String _noodleDoneness = 'Normal';
  String _spicyLevel = 'Tidak Pedas';
  int _quantity = 1;

  final List<String> _noodleSizes = ['Kecil', 'Regular', 'Besar'];
  final List<String> _noodleDonenesses = ['Lembek', 'Normal', 'Al Dente'];
  final List<String> _spicyLevels = [
    'Tidak Pedas',
    'Level 1',
    'Level 2',
    'Level 3',
    'Level 4',
    'Level 5 🔥',
  ];

  bool get _isNoodleDish {
    final name = widget.item['name']!.toLowerCase();
    return name.contains('ramen') ||
        name.contains('abura soba') ||
        name.contains('mazesoba') ||
        name.contains('ultimate takano') ||
        name.contains('supreme creamy') ||
        name.contains('komakura') ||
        name.contains('kara miso') ||
        name.contains('tori shio') ||
        name.contains('mini');


  }

  bool get _isSpicyDish {

    final name = widget.item['name']!.toLowerCase();
    return name.contains('ramen') ||
        name.contains('soba') ||
        name.contains('mazesoba') ||
        name.contains('don') ||
        name.contains('kakiage') ||
        name.contains('tori shio') ||
        name.contains('takano') ||
        name.contains('creamy') ||
        name.contains('komakura') ||
        name.contains('kara miso') ||
        name.contains('mini') ||
        name.contains('enoki');
  }

  // ─────────────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.75,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (_, controller) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: ListView(
                controller: controller,
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                children: [
                  Text(
                    widget.item['name']!,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.item['price']!,
                    style: const TextStyle(
                      color: Color(0xFF1ABC9C),
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Ukuran Mie & Kematangan 
                  if (_isNoodleDish) ...[
                    _buildSectionTitle('Ukuran Mie', Icons.straighten),
                    const SizedBox(height: 10),
                    _buildChipGroup(
                      options: _noodleSizes,
                      selected: _noodleSize,
                      onSelected: (v) => setState(() => _noodleSize = v),
                    ),
                    const SizedBox(height: 20),
                    _buildSectionTitle(
                        'Tingkat Kematangan Mie', Icons.timer_outlined),
                    const SizedBox(height: 10),
                    _buildChipGroup(
                      options: _noodleDonenesses,
                      selected: _noodleDoneness,
                      onSelected: (v) => setState(() => _noodleDoneness = v),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // Tingkat Kepedasan 
                  if (_isSpicyDish) ...[
                    _buildSectionTitle(
                        'Tingkat Kepedasan', Icons.local_fire_department),
                    const SizedBox(height: 10),
                    _buildChipGroup(
                      options: _spicyLevels,
                      selected: _spicyLevel,
                      onSelected: (v) => setState(() => _spicyLevel = v),
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Jumlah
                  _buildSectionTitle('Jumlah', Icons.shopping_bag_outlined),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      _buildQtyButton(
                        icon: Icons.remove,
                        onTap: () {
                          if (_quantity > 1) setState(() => _quantity--);
                        },
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Text(
                          '$_quantity',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      _buildQtyButton(
                        icon: Icons.add,
                        onTap: () => setState(() => _quantity++),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),

            // Tombol Tambah ke Keranjang
            Container(
              padding: EdgeInsets.fromLTRB(
                  24, 12, 24, MediaQuery.of(context).padding.bottom + 16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Tambah ke Keranjang • ${_calculateTotal()}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _calculateTotal() {
    final priceStr =
        widget.item['price']!.replaceAll(RegExp(r'[^0-9]'), '');
    final price = int.tryParse(priceStr) ?? 0;
    final total = price * _quantity;
    final formatted = total.toString().replaceAllMapped(
        RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]},');
    return 'IDR $formatted';
  }

  void _addToCart() {
    final cart = context.read<CartProvider>();
    cart.addItem(CartItem(
      name: widget.item['name']!,
      price: widget.item['price']!,
      image: widget.item['image']!,
      noodleSize: _isNoodleDish ? _noodleSize : '-',
      noodleDoneness: _isNoodleDish ? _noodleDoneness : '-',
      spicyLevel: _isSpicyDish ? _spicyLevel : '-',
      quantity: _quantity,
    ));

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${widget.item['name']} ditambahkan ke keranjang!'),
        backgroundColor: const Color(0xFF1ABC9C),
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 18, color: Colors.black87),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildChipGroup({
    required List<String> options,
    required String selected,
    required Function(String) onSelected,
  }) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: options.map((opt) {
        final isSelected = opt == selected;
        return GestureDetector(
          onTap: () => onSelected(opt),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.black : Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? Colors.black : Colors.grey[300]!,
              ),
            ),
            child: Text(
              opt,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight:
                    isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQtyButton(
      {required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18),
      ),
    );
  }
}
