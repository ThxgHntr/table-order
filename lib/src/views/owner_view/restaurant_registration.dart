import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:table_order/src/utils/toast_utils.dart';
import 'package:table_order/src/views/widgets/basic_restaurant_information_form_content.dart';
import 'package:table_order/src/views/widgets/restaurant_details_form.dart';
import 'package:table_order/src/views/widgets/restaurant_representative_form_content.dart';
import '../../model/restaurant.dart';
import '../../services/firebase_restaurants_services.dart';

class RestaurantRegistration extends StatefulWidget {
  const RestaurantRegistration({super.key});

  static const routeName = '/restaurant-registration';

  @override
  State<StatefulWidget> createState() => _RestaurantRegistrationState();
}

class _RestaurantRegistrationState extends State<RestaurantRegistration> {
  int currentStep = 0;
  bool isCompleted = false;

  // Controllers for basic info
  final restaurantName = TextEditingController();
  final restaurantCity = TextEditingController();
  final restaurantDistrict = TextEditingController();
  final restaurantWard = TextEditingController();
  final restaurantStreet = TextEditingController();

  // Controllers for representative info
  final restaurantOwnerName = TextEditingController();
  final restaurantPhone = TextEditingController();
  final restaurantEmail = TextEditingController();

  // Controllers for restaurant details
  final openTimeControllers = {
    'Monday': TextEditingController(),
    'Tuesday': TextEditingController(),
    'Wednesday': TextEditingController(),
    'Thursday': TextEditingController(),
    'Friday': TextEditingController(),
    'Saturday': TextEditingController(),
    'Sunday': TextEditingController(),
  };
  final closeTimeControllers = {
    'Monday': TextEditingController(),
    'Tuesday': TextEditingController(),
    'Wednesday': TextEditingController(),
    'Thursday': TextEditingController(),
    'Friday': TextEditingController(),
    'Saturday': TextEditingController(),
    'Sunday': TextEditingController(),
  };
  final isOpened = {
    'Monday': true,
    'Tuesday': true,
    'Wednesday': true,
    'Thursday': true,
    'Friday': true,
    'Saturday': true,
    'Sunday': true,
  };
  final restaurantDescription = TextEditingController();
  final selectedKeywords = <String>[];
  //image
  late final selectedImage = null;

