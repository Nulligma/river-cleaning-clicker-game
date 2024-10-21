import 'package:flutter/material.dart';

Future<void> dialogBuilder(BuildContext context) {
  return showDialog<void>(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        contentPadding: const EdgeInsets.all(10),
        icon: const Icon(Icons.discord, color: Colors.deepPurple),
        content: const Text(
          "discord.gg/CxNTvksB",
          textAlign: TextAlign.center,
        ),
        alignment: Alignment.center,
        actionsAlignment: MainAxisAlignment.center,
        actionsPadding: const EdgeInsets.all(0),
        actions: <Widget>[
          TextButton(
            child: const Text('OK'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}
