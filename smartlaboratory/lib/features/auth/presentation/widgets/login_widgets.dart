import 'package:flutter/material.dart';

Widget buildTextField(
  IconData icon,
  String hint,
  TextEditingController controller, {
  String? Function(String?)? validator,
  TextInputType keyboardType = TextInputType.text,
}) {
  return TextFormField(
    controller: controller,
    keyboardType: keyboardType,
    validator: validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: Icon(icon),
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget buildPasswordField(
  TextEditingController passwordController, {
  String? Function(String?)? validator,
}) {
  return TextFormField(
    controller: passwordController,
    obscureText: true,
    validator: validator,
    decoration: InputDecoration(
      filled: true,
      fillColor: Colors.white,
      prefixIcon: const Icon(Icons.lock_outline),
      suffixIcon: const Icon(Icons.visibility_outlined),
      hintText: "Password",
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(30),
        borderSide: BorderSide.none,
      ),
    ),
  );
}

Widget socialButton(IconData icon) {
  return CircleAvatar(
    radius: 26,
    backgroundColor: Colors.white,
    child: Icon(icon, color: Colors.black),
  );
}

