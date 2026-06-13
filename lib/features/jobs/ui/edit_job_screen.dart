import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';
import 'package:latinterritory/shared/widgets/category_dropdown.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class EditJobScreen extends ConsumerStatefulWidget {
  const EditJobScreen({super.key, required this.jobId});

  final String jobId;

  @override
  ConsumerState<EditJobScreen> createState() => _EditJobScreenState();
}

class _EditJobScreenState extends ConsumerState<EditJobScreen> {
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

  bool _isLoadingInitial = true;
  bool _isLoading = false;
  String? _loadError;

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
  void initState() {
    super.initState();
    _loadJob();
  }

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

  Future<void> _loadJob() async {
    try {
      final repo = ref.read(jobRepositoryProvider);
      final detail = await repo.getJobDetail(widget.jobId);
      if (!mounted) return;
      setState(() {
        _titleController.text = detail.title;
        _category = detail.category;
        _descriptionController.text = detail.description;
        _location = detail.location;
        _jobType = detail.jobType;
        _hourlyRateController.text = detail.hourlyRate.toString();
        _emailController.text = detail.email ?? '';
        _phoneController.text = detail.phone ?? '';
        _externalLinkController.text = detail.externalLink ?? '';
        _isLoadingInitial = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loadError = resolveApiErrorMessage(e);
        _isLoadingInitial = false;
      });
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    final hasEmail = _emailController.text.trim().isNotEmpty;
    final hasPhone = _phoneController.text.trim().isNotEmpty;
    final hasLink = _externalLinkController.text.trim().isNotEmpty;
    if (!hasEmail && !hasPhone && !hasLink) {
      context.showErrorSnackBar(
        'Debes proporcionar al menos un método de contacto.',
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
      await repo.updateJob(widget.jobId, data);

      if (mounted) {
        context.showSnackBar('¡Oferta de empleo actualizada exitosamente!');
        Navigator.of(context).pop(true);
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
    if (_isLoadingInitial) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Editar Empleo',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (_loadError != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            'Editar Empleo',
            style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppDimensions.xl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline,
                    size: 48, color: AppColors.error),
                const SizedBox(height: AppDimensions.md),
                Text(_loadError!, textAlign: TextAlign.center),
                const SizedBox(height: AppDimensions.lg),
                LtButton(
                  label: 'Reintentar',
                  icon: Icons.refresh,
                  onPressed: () {
                    setState(() {
                      _loadError = null;
                      _isLoadingInitial = true;
                    });
                    _loadJob();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Empleo',
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

                CategoryDropdown(
                  vertical: CategoryVertical.job,
                  label: 'Categoría',
                  hint: 'Área de trabajo',
                  value: _category,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) =>
                      v == null ? 'Selecciona una categoría.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

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

                _EditDropdownField(
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

                _EditDropdownField(
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

                LtTextField(
                  controller: _hourlyRateController,
                  label: 'Tarifa por hora (AUD)',
                  hint: 'Ej. 25',
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
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
                const SizedBox(height: AppDimensions.xl),

                LtButton(
                  label: 'GUARDAR CAMBIOS',
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

class _EditDropdownField extends StatelessWidget {
  const _EditDropdownField({
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
          value: items.contains(value) ? value : null,
          onChanged: enabled ? onChanged : null,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: fillColor,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
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
