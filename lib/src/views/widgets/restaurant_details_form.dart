import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'list_map.dart';

class RestaurantDetailsForm extends StatefulWidget {
  final Map<String, TextEditingController> openTimeControllers;
  final Map<String, TextEditingController> closeTimeControllers;
  final TextEditingController restaurantDescription;
  final Map<String, bool> isOpened;
  final List<String> selectedKeywords;

  const RestaurantDetailsForm({
    super.key,
    required this.openTimeControllers,
    required this.closeTimeControllers,
    required this.restaurantDescription,
    required this.isOpened,
    required this.selectedKeywords,
  });

  static final formKey = GlobalKey<FormState>();

  @override
  State<StatefulWidget> createState() => _RestaurantDetailsFormState();
}

class _RestaurantDetailsFormState extends State<RestaurantDetailsForm> {
  File? _selectedImage;

  TextEditingController keywordController = TextEditingController();
  List<String> filteredKeywords = [];

  Future _pickImageFromGallery() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (returnedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh nào được chọn!')));
      return;
    }
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
  }

  Future _pickImageFromCamera() async {
    final returnedImage = await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh nào được chọn!')));
      return;
    }
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Thời gian mở cửa'),
            ...daysOfTheWeek.map((day) {
              return Column(
                children: [
                  CheckboxListTile(
                    title: Text(day),
                    value: widget.isOpened[day] ?? false, // Ensure it's never null
                    onChanged: (value) {
                      setState(() {
                        widget.isOpened[day] = value ?? false;
                        if (widget.isOpened[day] == false) {
                          // Initialize controllers to avoid null values
                          widget.openTimeControllers[day] ??= TextEditingController();
                          widget.closeTimeControllers[day] ??= TextEditingController();
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
            _gap(),
            TextFormField(
              controller: widget.restaurantDescription,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập mô tả quán ăn';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Mô tả quán ăn',
                hintText: 'Nhập mô tả quán ăn',
              ),
            ),
            _gap(),
            Text('Chọn ảnh'),
            Row(
              children: [
                ElevatedButton(
                  onPressed: _pickImageFromGallery,
                  child: const Text('Chọn ảnh'),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _pickImageFromCamera,
                  child: const Text('Chụp ảnh'),
                ),
              ],
            ),
            _selectedImage != null
                ? Image.file(
              _selectedImage!,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
            )
                : const Text('Chưa chọn ảnh'),
            _gap(),
            // Keyword input field with dynamic hints
            TextFormField(
              controller: keywordController,
              decoration: const InputDecoration(
                labelText: 'Nhập từ khóa',
                hintText: 'Nhập từ khóa...',
              ),
              onChanged: (input) {
                setState(() {
                  // Filter the available keywords based on input
                  filteredKeywords = availableKeywords
                      .where((keyword) => keyword.toLowerCase().contains(input.toLowerCase()))
                      .toList();
                });
              },
            ),
            if (filteredKeywords.isNotEmpty) ...[
              // Show filtered keywords as hints below the input field
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
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
                        keywordController.clear(); // Clear input after selection
                        filteredKeywords.clear(); // Clear suggestions
                      });
                    },
                  );
                },
              ),
            ],
            _gap(),
            // Display selected keywords with remove button
            Wrap(
              children: widget.selectedKeywords.map((selectedKeyword) {
                return Chip(
                  label: Text(selectedKeyword),
                  backgroundColor: Colors.green,
                  deleteIcon: Icon(Icons.remove_circle_outline),
                  onDeleted: () {
                    setState(() {
                      widget.selectedKeywords.remove(selectedKeyword);
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

  Widget _gap() {
    return const SizedBox(height: 10);
  }
}
