import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartlaboratory/core/utils/image_picker.dart';
import 'package:smartlaboratory/features/auth/data/models/user_model.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/user_cubit.dart';

class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  @override
  void initState() {
    super.initState();
    final authState = context.read<AuthCubit>().state;
    if (authState is! Authentificated || !authState.user.isAdmin) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Accès réservé aux administrateurs.')),
        );
        Navigator.of(context).pop();
      });
      return;
    }
    context.read<UserCubit>().loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Gestion des utilisateurs')),
      body: BlocBuilder<UserCubit, UserState>(
        builder: (context, state) {
          if (state is UserLoading || state is UserInitial) {
            return const Center(child: CircularProgressIndicator());
          }
          if (state is UserError) {
            return Center(child: Text('Erreur : ${state.message}'));
          }
          final users = (state as UserLoaded).users;
          if (users.isEmpty) {
            return const Center(child: Text('Aucun utilisateur'));
          }
          return RefreshIndicator(
            onRefresh: () => context.read<UserCubit>().loadUsers(),
            child: ListView.separated(
              padding: const EdgeInsets.all(12),
              itemCount: users.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  child: ListTile(
                    leading: _UserAvatar(user: user),
                    title: Text(user.fullName),
                    subtitle: Text(
                      '${user.email}\n${user.role == 'admin' ? 'Administrateur' : 'Technicien'}',
                    ),
                    isThreeLine: true,
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') _edit(context, user);
                        if (value == 'delete') _delete(context, user);
                      },
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'edit', child: Text('Modifier')),
                        PopupMenuItem(
                          value: 'delete',
                          child: Text('Supprimer'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _edit(context, null),
        icon: const Icon(Icons.person_add_outlined),
        label: const Text('Ajouter'),
      ),
    );
  }

  Future<void> _edit(BuildContext context, User? user) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => UserFormScreen(user: user)),
    );
    if (context.mounted) context.read<UserCubit>().loadUsers();
  }

  Future<void> _delete(BuildContext context, User user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Supprimer cet utilisateur ?'),
        content: Text(user.email),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await context.read<UserCubit>().deleteUser(int.parse(user.id));
    }
  }
}

class UserFormScreen extends StatefulWidget {
  final User? user;
  const UserFormScreen({super.key, this.user});

  @override
  State<UserFormScreen> createState() => _UserFormScreenState();
}

class _UserFormScreenState extends State<UserFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _username;
  late final TextEditingController _email;
  late final TextEditingController _firstName;
  late final TextEditingController _lastName;
  late final TextEditingController _password;
  String _role = 'tech';
  File? _image;

  @override
  void initState() {
    super.initState();
    final user = widget.user;
    _username = TextEditingController(text: user?.username ?? '');
    _email = TextEditingController(text: user?.email ?? '');
    _firstName = TextEditingController(text: user?.firstName ?? '');
    _lastName = TextEditingController(text: user?.lastName ?? '');
    _password = TextEditingController();
    _role = user?.role ?? 'tech';
  }

  @override
  void dispose() {
    _username.dispose();
    _email.dispose();
    _firstName.dispose();
    _lastName.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loading = context.watch<UserCubit>().state is UserLoading;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.user == null
              ? 'Ajouter un utilisateur'
              : 'Modifier un utilisateur',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Center(
              child: GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 52,
                  backgroundImage: _image == null ? null : FileImage(_image!),
                  child: _image == null
                      ? const Icon(Icons.add_a_photo_outlined, size: 32)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 20),
            _field(_username, 'Nom d’utilisateur'),
            _field(_email, 'Email', email: true),
            _field(_firstName, 'Prénom'),
            _field(_lastName, 'Nom'),
            _field(
              _password,
              widget.user == null ? 'Mot de passe' : 'Nouveau mot de passe',
              password: true,
              required: widget.user == null,
            ),
            DropdownButtonFormField<String>(
              initialValue: _role,
              decoration: const InputDecoration(
                labelText: 'Rôle',
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(value: 'admin', child: Text('Administrateur')),
                DropdownMenuItem(value: 'tech', child: Text('Technicien')),
              ],
              onChanged: loading
                  ? null
                  : (value) => setState(() => _role = value!),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: loading ? null : _save,
              icon: loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(widget.user == null ? 'Créer' : 'Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool email = false,
    bool password = false,
    bool required = true,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        obscureText: password,
        keyboardType: email ? TextInputType.emailAddress : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: required
            ? (value) => value == null || value.trim().isEmpty
                  ? 'Champ obligatoire'
                  : null
            : null,
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await AppImagePicker.pickImage(context);
    if (image != null && mounted) setState(() => _image = image);
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    await context.read<UserCubit>().saveUser(
      id: widget.user == null ? null : int.parse(widget.user!.id),
      username: _username.text.trim(),
      email: _email.text.trim(),
      firstName: _firstName.text.trim(),
      lastName: _lastName.text.trim(),
      role: _role,
      password: _password.text.trim(),
      imageFile: _image,
    );
    if (!mounted) return;
    if (context.read<UserCubit>().state is UserError) return;
    Navigator.pop(context);
  }
}

class _UserAvatar extends StatelessWidget {
  final User user;
  const _UserAvatar({required this.user});

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      child: Text(user.username.isEmpty ? '?' : user.username[0].toUpperCase()),
    );
  }
}
