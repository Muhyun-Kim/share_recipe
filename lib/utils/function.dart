import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

Future<File> compressImg(File file) async {
  final dir = Directory.systemTemp;
  final targetPath =
      "${dir.absolute.path}/${DateTime.now().millisecondsSinceEpoch}.jpg";
  final result = await FlutterImageCompress.compressAndGetFile(
    file.absolute.path,
    targetPath,
    quality: 30,
    minWidth: 800,
    minHeight: 800,
    rotate: 0,
    keepExif: false,
  );

  if (result == null) {
    throw Exception("画像の圧縮に失敗しました");
  }

  final compressedFile = File(result.path);
  print("オリジナルのファイルサイズ: ${file.lengthSync()} bytes");
  print("圧縮されたファイルサイズ: ${compressedFile.lengthSync()} bytes");

  return compressedFile;
}

class TimestampConverter implements JsonConverter<DateTime, Timestamp> {
  const TimestampConverter();

  @override
  DateTime fromJson(Timestamp timestamp) {
    return timestamp.toDate();
  }

  @override
  Timestamp toJson(DateTime dateTime) {
    return Timestamp.fromDate(dateTime);
  }
}