  final FirebaseRestaurantsServices _firebaseAuthServices = FirebaseRestaurantsServices();  // Initialize Firebase service

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Đăng ký quán ăn'),
      ),
      body: isCompleted
          ? buildCompleted()
          : Theme(
        data: Theme.of(context).copyWith(
          colorScheme: ColorScheme.light(primary: Colors.blue),
        ),
        child: ResponsiveBuilder(
          builder: (context, sizingInformation) {
            return buildStepper(
              sizingInformation.deviceScreenType == DeviceScreenType.mobile
                  ? StepperType.vertical
                  : StepperType.horizontal,
            );
          },
        ),
      ),
    );
  }

  Widget buildStepper(StepperType type) {
    return Stepper(
      type: type,
      steps: getSteps(),
      currentStep: currentStep,
      onStepContinue: () {
        if (currentStep == 0) {
          final isValid = BasicRestaurantInformationFormContent
              .formKey.currentState
              ?.validate() ?? false;
          if (!isValid) return;
        } else if (currentStep == 1) {
          final isValid = RestaurantRepresentativeFormContent
              .formKey.currentState
              ?.validate() ?? false;
          if (!isValid) return;
        }

        final isLastStep = currentStep == getSteps().length - 1;
        if (isLastStep) {
          // Lưu thông tin vào Firebase
          saveRestaurantInfoToDatabase();
        } else {
          setState(() {
            currentStep += 1;
          });
        }
      },
      onStepTapped: (step) {
        if (currentStep == 0) {
          final isValid = BasicRestaurantInformationFormContent
              .formKey.currentState
              ?.validate() ?? false;
          if (!isValid) return;
        } else if (currentStep == 1) {
          final isValid = RestaurantRepresentativeFormContent
              .formKey.currentState
              ?.validate() ?? false;
          if (!isValid) return;
        }

        setState(() {
          currentStep = step;
        });
      },
      onStepCancel: () {
        if (currentStep > 0) {
          setState(() {
            currentStep -= 1;
          });
        }
      },
      controlsBuilder: (BuildContext context, ControlsDetails details) {
        final isLastStep = currentStep == getSteps().length - 1;

        return Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Row(
            children: <Widget>[
              ElevatedButton(
                onPressed: details.onStepContinue,
                child: Text(isLastStep ? 'Hoàn tất' : 'Tiếp theo'),
              ),
              const SizedBox(width: 8),
              if (currentStep != 0)
                TextButton(
                  onPressed: details.onStepCancel,
                  child: const Text('Quay lại'),
                ),
            ],
          ),
        );
      },
    );
  }

  List<Step> getSteps() => [
    Step(
      state: currentStep >= 0 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 0,
      title: const Text('Thông tin cơ bản'),
      content: Column(
        children: <Widget>[
          BasicRestaurantInformationFormContent(
            restaurantName: restaurantName,
            restaurantCity: restaurantCity,
            restaurantDistrict: restaurantDistrict,
            restaurantWard: restaurantWard,
            restaurantStreet: restaurantStreet,
          )
        ],
      ),
    ),
    Step(
      state: currentStep >= 1 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 1,
      title: const Text('Thông tin người đại diện'),
      content: Column(
        children: <Widget>[
          RestaurantRepresentativeFormContent(
              restaurantOwnerName: restaurantOwnerName,
              restaurantPhone: restaurantPhone,
              restaurantEmail: restaurantEmail)
        ],
      ),
    ),
    Step(
      state: currentStep >= 2 ? StepState.complete : StepState.indexed,
      isActive: currentStep >= 2,
      title: const Text('Thông tin chi tiết'),
      content: Column(
        children: <Widget>[
          RestaurantDetailsForm(
            openTimeControllers: openTimeControllers,
            closeTimeControllers: closeTimeControllers,
            isOpened: isOpened,
            restaurantDescription: restaurantDescription,
            selectedKeywords: selectedKeywords,
          )
        ],
      ),
    ),
  ];

  Future<void> saveRestaurantInfoToDatabase() async {
    final selectedDays = <String>[]; // Danh sách các ngày được chọn
    final openCloseTimes = <String, Map<String, String>>{}; // Thời gian mở/đóng của các ngày được chọn

    // Lặp qua các ngày trong 'isOpened' và lấy những ngày được chọn
    isOpened.forEach((day, isSelected) {
      if (isSelected) {
        selectedDays.add(day);
        openCloseTimes[day] = {
          'open': openTimeControllers[day]?.text ?? '',
          'close': closeTimeControllers[day]?.text ?? '',
        };
      }
    });

    // Lấy UID của người dùng đăng nhập từ Firebase Auth
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showToast('Vui lòng đăng nhập trước khi đăng ký nhà hàng.');
      return;
    }

    final userId = user.uid; // UID của người dùng đăng nhập

    // Tạo đối tượng RestaurantInfo từ dữ liệu người dùng nhập
    final restaurantInfo = Restaurant(
      restaurantName: restaurantName.text,
      restaurantCity: restaurantCity.text,
      restaurantDistrict: restaurantDistrict.text,
      restaurantWard: restaurantWard.text,
      restaurantStreet: restaurantStreet.text,
      restaurantOwnerName: restaurantOwnerName.text,
      restaurantPhone: restaurantPhone.text,
      restaurantEmail: restaurantEmail.text,
      restaurantDescription: restaurantDescription.text,
      selectedKeywords: selectedKeywords,
      selectedImage: selectedImage,
      openCloseTimes: openCloseTimes,
      userId: userId,
    );

    // Lưu thông tin vào Firebase
    final result = await _firebaseAuthServices.saveRestaurantInfo(restaurantInfo);

    if (result) {
      setState(() {
        isCompleted = true;
      });
    } else {
      showToast('Lỗi khi lưu thông tin. Vui lòng thử lại.');
    }
  }

  buildCompleted() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          const Icon(
            Icons.check_circle,
            color: Colors.green,
            size: 100,
          ),
          const SizedBox(height: 20),
          const Text(
            'Đăng ký quán ăn thành công!',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pushNamed('/restaurant-owner');
                },
                child: const Text('Trở về trang chủ'),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    currentStep = 0;
                    isCompleted = false;

                    // Clear form data
                    restaurantName.clear();
                    restaurantCity.clear();
                    restaurantDistrict.clear();
                    restaurantWard.clear();
                    restaurantStreet.clear();

                    restaurantOwnerName.clear();
                    restaurantPhone.clear();
                    restaurantEmail.clear();
                    restaurantDescription.clear();

                    openTimeControllers.forEach((key, value) {
                      value.clear();
                    });
                    closeTimeControllers.forEach((key, value) {
                      value.clear();
                    });
                    isOpened.forEach((key, value) {
                      isOpened[key] = true;
                    });
                    selectedKeywords.clear();
                  });
                },
                child: const Text('Đăng ký thêm quán ăn'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
