// Third-party
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

// Project
import '../controllers/settings_controller.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<SettingsController>(
        builder: (ctx, settings, _) {
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _SettingsSection(
                title: 'Import',
                children: [
                  SwitchListTile(
                    title: const Text('Delete book on import'),
                    value: settings.autoDelete,
                    onChanged: settings.setAutoDelete,
                    secondary: const Icon(Icons.delete),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SettingsSection(
                title: 'Reader',
                children: [
                  SwitchListTile(
                    title: const Text('Start zoomed on reader'),
                    value: settings.defaultZoom,
                    onChanged: settings.setDefaultZoom,
                    secondary: const Icon(Icons.zoom_in),
                  ),
                  ListTile(
                    leading: const Icon(Icons.grid_on),
                    title: Row(
                      children: [
                        Text(
                            'Pages per row: ${settings.pageSliderValue.round()}'),
                        Expanded(
                          child: Slider(
                            min: 5,
                            max: 10,
                            divisions: 5,
                            label: settings.pageSliderValue.round().toString(),
                            value: settings.pageSliderValue,
                            onChanged: settings.setPageCountSlider,
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SettingsSection(
                title: 'Badges',
                children: [
                  ListTile(
                    leading: const Icon(Icons.confirmation_number),
                    title: const Text('Page count badge position'),
                    trailing: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: settings.badgePosition,
                        onChanged: (v) {
                          if (v != null) settings.setBadgePosition(v);
                        },
                        items: const [
                          DropdownMenuItem(value: 'off', child: Text('Off')),
                          DropdownMenuItem(
                              value: 'topLeft', child: Text('Top Left')),
                          DropdownMenuItem(
                              value: 'topRight', child: Text('Top Right')),
                          DropdownMenuItem(
                              value: 'bottomLeft', child: Text('Bottom Left')),
                          DropdownMenuItem(
                              value: 'bottomRight',
                              child: Text('Bottom Right')),
                        ],
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Divider(height: 0),
                  ListTile(
                    leading: const Icon(Icons.text_fields),
                    title: Row(
                      children: [
                        Text(
                          'Badge font size: ${settings.badgeFontSize.toStringAsFixed(0)}',
                        ),
                        Expanded(
                          child: Slider(
                            min: 8,
                            max: 32,
                            divisions: 12,
                            label: settings.badgeFontSize.toStringAsFixed(0),
                            value: settings.badgeFontSize,
                            onChanged: settings.setBadgeFontSize,
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _SettingsSection(
                title: 'Library UI',
                children: [
                  // Author button size (1–5 → 50–250 px)
                  ListTile(
                    leading: const Icon(Icons.person),
                    title: Row(
                      children: [
                        Text(
                          'Author button size: ${((settings.authorButtonHeight - 50) / 50 + 1).round()}',
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
                            onChanged: (v) => settings
                                .setAuthorButtonHeight(50 + (v - 1) * 50),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Divider(height: 0),
                  // Tag button size (1–10 → 140–320 px, step 20)
                  ListTile(
                    leading: const Icon(Icons.label),
                    title: Row(
                      children: [
                        Text(
                          'Tag button size: ${(((settings.tagButtonHeight - 140) / 20) + 1).round()}',
                        ),
                        Expanded(
                          child: Slider(
                            min: 1,
                            max: 10,
                            divisions: 9,
                            value: (((settings.tagButtonHeight - 140) / 20) + 1)
                                .clamp(1, 10),
                            label: (((settings.tagButtonHeight - 140) / 20) + 1)
                                .round()
                                .toString(),
                            onChanged: (v) =>
                                settings.setTagButtonHeight(140 + (v - 1) * 20),
                          ),
                        ),
                      ],
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  ),
                  const Divider(height: 0),
                  // Pages per row (5–10)
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({
    required this.title,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      elevation: 0,
      // ignore: deprecated_member_use
      color: theme.colorScheme.surfaceContainerHighest.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // section title
            Padding(
              padding: const EdgeInsets.only(
                  left: 16, right: 16, top: 12, bottom: 8),
              child: Text(
                title,
                style: theme.textTheme.titleMedium,
              ),
            ),
            const Divider(height: 0),
            ...children,
          ],
        ),
      ),
    );
  }
}
