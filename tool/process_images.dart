import 'dart:io';
import 'package:image/image.dart' as img;

void main() async {
  print('Mulai memproses 9 gambar instruksi latihan...');

  final directories = ['arm_raise', 'bicep_curl', 'neck_rotation'];

  for (final dirName in directories) {
    final inputDir = Directory('assets/exercises/$dirName');
    final outputDir = Directory('assets/exercises_processed/$dirName');

    if (!outputDir.existsSync()) {
      outputDir.createSync(recursive: true);
    }

    final files = inputDir
        .listSync()
        .whereType<File>()
        .where((f) => f.path.endsWith('.png'))
        .toList();

    for (final file in files) {
      final fileName = file.path.split(Platform.pathSeparator).last;
      final bytes = await file.readAsBytes();
      final image = img.decodePng(bytes);

      if (image == null) {
        print('Gagal decode PNG: ${file.path}');
        continue;
      }

      print('Processing ${file.path} (${image.width}x${image.height})...');

      // Iterasi pixel untuk menghapus background putih dengan feathering
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixel(x, y);
          final r = pixel.r;
          final g = pixel.g;
          final b = pixel.b;

          // Cek warna putih/dekat-putih
          if (r > 235 && g > 235 && b > 235) {
            final minVal = [r, g, b].reduce((curr, next) => curr < next ? curr : next);
            final luminance = (r * 0.299 + g * 0.587 + b * 0.114);

            // Jika murni mendekati putih (> 248), buat transparan 100%
            if (minVal > 248 && luminance > 248) {
              pixel.a = 0;
            } else if (luminance > 235) {
              // Smooth feathering untuk anti-aliasing di bagian tepi
              final factor = (248.0 - luminance) / (248.0 - 235.0);
              pixel.a = (pixel.a * factor).clamp(0, 255).round();
            }
          }
        }
      }

      final encodedBytes = img.encodePng(image);
      final outputFile = File('${outputDir.path}/$fileName');
      await outputFile.writeAsBytes(encodedBytes);
      print('Disimpan ke: ${outputFile.path} (${encodedBytes.length} bytes)');
    }
  }

  print('Pembersihan background 9 gambar selesai!');
}
