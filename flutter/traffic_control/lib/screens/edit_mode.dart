import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bluetooth_controller.dart';

class EditModeView extends StatelessWidget {
  final BluetoothController controller = Get.put(BluetoothController());

  EditModeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Temporary variables to hold changes
    RxInt greenTime1 = controller.green1Value.value.obs;
    RxInt greenTime2 = controller.green2Value.value.obs;
    RxInt yellowTime = controller.yellowValue.value.obs;
    RxInt redTime = controller.redValue.value.obs;
    RxBool activateNightModeLocal = controller.activateNightMode.value.obs;

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.7,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildDialContainer(
                  buildDialWidget("Vert A", greenTime1, Colors.green),
                ),
                _buildDialContainer(
                  buildDialWidget("Vert B", greenTime2, Colors.green.shade700),
                ),
                _buildDialContainer(
                  buildDialWidget("Jaune", yellowTime, Colors.yellow),
                ),
                _buildDialContainer(
                  buildDialWidget("Rouge", redTime, Colors.red),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildFullWidthContainer(
              buildNightModeWidget(activateNightModeLocal),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                  elevation: 0, 
                    backgroundColor: Colors.grey,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  icon: const Icon(Icons.cancel, color: Colors.white, size: 24),
                  label: const Text("Annuler", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Exit edit mode without saving
                    controller.isEditMode.value = false;
                  },
                ),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orangeAccent[700],
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        vertical: 16.0, horizontal: 32.0),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  icon: const Icon(Icons.save, color: Colors.white, size: 24),
                  label: const Text("Sauvegarder", style: TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    // Save logic: Update controller values
                    controller.green1Value.value = greenTime1.value;
                    controller.green2Value.value = greenTime2.value;
                    controller.yellowValue.value = yellowTime.value;
                    controller.redValue.value = redTime.value;
                    controller.activateNightMode.value = activateNightModeLocal.value;

                    // Exit edit mode
                    controller.isEditMode.value = false;
                    
                    controller.updateValues();
                    controller.updateValues();

                    // Show confirmation message
                    Get.snackbar(
                      "Sauvegardé",
                      "Les valeurs ont été enregistrées avec succès !",
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildDialContainer(Widget child) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.blueGrey[800]!, Colors.black],
          center: const Alignment(0.5, -0.5),
          radius: 1.2,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget _buildFullWidthContainer(Widget child) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [Colors.blueGrey[800]!, Colors.black],
          center: const Alignment(0.5, -0.5),
          radius: 1.2,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(120),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: child,
    );
  }

  Widget buildDialWidget(String label, RxInt value, Color color) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(height: 20),
        Obx(() => GestureDetector(
              onPanUpdate: (details) {
                value.value =
                    (value.value + details.delta.dy.toInt()).clamp(1, 100);
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 80,
                    height: 80,
                    child: CircularProgressIndicator(
                      value: value.value / 100,
                      color: color,
                      backgroundColor: color.withAlpha(50),
                      strokeWidth: 10,
                    ),
                  ),
                  Text(
                    "${value.value}",
                    style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: color),
                  ),
                ],
              ),
            )),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: Icon(Icons.remove, color: color),
              onPressed: () => value.value = (value.value - 1).clamp(1, 100),
            ),
            IconButton(
              icon: Icon(Icons.add, color: color),
              onPressed: () => value.value = (value.value + 1).clamp(1, 100),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildNightModeWidget(RxBool activateNightModeLocal) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          "Mode Nuit",
          style: TextStyle(
              fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
        ),
        const SizedBox(width: 40),
        Obx(() => Switch(
              value: activateNightModeLocal.value,
              onChanged: (bool newValue) {
                activateNightModeLocal.value = newValue;
              },
              activeColor: Colors.blue,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey.shade600,
            )),
        const SizedBox(height: 10),
      ],
    );
  }
}
