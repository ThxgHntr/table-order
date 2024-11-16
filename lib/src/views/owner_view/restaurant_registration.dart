import 'package:flutter/material.dart';
import 'package:responsive_builder/responsive_builder.dart';
import 'package:table_order/src/utils/toast_utils.dart';

class RestaurantRegistration extends StatefulWidget {
  const RestaurantRegistration({super.key});

  static const routeName = '/restaurant-registration';

  @override
  State<StatefulWidget> createState() => _RestaurantRegistrationState();
}

class _RestaurantRegistrationState extends State<RestaurantRegistration> {
  int currentStep = 0;
  bool isCompleted = false;

  final restaurantName = TextEditingController();
  final restaurantOwnerName = TextEditingController();
  final restaurantDescription = TextEditingController();

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
        final isLastStep = currentStep == getSteps().length - 1;
        if (isLastStep) {
          showToast(
            'Tên quán ăn: ${restaurantName.text}\n'
                'Tên người đại diện: ${restaurantOwnerName.text}\n'
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
              TextFormField(
                controller: restaurantName,
                decoration: const InputDecoration(
                  hintText: 'Tên quán ăn',
                ),
              ),
            ],
          ),
        ),
        Step(
          state: currentStep >= 1 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 1,
          title: const Text('Thông tin người đại diện'),
          content: Column(
            children: <Widget>[
              TextFormField(
                controller: restaurantOwnerName,
                decoration: const InputDecoration(
                  hintText: 'Họ và tên',
                ),
              ),
            ],
          ),
        ),
        Step(
          state: currentStep >= 2 ? StepState.complete : StepState.indexed,
          isActive: currentStep >= 2,
          title: const Text('Thông tin chi tiết'),
          content: Column(
            children: <Widget>[
              TextFormField(
                controller: restaurantDescription,
                decoration: const InputDecoration(
                  hintText: 'Mô tả',
                ),
              ),
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
                    restaurantName.clear();
                    restaurantOwnerName.clear();
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
