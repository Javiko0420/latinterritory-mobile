import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/auth/data/models/auth_models.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        RegisterRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );

      if (mounted) {
        context.showSnackBar('Account created! Please check your email.');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.md),
                LtTextField(
                  controller: _nameController,
                  label: 'Name',
                  hint: 'Your full name',
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),
                LtTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'tu@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),
                LtTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'At least 8 characters',
                  obscureText: true,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),
                LtTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  obscureText: true,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.lg),
                LtButton(
                  label: 'Create Account',
                  onPressed: _handleRegister,
                  isLoading: _isLoading,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
