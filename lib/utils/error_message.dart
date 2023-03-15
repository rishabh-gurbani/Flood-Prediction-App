import 'package:flutter/material.dart';

class ErrorMessage extends StatelessWidget {
  const ErrorMessage({
    Key? key,
    required this.showErrorMessage,
    required this.errorMessage,
  }) : super(key: key);

  final bool showErrorMessage;
  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        if (showErrorMessage)
          const SizedBox(
            height: 5,
          ),
        if (showErrorMessage)
          Text(
            errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
        if (showErrorMessage)
          const SizedBox(
            height: 5,
          ),
      ],
    );
  }
}
