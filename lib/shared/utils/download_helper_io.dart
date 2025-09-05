import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

Future<String?> saveBytesImpl({required List<int> bytes, required String fileName}) async {
  final dir = await getTemporaryDirectory();
  final filePath = '${dir.path}/$fileName';
  final file = File(filePath);
  await file.writeAsBytes(bytes, flush: true);
  await OpenFile.open(filePath);
  return filePath;
}
