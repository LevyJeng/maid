import 'package:flutter/material.dart';
import 'package:maid/classes/providers/app_data.dart';

class StorageOperationDialog extends StatelessWidget {
  final Future<String> future;

  const StorageOperationDialog({super.key, required this.future});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: future,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return AlertDialog(
            title: Text(
              snapshot.data!,
              textAlign: TextAlign.center
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              FilledButton(
                onPressed: () {
                  AppData.of(context).notify();
                  Navigator.of(context).pop();
                },
                child: Text(
                  "Close",
                  style: Theme.of(context).textTheme.labelLarge,
                ),
              ),
            ],
          );
        } else {
          return const AlertDialog(
            title: Text(
              "Storage Operation Pending",
              textAlign: TextAlign.center
            ),
            content: Center(
              heightFactor: 1.0,
              child: CircularProgressIndicator(),
            )
          );
        }
      },
    );
  }
}