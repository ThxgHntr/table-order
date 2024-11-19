import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:table_order/src/utils/toast_utils.dart';
import 'package:table_order/src/views/widgets/basic_restaurant_information_form_content.dart';
import 'package:table_order/src/views/widgets/restaurant_details_form.dart';
import 'package:table_order/src/views/widgets/restaurant_representative_form_content.dart';

class RestaurantRegistration extends StatefulWidget {
  const RestaurantRegistration({super.key});

  static const routeName = '/restaurant-registration';

  @override
  State<StatefulWidget> createState() => _RestaurantRegistrationState();
}

class _RestaurantRegistrationState extends State<RestaurantRegistration> {
  int currentStep = 0;
  bool isCompleted = false;

  // Controllers basic info
  final restaurantName = TextEditingController();
  final restaurantCity = TextEditingController();
  final restaurantDistrict = TextEditingController();
  final restaurantWard = TextEditingController();
  final restaurantStreet = TextEditingController();

  // Controllers representative info
  final restaurantOwnerName = TextEditingController();
  final restaurantPhone = TextEditingController();
  final restaurantEmail = TextEditingController();

  // Controllers restaurant details
  final openTimeControllers = {
    'Chủ nhật': TextEditingController(),
    'Thứ hai': TextEditingController(),
    'Thứ ba': TextEditingController(),
    'Thứ tư': TextEditingController(),
    'Thứ năm': TextEditingController(),
    'Thứ sáu': TextEditingController(),
    'Thứ bảy': TextEditingController(),
  };
  final closeTimeControllers = {
    'Chủ nhật': TextEditingController(),
    'Thứ hai': TextEditingController(),
    'Thứ ba': TextEditingController(),
    'Thứ tư': TextEditingController(),
    'Thứ năm': TextEditingController(),
    'Thứ sáu': TextEditingController(),
    'Thứ bảy': TextEditingController(),
  };
  final isOpened = {
    'Chủ nhật': false,
    'Thứ hai': false,
    'Thứ ba': false,
    'Thứ tư': false,
    'Thứ năm': false,
    'Thứ sáu': false,
    'Thứ bảy': false,
  };
  final restaurantDescription = TextEditingController();
  final selectedKeywords = <String>[];

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
              sizingInformation.deviceScreenType ==
                  DeviceScreenType.mobile
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
          // Kiểm tra tính hợp lệ ở bước đầu tiên
          final isValid = BasicRestaurantInformationFormContent
              .formKey.currentState
              ?.validate() ??
              false;
          if (!isValid) return;
        } else if (currentStep == 1) {
          // Kiểm tra tính hợp lệ ở bước thứ hai
          final isValid = RestaurantRepresentativeFormContent
              .formKey.currentState
              ?.validate() ??
              false;
          if (!isValid) return;
        }

        final isLastStep = currentStep == getSteps().length - 1;
        if (isLastStep) {
          showToast(
            'Tên quán ăn: ${restaurantName.text}\n'
                'Tên người đại diện: ${restaurantOwnerName.text}\n'
                'Thành phố: ${restaurantCity.text}\n'
                'Mô tả: ${restaurantDescription.text}',
          );
          setState(() => isCompleted = true);
        } else {
          setState(() {
            currentStep += 1;
          });
        }
      },
      onStepTapped: (step) {
        if (currentStep == 0) {
          // Kiểm tra tính hợp lệ ở bước đầu tiên
          final isValid = BasicRestaurantInformationFormContent
              .formKey.currentState
              ?.validate() ??
              false;
          if (!isValid) return;
        } else if (currentStep == 1) {
          // Kiểm tra tính hợp lệ ở bước thứ hai
          final isValid = RestaurantRepresentativeFormContent
              .formKey.currentState
              ?.validate() ??
              false;
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
            restaurantDescription: restaurantDescription,
            isOpened: isOpened,
            selectedKeywords: selectedKeywords,
          )
        ],
      ),
    ),
  ];

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

                    //clear tf basic info
                    restaurantName.clear();
                    restaurantCity.clear();
                    restaurantDistrict.clear();
                    restaurantWard.clear();
                    restaurantStreet.clear();

                    //clear tf representative info
                    restaurantOwnerName.clear();
                    restaurantPhone.clear();
                    restaurantEmail.clear();

                    restaurantDescription.clear();
                  });
                },
                child: const Text('Đăng ký quán khác'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}