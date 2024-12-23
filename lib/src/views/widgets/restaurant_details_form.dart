
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../utils/toast_utils.dart';
import '../../utils/validation_utils.dart';
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
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                    if (validateOpeningDays(widget.isOpened) != null)
                      Text(
                        validateOpeningDays(widget.isOpened)!,
                        style: TextStyle(color: Colors.red),
                      ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                            validator: validateTime,
                            decoration: const InputDecoration(
                              labelText: 'Từ',
                              labelStyle: TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(color: Colors.blue),
                              hintText: 'Chọn giờ mở cửa',
                              hintStyle: TextStyle(color: Colors.grey),
                              icon: Icon(Icons.access_time),
                              border: UnderlineInputBorder(
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
                            onTap: () => _selectTime(context, widget.closeTimeController),
                            validator: validateTime, // Add validation
                            decoration: const InputDecoration(
                              labelText: 'Đến',
                              labelStyle: TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(color: Colors.blue),
                              hintText: 'Chọn giờ đóng cửa',
                              hintStyle: TextStyle(color: Colors.grey),
                              icon: Icon(Icons.access_time),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextFormField(
                      controller: widget.restaurantDescription,
                      validator: validateDescription, // Add validation
                      maxLines: 3,  // Allow multi-line input
                      minLines: 3,  // Start with 3 lines
                      decoration: const InputDecoration(
                        labelText: 'Mô tả nhà hàng',
                        labelStyle: TextStyle(color: Colors.grey),
                        floatingLabelStyle: TextStyle(color: Colors.blue),
                        hintText: 'Nhập mô tả nhà hàng',
                        hintStyle: TextStyle(color: Colors.grey),
                        icon: Icon(Icons.restaurant),
                        border: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.grey),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
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
                            validator: validatePrice, // Add validation
                            decoration: const InputDecoration(
                              labelText: 'Thấp nhất',
                              labelStyle: TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(color: Colors.blue),
                              hintText: 'Nhập giá thấp nhất',
                              hintStyle: TextStyle(color: Colors.grey),
                              icon: Icon(Icons.attach_money),
                              border: UnderlineInputBorder(
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
                            validator: validatePrice, // Add validation
                            decoration: const InputDecoration(
                              labelText: 'Cao nhất',
                              labelStyle: TextStyle(color: Colors.grey),
                              floatingLabelStyle: TextStyle(color: Colors.blue),
                              hintText: 'Nhập giá cao nhất',
                              hintStyle: TextStyle(color: Colors.grey),
                              icon: Icon(Icons.attach_money),
                              border: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _pickImagesFromGallery,
                icon: const Icon(Icons.image),
                label: const Text('Chọn ảnh từ thư viện'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              if (validateImages(_selectedImages) != null)
                Text(
                  validateImages(_selectedImages)!,
                  style: TextStyle(color: Colors.red),
                ),
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
                decoration: const InputDecoration(
                  labelText: 'Từ khóa',
                  labelStyle: TextStyle(color: Colors.grey),
                  floatingLabelStyle: TextStyle(color: Colors.blue),
                  hintText: 'Nhập từ khóa',
                  hintStyle: TextStyle(color: Colors.grey),
                  icon: Icon(Icons.search),
                  border: UnderlineInputBorder(
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
              if (validateKeywords(widget.selectedKeywords) != null)
                Text(
                  validateKeywords(widget.selectedKeywords)!,
                  style: TextStyle(color: Colors.red),
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
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}