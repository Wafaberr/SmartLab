import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:smartlaboratory/core/constants/endpoints.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';
import 'package:smartlaboratory/features/auth/presentation/screens/change_password_screen.dart';
import 'package:smartlaboratory/features/settings/presentation/screens/edit_profile_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mon profil'), centerTitle: true),
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          // ==============================
          // LOADING
          // ==============================
          if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ==============================
          // USER CONNECTED
          // ==============================
          if (state is Authentificated) {
            final User user = state.user;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ==============================
                  // PROFILE IMAGE
                  // ==============================
                  _buildProfileImage(user),

                  const SizedBox(height: 16),

                  // ==============================
                  // FULL NAME
                  // ==============================
                  Text(
                    user.fullName,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 6),

                  // USERNAME
                  Text(
                    '@${user.username}',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 15),
                  ),

                  const SizedBox(height: 12),

                  // ==============================
                  // ROLE
                  // ==============================
                  _buildRoleBadge(user),

                  const SizedBox(height: 30),

                  // ==============================
                  // INFORMATIONS
                  // ==============================
                  _buildSectionTitle('Informations personnelles'),

                  const SizedBox(height: 12),

                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: 'Prénom',
                    value: user.firstName.isEmpty
                        ? 'Non renseigné'
                        : user.firstName,
                  ),

                  _buildInfoCard(
                    icon: Icons.person_outline,
                    title: 'Nom',
                    value: user.lastName.isEmpty
                        ? 'Non renseigné'
                        : user.lastName,
                  ),

                  _buildInfoCard(
                    icon: Icons.account_circle_outlined,
                    title: 'Nom d’utilisateur',
                    value: user.username,
                  ),

                  _buildInfoCard(
                    icon: Icons.email_outlined,
                    title: 'Email',
                    value: user.email,
                  ),

                  _buildInfoCard(
                    icon: Icons.badge_outlined,
                    title: 'Rôle',
                    value: user.isAdmin ? 'Administrateur' : 'Technicien',
                  ),

                  const SizedBox(height: 30),

                  // ==============================
                  // ACTIONS
                  // ==============================
                  _buildSectionTitle('Actions'),

                  const SizedBox(height: 12),

                  // MODIFIER PROFIL
                  _buildActionTile(
                    icon: Icons.edit_outlined,
                    title: 'Modifier mon profil',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => EditProfileScreen(user: user),
                        ),
                      );
                    },
                  ),

                  // CHANGER MOT DE PASSE
                  _buildActionTile(
                    icon: Icons.lock_outline,
                    title: 'Changer le mot de passe',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ChangePasswordScreen(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 10),

                  // DECONNEXION
                  _buildActionTile(
                    icon: Icons.logout,
                    title: 'Se déconnecter',
                    iconColor: Colors.red,
                    textColor: Colors.red,
                    onTap: () {
                      _showLogoutDialog(context);
                    },
                  ),

                  const SizedBox(height: 30),

                  // ==============================
                  // ACCOUNT STATUS
                  // ==============================
                  if (!user.isActive)
                    Card(
                      color: Colors.red.shade50,
                      child: const ListTile(
                        leading: Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.red,
                        ),
                        title: Text('Compte désactivé'),
                      ),
                    ),
                ],
              ),
            );
          }

          // ==============================
          // NOT AUTHENTICATED
          // ==============================
          return const Center(child: Text('Utilisateur non connecté'));
        },
      ),
    );
  }

  // ============================================================
  // PROFILE IMAGE
  // ============================================================

  Widget _buildProfileImage(User user) {
    final image = user.image;

    if (image != null && image.isNotEmpty) {
      final imageUrl = image.startsWith('http')
          ? image
          : '${Endpoints.baseUrl}${image.startsWith('/') ? image.substring(1) : image}';
      return CircleAvatar(
        radius: 55,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (_, _) {},
      );
    }

    return CircleAvatar(
      radius: 55,
      child: Text(
        _getInitials(user),
        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ============================================================
  // INITIALS
  // ============================================================

  String _getInitials(User user) {
    String first = '';
    String last = '';

    if (user.firstName.isNotEmpty) {
      first = user.firstName[0];
    }

    if (user.lastName.isNotEmpty) {
      last = user.lastName[0];
    }

    if (first.isNotEmpty || last.isNotEmpty) {
      return '$first$last'.toUpperCase();
    }

    if (user.username.isNotEmpty) {
      return user.username[0].toUpperCase();
    }

    return '?';
  }

  // ============================================================
  // ROLE BADGE
  // ============================================================

  Widget _buildRoleBadge(User user) {
    final isAdmin = user.isAdmin;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isAdmin ? Colors.deepPurple.shade50 : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isAdmin
                ? Icons.admin_panel_settings_outlined
                : Icons.science_outlined,
            size: 18,
            color: isAdmin ? Colors.deepPurple : Colors.blue,
          ),
          const SizedBox(width: 8),
          Text(
            isAdmin ? 'Administrateur' : 'Technicien',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isAdmin ? Colors.deepPurple : Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SECTION TITLE
  // ============================================================

  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
      ),
    );
  }

  // ============================================================
  // INFO CARD
  // ============================================================

  Widget _buildInfoCard({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          title,
          style: const TextStyle(fontSize: 13, color: Colors.grey),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            value,
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // ACTION TILE
  // ============================================================

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? iconColor,
    Color? textColor,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(
          title,
          style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  // ============================================================
  // LOGOUT DIALOG
  // ============================================================

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Déconnexion'),
          content: const Text('Voulez-vous vraiment vous déconnecter ?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Annuler'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);

                context.read<AuthCubit>().logout();
              },
              child: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
