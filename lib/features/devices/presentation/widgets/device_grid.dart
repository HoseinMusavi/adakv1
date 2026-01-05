import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import 'device_card.dart';

class DeviceGrid extends StatelessWidget {
  const DeviceGrid({super.key});

  // TODO: Replace mock data with real device lists from repository
  static final _mockPcs = [
    ('PC-01', DeviceType.pc, DeviceStatus.idle),
    ('PC-02', DeviceType.pc, DeviceStatus.active),
    ('PC-03', DeviceType.pc, DeviceStatus.paused),
    ('PC-04', DeviceType.pc, DeviceStatus.idle),
    ('PC-05', DeviceType.pc, DeviceStatus.active),
  ];

  static final _mockConsoles = [
    ('PS5-01', DeviceType.console, DeviceStatus.idle),
    ('PS5-02', DeviceType.console, DeviceStatus.active),
    ('XBOX-01', DeviceType.console, DeviceStatus.paused),
    ('SWITCH-01', DeviceType.console, DeviceStatus.idle),
  ];

  List<Widget> _buildCards(List<(String, DeviceType, DeviceStatus)> devices) {
    return devices
        .map(
          (d) => Expanded(
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: DeviceCard.mock(
                name: d.$1,
                type: d.$2,
                status: d.$3,
              ),
            ),
          ),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // PCs Section
          Text(
            AppStrings.devicesPcs,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: _buildCards(_mockPcs),
            ),
          ),
          const SizedBox(height: 24),
          // Consoles Section
          Text(
            AppStrings.devicesConsoles,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 12),
          IntrinsicHeight(
            child: Row(
              children: _buildCards(_mockConsoles),
            ),
          ),
        ],
      ),
    );
  }
}
