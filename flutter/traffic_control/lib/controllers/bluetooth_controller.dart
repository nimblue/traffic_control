import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:get/get.dart';

class BluetoothController extends GetxController {
  final FlutterBluetoothSerial flutterBluetoothSerial =
      FlutterBluetoothSerial.instance;

  RxList<BluetoothDevice> devices = <BluetoothDevice>[].obs;
  Rx<BluetoothConnection?> connection = Rx<BluetoothConnection?>(null);
  RxBool isConnected = false.obs;
  Rx<BluetoothDevice?> connectedDevice = Rx<BluetoothDevice?>(null);

  final RxString receivedData = ''.obs;
  final RxList<String> responseBuffer = <String>[].obs;

  final RxBool isEditMode = false.obs;
  final RxInt green1Value = 30.obs;
  final RxInt green2Value = 35.obs;
  final RxInt yellowValue = 3.obs;
  final RxInt redValue = 2.obs;
  final RxBool activateNightMode = true.obs;

  RxBool isBluetoothEnabled = false.obs;
  RxMap<String, bool> loadingDevices = <String, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    getPairedDevices();
  }

  // Check if Bluetooth is enabled
  Future<void> checkBluetoothState() async {
    bool enabled = await flutterBluetoothSerial.isEnabled ?? false;
    isBluetoothEnabled.value = enabled;

    if (!enabled) {
      Get.defaultDialog(
        title: "Bluetooth Désactivé",
        middleText: "Voulez-vous activer le Bluetooth ?",
        titleStyle: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.deepOrangeAccent,
        ),
        middleTextStyle: const TextStyle(
          fontSize: 16,
          color: Colors.black87,
        ),
        backgroundColor: Colors.white,
        radius: 20.0, // Rounded corners for the dialog
        barrierDismissible: false, // Prevent dismissal by tapping outside
        contentPadding:
            const EdgeInsets.all(20.0), // Content padding for inner spacing
        actions: [
          // "Activer Bluetooth" button
          ElevatedButton(
            onPressed: () async {
              await flutterBluetoothSerial.requestEnable();
              await getPairedDevices();
              Get.back();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.deepOrangeAccent, // Button color
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 6, // Slight elevation for 3D effect
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.bluetooth,
                    color: Colors.white, size: 20), // Bluetooth icon
                SizedBox(width: 8),
                Text(
                  "Activer Bluetooth",
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ],
            ),
          ),
          // "Annuler" button
          TextButton(
            onPressed: () {
              Get.back();
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.deepOrangeAccent,
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
              textStyle:
                  const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
            child: const Text("Annuler", style: TextStyle(fontSize: 16)),
          ),
        ],
      );
    }
  }

  // Get a list of paired devices
  Future<void> getPairedDevices() async {
    try {
      final pairedDevices = await flutterBluetoothSerial.getBondedDevices();
      devices.value = pairedDevices;
      if (pairedDevices.isEmpty) {
        await checkBluetoothState();
      }
    } catch (e) {
      debugPrint("Error fetching paired devices: $e");
    }
  }

  Future<void> connectWithRetry(BluetoothDevice device) async {
    {
      await checkBluetoothState();
      loadingDevices[device.address] = true; // Start loading
      final startTime = DateTime.now();

      while (DateTime.now().difference(startTime).inSeconds < 2) {
        if (isBluetoothEnabled.value) {
          await connectToDevice(device);
          if (isConnected.value) return;
        }
        await Future.delayed(
            const Duration(milliseconds: 10)); // Retry after 1 second
      }
    }
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      final BluetoothConnection bluetoothConnection =
          await BluetoothConnection.toAddress(device.address);
      connection.value = bluetoothConnection;
      isConnected.value = true;
      await Future.delayed(const Duration(milliseconds: 100));
      fetchValues();
      await Future.delayed(const Duration(milliseconds: 100));
      fetchValues();
      _listenToIncomingData();
      connectedDevice.value = device;
    } catch (e) {
      debugPrint("Error connecting to ${device.name}: $e");
      isConnected.value = false;
    } finally {
      loadingDevices[device.address] = false; // Stop loading
    }
  }

  void _listenToIncomingData() {
    if (connection.value != null) {
      String buffer = "";

      connection.value!.input!.listen((Uint8List data) {
        String chunk = utf8.decode(data, allowMalformed: true);
        buffer += chunk;

        while (buffer.contains('\n')) {
          int newlineIndex = buffer.indexOf('\n');
          String message = buffer.substring(0, newlineIndex).trim();
          buffer =
              buffer.substring(newlineIndex + 1); // Remove processed message

          receivedData.value = message;
          _processCommand(message);
        }
      }).onDone(() {
        debugPrint('Disconnected from device');
        connection.value = null;
        isConnected.value = false;
        Get.snackbar("Déconnecté", "Déconnecté de l'appareil.",
            snackPosition: SnackPosition.BOTTOM,
            duration: const Duration(seconds: 1),
            backgroundColor: Colors.red,
            colorText: Colors.white);
      });
    }
  }

  void _processCommand(String command) {
    command = command.replaceAll(
        RegExp(r'[^\w: ]'), ''); // Remove unexpected characters
    List<String> splittedCommand = command.trim().split(":");
    switch (splittedCommand[0]) {
      case "GG1":
        green1Value.value = int.parse(splittedCommand[1]);
        debugPrint("green 1 changed to ${int.parse(splittedCommand[1])}");
        break;
      case "GG2":
        green2Value.value = int.parse(splittedCommand[1]);
        debugPrint("green 2 changed to ${int.parse(splittedCommand[1])}");
        break;
      case "GY":
        yellowValue.value = int.parse(splittedCommand[1]);
        debugPrint("yellow changed to ${int.parse(splittedCommand[1])}");
        break;
      case "GR":
        redValue.value = int.parse(splittedCommand[1]);
        debugPrint("red changed to ${int.parse(splittedCommand[1])}");
        break;
      case "INM":
        activateNightMode.value = splittedCommand[1] == "0" ? false : true;
        debugPrint("active mode changed to ${int.parse(splittedCommand[1])}");
        break;
      default:
        debugPrint('Ignore command: $command');
    }
  }

  Future<void> sendData(String data) async {
    if (connection.value != null && isConnected.value) {
      try {
        final encodedData = utf8.encode('$data\n');
        connection.value!.output.add(Uint8List.fromList(encodedData));
        await connection.value!.output.allSent; // Ensure data is fully sent
      } catch (e) {
        debugPrint("Error sending data: $e");
      }
    }
  }

  void fetchValues() async {
    debugPrint("Fetching values");
    try {
      await sendData('GET');
    } catch (e) {
      Get.snackbar("Error", "Failed to fetch values: $e");
    }
  }

  void updateValues() async {
    try {
      await Future.delayed(const Duration(milliseconds: 100));
      await sendData('SG1:${green1Value.value}');
      await Future.delayed(const Duration(milliseconds: 100));
      await sendData('SG2:${green2Value.value}');
      await Future.delayed(const Duration(milliseconds: 100));
      await sendData('SY:${yellowValue.value}');
      await Future.delayed(const Duration(milliseconds: 100));
      await sendData('SR:${redValue.value}');
      await Future.delayed(const Duration(milliseconds: 100));
      await sendData('INM:${activateNightMode.value ? 1 : 0}');
    } catch (e) {
      Get.snackbar("Error", "Failed to update values: $e");
    }
  }

  Future<void> disconnect() async {
    if (connection.value != null) {
      await connection.value!.close();
      connection.value = null;
      isConnected.value = false;
      connectedDevice.value = null;
      responseBuffer.clear();
    }
  }
}
