import 'package:flutter/material.dart';

class LastUpdatedWidget extends StatelessWidget {
  const LastUpdatedWidget({Key? key, required this.lastUpdatedOn})
      : super(key: key);

  final TimeOfDay lastUpdatedOn;

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.only(top: 20.0, left: 00),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(
            Icons.access_time,
            color: Colors.black45,
            size: 15,
          ),
          const SizedBox(width: 10),
          Text('Last updated on ${lastUpdatedOn.format(context)}',
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black45,
              ))
        ]));
  }
}