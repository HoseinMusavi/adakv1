import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class SessionsPage extends StatelessWidget {
  const SessionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppStrings.placeholderSessions),
      ),
    );
  }
}
