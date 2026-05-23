import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/profile/data/models/profile_models.dart';
import 'package:latinterritory/features/profile/providers/profile_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

/// Pantalla de edición de perfil.
///
/// Carga el perfil desde [profileProvider] (no via route extra) para
/// evitar errores de deserialización cuando GoRouter refresca la ruta.
class EditProfileScreen extends ConsumerWidget {
  const EditProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.md),
                const Text('Could not load profile data.'),
                const SizedBox(height: AppDimensions.md),
                LtButton(
                  label: 'Retry',
                  icon: Icons.refresh,
                  onPressed: () => ref.invalidate(profileProvider),
                ),
              ],
            ),
          ),
        ),
        data: (profile) => _EditProfileForm(profile: profile),
      ),
    );
  }
}

// ── Form ──────────────────────────────────────────────────

class _EditProfileForm extends ConsumerStatefulWidget {
  const _EditProfileForm({required this.profile});

  final UserProfile profile;

  @override
  ConsumerState<_EditProfileForm> createState() => _EditProfileFormState();
}

class _EditProfileFormState extends ConsumerState<_EditProfileForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameController;
  late final TextEditingController _nicknameController;
  late final TextEditingController _phoneController;
  DateTime? _dateOfBirth;

  @override
  void initState() {
    super.initState();
    _nameController =
        TextEditingController(text: widget.profile.name ?? '');
    _nicknameController =
        TextEditingController(text: widget.profile.nickname ?? '');
    _phoneController =
        TextEditingController(text: widget.profile.phoneNumber ?? '');

    if (widget.profile.dateOfBirth != null) {
      _dateOfBirth = DateTime.tryParse(widget.profile.dateOfBirth!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nicknameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  // ── Date Picker ───────────────────────────────────────────

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final initial = _dateOfBirth ?? DateTime(now.year - 25, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime(now.year - 16, now.month, now.day),
      helpText: 'Select your date of birth',
    );
    if (picked != null) setState(() => _dateOfBirth = picked);
  }

  // ── Submit ────────────────────────────────────────────────

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    if (_dateOfBirth != null) {
      final dobError = Validators.dateOfBirth(_dateOfBirth!.toIso8601String());
      if (dobError != null) {
        context.showErrorSnackBar(dobError);
        return;
      }
    }

    final request = UpdateProfileRequest(
      name: _nameController.text.trim(),
      nickname: _nicknameController.text.trim().isEmpty
          ? null
          : _nicknameController.text.trim(),
      phoneNumber: _phoneController.text.trim().isEmpty
          ? null
          : _phoneController.text.trim(),
      dateOfBirth: _dateOfBirth?.toUtc().toIso8601String(),
    );

    final success = await ref
        .read(editProfileNotifierProvider.notifier)
        .updateProfile(request);

    if (!mounted) return;

    if (success) {
      context.showSnackBar('Profile updated successfully!');
      context.pop();
    } else {
      final error = ref.read(editProfileNotifierProvider).error;
      if (error != null) context.showErrorSnackBar(error);
    }
  }

  // ── Build ─────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final isLoading = ref.watch(
      editProfileNotifierProvider.select((s) => s.isLoading),
    );

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppDimensions.sm),

              // ── Name ─────────────────────────────────
              LtTextField(
                controller: _nameController,
                label: 'Full Name *',
                hint: 'Your full name',
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                validator: Validators.name,
              ),
              const SizedBox(height: AppDimensions.md),

              // ── Nickname ──────────────────────────────
              LtTextField(
                controller: _nicknameController,
                label: 'Nickname',
                hint: 'Letters, numbers and _ (3–20 chars)',
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return Validators.nickname(value);
                },
              ),
              const SizedBox(height: AppDimensions.md),

              // ── Phone ─────────────────────────────────
              LtTextField(
                controller: _phoneController,
                label: 'Phone Number',
                hint: '+61 4XX XXX XXX or 04XX XXX XXX',
                keyboardType: TextInputType.phone,
                textInputAction: TextInputAction.next,
                enabled: !isLoading,
                prefixIcon: const Icon(
                  Icons.phone_outlined,
                  color: AppColors.textTertiary,
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return null;
                  return _validateAustralianPhone(value.trim());
                },
              ),
              const SizedBox(height: AppDimensions.md),

              // ── Date of Birth ─────────────────────────
              Text(
                'Date of Birth',
                style: context.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppDimensions.xs),
              _DatePickerField(
                date: _dateOfBirth,
                enabled: !isLoading,
                onTap: _selectDateOfBirth,
              ),
              const SizedBox(height: AppDimensions.xs),
              const Text(
                'You must be at least 16 years old.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textTertiary,
                ),
              ),

              const SizedBox(height: AppDimensions.xl),

              // ── Save Button ───────────────────────────
              LtButton(
                label: 'Save Changes',
                onPressed: _handleSave,
                isLoading: isLoading,
              ),
              const SizedBox(height: AppDimensions.md),
            ],
          ),
        ),
      ),
    );
  }

  String? _validateAustralianPhone(String value) {
    final cleaned = value.replaceAll(RegExp(r'[\s\-()]'), '');
    final regex =
        RegExp(r'^(\+614\d{8}|04\d{8}|\+61[2-9]\d{8}|0[2-9]\d{8})$');
    if (!regex.hasMatch(cleaned)) {
      return 'Enter a valid Australian phone number (e.g. 0412 345 678).';
    }
    return null;
  }
}

// ── Date Picker Field ─────────────────────────────────────

class _DatePickerField extends StatelessWidget {
  const _DatePickerField({
    required this.date,
    required this.onTap,
    required this.enabled,
  });

  final DateTime? date;
  final VoidCallback onTap;
  final bool enabled;

  String get _label => date != null
      ? '${date!.day.toString().padLeft(2, '0')}/'
          '${date!.month.toString().padLeft(2, '0')}/'
          '${date!.year}'
      : 'Select date of birth';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
      child: Container(
        height: AppDimensions.inputHeight,
        padding: const EdgeInsets.symmetric(horizontal: AppDimensions.md),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.calendar_today_outlined,
              size: AppDimensions.iconSm,
              color: AppColors.textTertiary,
            ),
            const SizedBox(width: AppDimensions.sm),
            Expanded(
              child: Text(
                _label,
                style: TextStyle(
                  color: date != null
                      ? Theme.of(context).colorScheme.onSurface
                      : AppColors.textTertiary,
                ),
              ),
            ),
            if (date != null)
              const Icon(
                Icons.check_circle_outline,
                size: AppDimensions.iconSm,
                color: AppColors.success,
              ),
          ],
        ),
      ),
    );
  }
}
