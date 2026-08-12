// presentation/screens/reset_password_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/utils/validators.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit_2/password_reset_state.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/loading_widget.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/snackbar_widget.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _validateToken();
  }

  Future<void> _validateToken() async {
    final cubit = context.read<PasswordResetCubit>();
    await cubit.validateToken(widget.token);
  }

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nouveau mot de passe'),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
        elevation: 0,
        automaticallyImplyLeading: false,
      ),
      body: BlocConsumer<PasswordResetCubit, PasswordResetState>(
        listener: (context, state) {
          if (state is TokenInvalid) {
            SnackbarWidget.showError(context, state.error);
            Future.delayed(const Duration(seconds: 2), () {
              context.go('/reset_pass');
            });
          } else if (state is PasswordResetSuccess) {
            SnackbarWidget.showSuccess(context, state.message);
            Future.delayed(const Duration(seconds: 2), () {
              context.go('/login');
            });
          } else if (state is PasswordResetFailure) {
            SnackbarWidget.showError(context, state.error);
          }
        },
        builder: (context, state) {
          if (state is PasswordResetLoading) {
            return const LoadingWidget(message: 'Validation en cours...');
          }

          if (state is TokenInvalid) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red.shade300,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Token invalide ou expiré',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      context.go('/reset_pass');
                    },
                    child: const Text('Demander un nouveau lien'),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
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
                      Icons.password,
                      size: 64,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Title
                const Text(
                  'Créer un nouveau mot de passe',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                // Form
                Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      CustomTextField(
                        label: 'Nouveau mot de passe',
                        hintText: 'Entrez votre nouveau mot de passe',
                        controller: _passwordController,
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
                              _passwordController.text,
                            ),
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      const SizedBox(height: 24),
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
                                  'Réinitialiser le mot de passe',
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
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleSubmit() async {
    if (_formKey.currentState?.validate() ?? false) {
      final cubit = context.read<PasswordResetCubit>();
      await cubit.confirmPasswordReset(
        token: widget.token,
        newPassword: _passwordController.text,
        confirmPassword: _confirmPasswordController.text,
      );
    }
  }
}
