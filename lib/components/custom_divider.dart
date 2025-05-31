import 'package:flutter/material.dart';

import '../main.dart';

class CustomDivider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Divider(
        height: 50,
        thickness: appStore.isDarkMode ? 0.3 : 0.2,
        indent: 10,
        endIndent: 10,
        color: Colors.black,
      ),
    );
  }
}
