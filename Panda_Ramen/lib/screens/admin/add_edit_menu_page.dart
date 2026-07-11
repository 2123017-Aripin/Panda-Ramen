import 'dart:typed_data';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html show FileUploadInputElement, FileReader;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../providers/menu_provider.dart';
import '../../widgets/image_helper.dart';
import '../../services/cloudinary_helper.dart';

class AddEditMenuPage extends StatefulWidget {
  final MenuItem? existingItem;

  const AddEditMenuPage({super.key, this.existingItem});

  @override
  State<AddEditMenuPage> createState() => _AddEditMenuPageState();
}

class _AddEditMenuPageState extends State<AddEditMenuPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _imageController;
  late String _category;

  bool _isSaving = false;
  bool _isPickingImage = false;

  Uint8List? _pickedImageBytes;
  String? _pickedImageFileName;

  bool get _isEditing => widget.existingItem != null;

  @override
  void initState() {
    super.initState();
    final item = widget.existingItem;
    _nameController = TextEditingController(text: item?.name ?? '');
    _priceController = TextEditingController(
      text: item != null ? item.price.replaceAll(RegExp(r'[^0-9]'), '') : '',
    );
    _imageController = TextEditingController(text: item?.image ?? '');
    _category = item?.category ?? MenuProvider.categories.first;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _imageController.dispose();
    super.dispose();
  }

  // ── Pilih gambar via browser (Web) ────────────────────────────────────────
  Future<void> _pickImage() async {
    setState(() => _isPickingImage = true);
    try {
      final uploadInput = html.FileUploadInputElement()
        ..accept = 'image/jpeg,image/png,image/webp'
        ..click();

      await uploadInput.onChange.first;

      final file = uploadInput.files?.first;
      if (file == null) return;

      final reader = html.FileReader();
      reader.readAsArrayBuffer(file);
      await reader.onLoad.first;

      final bytes = reader.result as Uint8List;
      setState(() {
        _pickedImageBytes = bytes;
        _pickedImageFileName = file.name;
        _imageController.clear();
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memilih gambar: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  // ── Input URL manual ──────────────────────────────────────────────────────
  Future<void> _showUrlDialog() async {
    final controller = TextEditingController(text: _imageController.text);
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Masukkan URL Gambar'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.url,
          decoration: const InputDecoration(hintText: 'https://...'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              setState(() {
                _imageController.text = controller.text.trim();
                _pickedImageBytes = null;
                _pickedImageFileName = null;
              });
              Navigator.pop(ctx);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // ── Bottom sheet pilihan sumber gambar ────────────────────────────────────
  Future<void> _showImageSourceSheet() async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pilih Sumber Gambar',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.folder_outlined),
              title: const Text('Pilih dari Device'),
              subtitle: const Text('Buka file manager / galeri'),
              onTap: () {
                Navigator.pop(context);
                _pickImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.link_outlined),
              title: const Text('URL Gambar'),
              subtitle: const Text('Masukkan link gambar dari internet'),
              onTap: () {
                Navigator.pop(context);
                _showUrlDialog();
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  // ── Preview gambar ────────────────────────────────────────────────────────
  Widget _buildImagePreview() {
    const double size = 140;

    if (_pickedImageBytes != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.memory(
          _pickedImageBytes!,
          width: size, height: size,
          fit: BoxFit.cover,
        ),
      );
    }

    if (_imageController.text.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: buildMenuImage(
          _imageController.text.trim(),
          width: size, height: size,
        ),
      );
    }

    return Container(
      width: size, height: size,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.image_outlined, size: 40, color: Colors.grey),
    );
  }

  // ── Format harga ──────────────────────────────────────────────────────────
  String _formatNumber(int number) {
    final str = number.toString();
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write(',');
      buffer.write(str[i]);
    }
    return buffer.toString();
  }

  // ── Simpan ────────────────────────────────────────────────────────────────
  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_pickedImageBytes == null && _imageController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Pilih gambar terlebih dahulu'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);

    try {
      String finalImageUrl = _imageController.text.trim();

      // Upload ke Cloudinary jika ada gambar baru dari device
      if (_pickedImageBytes != null && _pickedImageFileName != null) {
        final uniqueName =
            '${DateTime.now().millisecondsSinceEpoch}_$_pickedImageFileName';
        finalImageUrl = await CloudinaryHelper.uploadImage(
          imageBytes: _pickedImageBytes!,
          fileName: uniqueName,
        );
      }

      final priceNumber = int.tryParse(_priceController.text.trim()) ?? 0;
      final formattedPrice = 'IDR ${_formatNumber(priceNumber)}';

      final item = MenuItem(
        id: widget.existingItem?.id,
        name: _nameController.text.trim(),
        price: formattedPrice,
        category: _category,
        image: finalImageUrl,
      );

      final provider = context.read<MenuProvider>();
      if (_isEditing) {
        await provider.updateItem(item);
      } else {
        await provider.addItem(item);
      }

      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              _isEditing ? 'Menu diperbarui' : 'Menu baru ditambahkan'),
          backgroundColor: const Color(0xFF1ABC9C),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  InputDecoration _inputDecoration(String? hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: Colors.grey[50],
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.black, width: 1.5),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasImage =
        _pickedImageBytes != null || _imageController.text.trim().isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          _isEditing ? 'Edit Menu' : 'Tambah Menu Baru',
          style: const TextStyle(
              color: Colors.black, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _isPickingImage ? null : _showImageSourceSheet,
                      child: Stack(
                        children: [
                          _buildImagePreview(),
                          if (_isPickingImage)
                            Positioned.fill(
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.black38,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: CircularProgressIndicator(
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          if (!_isPickingImage)
                            Positioned(
                              bottom: 6, right: 6,
                              child: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: const BoxDecoration(
                                  color: Colors.black,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.camera_alt,
                                    color: Colors.white, size: 16),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      hasImage
                          ? 'Tap untuk ganti gambar'
                          : 'Tap untuk pilih gambar',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              const Text('Nama Menu',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: _inputDecoration('Contoh: Abura Soba Regular'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Nama wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              const Text('Harga (IDR)',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _priceController,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: _inputDecoration('Contoh: 30000'),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Harga wajib diisi' : null,
              ),
              const SizedBox(height: 16),

              const Text('Kategori',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: _category,
                decoration: _inputDecoration(null),
                items: MenuProvider.categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) => setState(() => _category = v!),
              ),
              const SizedBox(height: 28),

              ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 52),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 22, height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : Text(
                        _isEditing ? 'Simpan Perubahan' : 'Tambah Menu',
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
              ),
              SizedBox(height: MediaQuery.of(context).padding.bottom + 16),
            ],
          ),
        ),
      ),
    );
  }
}