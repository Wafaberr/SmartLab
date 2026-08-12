import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:smartlaboratory/core/utils/validators.dart';
import 'package:smartlaboratory/features/auth/presentation/cubit/auth_cubit.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/custom_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose(); // ⚠️ toujours dispose
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
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    children: [
                      const SizedBox(height: 150),

                      const Text(
                        "Welcome Back",
                        style: TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        "Sign in with your email to access your saved recipes\nmeal plans, and favorite dishes.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey),
                      ),

                      const SizedBox(height: 40),

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
                        validator: Validators.validatePassword,
                        hintText: 'Entrez votre mot de passe',
                        obscureText: true,
                        prefixIcon: const Icon(Icons.lock_outline),
                      ),

                      const SizedBox(height: 20),

                      const SizedBox(height: 10),

                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            context.push("/reset_pass");
                          },
                          child: const Text(
                            "Forgot Password",
                            style: TextStyle(color: Colors.red),
                          ),
                        ),
                      ),

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
                                    context.read<AuthCubit>().login(
                                      emailController.text.trim(),
                                      passwordController.text.trim(),
                                    );
                                  }
                                },
                          child: const Text(
                            "Log In",
                            style: TextStyle(fontSize: 18, color: Colors.black),
                          ),
                        ),
                      ),

                      const SizedBox(height: 25),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Don't have an account? "),
                          GestureDetector(
                            onTap: () {
                              context.go('/signup');
                            },
                            child: const Text(
                              "Sign Up",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
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
