import 'dart:io';
import 'package:aws_s3_upload_lite/aws_s3_upload_lite.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../model/restaurant.dart';

class FirebaseRestaurantsServices {
  final storage = FirebaseStorage.instance;

  Future<String?> uploadImageToS3(File image) async {
    try {
      //final bucketName = dotenv.env['AWS_BUCKET_NAME'] ?? 'your-bucket-name';
      final accessKey = dotenv.env['AWS_ACCESS_KEY'] ?? 'your-access';
      final secretKey = dotenv.env['AWS_SECRET_KEY'] ?? 'your-secret';
      final file = image;
      final bucket = dotenv.env['AWS_BUCKET_NAME'] ?? 'your-bucket-name';
      final region = dotenv.env['AWS_REGION'] ?? 'your-region';
      final destDir =
          'restaurant_pictures/${DateTime.now().millisecondsSinceEpoch}_${image.path.split('/').last}';
      final filename = destDir.split('/').last;

      String uploadResult = await AwsS3.uploadFile(
          accessKey: accessKey,
          secretKey: secretKey,
          bucket: bucket,
          file: file,
          region: region,
          destDir: destDir,
          filename: filename);

      /*// Cấu hình thông tin để upload ảnh lên S3
      final s3Uploader = AwsS3(
        awsS3AccessKey: accessKey,
        awsS3SecretKey: secretKey,
        defaultBucketName: bucketName,
        awsRegion: region,

      );

      // Tải ảnh lên S3 và lấy URL
      final uploadResult = await s3Uploader.uploadFile(
        image,
        fileName: imagePath,
      );*/

      /*if (uploadResult != null) {
        print(
            'Image uploaded successfully: $uploadResult'); // Log URL của ảnh đã tải lên
        return uploadResult;
      } else {
        print('Failed to get S3 URL');
        return null;
      }*/
    } catch (e) {
      print('Error uploading image to S3: $e');
      return null;
    }
  }

  Future<List<String>> uploadImages(List<File> images) async {
    List<String> downloadUrls = [];

    for (var image in images) {
      try {
        final s3Url = await uploadImageToS3(image);
        if (s3Url != null) {
          downloadUrls.add(s3Url);
        }
      } catch (e) {
        print('Error uploading image: $e');
      }
    }

    return downloadUrls;
  }

  Future<bool> saveRestaurantInfo(Restaurant restaurant) async {
    try {
      final imageUrls = await uploadImages(
          restaurant.selectedImage.map((path) => File(path)).toList());
      restaurant.selectedImage = imageUrls;

      final ref = FirebaseDatabase.instance.ref().child('restaurants').push();
      await ref.set(restaurant.toMap());

      return true;
    } catch (e) {
      print('Error saving data: $e');
      return false;
    }
  }
}
