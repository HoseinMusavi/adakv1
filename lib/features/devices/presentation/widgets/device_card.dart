import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../sessions/presentation/widgets/start_session_bottom_sheet.dart';

enum DeviceStatus { idle, active, paused }
enum DeviceType { pc, console }

class DeviceCard extends StatelessWidget {
  const DeviceCard({
    super.key,
    required this.name,
    required this.type,
    required this.status,
  });

  final String name;
  final DeviceType type;
  final DeviceStatus status;

  // TODO: Replace mock data with real device entities
  // This widget should accept domain Device entity once wired
  factory DeviceCard.mock({
    required String name,
    required DeviceType type,
    required DeviceStatus status,
  }) {
    return DeviceCard(name: name, type: type, status: status);
  }

  String _typeLabel() {
    switch (type) {
      case DeviceType.pc:
        return AppStrings.deviceTypePc;
      case DeviceType.console:
        return AppStrings.deviceTypeConsole;
    }
  }

  String _statusLabel() {
    switch (status) {
      case DeviceStatus.idle:
        return AppStrings.deviceStatusIdle;
      case DeviceStatus.active:
        return AppStrings.deviceStatusActive;
      case DeviceStatus.paused:
        return AppStrings.deviceStatusPaused;
    }
  }

  Color _statusColor() {
    switch (status) {
      case DeviceStatus.idle:
        return Colors.green;
      case DeviceStatus.active:
        return Colors.red;
      case DeviceStatus.paused:
        return Colors.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          // TODO: Only show bottom sheet for idle devices
          if (status == DeviceStatus.idle) {
            showModalBottomSheet<void>(
              context: context,
              builder: (context) => StartSessionBottomSheet(
                deviceName: name,
                deviceType: type,
              ),
            );
          }
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                _typeLabel(),
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                    ),
              ),
              const Spacer(),
              Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _statusColor(),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _statusLabel(),
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: _statusColor(),
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
