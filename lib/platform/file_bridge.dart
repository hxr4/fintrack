import 'dart:io';

import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

abstract interface class FileBridge {
  Future<String?> saveToDownloads(String name, Uint8List bytes);

  Future<Uint8List?> pickFile();

  Future<void> share(String name, Uint8List bytes);
}

final class AndroidFileBridge implements FileBridge {
  static const _channel = MethodChannel('fintrack/files');

  @override
  Future<String?> saveToDownloads(String name, Uint8List bytes) =>
      _channel.invokeMethod<String>('saveToDownloads', {'name': name, 'bytes': bytes});

  @override
  Future<Uint8List?> pickFile() => _channel.invokeMethod<Uint8List>('pickFile');

  @override
  Future<void> share(String name, Uint8List bytes) async {
    final directory = await getTemporaryDirectory();
    final file = File('${directory.path}/$name');
    await file.writeAsBytes(bytes, flush: true);
    await SharePlus.instance.share(ShareParams(files: [XFile(file.path, mimeType: 'application/octet-stream')]));
  }
}
