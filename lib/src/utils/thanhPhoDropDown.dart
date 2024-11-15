import 'package:flutter/material.dart';

class ThanhPhoDropDown extends StatefulWidget {
  const ThanhPhoDropDown({super.key});

  @override
  State<ThanhPhoDropDown> createState() => _ThanhPhoDropDownState();
}

class _ThanhPhoDropDownState extends State<ThanhPhoDropDown> {
  String _selectedItem = '';
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Center(
          child: Container(
            width: 300,
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 20),
                AutocompleteTextField(
                  items: _countries,
                  decoration: const InputDecoration(
                      labelText: 'Chọn thành phố',
                      border: OutlineInputBorder()),
                  validator: (val) {
                    if (_countries.contains(val)) {
                      return null;
                    } else {
                      return 'Thành phố không hợp lệ';
                    }
                  },
                  onItemSelect: (selected) {
                    setState(() {
                      _selectedItem = selected;
                    });
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AutocompleteTextField extends StatefulWidget {
  final List<String> items;
  final Function(String) onItemSelect;
  final InputDecoration? decoration;
  final String? Function(String?)? validator;

  const AutocompleteTextField(
      {super.key,
      required this.items,
      required this.onItemSelect,
      this.decoration,
      this.validator});

  @override
  State<AutocompleteTextField> createState() => _AutocompleteTextFieldState();
}

class _AutocompleteTextFieldState extends State<AutocompleteTextField> {
  final FocusNode _focusNode = FocusNode();
  late OverlayEntry _overlayEntry;
  final LayerLink _layerLink = LayerLink();
  late List<String> _filteredItems;

  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _focusNode.addListener(() {
      if (_focusNode.hasFocus) {
        _overlayEntry = _createOverlayEntry();
        Overlay.of(context)?.insert(_overlayEntry);
      } else {
        _overlayEntry.remove();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: TextFormField(
        controller: _controller,
        focusNode: _focusNode,
        onChanged: _onFieldChange,
        decoration: widget.decoration,
        validator: widget.validator,
      ),
    );
  }

  void _onFieldChange(String val) {
    setState(() {
      if (val == '') {
        _filteredItems = widget.items;
      } else {
        _filteredItems = widget.items
            .where(
                (element) => element.toLowerCase().contains(val.toLowerCase()))
            .toList();
      }
    });
  }

  OverlayEntry _createOverlayEntry() {
    RenderBox renderBox = context.findRenderObject() as RenderBox;
    var size = renderBox.size;

    return OverlayEntry(
        builder: (context) => Positioned(
              width: size.width,
              child: CompositedTransformFollower(
                link: _layerLink,
                showWhenUnlinked: false,
                offset: Offset(0.0, size.height + 5.0),
                child: Material(
                  elevation: 4.0,
                  child: Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    child: ListView.builder(
                      itemCount: _filteredItems.length,
                      itemBuilder: (BuildContext context, int index) {
                        final item = _filteredItems[index];
                        return ListTile(
                          title: Text(item),
                          onTap: () {
                            _controller.text = item;
                            _focusNode.unfocus();
                            widget.onItemSelect(item);
                          },
                        );
                      },
                    ),
                  ),
                ),
              ),
            ));
  }
}

final List<String> _countries = [
'An Giang',
'Bà Rịa - Vũng Tàu',
'Bắc Giang',
'Bắc Kạn',
'Bạc Liêu',
'Bắc Ninh',
'Bến Tre',
'Bình Định',
'Bình Dương',
'Bình Phước',
'Bình Thuận',
'Cà Mau',
'Cần Thơ',
'Cao Bằng',
'Đà Nẵng',
'Đắk Lắk',
'Đắk Nông',
'Điện Biên',
'Đồng Nai',
'Đồng Tháp',
'Gia Lai',
'Hà Giang',
'Hà Nam',
'Hà Nội',
'Hà Tĩnh',
'Hải Dương',
'Hải Phòng',
'Hậu Giang',
'Hòa Bình',
'Hưng Yên',
'Khánh Hòa',
'Kiên Giang',
'Kon Tum',
'Lai Châu',
'Lâm Đồng',
'Lạng Sơn',
'Lào Cai',
'Long An',
'Nam Định',
'Nghệ An',
'Ninh Bình',
'Ninh Thuận',
'Phú Thọ',
'Phú Yên',
'Quảng Bình',
'Quảng Nam',
'Quảng Ngãi',
'Quảng Ninh',
'Quảng Trị',
'Sóc Trăng',
'Sơn La',
'Tây Ninh',
'Thái Bình',
'Thái Nguyên',
'Thanh Hóa',
'Thừa Thiên Huế',
'Tiền Giang',
'TP. Hồ Chí Minh',
'Trà Vinh',
'Tuyên Quang',
'Vĩnh Long',
'Vĩnh Phúc',
'Yên Bái'
];
