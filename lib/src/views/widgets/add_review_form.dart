import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:table_order/src/services/firebase_review_services.dart';

class AddReviewForm extends StatefulWidget {
  final String restaurantId;

  const AddReviewForm({super.key, required this.restaurantId});

  @override
  State<AddReviewForm> createState() => _AddReviewFormState();
}

class _AddReviewFormState extends State<AddReviewForm> {
  final _formKey = GlobalKey<FormState>();
  final _commentController = TextEditingController();
  int _rating = 0;
  List<XFile> _images = [];
  final FirebaseReviewServices _service = FirebaseReviewServices();

  Future<void> _pickImages() async {
    final ImagePicker picker = ImagePicker();
    final List<XFile> images = await picker.pickMultiImage();
    setState(() {
      _images = images;
    });
  }

  Future<void> _submitReview() async {
    if (_formKey.currentState!.validate()) {
      try {
        await _service.submitReview(widget.restaurantId, _commentController.text, _rating, _images);
        _commentController.clear();
        setState(() {
          _rating = 0;
          _images = [];
        });
      } catch (e) {
        debugPrint("Error adding review: $e");
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _images.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 6.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_images.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _images.asMap().entries.map((entry) {
                    int index = entry.key;
                    XFile image = entry.value;
                    return Stack(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6.0),
                            child: Image.file(
                              File(image.path),
                              height: 80,
                              width: 80,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: IconButton(
                            icon: const Icon(Icons.remove_circle, color: Colors.red),
                            onPressed: () => _removeImage(index),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _commentController,
              decoration: const InputDecoration(
                labelText: 'Thêm đánh giá',
                border: OutlineInputBorder(),
                contentPadding: EdgeInsets.symmetric(vertical: 8.0, horizontal: 12.0),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập đánh giá';
                }
                return null;
              },
              minLines: 1,
              maxLines: null,
            ),
            const SizedBox(height: 2),
            Row(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < _rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                            size: 24,
                          ),
                          onPressed: () {
                            setState(() {
                              _rating = index + 1;
                            });
                          },
                        );
                      }),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _pickImages,
                  icon: const Icon(Icons.add_a_photo, color: Colors.deepOrange),
                ),
                const SizedBox(width: 2),
                IconButton(
                  onPressed: _submitReview,
                  icon: const Icon(Icons.send, color: Colors.lightBlue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}