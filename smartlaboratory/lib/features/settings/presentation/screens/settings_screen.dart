import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/localization/app_locale.dart';
import 'package:smartlaboratory/core/theme/theme_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocaleScope.of(context);
    final theme = ThemeScope.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
      child: Column(
        children: [
          Padding(
            padding: EdgeInsets.zero,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  locale.text('more'),
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.person_outline,
                  title: locale.text('profile'),
                  subtitle: locale.text('manageProfile'),
                  onTap: () {
                    context.push('/profile');
                  },
                ),
                _buildThemeTile(context, theme),

                _buildSettingsTile(
                  context: context,
                  icon: Icons.language,
                  title: locale.text('language'),
                  subtitle: locale.text('languageSubtitle'),
                  onTap: () => _showLanguageDialog(context),
                ),
                _buildSettingsTile(
                  context: context,
                  icon: Icons.help_outline,
                  title: locale.text('help'),
                  subtitle: locale.text('helpSubtitle'),
                  onTap: () {},
                ),
                _buildSettingsTile(
                  context: context,
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

  Widget _buildThemeTile(BuildContext context, ThemeController theme) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: colors.primaryContainer,
            child: Icon(
              theme.isDark
                  ? Icons.dark_mode_outlined
                  : Icons.light_mode_outlined,
              color: colors.primary,
            ),
          ),
          title: const Text('Mode sombre'),
          subtitle: Text(theme.isDark ? 'Activé' : 'Désactivé'),
          trailing: Switch.adaptive(
            value: theme.isDark,
            onChanged: theme.setDarkMode,
          ),
        ),
        const Divider(height: 1),
      ],
    );
  }

  Widget _buildSettingsTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          title: Text(title),
          subtitle: Text(subtitle),
          trailing: Icon(
            Icons.chevron_right,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }
}
