import 'package:flutter/material.dart';

import '../../../devices/presentation/widgets/device_grid.dart';

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DeviceGrid(),
    );
  }
}
