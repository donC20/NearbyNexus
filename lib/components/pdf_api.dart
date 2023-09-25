import 'dart:io';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart';

class PdfApi {
  static Future<File?> saveDocument({
    required String name,
    required Document pdf,
  }) async {
    try {
      final bytes = await pdf.save();
      final dir = await getDownloadsDirectory();
      final file = File('${dir?.path}/$name');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      print("Error saving PDF: $e");
      return null; // Return null if an error occurs
    }
  }

  static Future<void> openFile(File? file) async {
    if (file != null) {
      final url = file.path;

      try {
        await OpenFile.open(url);
      } catch (e) {
        print("Error opening PDF: $e");
      }
    }
  }
}
