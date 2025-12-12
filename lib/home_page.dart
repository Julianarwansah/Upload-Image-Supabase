import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String? _publicImageUrl; // Untuk menyimpan URL gambar yang diupload
  bool _isUploading = false; // Status loading saat upload

  // Instance Supabase client
  final SupabaseClient supabase = Supabase.instance.client;

  Future<void> _pickAndUploadToPublicBucket() async {
    final picker = ImagePicker();
    // Membuka galeri untuk memilih gambar
    final picked = await picker.pickImage(source: ImageSource.gallery);

    // Jika user batal memilih, return
    if (picked == null) return;

    // Set status uploading menjadi true untuk menampilkan loading
    setState(() => _isUploading = true);

    try {
      // Membuat nama file unik menggunakan timestamp
      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}_${picked.name}';
      final filePath = 'uploads/$fileName';

      // Cek apakah aplikasi berjalan di web atau mobile
      if (kIsWeb) {
        // Khusus untuk di web, kita perlu membaca sebagai bytes
        final bytes = await picked.readAsBytes();
        await supabase.storage
            .from('bucket_images')
            .uploadBinary(
              filePath,
              bytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg', // Sesuaikan tipe konten jika perlu
              ),
            );
      } else {
        // Untuk mobile (Android/iOS), gunakan File dari path
        final file = File(picked.path);
        await supabase.storage.from('bucket_images').upload(filePath, file);
      }

      // Ambil public URL dari file yang baru diupload
      final publicUrl = supabase.storage
          .from('bucket_images')
          .getPublicUrl(filePath);

      // Update state untuk menampilkan gambar
      if (mounted) {
        setState(() {
          _publicImageUrl = publicUrl;
        });
      }
    } catch (e) {
      debugPrint('Error upload: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Gagal upload: $e')));
      }
    } finally {
      // Reset status uploading
      if (mounted) {
        setState(() => _isUploading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Supabase Image Upload')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // Menampilkan loading bar jika sedang upload
            if (_isUploading) const LinearProgressIndicator(),
            const SizedBox(height: 16),

            // Tombol untuk memilih dan upload gambar
            ElevatedButton(
              onPressed: _isUploading ? null : _pickAndUploadToPublicBucket,
              child: const Text('Pilih & Upload Gambar'),
            ),

            const SizedBox(height: 24),

            // Menampilkan gambar yang berhasil diupload
            if (_publicImageUrl != null) ...[
              const Text('Gambar dari Public URL:'),
              const SizedBox(height: 8),
              Expanded(
                child: Image.network(
                  _publicImageUrl!,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const Center(child: CircularProgressIndicator());
                  },
                  errorBuilder: (context, error, stackTrace) =>
                      const Text('Gagal memuat gambar'),
                ),
              ),
              const SizedBox(height: 8),
              SelectableText(
                _publicImageUrl!,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
