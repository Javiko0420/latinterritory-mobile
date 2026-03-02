import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/constants/legal_documents.dart';
import 'package:latinterritory/features/auth/data/models/auth_models.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/legal_document_sheet.dart';
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
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _acceptedTerms = false;
  DateTime? _dateOfBirth;

  // Current legal document versions — update when docs change.
  static const _contractVersion = '1.0';
  static const _termsVersion = '1.0';
  static const _privacyVersion = '1.0';

  // Gesture recognizers for legal document links.
  final _termsRecognizer = TapGestureRecognizer();
  final _privacyRecognizer = TapGestureRecognizer();
  final _contractRecognizer = TapGestureRecognizer();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _termsRecognizer.dispose();
    _privacyRecognizer.dispose();
    _contractRecognizer.dispose();
    super.dispose();
  }

  TextSpan _buildLegalSpan({
    required String text,
    required TapGestureRecognizer recognizer,
  }) {
    return TextSpan(
      text: text,
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.w600,
        decoration: TextDecoration.underline,
        decorationColor: AppColors.primary,
      ),
      recognizer: recognizer,
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(now.year - 18, now.month, now.day),
      firstDate: DateTime(1900),
      lastDate: now,
      helpText: 'Select your date of birth',
    );
    if (picked != null) {
      setState(() => _dateOfBirth = picked);
    }
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth == null) {
      context.showErrorSnackBar('Please select your date of birth.');
      return;
    }

    // Validate age
    final dobError = Validators.dateOfBirth(_dateOfBirth!.toIso8601String());
    if (dobError != null) {
      context.showErrorSnackBar(dobError);
      return;
    }

    if (!_acceptedTerms) {
      context.showErrorSnackBar(
        'You must accept the Terms of Use, Privacy Policy, and Registration Agreement.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = ref.read(authRepositoryProvider);
      await repo.register(
        RegisterRequest(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
          dateOfBirth: _dateOfBirth!.toIso8601String(),
          contractAcceptedAt: DateTime.now().toUtc().toIso8601String(),
          contractVersion: _contractVersion,
          termsVersion: _termsVersion,
          privacyVersion: _privacyVersion,
        ),
      );

      if (mounted) {
        context.showSnackBar('Account created successfully! Please log in.');
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

                // ── Name ────────────────────────────────
                LtTextField(
                  controller: _nameController,
                  label: 'Full Name',
                  hint: 'Your full name',
                  textInputAction: TextInputAction.next,
                  validator: Validators.name,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Email ───────────────────────────────
                LtTextField(
                  controller: _emailController,
                  label: 'Email',
                  hint: 'your@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: Validators.email,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Date of Birth ───────────────────────
                Text(
                  'Date of Birth',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                ),
                const SizedBox(height: AppDimensions.xs),
                InkWell(
                  onTap: _isLoading ? null : _selectDateOfBirth,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    height: AppDimensions.inputHeight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppDimensions.md,
                    ),
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .surfaceContainerHighest,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _dateOfBirth != null
                                ? '${_dateOfBirth!.day}/${_dateOfBirth!.month}/${_dateOfBirth!.year}'
                                : 'Select your date of birth',
                            style: TextStyle(
                              color: _dateOfBirth != null
                                  ? Theme.of(context).colorScheme.onSurface
                                  : AppColors.textTertiary,
                            ),
                          ),
                        ),
                        const Icon(
                          Icons.calendar_today_outlined,
                          color: AppColors.textTertiary,
                          size: AppDimensions.iconSm,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Password ────────────────────────────
                LtTextField(
                  controller: _passwordController,
                  label: 'Password',
                  hint: 'Min 8 chars with A-z, 0-9, @\$!%*?&',
                  obscureText: _obscurePassword,
                  textInputAction: TextInputAction.next,
                  validator: Validators.password,
                  enabled: !_isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() => _obscurePassword = !_obscurePassword);
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Confirm Password ────────────────────
                LtTextField(
                  controller: _confirmPasswordController,
                  label: 'Confirm Password',
                  hint: 'Repeat your password',
                  obscureText: _obscureConfirm,
                  textInputAction: TextInputAction.done,
                  validator: (value) => Validators.confirmPassword(
                    value,
                    _passwordController.text,
                  ),
                  enabled: !_isLoading,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: AppColors.textTertiary,
                    ),
                    onPressed: () {
                      setState(() => _obscureConfirm = !_obscureConfirm);
                    },
                  ),
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Terms Acceptance ────────────────────
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _acceptedTerms,
                        onChanged: _isLoading
                            ? null
                            : (value) {
                                setState(
                                    () => _acceptedTerms = value ?? false);
                              },
                        activeColor: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppDimensions.sm),
                    Expanded(
                      child: Text.rich(
                        TextSpan(
                          text: 'By creating my account, I confirm that I am 16 years or older and accept the ',
                          style: Theme.of(context).textTheme.bodySmall,
                          children: [
                            _buildLegalSpan(
                              text: 'Terms of Use',
                              recognizer: _termsRecognizer
                                ..onTap = () => LegalDocumentSheet.show(
                                      context,
                                      title: LegalDocuments.termsTitle,
                                      content: LegalDocuments.termsContent,
                                    ),
                            ),
                            const TextSpan(text: ', the '),
                            _buildLegalSpan(
                              text: 'Privacy Policy',
                              recognizer: _privacyRecognizer
                                ..onTap = () => LegalDocumentSheet.show(
                                      context,
                                      title: LegalDocuments.privacyTitle,
                                      content: LegalDocuments.privacyContent,
                                    ),
                            ),
                            const TextSpan(text: ', and the '),
                            _buildLegalSpan(
                              text: 'Registration & Use Agreement',
                              recognizer: _contractRecognizer
                                ..onTap = () => LegalDocumentSheet.show(
                                      context,
                                      title: LegalDocuments.contractTitle,
                                      content: LegalDocuments.contractContent,
                                    ),
                            ),
                            const TextSpan(text: '.'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: AppDimensions.lg),

                // ── Register Button ─────────────────────
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
