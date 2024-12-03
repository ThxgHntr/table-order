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
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1000),  // Limit max width
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: RestaurantDetailsForm.formKey,
          child: Column(
            children: [
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Ngày mở cửa', style: Theme.of(context).textTheme.titleMedium),
                      ...daysOfTheWeek.map((day) {
                        return CheckboxListTile(
                          title: Text(day, style: Theme.of(context).textTheme.bodyLarge),
                          value: widget.isOpened[day] ?? false,
                          onChanged: (value) {
                            setState(() {
                              widget.isOpened[day] = value ?? false;
                            });
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giờ mở cửa', style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: widget.openTimeController,
                              readOnly: true,
                              onTap: () => _selectTime(context, widget.openTimeController),
                              decoration: InputDecoration(
                                labelText: 'Từ',
                                icon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: widget.closeTimeController,
                              readOnly: true,
                              onTap: () => _selectTime(context, widget.closeTimeController),
                              decoration: InputDecoration(
                                labelText: 'Đến',
                                icon: const Icon(Icons.access_time),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      TextFormField(
                        controller: widget.restaurantDescription,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Vui lòng nhập mô tả nhà hàng';
                          }
                          return null;
                        },
                        maxLines: 3,  // Allow multi-line input
                        minLines: 3,  // Start with 3 lines
                        decoration: InputDecoration(
                          labelText: 'Mô tả nhà hàng',
                          hintText: 'Nhập mô tả nhà hàng',
                          icon: const Icon(Icons.restaurant),
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                elevation: 5,
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Giá cả', style: Theme.of(context).textTheme.titleMedium),
                      Row(
                        children: [
                          Expanded(
                            child: TextFormField(
                              controller: widget.minPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Thấp I',
                                icon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: TextFormField(
                              controller: widget.maxPriceController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                labelText: 'Cao I',
                                icon: const Icon(Icons.attach_money),
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickImagesFromGallery,
                icon: const Icon(Icons.image),
                label: const Text('Chọn ảnh từ thư viện'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              _selectedImages.isNotEmpty
                  ? Wrap(
                spacing: 10,
                runSpacing: 10,
                children: _selectedImages.map((image) {
                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(
                          image,
                          width: 100,
                          height: 100,
                          fit: BoxFit.cover,
                        ),
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
                decoration: InputDecoration(
                  labelText: 'Từ khóa',
                  hintText: 'Nhập từ khóa',
                  icon: const Icon(Icons.search),
                  border: OutlineInputBorder(),
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
                spacing: 8,
                children: widget.selectedKeywords
                    .map((keyword) => Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    setState(() {
                      widget.selectedKeywords.remove(keyword);
                    });
                  },
                ))
                    .toList(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
