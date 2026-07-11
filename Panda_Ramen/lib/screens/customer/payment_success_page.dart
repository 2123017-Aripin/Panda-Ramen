import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:gal/gal.dart';
import 'package:intl/intl.dart';
import '../customer/home_page.dart'; // sesuaikan path HomePage kamu

class PaymentSuccessPage extends StatefulWidget {
  final String orderId;
  final String customerName;
  final String tableNumber;
  final List<Map<String, dynamic>> items; // [{name, quantity, price}]
  final int grossAmount;

  const PaymentSuccessPage({
    super.key,
    required this.orderId,
    required this.customerName,
    required this.tableNumber,
    required this.items,
    required this.grossAmount,
  });

  @override
  State<PaymentSuccessPage> createState() => _PaymentSuccessPageState();
}

class _PaymentSuccessPageState extends State<PaymentSuccessPage> {
  final ScreenshotController _screenshotController = ScreenshotController();
  bool _isSaving = false;

  String _formatCurrency(int amount) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp', decimalDigits: 0)
        .format(amount);
  }

  Future<void> _downloadStruk() async {
    setState(() => _isSaving = true);
    try {
      final Uint8List? imageBytes =
          await _screenshotController.capture(pixelRatio: 3);
      if (imageBytes == null) throw Exception('Gagal mengambil gambar struk');

      await Gal.putImageBytes(imageBytes, name: 'struk_${widget.orderId}');

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Struk berhasil disimpan ke galeri')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal menyimpan struk: $e')),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1ABC9C).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle,
                    color: Color(0xFF1ABC9C), size: 64),
              ),
              const SizedBox(height: 16),
              const Text(
                'Pembayaran Berhasil',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'Pesanan Anda sedang disiapkan oleh dapur.\nMohon tunggu 15-20 menit.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.black54),
              ),
              const SizedBox(height: 24),

              // Bagian ini yang akan di-screenshot jadi struk
              Screenshot(
                controller: _screenshotController,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Center(
                        child: Text(
                          'PANDA RAMEN',
                          style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1),
                        ),
                      ),
                      const Center(
                        child: Text('Struk Pembayaran',
                            style:
                                TextStyle(fontSize: 12, color: Colors.black54)),
                      ),
                      const SizedBox(height: 16),
                      _divider(),
                      const SizedBox(height: 12),
                      _infoRow('Order ID', widget.orderId),
                      _infoRow('Nama', widget.customerName),
                      _infoRow('Meja', widget.tableNumber),
                      _infoRow('Tanggal',
                          DateFormat('dd MMM yyyy, HH:mm').format(DateTime.now())),
                      const SizedBox(height: 12),
                      _divider(),
                      const SizedBox(height: 12),
                      ...widget.items.map((item) => Padding(
                            padding: const EdgeInsets.only(bottom: 8),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 3,
                                  child: Text(
                                    '${item['name']} x${item['quantity']}',
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                                Expanded(
                                  flex: 2,
                                  child: Text(
                                    _formatCurrency(
                                        (item['price'] as int) *
                                            (item['quantity'] as int)),
                                    textAlign: TextAlign.right,
                                    style: const TextStyle(fontSize: 13),
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const SizedBox(height: 8),
                      _divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15)),
                          Text(
                            _formatCurrency(widget.grossAmount),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1ABC9C)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Center(
                        child: Text('Terima kasih telah memesan di Panda Ramen!',
                            style:
                                TextStyle(fontSize: 11, color: Colors.black45)),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _downloadStruk,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.download),
                  label: Text(_isSaving ? 'Menyimpan...' : 'Download Struk'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1ABC9C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const HomePage()),
                      (route) => false,
                    );
                  },
                  child: const Text('Kembali ke Beranda'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          Text(value,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _divider() {
    return const SizedBox(
      height: 1,
      child: DecoratedBox(decoration: BoxDecoration(color: Color(0xFFE0E0E0))),
    );
  }
}