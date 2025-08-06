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
              // Add dropdown for badge position
              ListTile(
                leading: const Icon(Icons.confirmation_number),
                title: const Text('Page count badge position',
                    style: TextStyle(fontSize: 16)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                trailing: DropdownButton<String>(
                  value: settings.badgePosition,
                  items: const [
                    DropdownMenuItem(value: 'off', child: Text('Off')),
                    DropdownMenuItem(value: 'topLeft', child: Text('Top Left')),
                    DropdownMenuItem(
                        value: 'topRight', child: Text('Top Right')),
                    DropdownMenuItem(
                        value: 'bottomLeft', child: Text('Bottom Left')),
                    DropdownMenuItem(
                        value: 'bottomRight', child: Text('Bottom Right')),
                  ],
                  onChanged: (v) => settings.setBadgePosition(v!),
                ),
              ),
              // Add slider for badge font size
              ListTile(
                leading: const Icon(Icons.text_fields),
                title: Row(
                  children: [
                    Text(
                      'Badge font size: ${settings.badgeFontSize.toStringAsFixed(0)}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        min: 8,
                        max: 32,
                        divisions: 12,
                        label: settings.badgeFontSize.toStringAsFixed(0),
                        value: settings.badgeFontSize,
                        onChanged: (v) => settings.setBadgeFontSize(v),
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),

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
              // Author button height slider
              ListTile(
                leading: const Icon(Icons.aspect_ratio),
                title: Row(
                  children: [
                    Text(
                      // Show 1-5 mapped to 50-250
                      'Author button size: ${((settings.authorButtonHeight - 50) / 50 + 1).round()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 5,
                        divisions: 4,
                        label: ((settings.authorButtonHeight - 50) / 50 + 1)
                            .round()
                            .toString(),
                        value: ((settings.authorButtonHeight - 50) / 50 + 1)
                            .clamp(1, 5),
                        onChanged: (v) =>
                            settings.setAuthorButtonHeight(50 + (v - 1) * 50),
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
              ),
              // Tag button height slider
              ListTile(
                leading: const Icon(Icons.label),
                title: Row(
                  children: [
                    Text(
                      // Show 1-10 mapped to 120-180 (min) to 120-210 (max bigger)
                      'Tag button size: ${((settings.tagButtonHeight - 120) / 10 + 1).round()}',
                      style: const TextStyle(fontSize: 16),
                    ),
                    Expanded(
                      child: Slider(
                        min: 1,
                        max: 10,
                        divisions: 9,
                        label: ((settings.tagButtonHeight - 120) / 10 + 1)
                            .round()
                            .toString(),
                        value: ((settings.tagButtonHeight - 120) / 10 + 1)
                            .clamp(1, 10),
                        onChanged: (v) =>
                            settings.setTagButtonHeight(120 + (v - 1) * 10),
                      ),
                    ),
                  ],
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
