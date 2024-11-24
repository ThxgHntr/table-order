import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:table_order/src/utils/toast_utils.dart';
import 'package:table_order/src/views/widgets/basic_restaurant_information_form_content.dart';
import 'package:table_order/src/views/widgets/restaurant_details_form.dart';
import 'package:table_order/src/views/widgets/restaurant_representative_form_content.dart';
import '../../model/restaurant_model.dart';
import '../../services/firebase_restaurants_services.dart';
import '../../utils/location_helper.dart'; // Import the location helper

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
  final restaurantAddress = TextEditingController();

  // Controllers for representative info
  final restaurantPhone = TextEditingController();
  final restaurantEmail = TextEditingController();

  // Controllers for restaurant details
  final openTimeController = TextEditingController();
  final closeTimeController = TextEditingController();
  final isOpened = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
    'Sunday': false,
  };
  final restaurantDescription = TextEditingController();
  final selectedKeywords = List<String>.empty(growable: true);
  final List<File> selectedImages = [];
  final minPriceController = TextEditingController();
  final maxPriceController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đăng ký nhà hàng',
            style: Theme.of(context).textTheme.headlineSmall),
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
          final isValid = BasicRestaurantInformationFormContent
                  .formKey.currentState
                  ?.validate() ??
              false;
          if (!isValid) return;
        } else if (currentStep == 1) {
          final isValid = RestaurantRepresentativeFormContent
                  .formKey.currentState
                  ?.validate() ??
              false;
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
                  ?.validate() ??
              false;
          if (!isValid) return;
        } else if (currentStep == 1) {
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
          title: Text('Thông tin cơ bản',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            children: <Widget>[
              BasicRestaurantInformationFormContent(
                restaurantName: restaurantName,
                restaurantAddress: restaurantAddress,
              ),
            ],
          ),
        ),
        Step(
          state: currentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: Text('Thông tin người đại diện',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            children: <Widget>[
              RestaurantRepresentativeFormContent(
                  restaurantPhone: restaurantPhone,
                  restaurantEmail: restaurantEmail),
            ],
          ),
        ),
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: Text('Thông tin chi tiết',
              style: Theme.of(context).textTheme.titleLarge),
          content: Column(
            children: <Widget>[
              RestaurantDetailsForm(
                openTimeController: openTimeController,
                closeTimeController: closeTimeController,
                minPriceController: minPriceController,
                maxPriceController: maxPriceController,
                isOpened: isOpened,
                restaurantDescription: restaurantDescription,
                selectedKeywords: selectedKeywords,
                selectedImages: selectedImages,
                onImagesSelected: (images) {
                  setState(() {
                    selectedImages.clear();
                    selectedImages.addAll(images);
                  });
                  if (kDebugMode) {
                    print('Selected images: $selectedImages');
                  }
                },
              ),
            ],
          ),
        ),
      ];

  Future<void> saveRestaurantInfoToDatabase() async {
    final selectedDays = <String>[];
    final openCloseTimes = <String, String>{};

    isOpened.forEach((day, isSelected) {
      if (isSelected) {
        selectedDays.add(day);
      }
    });

    openCloseTimes['open'] = openTimeController.text;
    openCloseTimes['close'] = closeTimeController.text;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      showToast('Vui lòng đăng nhập trước khi đăng ký nhà hàng.');
      return;
    }

    final restaurantId =
        user.uid + DateTime.now().millisecondsSinceEpoch.toString();

    final ownerId = user.uid;

    final location = await getGeopointFromAddress(restaurantAddress.text);

    final restaurantInfo = RestaurantModel(
      restaurantId: restaurantId,
      name: restaurantName.text,
      phone: restaurantPhone.text,
      description: restaurantDescription.text,
      dishesStyle: selectedKeywords,
      priceRange: PriceRange(
        lowest: int.parse(minPriceController.text.trim()),
        highest: int.parse(maxPriceController.text.trim()),
      ),
      openDates: selectedDays,
      openTime: openCloseTimes,
      rating: 0.0,
      photosToUpload: selectedImages,
      ownerId: ownerId,
      location: location,
      state: 0, // 0: Chờ duyệt, 1: Đã duyệt, 2: Từ chối
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    final result =
        await FirebaseRestaurantsServices().saveRestaurantInfo(restaurantInfo);

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
            'Đăng ký nhà hàng thành công!',
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
                  Navigator.of(context).pushNamed('/');
                },
                child: const Text('Trở về trang chủ'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
