import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/profile/providers/profile_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState
    extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // ── Submit ────────────────────────────────────────────────

  Future<void> _handleChangePassword() async {
    if (!_formKey.currentState!.validate()) return;

    final currentPw = _currentPasswordController.text;
    final newPw = _newPasswordController.text;
    final confirmPw = _confirmPasswordController.text;

    // Extra UI-level guard: new password must differ from current.
    if (currentPw == newPw) {
      context.showErrorSnackBar(
        'New password must be different from your current password.',
      );
      return;
    }

    final success = await ref
        .read(changePasswordNotifierProvider.notifier)
        .changePassword(
          currentPassword: currentPw,
          newPassword: newPw,
          confirmPassword: confirmPw,
        );

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Password changed successfully!');
      context.pop();
    } else {
      final error = ref.read(changePasswordNotifierProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      changePasswordNotifierProvider.select((s) => s.isLoading),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: isLoading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppDimensions.sm),

                // ── Info Banner ───────────────────────────
                const _PasswordInfoBanner(),
                const SizedBox(height: AppDimensions.lg),

                // ── Current Password ──────────────────────
                LtTextField(
                  controller: _currentPasswordController,
                  label: 'Current Password',
                  hint: 'Your current password',
                  obscureText: _obscureCurrent,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) =>
                      Validators.required(value, 'Current password'),
                  suffixIcon: _VisibilityToggle(
                    obscure: _obscureCurrent,
                    onToggle: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── New Password ──────────────────────────
                LtTextField(
                  controller: _newPasswordController,
                  label: 'New Password',
                  hint: 'Min 8 chars · A-z · 0-9 · @\$!%*?&',
                  obscureText: _obscureNew,
                  textInputAction: TextInputAction.next,
                  enabled: !isLoading,
                  validator: (value) {
                    final baseError = Validators.password(value);
                    if (baseError != null) return baseError;
                    if (value == _currentPasswordController.text) {
                      return 'New password must differ from the current one.';
                    }
                    return null;
                  },
                  suffixIcon: _VisibilityToggle(
                    obscure: _obscureNew,
                    onToggle: () =>
                        setState(() => _obscureNew = !_obscureNew),
                  ),
                ),

                // ── Password Strength Hint ────────────────
                const SizedBox(height: AppDimensions.xs),
                const _PasswordRulesHint(),
                const SizedBox(height: AppDimensions.md),

                // ── Confirm New Password ──────────────────
                LtTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm New Password',
                  hint: 'Repeat your new password',
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  enabled: !isLoading,
                  onFieldSubmitted: (_) => _handleChangePassword(),
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _newPasswordController.text,
                  ),
                  suffixIcon: _VisibilityToggle(
                    obscure: _obscureConfirm,
                    onToggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),

                const SizedBox(height: AppDimensions.xl),

                // ── Submit Button ─────────────────────────
                LtButton(
                  label: 'Change Password',
                  onPressed: _handleChangePassword,
                  isLoading: isLoading,
                ),
                const SizedBox(height: AppDimensions.md),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Info Banner ───────────────────────────────────────────

class _PasswordInfoBanner extends StatelessWidget {
  const _PasswordInfoBanner();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.md),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: AppColors.info, size: 20),
          SizedBox(width: AppDimensions.sm),
          Expanded(
            child: Text(
              'Choose a strong password. You will be kept signed in after changing it.',
              style: TextStyle(
                fontSize: 13,
                color: AppColors.info,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Password Rules Hint ───────────────────────────────────

class _PasswordRulesHint extends StatelessWidget {
  const _PasswordRulesHint();

  @override
  Widget build(BuildContext context) {
    return const Wrap(
      spacing: AppDimensions.sm,
      runSpacing: AppDimensions.xs,
      children: [
        _RuleChip(label: '8+ chars'),
        _RuleChip(label: 'Uppercase'),
        _RuleChip(label: 'Lowercase'),
        _RuleChip(label: 'Number'),
        _RuleChip(label: 'Special (@\$!%*?&)'),
      ],
    );
  }
}

class _RuleChip extends StatelessWidget {
  const _RuleChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: 3,
      ),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Visibility Toggle ─────────────────────────────────────

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({
    required this.obscure,
    required this.onToggle,
  });

  final bool obscure;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: AppColors.textTertiary,
      ),
      onPressed: onToggle,
    );
  }
}
