import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class CreateJobScreen extends ConsumerStatefulWidget {
  const CreateJobScreen({super.key});

  @override
  ConsumerState<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends ConsumerState<CreateJobScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _hourlyRateController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _externalLinkController = TextEditingController();

  String? _category;
  String? _location;
  String? _jobType;

  bool _isLoading = false;
  bool _termsAccepted = false;
  bool _noPaymentConfirmed = false;
  bool _minWageConfirmed = false;

  static const _categories = [
    'Pastelería',
    'Construcción',
    'Ventas',
    'Marketing',
  ];

  static const _locations = [
    'Brisbane',
    'Sydney',
    'Melbourne',
    'Gold Coast',
    'Remoto',
  ];

  static const _jobTypes = [
    'Full-time',
    'Part-time',
    'Freelance',
    'Contract',
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _hourlyRateController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _externalLinkController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación checkboxes
    if (!_termsAccepted) {
      context.showErrorSnackBar(
        'Debes aceptar los términos de publicación de empleo.',
      );
      return;
    }
    if (!_noPaymentConfirmed) {
      context.showErrorSnackBar(
        'Debes confirmar que la oferta no solicita pagos al candidato.',
      );
      return;
    }
    if (!_minWageConfirmed) {
      context.showErrorSnackBar(
        'Debes confirmar que el salario cumple con el mínimo australiano.',
      );
      return;
    }

    // Validación: al menos un contacto
    final hasEmail = _emailController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    final hasLink = _externalLinkController.text.trim().isNotEmpty;
    if (!hasEmail && !hasPhone && !hasLink) {
      context.showErrorSnackBar(
        'Debes proporcionar al menos un método de contacto (email, teléfono o enlace).',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final hourlyRate =
          double.parse(_hourlyRateController.text.trim());

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'category': _category,
        'description': _descriptionController.text.trim(),
        'location': _location,
        'jobType': _jobType,
        'hourlyRate': hourlyRate,
        if (hasEmail) 'email': _emailController.text.trim(),
        if (hasPhone) 'phone': _phoneController.text.trim(),
        if (hasLink) 'externalLink': _externalLinkController.text.trim(),
      };

      final repo = ref.read(jobRepositoryProvider);
      await repo.createJob(data);

      if (mounted) {
        context.showSnackBar('¡Oferta de empleo publicada exitosamente!');
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        context.showErrorSnackBar(resolveApiErrorMessage(e));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final fillColor =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;
    final borderColor = isDark ? AppColors.darkBorder : AppColors.border;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Publicar Empleo',
          style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
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

                // ── Título del puesto ────────────────────
                LtTextField(
                  controller: _titleController,
                  label: 'Título del puesto',
                  hint: 'Ej. Pastelero/a Senior',
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El título es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Categoría ────────────────────────────
                _DropdownField(
                  label: 'Categoría',
                  hint: 'Área de trabajo',
                  value: _category,
                  items: _categories,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) =>
                      v == null ? 'Selecciona una categoría.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Descripción ──────────────────────────
                LtTextField(
                  controller: _descriptionController,
                  label: 'Descripción del trabajo',
                  hint: 'Describe responsabilidades, requisitos y beneficios...',
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La descripción es obligatoria.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Ubicación ────────────────────────────
                _DropdownField(
                  label: 'Ubicación',
                  hint: 'Ciudad o modalidad',
                  value: _location,
                  items: _locations,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _location = v),
                  validator: (v) =>
                      v == null ? 'Selecciona una ubicación.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Tipo de empleo ───────────────────────
                _DropdownField(
                  label: 'Tipo de empleo',
                  hint: 'Modalidad de contrato',
                  value: _jobType,
                  items: _jobTypes,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _jobType = v),
                  validator: (v) =>
                      v == null ? 'Selecciona el tipo de empleo.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Tarifa por hora ──────────────────────
                LtTextField(
                  controller: _hourlyRateController,
                  label: 'Tarifa por hora (AUD)',
                  hint: 'Ej. 25',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La tarifa por hora es obligatoria.';
                    }
                    final val = double.tryParse(v.trim());
                    if (val == null || val <= 0) {
                      return 'Ingresa una tarifa válida mayor a 0.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Contacto ─────────────────────────────
                Text(
                  'Información de contacto (al menos uno)',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),

                LtTextField(
                  controller: _emailController,
                  label: 'Email (opcional)',
                  hint: 'rrhh@empresa.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      return Validators.email(v);
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _phoneController,
                  label: 'Teléfono (opcional)',
                  hint: '+61 4XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _externalLinkController,
                  label: 'Enlace externo (opcional)',
                  hint: 'https://empresa.com/empleos',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Confirmaciones ───────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: Column(
                    children: [
                      CheckboxListTile(
                        value: _termsAccepted,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(
                                () => _termsAccepted = v ?? false),
                        activeColor: AppColors.primary,
                        title: Text(
                          'Acepto los términos de publicación de empleo',
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm),
                      ),
                      Divider(
                        height: 1,
                        color: borderColor,
                        indent: AppDimensions.md,
                        endIndent: AppDimensions.md,
                      ),
                      CheckboxListTile(
                        value: _noPaymentConfirmed,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(
                                () => _noPaymentConfirmed = v ?? false),
                        activeColor: AppColors.primary,
                        title: Text(
                          'Confirmo que esta oferta no solicita pagos al candidato',
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm),
                      ),
                      Divider(
                        height: 1,
                        color: borderColor,
                        indent: AppDimensions.md,
                        endIndent: AppDimensions.md,
                      ),
                      CheckboxListTile(
                        value: _minWageConfirmed,
                        onChanged: _isLoading
                            ? null
                            : (v) => setState(
                                () => _minWageConfirmed = v ?? false),
                        activeColor: AppColors.primary,
                        title: Text(
                          'Confirmo que el salario ofrecido cumple con el salario mínimo australiano',
                          style: GoogleFonts.dmSans(fontSize: 13),
                        ),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: AppDimensions.sm),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // ── Botón enviar ─────────────────────────
                LtButton(
                  label: 'PUBLICAR EMPLEO',
                  onPressed: _isLoading ? null : _handleSubmit,
                  isLoading: _isLoading,
                ),
                const SizedBox(height: AppDimensions.xl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Widget auxiliar ───────────────────────────────────────

class _DropdownField extends StatelessWidget {
  const _DropdownField({
    required this.label,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    required this.validator,
    this.enabled = true,
  });

  final String label;
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?) validator;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
    final fillColor =
        isDark ? AppColors.darkSurfaceVariant : AppColors.surfaceVariant;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        DropdownButtonFormField<String>(
          value: value,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fillColor,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 13,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide:
                  const BorderSide(color: AppColors.primary, width: 2),
            ),
          ),
          items: items
              .map((e) => DropdownMenuItem(value: e, child: Text(e)))
              .toList(),
        ),
      ],
    );
  }
}
