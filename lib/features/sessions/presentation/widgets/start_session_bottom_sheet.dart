import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../devices/presentation/widgets/device_card.dart';

class StartSessionBottomSheet extends StatelessWidget {
  const StartSessionBottomSheet({
    super.key,
    required this.deviceName,
    required this.deviceType,
  });

  final String deviceName;
  final DeviceType deviceType;

  // TODO: Replace mock users with real user data from repository
  static const _mockUsers = ['کاربر ۱', 'کاربر ۲', 'کاربر ۳'];

  // TODO: Replace mock session mode with real mode selection
  static const _mockSessionMode = 'آنلاین'; // Read-only for now

  String _deviceTypeLabel() {
    switch (deviceType) {
      case DeviceType.pc:
        return AppStrings.deviceTypePc;
      case DeviceType.console:
        return AppStrings.deviceTypeConsole;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            AppStrings.startSessionTitle,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: 24),

          // Device Info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.selectedDevice,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
                      ),
                ),
                const SizedBox(height: 8),
                Text(
                  '$deviceName (${_deviceTypeLabel()})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // User Selector
          Text(
            AppStrings.selectUser,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: _mockUsers.first,
            decoration: InputDecoration(
              hintText: AppStrings.selectUserHint,
            ),
            items: _mockUsers.map((user) {
              return DropdownMenuItem<String>(
                value: user,
                child: Text(user),
              );
            }).toList(),
            onChanged: (value) {
              // TODO: Handle user selection
            },
          ),
          const SizedBox(height: 24),

          // Session Mode (Read-only)
          Text(
            AppStrings.sessionMode,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(_mockSessionMode),
          ),
          const SizedBox(height: 32),

          // Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: Text(AppStrings.cancel),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FilledButton(
                  onPressed: () {
                    // TODO: Wire real session start logic
                    Navigator.of(context).pop();
                  },
                  child: Text(AppStrings.startSession),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
