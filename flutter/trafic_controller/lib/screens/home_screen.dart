import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/bluetooth_controller.dart';
import 'device_list.dart';
import 'edit_mode.dart';
import 'light_graph.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({super.key});
  final BluetoothController controller = Get.put(BluetoothController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: customAppBar(),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orange[200]!, Colors.orange[100]!],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Obx(() {
          if (!controller.isConnected.value) {
            return DeviceList(controller: controller, context: context);
          } else {
            return ControlPanel(
                isEditMode: controller.isEditMode,
                controller: controller,
                context: context);
          }
        }),
      ),
    );
  }

  // Custom AppBar
  AppBar customAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.orangeAccent, Colors.redAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Row(
        children: [
          Icon(Icons.traffic, color: Colors.white, size: 28),
          SizedBox(width: 10),
          Text(
            'Trafic control',
            style: TextStyle(
                fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ],
      ),
      actions: [
        // Edit Mode Button
        Obx(() => IconButton(
              icon: Icon(!controller.isEditMode.value ? Icons.edit : Icons.view_carousel, color: Colors.white, size: 30),
              onPressed: () {
                if (!controller.isConnected.value) {
                  Get.snackbar(
                    "Non Connecté",
                    "Vous devez être connecté pour modifier les paramètres.",
                    snackPosition: SnackPosition.BOTTOM,
                    duration: const Duration(seconds: 1),
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                } else {
                  controller.isEditMode.value = !controller.isEditMode.value;
                }
              },
            )),
        // Bluetooth Button in AppBar
        Obx(() => IconButton(
              icon: Icon(
                controller.isConnected.value
                    ? Icons.exit_to_app
                    : Icons.refresh,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () async {
                if (controller.isConnected.value) {
                  await controller.disconnect();
                  Get.snackbar("Déconnecté",
                      "Déconnecté avec succès de l'appareil.",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.red,
                      colorText: Colors.white);
                } else {
                  await controller.getPairedDevices();
                  Get.snackbar("Actualisé", "Liste des appareils jumelés mise à jour.",
                      snackPosition: SnackPosition.BOTTOM,
                      duration: const Duration(seconds: 1),
                      backgroundColor: Colors.green,
                      colorText: Colors.white);
                }
              },
            )),
      ],
    );
  }
}

class ControlPanel extends StatelessWidget {
  const ControlPanel({
    super.key,
    required this.isEditMode,
    required this.controller,
    required this.context,
  });

  final RxBool isEditMode;
  final BluetoothController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 16),
        Expanded(
          child: Obx(() {
            if (isEditMode.value) {
              return EditModeView();
            } else {
              return TrafficLightView();
            }
          }),
        ),
      ],
    );
  }
}
