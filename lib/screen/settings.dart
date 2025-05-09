// Third-party package imports
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project-specific imports
import '../controllers/settings_controller.dart';

// replace your existing Settings widget with something like:

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Consumer<SettingsController>(
          builder: (ctx, settings, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Divider(),
              SwitchListTile(
                title: const Text(
                  'Delete book on import',
                  style: TextStyle(fontSize: 16),
                ),
                value: settings.autoDelete,
                onChanged: (v) => settings.setAutoDelete(v),
                secondary: const Icon(Icons.delete),
              ),
              SwitchListTile(
                title: const Text(
                  'Start zoomed on reader',
                  style: TextStyle(fontSize: 16),
                ),
                value: settings.defaultZoom,
                onChanged: (v) => settings.setDefaultZoom(v),
                secondary: const Icon(Icons.zoom_in),
              ),
              const Divider(),
              ListTile(
                leading: const Icon(Icons.grid_on),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                title: Row(
                  children: [
                    Text(
                      'Pages per row: ${settings.pageSliderValue.round()}',
                      style: TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        min: 5,
                        max: 10,
                        divisions: 5,
                        label: settings.pageSliderValue.round().toString(),
                        value: settings.pageSliderValue,
                        onChanged: (v) => settings.setPageCountSlider(v),
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(),
            ],
          ),
        ),
      ),
    );
  }
}
