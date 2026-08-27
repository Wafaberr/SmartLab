import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/utils/image_picker.dart';
import 'package:smartlaboratory/core/widgets/validators.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/custom_text_field.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/auth_background.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final userNameController = TextEditingController();
  File? selectedImage;
  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose(); // ⚠️ toujours dispose
    userNameController.dispose(); // ⚠️ toujours dispose
    super.dispose();
  }

  void showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 3),
      ),
    );
  }

  Future<void> _pickImage() async {
    final image = await AppImagePicker.pickImage(context);
    if (image == null || !mounted) return;

    setState(() {
      selectedImage = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showError(state.message);
            context.read<AuthCubit>().clearError();
          }
          if (state is Authentificated) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (!mounted) return;
              context.go('/home');
            });
          }
        },
        builder: (context, state) {
          return AuthBackground(
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 32),

                      Text(
                        "Ajouter un utilisateur",
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),

                      const SizedBox(height: 24),

                      GestureDetector(
                        onTap: _pickImage,
                        child: CircleAvatar(
                          radius: 46,
                          backgroundImage: selectedImage == null
                              ? null
                              : FileImage(selectedImage!),
                          child: selectedImage == null
                              ? const Icon(Icons.add_a_photo_outlined, size: 32)
                              : null,
                        ),
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'User name',
                        prefixIcon: const Icon(Icons.person),
                        hintText: 'Entrez votre nom',
                        controller: userNameController,
                      ),
                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'Email',
                        validator: Validators.validateEmail,
                        controller: emailController,
                        hintText: 'exemple@email.com',
                        keyboardType: TextInputType.emailAddress,
                        prefixIcon: const Icon(Icons.email_outlined),
                      ),

                      const SizedBox(height: 20),

                      CustomTextField(
                        label: 'password',
                        controller: passwordController,
                        hintText: 'Entrez votre mot de passe',
                        validator: Validators.validatePassword,
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),
                      const SizedBox(height: 16),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(
                              context,
                            ).colorScheme.primary,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: state is AuthLoading
                              ? null
                              : () {
                                  if (_formKey.currentState?.validate() ??
                                      false) {
                                    // print('BOUTON CLIQUÉ');
                                    context.read<AuthCubit>().signup(
                                      userNameController.text.trim(),
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                      imageFile: selectedImage,
                                    );
                                  }
                                },
                          child: const Text(
                            "Créer l'utilisateur",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Retour à la connexion : "),
                          GestureDetector(
                            onTap: () {
                              context.go('/login');
                            },
                            child: const Text(
                              "Connexion",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 40),

                      const Text(
                        "By continuing to use CookShelf, you agree to our",
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 5),

                      const Text(
                        "Terms of Service and Privacy Policy",
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
