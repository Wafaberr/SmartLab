import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/localization/app_locale.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocaleScope.of(context);
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.text('more'),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: locale.text('profile'),
                  subtitle: locale.text('manageProfile'),
                  onTap: () {
                    context.push('/profile');
                  },
                ),
                _buildSettingsTile(
                  icon: Icons.settings,
                  title: locale.text('settings'),
                  subtitle: locale.text('settingsSubtitle'),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.language,
                  title: locale.text('language'),
                  subtitle: locale.text('languageSubtitle'),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: locale.text('help'),
                  subtitle: locale.text('helpSubtitle'),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: locale.text('about'),
                  subtitle: locale.text('version'),
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguageDialog(BuildContext context) async {
    final locale = AppLocaleScope.of(context);
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => SimpleDialog(
        title: Text(locale.text('language')),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'fr'),
            child: Text(locale.text('french')),
          ),
          SimpleDialogOption(
            onPressed: () => Navigator.pop(dialogContext, 'en'),
            child: Text(locale.text('english')),
          ),
        ],
      ),
    );
    if (selected == null) return;
    await locale.setLanguage(selected);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(locale.text('languageChanged'))));
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon, color: const Color.fromARGB(255, 54, 214, 126)),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: const Icon(Icons.arrow_forward_ios, size: 16),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
