import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  bool autoDelete = false;
  bool defaultZoom = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Delete book after import',
                    style: TextStyle(fontSize: 18),
                  ),
                  Checkbox(
                    value: autoDelete,
                    onChanged: (bool? value) {
                      setState(() {
                        autoDelete = value ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Start zoomed in',
                    style: TextStyle(fontSize: 18),
                  ),
                  Checkbox(
                    value: defaultZoom,
                    onChanged: (bool? value) {
                      setState(() {
                        defaultZoom = value ?? false;
                      });
                    },
                    activeColor: Colors.blue,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
