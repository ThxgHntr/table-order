import 'package:flutter/material.dart';
import 'list_map.dart';

class BasicRestaurantInformationFormContent extends StatefulWidget {
  const BasicRestaurantInformationFormContent({
    super.key,
    required this.restaurantName,
    required this.restaurantCity,
    required this.restaurantDistrict,
    required this.restaurantWard,
    required this.restaurantStreet,
  });

  final TextEditingController restaurantName;
  final TextEditingController restaurantCity;
  final TextEditingController restaurantDistrict;
  final TextEditingController restaurantWard;
  final TextEditingController restaurantStreet;

  static final formKey = GlobalKey<FormState>();

  @override
  State<BasicRestaurantInformationFormContent> createState() =>
      BasicRestaurantInformationFormContentState();
}

class BasicRestaurantInformationFormContentState
    extends State<BasicRestaurantInformationFormContent> {

  String? selectedCity;
  String? selectedDistrict;
  String? selectedWard;

  @override
  void initState() {
    super.initState();
    selectedCity = null;
    selectedDistrict = null;
    selectedWard = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 300),
      child: Form(
        key: BasicRestaurantInformationFormContent.formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextFormField(
              controller: widget.restaurantName,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập tên nhà hàng';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Tên nhà hàng',
                hintText: 'Nhập tên nhà hàng',
              ),
            ),
            _gap(),
            FormField<String>(
              validator: (value) {
                if (selectedCity == null) {
                  return 'Làm ơn chọn thành phố';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedCity,
                      onChanged: (newCity) {
                        setState(() {
                          selectedCity = newCity;
                          selectedDistrict = null;
                          selectedWard = null;
                        });
                        widget.restaurantCity.text = newCity ?? '';
                        state.didChange(newCity);
                      },
                      items: cityDistrictMap.keys.map<DropdownMenuItem<String>>((city) {
                        return DropdownMenuItem<String>(
                          value: city,
                          child: Text(city),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Thành phố',
                        hintText: 'Chọn thành phố',
                      ),
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                );
              },
            ),
            _gap(),
            FormField<String>(
              validator: (value) {
                if (selectedDistrict == null) {
                  return 'Làm ơn chọn quận/huyện';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedDistrict,
                      onChanged: (newDistrict) {
                        setState(() {
                          selectedDistrict = newDistrict;
                          selectedWard = null;
                        });
                        widget.restaurantDistrict.text = newDistrict ?? '';
                        state.didChange(newDistrict);
                      },
                      items: selectedCity == null
                          ? []
                          : cityDistrictMap[selectedCity]!
                          .keys
                          .map<DropdownMenuItem<String>>((district) {
                        return DropdownMenuItem<String>(
                          value: district,
                          child: Text(district),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Quận/Huyện',
                        hintText: 'Chọn quận/huyện',
                      ),
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                );
              },
            ),
            _gap(),
            FormField<String>(
              validator: (value) {
                if (selectedWard == null) {
                  return 'Làm ơn chọn phường';
                }
                return null;
              },
              builder: (FormFieldState<String> state) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DropdownButtonFormField<String>(
                      value: selectedWard,
                      onChanged: (newWard) {
                        setState(() {
                          selectedWard = newWard;
                        });
                        widget.restaurantWard.text = newWard ?? '';
                        state.didChange(newWard);
                      },
                      items: selectedDistrict == null
                          ? []
                          : cityDistrictMap[selectedCity]?[selectedDistrict]!
                          .map<DropdownMenuItem<String>>((ward) {
                        return DropdownMenuItem<String>(
                          value: ward,
                          child: Text(ward),
                        );
                      }).toList(),
                      decoration: const InputDecoration(
                        labelText: 'Phường',
                        hintText: 'Chọn phường',
                      ),
                    ),
                    if (state.hasError)
                      Text(
                        state.errorText!,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                  ],
                );
              },
            ),
            _gap(),
            TextFormField(
              controller: widget.restaurantStreet,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Làm ơn nhập tên đường';
                }
                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Đường',
                hintText: 'Nhập đường',
              ),
            ),
            _gap(),
          ],
        ),
      ),
    );
  }

  Widget _gap() {
    return const SizedBox(height: 10);
  }
}