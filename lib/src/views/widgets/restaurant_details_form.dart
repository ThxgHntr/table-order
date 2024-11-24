import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/toast_utils.dart';
import 'list_map.dart';

class RestaurantDetailsForm extends StatefulWidget {
  final TextEditingController openTimeController;
  final TextEditingController closeTimeController;
  final TextEditingController minPriceController;
  final TextEditingController maxPriceController;
  final TextEditingController restaurantDescription;
  final Map<String, bool> isOpened;
  final List<String> selectedKeywords;
  final List<File> selectedImages;
  final Function(List<File>) onImagesSelected;

  const RestaurantDetailsForm({
    super.key,
    required this.openTimeController,
    required this.closeTimeController,
    required this.minPriceController,
    required this.maxPriceController,
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

      // Đảm bảo rằng selectedImages được truyền lại cho widget cha
      widget.onImagesSelected(_selectedImages);

      showToast('Đã chọn ${returnedImages.length} ảnh.');
    } catch (e) {
      showToast('Lỗi khi chọn ảnh: $e');
    }
  }

  Future<void> _selectTime(
      BuildContext context, TextEditingController controller) async {
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
            Text('Ngày mở cửa', style: Theme.of(context).textTheme.titleMedium),
            ...daysOfTheWeek.map((day) {
              return Column(
                children: [
                  CheckboxListTile(
                    title:
                        Text(day, style: Theme.of(context).textTheme.bodyLarge),
                    value: widget.isOpened[day] ?? false,
                    side: const BorderSide(color: Colors.grey),
                    onChanged: (value) {
                      setState(() {
                        widget.isOpened[day] = value ?? false;
                      });
                    },
                  ),
                ],
              );
            }),
            //giá ca bao gom 1 hang co min price - max price
            const SizedBox(height: 10),
            Text('Giờ mở cửa', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.openTimeController,
                    readOnly: true,
                    onTap: () =>
                        _selectTime(context, widget.openTimeController),
                    decoration: const InputDecoration(
                      labelText: 'Từ',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: widget.closeTimeController,
                    readOnly: true,
                    onTap: () =>
                        _selectTime(context, widget.closeTimeController),
                    decoration: const InputDecoration(
                      labelText: 'Đến',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: widget.restaurantDescription,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Vui lòng nhập mô tả nhà hàng';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Mô tả nhà hàng',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                hintText: 'Nhập mô tả nhà hàng',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
            //giá ca bao gom 1 hang co min price - max price
            const SizedBox(height: 10),
            Text('Giá cả', style: Theme.of(context).textTheme.titleMedium),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: widget.minPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá thấp nhất',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      hintText: 'Nhập giá thấp nhất',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextFormField(
                    controller: widget.maxPriceController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Giá cao nhất',
                      labelStyle: TextStyle(color: Colors.grey),
                      floatingLabelStyle: TextStyle(color: Colors.blue),
                      hintText: 'Nhập giá cao nhất',
                      hintStyle: TextStyle(color: Colors.grey),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
                              icon: const Icon(Icons.remove_circle,
                                  color: Colors.red),
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
                labelText: 'Từ khóa',
                labelStyle: TextStyle(color: Colors.grey),
                floatingLabelStyle: TextStyle(color: Colors.blue),
                hintText: 'Nhập từ khóa',
                hintStyle: TextStyle(color: Colors.grey),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
              onChanged: (input) {
                setState(() {
                  filteredKeywords = availableKeywords
                      .where((keyword) =>
                          keyword.toLowerCase().contains(input.toLowerCase()))
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
                    title: Text(
                      keyword,
                      style: TextStyle(color: Colors.grey),
                    ),
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
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.selectedKeywords.map((keyword) {
                return Chip(
                  label: Text(keyword),
                  labelStyle: const TextStyle(color: Colors.grey),
                  side: BorderSide(color: Colors.grey),
                  deleteIconColor: Colors.grey,
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
