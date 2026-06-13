import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/core/services/cloudinary_service.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/shared/widgets/category_dropdown.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class EditBusinessScreen extends ConsumerStatefulWidget {
  const EditBusinessScreen({super.key, required this.businessSlug});

  final String businessSlug;

  @override
  ConsumerState<EditBusinessScreen> createState() =>
      _EditBusinessScreenState();
}

class _EditBusinessScreenState extends ConsumerState<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _websiteController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _instagramController = TextEditingController();

  String? _category;
  String? _city;

  // ID resolved after loading via slug; required for PUT /api/businesses/:id.
  String? _businessId;

  List<String> _existingImages = [];
  final List<File> _newImages = [];
  bool _isLoadingInitial = true;
  bool _isLoading = false;
  String? _loadError;

  static const _cities = ['Brisbane', 'Sydney', 'Melbourne', 'Gold Coast'];

  @override
  void initState() {
    super.initState();
    _loadBusiness();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _websiteController.dispose();
    _whatsappController.dispose();
    _instagramController.dispose();
    super.dispose();
  }

  Future<void> _loadBusiness() async {
    try {
      final repo = ref.read(businessRepositoryProvider);
      // Load via slug — the confirmed stable endpoint on the backend.
      final detail = await repo.getBusinessBySlug(widget.businessSlug);
      if (!mounted) return;
      setState(() {
        _businessId = detail.id; // store ID for the PUT request
        _nameController.text = detail.name;
        _descriptionController.text = detail.description;
        _category = detail.category;
        _city = detail.city;
        _addressController.text = detail.address ?? '';
        _phoneController.text = detail.phone ?? '';
        _emailController.text = detail.email ?? '';
        _websiteController.text = detail.website ?? '';
        _whatsappController.text = detail.whatsapp ?? '';
        _instagramController.text = detail.instagram ?? '';
        _existingImages = List<String>.from(detail.images);
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

  Future<void> _pickImage() async {
    if (_existingImages.length + _newImages.length >= 5) return;
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _newImages.add(File(xfile.path)));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_existingImages.isEmpty && _newImages.isEmpty) {
      context.showErrorSnackBar('Debes tener al menos 1 foto del negocio.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final uploadedUrls = <String>[];
      if (_newImages.isNotEmpty) {
        final cloudinary = ref.read(cloudinaryServiceProvider);
        for (final image in _newImages) {
          final url = await cloudinary.uploadImage(image);
          uploadedUrls.add(url);
        }
      }

      final data = <String, dynamic>{
        'name': _nameController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category,
        'city': _city,
        if (_addressController.text.trim().isNotEmpty)
          'address': _addressController.text.trim(),
        'phone': _phoneController.text.trim(),
        'email': _emailController.text.trim(),
        if (_websiteController.text.trim().isNotEmpty)
          'website': Validators.normalizeUrl(_websiteController.text),
        if (_whatsappController.text.trim().isNotEmpty)
          'whatsapp': _whatsappController.text.trim(),
        if (_instagramController.text.trim().isNotEmpty)
          'instagram': _instagramController.text.trim(),
        'images': [..._existingImages, ...uploadedUrls],
      };

      final repo = ref.read(businessRepositoryProvider);
      await repo.updateBusiness(_businessId!, data);

      if (mounted) {
        context.showSnackBar('¡Negocio actualizado exitosamente!');
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
            'Editar Negocio',
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
            'Editar Negocio',
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
                    _loadBusiness();
                  },
                ),
              ],
            ),
          ),
        ),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final totalImages = _existingImages.length + _newImages.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Editar Negocio',
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
                  controller: _nameController,
                  label: 'Nombre del negocio',
                  hint: 'Ej. La Cocina de María',
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El nombre es obligatorio.';
                    }
                    if (v.trim().length < 2) {
                      return 'El nombre debe tener al menos 2 caracteres.';
                    }
                    if (v.trim().length > 100) {
                      return 'El nombre no puede superar 100 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe tu negocio...',
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La descripción es obligatoria.';
                    }
                    if (v.trim().length < 10) {
                      return 'Mínimo 10 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                CategoryDropdown(
                  vertical: CategoryVertical.business,
                  label: 'Categoría',
                  hint: 'Selecciona una categoría',
                  value: _category,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) =>
                      v == null ? 'Selecciona una categoría.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                _EditDropdownField(
                  label: 'Ciudad',
                  hint: 'Selecciona una ciudad',
                  value: _city,
                  items: _cities,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _city = v),
                  validator: (v) =>
                      v == null ? 'Selecciona una ciudad.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _addressController,
                  label: 'Dirección (opcional)',
                  hint: 'Ej. 123 Queen St',
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _phoneController,
                  label: 'Teléfono',
                  hint: '+61 4XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El teléfono es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _emailController,
                  label: 'Email de contacto',
                  hint: 'negocio@email.com',
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: Validators.email,
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _websiteController,
                  label: 'Sitio web (opcional)',
                  hint: 'https://minegocio.com.au',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: Validators.optionalWebsite,
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _whatsappController,
                  label: 'WhatsApp (opcional)',
                  hint: '+61 4XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                LtTextField(
                  controller: _instagramController,
                  label: 'Instagram (opcional)',
                  hint: '@minegocio',
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Fotos ────────────────────────────────
                Row(
                  children: [
                    Text(
                      'Fotos del negocio',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '($totalImages/5)',
                      style: GoogleFonts.dmSans(
                          fontSize: 12, color: AppColors.primary),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),

                if (_existingImages.isNotEmpty || _newImages.isNotEmpty) ...[
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: [
                      for (var i = 0; i < _existingImages.length; i++)
                        _NetworkImageTile(
                          url: _existingImages[i],
                          onRemove: _isLoading
                              ? null
                              : () => setState(
                                  () => _existingImages.removeAt(i)),
                        ),
                      for (var i = 0; i < _newImages.length; i++)
                        _LocalImageTile(
                          file: _newImages[i],
                          onRemove: _isLoading
                              ? null
                              : () =>
                                  setState(() => _newImages.removeAt(i)),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                ],

                if (totalImages < 5 && !_isLoading)
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary),
                    label: Text(
                      'Agregar foto',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side:
                          const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      minimumSize: const Size.fromHeight(
                          AppDimensions.buttonHeight),
                    ),
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

// ── Helpers de imagen ─────────────────────────────────────

class _NetworkImageTile extends StatelessWidget {
  const _NetworkImageTile({required this.url, required this.onRemove});

  final String url;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: CachedNetworkImage(
            imageUrl: url,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            placeholder: (_, _) => Container(
              width: 90,
              height: 90,
              color: AppColors.border,
            ),
            errorWidget: (_, _, _) => Container(
              width: 90,
              height: 90,
              color: AppColors.border,
              child: const Icon(Icons.broken_image_outlined),
            ),
          ),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

class _LocalImageTile extends StatelessWidget {
  const _LocalImageTile({required this.file, required this.onRemove});

  final File file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Image.file(file, width: 90, height: 90, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: onRemove,
            child: Container(
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(2),
              child:
                  const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Dropdown controlado ───────────────────────────────────

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
