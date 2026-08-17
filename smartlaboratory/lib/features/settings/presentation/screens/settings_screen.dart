import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Plus',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),
                _buildSettingsTile(
                  icon: Icons.person_outline,
                  title: 'Profil',
                  subtitle: 'Gérer vos informations',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.settings,
                  title: 'Paramètres',
                  subtitle: 'Préférences de l\'application',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.help_outline,
                  title: 'Aide & Support',
                  subtitle: 'Besoin d\'aide?',
                  onTap: () {},
                ),
                _buildSettingsTile(
                  icon: Icons.info_outline,
                  title: 'À propos',
                  subtitle: 'Version 1.0.0',
                  onTap: () {},
                ),
              ],
            ),
          ),
        ],
      ),
    );
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
