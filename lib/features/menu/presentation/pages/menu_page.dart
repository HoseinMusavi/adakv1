import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class MenuPage extends StatelessWidget {
  const MenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppStrings.placeholderMenu),
      ),
    );
  }
}
