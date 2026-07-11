import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../providers/cart_provider.dart';
import 'home_page.dart';
import 'waiting_payment_page.dart';
import 'payment_success_page.dart';

enum PaymentMethod { qrCashier, onlinePayment }

class OrderSummaryPage extends StatefulWidget {
  final String customerName;
  final String tableNumber;

  const OrderSummaryPage({
    super.key,
    required this.customerName,
    required this.tableNumber,
  });

  @override
  State<OrderSummaryPage> createState() => _OrderSummaryPageState();
}

class _OrderSummaryPageState extends State<OrderSummaryPage> {
  PaymentMethod _selectedMethod = PaymentMethod.qrCashier;
  bool _isProcessingPayment = false;

  // Ganti dengan base URL backend Express kamu
  // (kalau test di emulator Android, biasanya http://10.0.2.2:3000)
  static const String baseUrl = 'http://localhost:3000';

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    final items = cart.items;
    final total = cart.totalPriceFormatted;
    final orderTime = TimeOfDay.now().format(context);
    final orderId =
        'PANDA-T${widget.tableNumber}-${orderTime.replaceAll(':', '').replaceAll(' ', '')}';

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 32),

              // ── SUCCESS ICON ──
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C).withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Color(0xFF1ABC9C),
                  size: 50,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pesanan Diterima!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'pilih metode pembayaran untuk melanjutkan',
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),

              // ── PILIHAN METODE PEMBAYARAN ──
              _buildPaymentMethodSelector(),

              const SizedBox(height: 24),

              // ── STRUK / RECEIPT ──
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[200]!),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // Header struk
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: const BoxDecoration(
                        color: Colors.black,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(16)),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'PANDA RAMEN',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 3,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Struk Pesanan • $orderTime',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 12),
                          ),
                        ],
                      ),
                    ),

                    // Info pemesan
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          _buildInfoRow(
                            icon: Icons.person,
                            label: 'Nama Pemesan',
                            value: widget.customerName,
                          ),
                          const SizedBox(height: 10),
                          _buildInfoRow(
                            icon: Icons.table_restaurant,
                            label: 'Nomor Meja',
                            value: 'Meja ${widget.tableNumber}',
                          ),
                        ],
                      ),
                    ),

                    _buildDashedLine(),

                    // Daftar item
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Detail Pesanan',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: Colors.black54,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...items.map((item) => Padding(
                                padding: const EdgeInsets.only(bottom: 14),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Container(
                                      width: 22,
                                      height: 22,
                                      decoration: BoxDecoration(
                                        color: Colors.black,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Center(
                                        child: Text(
                                          '${item.quantity}',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 11,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            item.name,
                                            style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          const SizedBox(height: 3),
                                          Wrap(
                                            spacing: 6,
                                            children: [
                                              if (item.noodleSize != '-')
                                                _buildTag(
                                                    '🍜 ${item.noodleSize}'),
                                              if (item.noodleDoneness != '-')
                                                _buildTag(
                                                    '⏱ ${item.noodleDoneness}'),
                                              if (item.spicyLevel !=
                                                      'Tidak Pedas' &&
                                                  item.spicyLevel != '-' &&
                                                  item.spicyLevel.isNotEmpty)
                                                _buildTag(
                                                    '🌶 ${item.spicyLevel}'),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      item.subtotalFormatted,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),

                    _buildDashedLine(),

                    // Total
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'TOTAL',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            total,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1ABC9C),
                            ),
                          ),
                        ],
                      ),
                    ),

                    _buildDashedLine(),

                    // ── QR CODE SECTION (hanya tampil jika pilih bayar di kasir) ──
                    if (_selectedMethod == PaymentMethod.qrCashier)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.qr_code_scanner,
                                    size: 16, color: Colors.grey[600]),
                                const SizedBox(width: 6),
                                Text(
                                  'Tunjukkan QR ini ke kasir',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'untuk melakukan pembayaran dan konfirmasi pesanan',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 11, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: Colors.grey[200]!),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.05),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: QrImageView(
                                data: _buildQrData(
                                  orderId: orderId,
                                  items: items,
                                  total: total,
                                  orderTime: orderTime,
                                ),
                                version: QrVersions.auto,
                                size: 180,
                                backgroundColor: Colors.white,
                                eyeStyle: const QrEyeStyle(
                                  eyeShape: QrEyeShape.square,
                                  color: Colors.black,
                                ),
                                dataModuleStyle: const QrDataModuleStyle(
                                  dataModuleShape: QrDataModuleShape.square,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Order ID: $orderId',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),

                    // ── INFO JIKA PILIH BAYAR ONLINE ──
                    if (_selectedMethod == PaymentMethod.onlinePayment)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Column(
                          children: [
                            Icon(Icons.payments_outlined,
                                size: 40, color: Colors.grey[400]),
                            const SizedBox(height: 8),
                            Text(
                              'Klik tombol di bawah untuk membayar sekarang',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontSize: 12, color: Colors.grey[500]),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                'Order ID: $orderId',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[600],
                                  fontFamily: 'monospace',
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                    // Footer struk
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: const BorderRadius.vertical(
                            bottom: Radius.circular(16)),
                      ),
                      child: Text(
                        'Terima kasih telah memesan di Panda Ramen! 🐼',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              // ── TOMBOL AKSI (berubah sesuai metode) ──
              if (_selectedMethod == PaymentMethod.onlinePayment)
                ElevatedButton(
                  onPressed: _isProcessingPayment
                      ? null
                      : () => _handleOnlinePayment(
                            orderId: orderId,
                            items: items,
                            cart: cart,
                          ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: _isProcessingPayment
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : const Text(
                          'Bayar Sekarang',
                          style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5),
                        ),
                )
              else
                ElevatedButton(
                  onPressed: () {
                    cart.clearCart();
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(double.infinity, 52),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5),
                  ),
                ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ── WIDGET TOGGLE PILIHAN PEMBAYARAN ──
  Widget _buildPaymentMethodSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _methodOption(
              method: PaymentMethod.qrCashier,
              icon: Icons.qr_code,
              label: 'Bayar di Kasir',
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: _methodOption(
              method: PaymentMethod.onlinePayment,
              icon: Icons.credit_card,
              label: 'Bayar Online',
            ),
          ),
        ],
      ),
    );
  }

  Widget _methodOption({
    required PaymentMethod method,
    required IconData icon,
    required String label,
  }) {
    final isSelected = _selectedMethod == method;
    return GestureDetector(
      onTap: () => setState(() => _selectedMethod = method),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon,
                size: 20, color: isSelected ? Colors.white : Colors.grey[600]),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isSelected ? Colors.white : Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── PANGGIL BACKEND UNTUK BUAT TRANSAKSI MIDTRANS ──
  Future<void> _handleOnlinePayment({
    required String orderId,
    required List<CartItem> items,
    required CartProvider cart,
  }) async {
    setState(() => _isProcessingPayment = true);

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/payment/create-transaction'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'orderId': orderId,
          'customerName': widget.customerName,
          'tableNumber': widget.tableNumber,
          'grossAmount':
              cart.totalPrice, // pastikan ini int, bukan formatted string
          'items': items
              .map((item) => {
                    'id': item.name,
                    'name': item.name,
                    'quantity': item.quantity,
                    'price': item
                        .priceValue, // sesuaikan getter harga satuan di CartItem kamu
                  })
              .toList(),
        }),
      );

      if (!mounted) return;

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final redirectUrl = data['redirect_url'];

        if (redirectUrl == null) {
          _showError('Server tidak mengembalikan link pembayaran.');
          return;
        }

        final paymentResult = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (_) => WaitingPaymentPage(
              orderId: orderId,
              paymentUrl: redirectUrl,
              baseUrl: baseUrl,
            ),
          ),
        );

        if (!mounted) return;
        if (paymentResult == true) {
          final itemsForReceipt = items
              .map((item) => {
                    'name': item.name,
                    'quantity': item.quantity,
                    'price': item.priceValue,
                  })
              .toList();
          final grossAmountForReceipt = cart.totalPrice;

          cart.clearCart();
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) => PaymentSuccessPage(
                orderId: orderId,
                customerName: widget.customerName,
                tableNumber: widget.tableNumber,
                grossAmount: grossAmountForReceipt,
                items: itemsForReceipt,
              ),
            ),
            (route) => false,
          );
        } else {
          _showError('Pembayaran gagal atau dibatalkan.');
        }
      } else {
        _showError('Gagal membuat transaksi (${response.statusCode}).');
      }
    } catch (e) {
      _showError('Terjadi kesalahan koneksi ke server.');
    } finally {
      if (mounted) setState(() => _isProcessingPayment = false);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  String _buildQrData({
    required String orderId,
    required List<CartItem> items,
    required String total,
    required String orderTime,
  }) {
    final itemLines = items.map((item) {
      final opts = <String>[];
      if (item.noodleSize != '-') {
        opts.add('${item.noodleSize}/${item.noodleDoneness}');
      }
      opts.add(item.spicyLevel);
      return '${item.quantity}x ${item.name} (${opts.join(', ')}) = ${item.subtotalFormatted}';
    }).join(' | ');

    return 'ORDER_ID:$orderId\n'
        'NAMA:${widget.customerName}\n'
        'MEJA:${widget.tableNumber}\n'
        'WAKTU:$orderTime\n'
        'ITEMS:$itemLines\n'
        'TOTAL:$total';
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey),
        const SizedBox(width: 8),
        Text('$label: ',
            style: TextStyle(fontSize: 13, color: Colors.grey[500])),
        Text(value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDashedLine() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: LayoutBuilder(
        builder: (_, constraints) {
          final dashWidth = 6.0;
          final dashSpace = 4.0;
          final count =
              (constraints.maxWidth / (dashWidth + dashSpace)).floor();
          return Row(
            children: List.generate(
              count,
              (_) => Container(
                width: dashWidth,
                height: 1,
                color: Colors.grey[300],
                margin: EdgeInsets.only(right: dashSpace),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTag(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
          color: Colors.grey[100], borderRadius: BorderRadius.circular(4)),
      child: Text(text, style: const TextStyle(fontSize: 11)),
    );
  }
}
