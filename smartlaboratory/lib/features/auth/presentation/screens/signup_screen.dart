import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/login_widgets.dart';
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
          return Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xffE8FFE5), Colors.white, Color(0xffFFF9D8)],
              ),
            ),
            child: SafeArea(
              child: Form(
                key: _formKey,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 50),

                      const Text(
                        "Welcome ",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 40),

                      buildTextField(
                        Icons.person,
                        "User name",
                        userNameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Entrez un nom d’utilisateur';
                          }
                          if (value.trim().length < 3) {
                            return 'Le nom doit contenir au moins 3 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      buildTextField(
                        Icons.email_outlined,
                        "Email Address",
                        emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Entrez votre email';
                          }
                          if (!RegExp(
                            r"^[^@\s]+@[^@\s]+\.[^@\s]+$",
                          ).hasMatch(value.trim())) {
                            return 'Email invalide';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),

                      buildPasswordField(
                        passwordController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Entrez votre mot de passe';
                          }
                          if (value.trim().length < 6) {
                            return 'Le mot de passe doit contenir au moins 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),

                      const SizedBox(height: 20),

                      SizedBox(
                        width: double.infinity,
                        height: 58,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xff43F15C),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
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
                                    );
                                  }
                                },
                          child: const Text(
                            "Sign up",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("have you already an account? "),
                          GestureDetector(
                            onTap: () {
                              context.go('/login');
                            },
                            child: const Text(
                              "Login",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Row(
                        children: [
                          const Expanded(child: Divider()),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              "or",
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                          ),
                          const Expanded(child: Divider()),
                        ],
                      ),

                      const SizedBox(height: 30),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          socialButton(Icons.facebook),
                          socialButton(Icons.g_mobiledata),
                          socialButton(Icons.apple),
                          socialButton(Icons.menu_book),
                        ],
                      ),

                      const SizedBox(height: 120),

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
