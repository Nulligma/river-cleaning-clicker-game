import 'package:flutter/material.dart';
import 'package:gold_miner/widgets/dialog.dart';

class Shop extends StatelessWidget {
  final Function() onAdd;
  const Shop({super.key, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Shop",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
            const Text(
              'Under construction',
              style: TextStyle(color: Colors.white, fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const Text(
              'Check for updates',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
            TextButton.icon(
                onPressed: () {
                  dialogBuilder(context);
                },
                icon: const Icon(Icons.discord),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  iconColor: Colors.white,
                ),
                label: const Text(
                  "Discord",
                  style: TextStyle(color: Colors.white),
                ))
          ],
        ),
      ),
    );
  }
}
