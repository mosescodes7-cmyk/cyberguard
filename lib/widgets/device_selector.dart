import 'package:device_preview/device_preview.dart';
import 'package:device_preview/presets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class DeviceSelector extends StatelessWidget {
  const DeviceSelector({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode || !kIsWeb) return const SizedBox.shrink();
    
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(12),
            ),
            child: PopupMenuButton<DevicePreset>(
              icon: const Icon(Icons.phone_android, color: Colors.white),
              tooltip: 'Change Device',
              onSelected: (preset) async {
                final controller = DevicePreview.maybeController;
                if (controller != null) {
                  await controller.applyPreset(preset);
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: DevicePresets.iPhone16,
                  child: Text('iPhone 16'),
                ),
                const PopupMenuItem(
                  value: DevicePresets.iPhone16Pro,
                  child: Text('iPhone 16 Pro'),
                ),
                const PopupMenuItem(
                  value: DevicePresets.iPhone16ProMax,
                  child: Text('iPhone 16 Pro Max'),
                ),
                const PopupMenuItem(
                  value: DevicePresets.iPhoneSe3,
                  child: Text('iPhone SE (3rd gen)'),
                ),
                const PopupMenuDivider(),
                const PopupMenuItem(
                  value: DevicePresets.galaxyS24,
                  child: Text('Galaxy S24'),
                ),
                const PopupMenuItem(
                  value: DevicePresets.pixel9,
                  child: Text('Google Pixel 9'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


