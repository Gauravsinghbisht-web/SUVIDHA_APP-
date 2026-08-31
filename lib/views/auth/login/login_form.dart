
import 'package:flutter/material.dart';

class LoginForm extends StatelessWidget {
  final TextEditingController emailController;
  final TextEditingController passwordController;

  final bool obscurePassword;
  final bool isLoading;

  final VoidCallback onLogin;
  final VoidCallback onForgotPassword;
  final VoidCallback onCreateAccount;
  final VoidCallback onTogglePassword;

  const LoginForm({
    super.key,
    required this.emailController,
    required this.passwordController,
    required this.obscurePassword,
    required this.isLoading,
    required this.onLogin,
    required this.onForgotPassword,
    required this.onCreateAccount,
    required this.onTogglePassword,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // =================================================
        // EMAIL
        // =================================================

        const Text(
          'Email',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: emailController,
          keyboardType: TextInputType.emailAddress,
          textInputAction: TextInputAction.next,
          enabled: !isLoading,
          decoration: InputDecoration(
            hintText: 'Enter your email',

            prefixIcon: const Icon(
              Icons.email_outlined,
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 20),

        // =================================================
        // PASSWORD
        // =================================================

        const Text(
          'Password',
          style: TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: passwordController,
          obscureText: obscurePassword,
          textInputAction: TextInputAction.done,
          enabled: !isLoading,

          onSubmitted: (_) {
            if (!isLoading) {
              onLogin();
            }
          },

          decoration: InputDecoration(
            hintText: 'Enter your password',

            prefixIcon: const Icon(
              Icons.lock_outline,
            ),

            suffixIcon: IconButton(
              onPressed: isLoading
                  ? null
                  : onTogglePassword,

              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
            ),

            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // =================================================
        // FORGOT PASSWORD
        // =================================================

        Align(
          alignment: Alignment.centerRight,

          child: TextButton(
            onPressed: isLoading
                ? null
                : onForgotPassword,
            child: const Text(
              'Forgot Password?',
            ),
          ),
        ),

        const SizedBox(height: 15),
        // =================================================
        // LOGIN BUTTON
        // =================================================
        SizedBox(
          width: double.infinity,
          height: 52,

          child: ElevatedButton(
            onPressed: isLoading
                ? null
                : onLogin,

            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,

                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                    ),
                  )
                : const Text(
                    'Login',
                    style: TextStyle(
                      fontSize: 17,
                    ),
                  ),
          ),
        ),

        const SizedBox(height: 25),
        // =================================================
        // CREATE ACCOUNT
        // =================================================
        Center(
          child: Row(
            mainAxisAlignment:
                MainAxisAlignment.center,

            children: [
              const Text(
                "Don't have an account?",
              ),

              TextButton(
                onPressed: isLoading
                    ? null
                    : onCreateAccount,

                child: const Text(
                  'Create Account',

                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

