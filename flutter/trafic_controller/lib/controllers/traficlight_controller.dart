import 'package:get/get.dart';

import 'bluetooth_controller.dart';

class TrafficLightController extends GetxController {
  final BluetoothController btController = Get.put(BluetoothController());
  RxInt currentTime = 0.obs; // Current time in seconds
  RxInt direction1Light = 0.obs; // 0: Red, 1: Yellow, 2: Green
  RxInt direction2Light = 0.obs;
  RxInt pedestrian1Light = 0.obs; // 0: Red, 1: Green
  RxInt pedestrian2Light = 0.obs;
  int totalSeconds = 75;

  final currentPhase = 0.obs;
  final phaseStartTime = 0.obs;

  void activateTrafficLight({
    required int direction1,
    required int direction2,
    required int pedestrian1,
    required int pedestrian2,
  }) {
    direction1Light.value = direction1; // Green
    direction2Light.value = direction2;
    pedestrian1Light.value = pedestrian1; // Green
    pedestrian2Light.value = pedestrian2;
  }

  Future<void> updateLight() async {
    await Future.delayed(const Duration(milliseconds: 50));
    int greenTime1 = btController.green1Value.value;
    int greenTime2 = btController.green2Value.value;
    int yellowTime = btController.yellowValue.value;
    int redClearTime = btController.redValue.value;
    totalSeconds =
        greenTime1 + yellowTime + redClearTime + greenTime2 + yellowTime;
    int elapsed = currentTime.value;
    print("case ${currentPhase.value}");

    if (elapsed >= 0 && elapsed <= greenTime1) {
      // Phase 0
      activateTrafficLight(
          direction1: 2, direction2: 0, pedestrian1: 0, pedestrian2: 2);
    } else if (elapsed > greenTime1 && elapsed <= greenTime1 + yellowTime) {
      // Phase 1
      activateTrafficLight(
          direction1: 1, direction2: 0, pedestrian1: 0, pedestrian2: 0);
    } else if (elapsed > greenTime1 + yellowTime &&
        elapsed <= greenTime1 + yellowTime + redClearTime) {
      // Phase 2
      activateTrafficLight(
          direction1: 0, direction2: 0, pedestrian1: 0, pedestrian2: 0);
    } else if (elapsed > greenTime1 + yellowTime + redClearTime &&
        elapsed <= greenTime1 + yellowTime + redClearTime + redClearTime) {
      // Phase 3
      activateTrafficLight(
          direction1: 0, direction2: 2, pedestrian1: 0, pedestrian2: 0);
    } else if (elapsed > greenTime1 + yellowTime + redClearTime &&
        elapsed <= greenTime1 + yellowTime + redClearTime + greenTime2) {
      // Phase 4
      activateTrafficLight(
          direction1: 0, direction2: 2, pedestrian1: 2, pedestrian2: 0);
    } else if (elapsed > greenTime1 + yellowTime + redClearTime + greenTime2 &&
        elapsed <=
            greenTime1 + yellowTime + redClearTime + greenTime2 + yellowTime) {
      // Phase 5
      activateTrafficLight(
          direction1: 0, direction2: 1, pedestrian1: 0, pedestrian2: 0);
    }
  }

  void setTime(int time) {
    currentTime.value = time;
    updateLight();
    print(currentTime);
  }

  @override
  void onInit() {
    super.onInit();
    updateLight();
  }
}
