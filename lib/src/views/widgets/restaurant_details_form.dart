import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class RestaurantDetailsForm extends StatefulWidget {
  const RestaurantDetailsForm({
    super.key,
    required this.openTimeControllers,
    required this.closeTimeControllers,
    required this.restaurantDescription,
    required this.isOpened,
    required this.selectedKeywords,
  });

  final Map<String, TextEditingController> openTimeControllers;
  final Map<String, TextEditingController> closeTimeControllers;
  final TextEditingController restaurantDescription;
  final Map<String, bool> isOpened;

  final List<String> selectedKeywords;

  static final formKey = GlobalKey<FormState>();

  @override
  State<StatefulWidget> createState() => _RestaurantDetailsFormState();
}

class _RestaurantDetailsFormState extends State<RestaurantDetailsForm> {
  File? _selectedImage;

  final Map<String, bool> isOpened = {
    'Chủ nhật': false,
    'Thứ hai': false,
    'Thứ ba': false,
    'Thứ tư': false,
    'Thứ năm': false,
    'Thứ sáu': false,
    'Thứ bảy': false,
  };

  final Map<String, TextEditingController> openTimeControllers = {
    'Chủ nhật': TextEditingController(),
    'Thứ hai': TextEditingController(),
    'Thứ ba': TextEditingController(),
    'Thứ tư': TextEditingController(),
    'Thứ năm': TextEditingController(),
    'Thứ sáu': TextEditingController(),
    'Thứ bảy': TextEditingController(),
  };

  final Map<String, TextEditingController> closeTimeControllers = {
    'Chủ nhật': TextEditingController(),
    'Thứ hai': TextEditingController(),
    'Thứ ba': TextEditingController(),
    'Thứ tư': TextEditingController(),
    'Thứ năm': TextEditingController(),
    'Thứ sáu': TextEditingController(),
    'Thứ bảy': TextEditingController(),
  };

  final List<String> restaurantTypes = [
    'Fast Food',
    'Casual Dining',
    'Fine Dining',
    'Cafe',
    'Buffet',
    'Food Truck',
  ];

  final List<String> selectedKeywords = [];
  final List<String> hints = [];

  final TextEditingController restaurantTypeController =
  TextEditingController();

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

  Future _pickImageFromGallery() async {
    final returnedImage =
    await ImagePicker().pickImage(source: ImageSource.gallery);

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
    final returnedImage =
    await ImagePicker().pickImage(source: ImageSource.camera);

    if (returnedImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Không có ảnh nào được chụp!')));
      return;
    }
    setState(() {
      _selectedImage = File(returnedImage.path);
    });
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
            ...isOpened.keys.map((day) => _buildDaySchedule(day)),
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
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return restaurantTypes.where((String option) {
                  return option
                      .toLowerCase()
                      .contains(textEditingValue.text.toLowerCase());
                });
              },
              onSelected: (String selection) {
                setState(() {
                  if (!selectedKeywords.contains(selection)) {
                    selectedKeywords.add(selection);
                    hints.add(selection);
                  }
                  restaurantTypeController.clear();
                });
              },
              fieldViewBuilder: (BuildContext context,
                  TextEditingController fieldTextEditingController,
                  FocusNode fieldFocusNode,
                  VoidCallback onFieldSubmitted) {
                return TextFormField(
                  controller: fieldTextEditingController,
                  focusNode: fieldFocusNode,
                  decoration: const InputDecoration(
                    labelText: 'Nhập loại nhà hàng',
                    hintText: 'Nhập loại nhà hàng',
                  ),
                  onChanged: (value) {
                    restaurantTypeController.text = value;
                  },
                );
              },
            ),
            Wrap(
              spacing: 6.0,
              children: selectedKeywords.map((String keyword) {
                return Chip(
                  label: Text(keyword),
                  onDeleted: () {
                    setState(() {
                      selectedKeywords.remove(keyword);
                      hints.remove(keyword);
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

  Widget _buildDaySchedule(String day) {
    return Column(
      children: [
        Row(
          children: [
            Switch(
              value: isOpened[day]!,
              onChanged: (value) {
                setState(() {
                  isOpened[day] = value;
                });
              },
            ),
            Text(day),
            isOpened[day]! ? const Text('Mở cửa') : const Text('Đóng cửa'),
          ],
        ),
        if (isOpened[day]!)
          TextFormField(
            controller: openTimeControllers[day],
            readOnly: true,
            onTap: () => _selectTime(context, openTimeControllers[day]!),
            decoration: const InputDecoration(
              labelText: 'Giờ mở cửa',
              hintText: 'Chọn giờ mở cửa',
            ),
          ),
        if (isOpened[day]!)
          TextFormField(
            controller: closeTimeControllers[day],
            readOnly: true,
            onTap: () => _selectTime(context, closeTimeControllers[day]!),
            decoration: const InputDecoration(
              labelText: 'Giờ đóng cửa',
              hintText: 'Chọn giờ đóng cửa',
            ),
          ),
        _gap(),
      ],
    );
  }

  Widget _gap() {
    return const SizedBox(height: 10);
  }
}