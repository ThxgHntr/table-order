import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

Future<void> deleteAllFilesInFolder(String folderPath) async {
  try {
    final storageRef = FirebaseStorage.instance.ref(folderPath);

    // Liệt kê tất cả tệp trong thư mục
    final listResult = await storageRef.listAll();

    // Xoá từng tệp
    for (var item in listResult.items) {
      await item.delete();
    }

    if (kDebugMode) {
      print('Đã xoá tất cả tệp trong thư mục $folderPath');
    }
  } catch (e) {
    if (kDebugMode) {
      print('Lỗi khi xoá tệp trong thư mục $folderPath: $e');
    }
  }
}

Future<String?> uploadImageToStorage(String path, File image) async {
  try {
    if (!image.existsSync()) {
      if (kDebugMode) {
        print('File does not exist: ${image.path}');
      }
      return null;
    }

    final ref = FirebaseStorage.instance.ref().child(path);
    final uploadTask = ref.putFile(image);
    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();
    if (kDebugMode) {
      print('Image uploaded successfully: $downloadUrl');
    }
    return downloadUrl;
  } catch (e) {
    if (kDebugMode) {
      print('Error uploading image to Firebase Storage: $e');
    }
    return null;
  }
}
