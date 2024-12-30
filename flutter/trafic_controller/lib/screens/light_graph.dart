import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/traficlight_controller.dart';

class TrafficLightView extends StatelessWidget {
  final TrafficLightController controller = Get.put(TrafficLightController());

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.66,
              ),
              itemCount: 4,
              itemBuilder: (context, index) {
                switch (index) {
                  case 0:
                    return Obx(() => _buildTrafficLight(
                          label: 'Direction A',
                          red: controller.direction1Light.value == 0,
                          yellow: controller.direction1Light.value == 1,
                          green: controller.direction1Light.value == 2,
                        ));
                  case 1:
                    return Obx(() => _buildTrafficLight(
                          label: 'Direction B',
                          red: controller.direction2Light.value == 0,
                          yellow: controller.direction2Light.value == 1,
                          green: controller.direction2Light.value == 2,
                        ));
                  case 2:
                    return Obx(() => _buildTrafficLight(
                          label: 'Piéton A',
                          red: controller.pedestrian1Light.value == 0,
                          green: controller.pedestrian1Light.value == 2,
                        ));
                  case 3:
                    return Obx(() => _buildTrafficLight(
                          label: 'Piéton B',
                          red: controller.pedestrian2Light.value == 0,
                          green: controller.pedestrian2Light.value == 2,
                        ));
                  default:
                    return SizedBox.shrink();
                }
              },
            ),
          ),
          const SizedBox(height: 20),
          _buildSlider(context),
        ],
      ),
    );
  }

  Widget _buildTrafficLight({
    required String label,
    bool red = false,
    bool yellow = false,
    bool green = false,
  }) {
    IconData? icon;
    if (label.contains('Direction')) {
      icon = Icons.traffic; // Icône de feu de signalisation
    } else if (label.contains('Piéton')) {
      icon = Icons.directions_walk; // Icône pour les piétons
    }

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
      child: Column(
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                if (icon != null)
                  Positioned(
                    top: -40,
                    child: Icon(
                      icon,
                      size: 250,
                      color: Colors.white.withAlpha(25),
                    ),
                  ),
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: label.contains('Direction')
                      ? [
                          _buildLight(red, Colors.red),
                          const SizedBox(height: 12),
                          _buildLight(yellow, Colors.amber),
                          const SizedBox(height: 10),
                          _buildLight(green, Colors.green),
                        ]
                      : [
                          _buildPedestrianIcon(red, Colors.red),
                          const SizedBox(height: 20),
                          _buildPedestrianIcon(green, Colors.green),
                        ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLight(bool active, Color color) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      height: 45,
      width: 45,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? color : Colors.grey[600],
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: color.withAlpha(60),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ]
            : [],
        border: Border.all(color: active ? color.withAlpha(200) : Colors.grey),
      ),
    );
  }

  Widget _buildPedestrianIcon(bool active, Color color) {
    return AnimatedContainer(
      child: Icon(
        color == Colors.green
            ? Icons.directions_run
            : Icons.directions_walk_outlined,
        size: 60,
        color: active ? color : Colors.grey[600],
      ),
      duration: const Duration(milliseconds: 400),
      height: 60,
      width: 60,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: active
            ? [
                BoxShadow(
                  color: color.withAlpha(100),
                  blurRadius: 20,
                  spreadRadius: 5,
                ),
                BoxShadow(
                  color: color.withAlpha(60),
                  blurRadius: 10,
                  spreadRadius: 3,
                ),
              ]
            : [],
        border: Border.all(color: active ? color.withAlpha(200) : Colors.grey),
      ),
    );
  }

Widget _buildSlider(BuildContext context) {
  return Container(
    decoration: BoxDecoration(
      color: Color(0xFF37474F), // Darker gray background
      borderRadius: BorderRadius.circular(16),
      boxShadow: [
        BoxShadow(
          color: Color(0xFF455A64).withAlpha(100), // Subtle shadow
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    padding: const EdgeInsets.all(16),
    height: 120, // Reduced height for the widget
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Obx(() => Text(
              'Temps : ${controller.currentTime.value}s',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )),
        const SizedBox(height: 8),
        Obx(() => SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: Color(0xFF607D8B), // Slate gray for active track
                inactiveTrackColor: Color(0xFFB0BEC5), // Light blue for inactive track
                thumbColor: Color(0xFF455A64), // Darker gray for thumb
                overlayColor: Color(0xFF37474F).withAlpha(50), // Darker gray overlay
                trackShape: const RoundedRectSliderTrackShape(),
                thumbShape:
                    const RoundSliderThumbShape(enabledThumbRadius: 14),
                overlayShape:
                    const RoundSliderOverlayShape(overlayRadius: 24),
              ),
              child: Slider(
                value: controller.currentTime.value.toDouble(),
                min: 0,
                max: controller.totalSeconds.toDouble(),
                divisions: controller.totalSeconds,
                label: '${controller.currentTime.value}s',
                onChanged: (value) {
                  controller.setTime(value.toInt());
                },
              ),
            )),
      ],
    ),
  );
}


}
