import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/toast_utils.dart';
import 'list_map.dart';

class RestaurantDetailsForm extends StatefulWidget {
  final Map<String, TextEditingController> openTimeControllers;
  final Map<String, TextEditingController> closeTimeControllers;
  final TextEditingController restaurantDescription;
  final Map<String, bool> isOpened;
  final List<String> selectedKeywords;
  final List<File> selectedImages;
  final Function(List<File>) onImagesSelected;

  const RestaurantDetailsForm({
    super.key,
    required this.openTimeControllers,
    required this.closeTimeControllers,
    required this.restaurantDescription,
    required this.isOpened,
    required this.selectedKeywords,
    required this.selectedImages,
    required this.onImagesSelected,
  });

  static final formKey = GlobalKey<FormState>();

  @override
  State<StatefulWidget> createState() => _RestaurantDetailsFormState();
}

class _RestaurantDetailsFormState extends State<RestaurantDetailsForm> {
  final List<File> _selectedImages = [];
  TextEditingController keywordController = TextEditingController();
  List<String> filteredKeywords = [];

  Future<void> _pickImagesFromGallery() async {
    try {
      final List<XFile> returnedImages = await ImagePicker().pickMultiImage();
      if (returnedImages.isEmpty) {
        showToast('Không có ảnh nào được chọn!');
        return;
      }

      setState(() {
        _selectedImages.addAll(returnedImages.map((img) => File(img.path)));
      });

      showToast('Đã chọn ${returnedImages.length} ảnh.');
    } catch (e) {
      showToast('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _selectTime(BuildContext context, TextEditingController controller) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        controller.text = picked.format(context);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: RestaurantDetailsForm.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Thời gian mở cửa'),
            ...daysOfTheWeek.map((day) {
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(day),
                    value: widget.isOpened[day] ?? false,
                    onChanged: (value) {
                      setState(() {
                        widget.isOpened[day] = value ?? false;
                        if (!widget.isOpened[day]!) {
                          widget.openTimeControllers[day]?.clear();
                          widget.closeTimeControllers[day]?.clear();
                        }
                      });
                    },
                  ),
                  if (widget.isOpened[day] == true)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: widget.openTimeControllers[day] ??= TextEditingController(),
                            readOnly: true,
                            onTap: () => _selectTime(context, widget.openTimeControllers[day]!),
                            decoration: const InputDecoration(
                              labelText: 'Thời gian mở cửa',
                              hintText: 'Chọn thời gian mở cửa',
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: widget.closeTimeControllers[day] ??= TextEditingController(),
                            readOnly: true,
                            onTap: () => _selectTime(context, widget.closeTimeControllers[day]!),
                            decoration: const InputDecoration(
                              labelText: 'Thời gian đóng cửa',
                              hintText: 'Chọn thời gian đóng cửa',
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              );
            }).toList(),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.restaurantDescription,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mô tả quán ăn';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Mô tả quán ăn',
                hintText: 'Nhập mô tả quán ăn',
              ),
            ),
            const SizedBox(height: 10),
            const Text('Chọn nhiều ảnh'),
            ElevatedButton(
              onPressed: _pickImagesFromGallery,
              child: const Text('Chọn ảnh từ thư viện'),
            ),
            const SizedBox(height: 10),
            _selectedImages.isNotEmpty
                ? Wrap(
              spacing: 10,
              runSpacing: 10,
              children: _selectedImages.map((image) {
                return Stack(
                  children: [
                    Image.file(
                      image,
                      width: 100,
                      height: 100,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton(
                        icon: const Icon(Icons.remove_circle, color: Colors.red),
                        onPressed: () {
                          setState(() {
                            _selectedImages.remove(image);
                          });
                          widget.onImagesSelected(_selectedImages);
                        },
                      ),
                    ),
                  ],
                );
              }).toList(),
            )
                : const Text('Chưa chọn ảnh nào'),
            const SizedBox(height: 10),
            TextFormField(
              controller: keywordController,
              decoration: const InputDecoration(
                labelText: 'Nhập từ khóa',
                hintText: 'Nhập từ khóa...',
              ),
              onChanged: (input) {
                setState(() {
                  filteredKeywords = availableKeywords
                      .where((keyword) => keyword.toLowerCase().contains(input.toLowerCase()))
                      .toList();
                });
              },
            ),
            if (filteredKeywords.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                itemCount: filteredKeywords.length,
                itemBuilder: (context, index) {
                  final keyword = filteredKeywords[index];
                  return ListTile(
                    title: Text(keyword),
                    onTap: () {
                      setState(() {
                        if (!widget.selectedKeywords.contains(keyword)) {
                          widget.selectedKeywords.add(keyword);
                        }
                        keywordController.clear();
                        filteredKeywords.clear();
                      });
                    },
                  );
                },
              ),
            const SizedBox(height: 10),
            Wrap(
              children: widget.selectedKeywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    setState(() {
                      widget.selectedKeywords.remove(keyword);
                    });
                  },
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
