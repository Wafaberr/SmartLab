import 'package:flutter/material.dart';
import 'package:smartlaboratory/features/auth/presentation/widgets/login_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final passwordController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pop;
            },
            icon: Icon(Icons.keyboard_return_outlined),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            SizedBox(height: 70),
            Text(
              "reset password",
              style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
            ),
            buildPasswordField(passwordController),
            buildPasswordField(passwordController),
          ],
        ),
      ),
    );
  }
}
