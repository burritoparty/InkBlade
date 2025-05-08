import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
            children: [
              SwitchListTile(
                title: const Text('Delete book on import'),
                value: settings.autoDelete,
                onChanged: (v) => settings.setAutoDelete(v),
                secondary: const Icon(Icons.delete),
              ),
              SwitchListTile(
                title: const Text('Start zoomed on reader'),
                value: settings.defaultZoom,
                onChanged: (v) => settings.setDefaultZoom(v),
                secondary: const Icon(Icons.zoom_in),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
