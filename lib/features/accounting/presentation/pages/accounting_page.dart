import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

class AccountingPage extends StatelessWidget {
  const AccountingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Text(AppStrings.placeholderAccounting),
      ),
    );
  }
}
