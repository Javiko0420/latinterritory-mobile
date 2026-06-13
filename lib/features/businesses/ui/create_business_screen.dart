import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/core/services/cloudinary_service.dart';
import 'package:latinterritory/shared/utils/logger.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/shared/widgets/category_dropdown.dart';
import 'package:latinterritory/features/profile/providers/my_publications_providers.dart' show myBusinessesProvider;
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class CreateBusinessScreen extends ConsumerStatefulWidget {
  const CreateBusinessScreen({super.key});

  @override
  ConsumerState<CreateBusinessScreen> createState() =>
      _CreateBusinessScreenState();
}

class _CreateBusinessScreenState extends ConsumerState<CreateBusinessScreen> {
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

  final List<File> _selectedImages = [];
  final List<String> _uploadedUrls = [];
  bool _isUploadingImages = false;
  bool _isLoading = false;
  bool _termsAccepted = false;

  static const _cities = ['Brisbane', 'Sydney', 'Melbourne', 'Gold Coast'];

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

  Future<void> _pickImage() async {
    if (_selectedImages.length >= 5) return;
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _selectedImages.add(File(xfile.path)));
    }
  }

  void _removeImage(int index) {
    setState(() => _selectedImages.removeAt(index));
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    // Validación: al menos 1 imagen obligatoria.
    if (_selectedImages.isEmpty) {
      context.showErrorSnackBar(
        'Debes agregar al menos 1 foto del negocio.',
      );
      return;
    }

    if (!_termsAccepted) {
      context.showErrorSnackBar(
        'Debes aceptar los términos de publicación de negocios.',
      );
      return;
    }

    setState(() {
      _isUploadingImages = true;
      _isLoading = true;
    });

    try {
      // Subir imágenes a Cloudinary
      _uploadedUrls.clear();
      if (_selectedImages.isNotEmpty) {
        final cloudinary = ref.read(cloudinaryServiceProvider);
        for (final image in _selectedImages) {
          final url = await cloudinary.uploadImage(image);
          _uploadedUrls.add(url);
        }
      }

      setState(() => _isUploadingImages = false);

      // Construir payload
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
        'images': _uploadedUrls,
      };

      final repo = ref.read(businessRepositoryProvider);
      await repo.createBusiness(data);

      ref.invalidate(myBusinessesProvider);

      if (mounted) {
        context.showSnackBar('¡Negocio publicado exitosamente!');
        context.pop();
      }
    } on CloudinaryException catch (e) {
      AppLogger.error('[Business] Cloudinary upload failed', error: e);
      if (mounted) {
        context.showErrorSnackBar('Error al subir imagen: ${e.message}');
      }
    } catch (e) {
      AppLogger.error('[Business] createBusiness failed', error: e);
      if (mounted) {
        context.showErrorSnackBar(resolveApiErrorMessage(e));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isUploadingImages = false;
          _isLoading = false;
        });
      }
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
          'Publicar Negocio',
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

                // ── Nombre ───────────────────────────────
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

                // ── Descripción ──────────────────────────
                LtTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe tu negocio, servicios y propuesta de valor...',
                  maxLines: 4,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'La descripción es obligatoria.';
                    }
                    if (v.trim().length < 10) {
                      return 'La descripción debe tener al menos 10 caracteres.';
                    }
                    if (v.trim().length > 1000) {
                      return 'La descripción no puede superar 1000 caracteres.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Categoría ────────────────────────────
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

                // ── Ciudad ───────────────────────────────
                _DropdownField(
                  label: 'Ciudad',
                  hint: 'Selecciona una ciudad',
                  value: _city,
                  items: _cities,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _city = v),
                  validator: (v) => v == null ? 'Selecciona una ciudad.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Dirección (opcional) ─────────────────
                LtTextField(
                  controller: _addressController,
                  label: 'Dirección (opcional)',
                  hint: 'Ej. 123 Queen St, Brisbane QLD 4000',
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Teléfono ─────────────────────────────
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

                // ── Email ────────────────────────────────
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

                // ── Sitio web (opcional) ─────────────────
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

                // ── WhatsApp (opcional) ──────────────────
                LtTextField(
                  controller: _whatsappController,
                  label: 'WhatsApp (opcional)',
                  hint: '+61 4XX XXX XXX',
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Instagram (opcional) ─────────────────
                LtTextField(
                  controller: _instagramController,
                  label: 'Instagram (opcional)',
                  hint: '@minegocio',
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.lg),

                // ── Imágenes (obligatorio mín. 1) ─────────
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
                      '(mín. 1, máx. 5)',
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppDimensions.sm),

                if (_selectedImages.isNotEmpty) ...[
                  Wrap(
                    spacing: AppDimensions.sm,
                    runSpacing: AppDimensions.sm,
                    children: [
                      for (var i = 0; i < _selectedImages.length; i++)
                        _ImagePreviewTile(
                          file: _selectedImages[i],
                          onRemove: _isLoading ? null : () => _removeImage(i),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                ],

                if (_isUploadingImages)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppDimensions.sm),
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: AppDimensions.sm),
                        Text(
                          'Subiendo imágenes...',
                          style: GoogleFonts.dmSans(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                if (_selectedImages.length < 5 && !_isLoading)
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary),
                    label: Text(
                      _selectedImages.isEmpty
                          ? 'Agregar foto (obligatorio)'
                          : 'Agregar otra foto (${_selectedImages.length}/5)',
                      style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: _selectedImages.isEmpty
                            ? AppColors.primary.withValues(alpha: 0.7)
                            : AppColors.primary,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      minimumSize:
                          const Size.fromHeight(AppDimensions.buttonHeight),
                    ),
                  ),

                const SizedBox(height: AppDimensions.lg),

                // ── Términos ─────────────────────────────
                Container(
                  decoration: BoxDecoration(
                    color: fillColor,
                    borderRadius:
                        BorderRadius.circular(AppDimensions.radiusMd),
                    border: Border.all(color: borderColor),
                  ),
                  child: CheckboxListTile(
                    value: _termsAccepted,
                    onChanged: _isLoading
                        ? null
                        : (v) =>
                            setState(() => _termsAccepted = v ?? false),
                    activeColor: AppColors.primary,
                    title: Text(
                      'Acepto los términos de publicación de negocios',
                      style: GoogleFonts.dmSans(fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // ── Botón enviar ─────────────────────────
                LtButton(
                  label: 'PUBLICAR NEGOCIO',
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

// ── Widget auxiliares ─────────────────────────────────────

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
          initialValue: value,
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
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
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

class _ImagePreviewTile extends StatelessWidget {
  const _ImagePreviewTile({required this.file, required this.onRemove});

  final File file;
  final VoidCallback? onRemove;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          child: Image.file(
            file,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
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
              child: const Icon(Icons.close, color: Colors.white, size: 14),
            ),
          ),
        ),
      ],
    );
  }
}
