import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class WaitingPaymentPage extends StatefulWidget {
  final String orderId;
  final String paymentUrl;
  final String baseUrl;

  const WaitingPaymentPage({
    super.key,
    required this.orderId,
    required this.paymentUrl,
    required this.baseUrl,
  });

  @override
  State<WaitingPaymentPage> createState() => _WaitingPaymentPageState();
}

class _WaitingPaymentPageState extends State<WaitingPaymentPage> {
  Timer? _pollingTimer;
  String _status = 'pending';
  bool _isChecking = false;

  @override
  void initState() {
    super.initState();
    _openPaymentPage();
    _startPolling();
  }

  Future<void> _openPaymentPage() async {
    final uri = Uri.parse(widget.paymentUrl);
    // externalApplication: buka di browser/tab terpisah, bukan di dalam app
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  void _startPolling() {
    // Cek status setiap 3 detik
    _pollingTimer = Timer.periodic(const Duration(seconds: 3), (_) => _checkStatus());
  }

  Future<void> _checkStatus() async {
    if (_isChecking) return;
    _isChecking = true;

    try {
      final response = await http.get(
        Uri.parse('${widget.baseUrl}/api/payment/status/${widget.orderId}'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final status = data['status'] as String;

        if (!mounted) return;

        if (status != _status) {
          setState(() => _status = status);
        }

        if (status == 'success') {
          _pollingTimer?.cancel();
          if (mounted) Navigator.pop(context, true);
        } else if (status == 'failed' || status == 'expired') {
          _pollingTimer?.cancel();
          if (mounted) Navigator.pop(context, false);
        }
      }
    } catch (e) {
      // Kalau gagal cek (misal koneksi putus sesaat), coba lagi di polling berikutnya
      debugPrint('Gagal cek status: $e');
    } finally {
      _isChecking = false;
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF1ABC9C)),
              const SizedBox(height: 24),
              const Text(
                'Menunggu Pembayaran',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                'Selesaikan pembayaran di tab/jendela yang baru terbuka.\nHalaman ini akan otomatis lanjut setelah pembayaran berhasil.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13, color: Colors.grey[500]),
              ),
              const SizedBox(height: 32),
              OutlinedButton.icon(
                onPressed: _openPaymentPage,
                icon: const Icon(Icons.open_in_new),
                label: const Text('Buka Halaman Pembayaran Lagi'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  _pollingTimer?.cancel();
                  Navigator.pop(context, false);
                },
                child: const Text('Batalkan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
