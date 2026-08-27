// presentation/screens/change_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/widgets/validators.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_state.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/loading_widget.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/snackbar_widget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Changer le mot de passe'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      body: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) {
          if (state is PasswordResetSuccess) {
            SnackbarWidget.showSuccess(context, state.message);
            Future.delayed(const Duration(seconds: 2), () {
              if (!context.mounted) return;
              context.go('/home');
            });
          } else if (state is PasswordResetFailure) {
            SnackbarWidget.showError(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is PasswordResetLoading) {
            return const LoadingWidget(message: 'Changement en cours...');
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Icon
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.security,
                        size: 64,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Title
                  const Text(
                    'Changer votre mot de passe',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Assurez-vous d\'utiliser un mot de passe sécurisé',
                    style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
                  ),
                  const SizedBox(height: 32),
                  // Form
                  Column(
                    children: [
                      CustomTextField(
                        label: 'Ancien mot de passe',
                        hintText: 'Entrez votre mot de passe actuel',
                        controller: _oldPasswordController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'L\'ancien mot de passe est requis';
                          }
                          return null;
                        },
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Nouveau mot de passe',
                        hintText: 'Entrez votre nouveau mot de passe',
                        controller: _newPasswordController,
                        validator: Validators.validatePassword,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Confirmer le mot de passe',
                        hintText: 'Confirmez votre nouveau mot de passe',
                        controller: _confirmPasswordController,
                        validator: (value) =>
                            Validators.validateConfirmPassword(
                              value,
                              _newPasswordController.text,
                            ),
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      const SizedBox(height: 32),
                      // Submit Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton(
                          onPressed: state is PasswordResetLoading
                              ? null
                              : _handleSubmit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            elevation: 2,
                          ),
                          child: state is PasswordResetLoading
                              ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  'Changer le mot de passe',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<PasswordResetCubit>();
      await cubit.changePassword(
        oldPassword: _oldPasswordController.text,
        newPassword: _newPasswordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }
}
