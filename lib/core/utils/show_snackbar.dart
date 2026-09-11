import 'package:flutter/material.dart';

void showSnackbar({
  required BuildContext context,
  required String msg,
  required bool isError,
}) {
  final messager = ScaffoldMessenger.of(context);

  messager.hideCurrentSnackBar();
  messager.showSnackBar(
    SnackBar(
      content: Text(msg),
      backgroundColor: isError ? Colors.red : Colors.green,
      showCloseIcon: true,
      duration: Duration(seconds: 2),
    ),
  );
}
