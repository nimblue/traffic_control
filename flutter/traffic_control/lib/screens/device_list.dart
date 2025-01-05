import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/bluetooth_controller.dart';

class DeviceList extends StatelessWidget {
  const DeviceList({
    super.key,
    required this.controller,
    required this.context,
  });

  final BluetoothController controller;
  final BuildContext context;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Obx(() => ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: controller.devices.length,
              itemBuilder: (context, index) {
                final device = controller.devices[index];
                bool isDeviceConnected = controller.isConnected.value;

                return Obx(() =>
                  Card(
                    elevation: 6,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    color: Colors.transparent,
                    shadowColor: Colors.transparent,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: RadialGradient(
                          colors: [Colors.blueGrey[800]!, Colors.black],
                          center: const Alignment(0.5, -0.5),
                          radius: 1.2,
                        ),
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: ListTile(
                        contentPadding:
                            const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                        leading: CircleAvatar(
                          radius: 30,
                          backgroundColor:
                              isDeviceConnected ? Colors.green : Colors.blue,
                          child: Icon(
                            isDeviceConnected
                                ? Icons.bluetooth_connected
                                : Icons.bluetooth,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        title: Text(
                          device.name ?? 'Appareil Inconnu',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.white,
                          ),
                        ),
                        subtitle: Text(
                          device.address,
                          style: const TextStyle(color: Colors.white70),
                        ),
                        trailing: controller.loadingDevices[device.address] ?? false
                            ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white,
                              ),
                        onTap: () async {
                          await controller.connectWithRetry(device);
                          if (controller.isConnected.value) {
                            Get.snackbar(
                              "Connecté",
                              "Connecté à ${device.name}",
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.green,
                              colorText: Colors.white,
                            );
                          } else {
                            Get.snackbar(
                              "Connexion Échouée",
                              "Échec de la connexion à ${device.name}",
                              snackPosition: SnackPosition.BOTTOM,
                              duration: const Duration(seconds: 1),
                              backgroundColor: Colors.red,
                              colorText: Colors.white,
                            );
                          }
                        },
                      ),
                    ),
                  ),
                );
              },
            )),
        // Instructional text at the bottom of the screen
        Positioned(
          bottom: 16.0,
          left: 16.0,
          right: 16.0,
          child: Card(
            color: Colors.white70,
            elevation: 2,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child:  Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.info, color: Colors.blue, size: 25),
                  SizedBox(width: 16),
                    Flexible(
                    child: Text(
                      'Sélectionnez un appareil',
                      style: TextStyle(fontSize: 18, color: Colors.black87),
                      textAlign: TextAlign.center,
                    ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
