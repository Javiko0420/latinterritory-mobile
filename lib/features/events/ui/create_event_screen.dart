import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/networking/api_exceptions.dart';
import 'package:latinterritory/core/services/cloudinary_service.dart';
import 'package:latinterritory/features/categories/domain/category_option.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/shared/widgets/category_dropdown.dart';
import 'package:latinterritory/features/profile/providers/my_publications_providers.dart' show myEventsProvider;
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

class CreateEventScreen extends ConsumerStatefulWidget {
  const CreateEventScreen({super.key});

  @override
  ConsumerState<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends ConsumerState<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _ticketLinkController = TextEditingController();
  final _ticketPriceController = TextEditingController();

  String? _category;
  DateTime? _eventDate;
  File? _imageFile;
  bool _isLoading = false;
  bool _termsAccepted = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _ticketLinkController.dispose();
    _ticketPriceController.dispose();
    super.dispose();
  }

  Future<void> _selectEventDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now.add(const Duration(days: 1)),
      firstDate: now,
      lastDate: DateTime(now.year + 5),
      helpText: 'Selecciona la fecha del evento',
    );
    if (picked == null) return;

    if (!mounted) return;
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 19, minute: 0),
      helpText: 'Selecciona la hora del evento',
    );

    if (time != null) {
      setState(() {
        _eventDate = DateTime(
          picked.year,
          picked.month,
          picked.day,
          time.hour,
          time.minute,
        );
      });
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final xfile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (xfile != null) {
      setState(() => _imageFile = File(xfile.path));
    }
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_eventDate == null) {
      context.showErrorSnackBar('Selecciona la fecha y hora del evento.');
      return;
    }

    if (_eventDate!.isBefore(DateTime.now())) {
      context.showErrorSnackBar('La fecha del evento debe ser futura.');
      return;
    }

    if (!_termsAccepted) {
      context.showErrorSnackBar(
        'Debes aceptar los términos de publicación de eventos.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      String? imageUrl;
      if (_imageFile != null) {
        final cloudinary = ref.read(cloudinaryServiceProvider);
        imageUrl = await cloudinary.uploadImage(_imageFile!);
      }

      final priceText = _ticketPriceController.text.trim();
      final ticketPrice =
          priceText.isEmpty ? null : double.tryParse(priceText);

      final data = <String, dynamic>{
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'category': _category,
        'eventDate': _eventDate!.toIso8601String(),
        'location': _locationController.text.trim(),
        'imageUrl': ?imageUrl,
        if (_ticketLinkController.text.trim().isNotEmpty)
          'ticketLink': _ticketLinkController.text.trim(),
        'ticketPrice': ?ticketPrice,
      };

      final repo = ref.read(eventRepositoryProvider);
      await repo.createEvent(data);

      ref.invalidate(myEventsProvider);

      if (mounted) {
        context.showSnackBar('¡Evento publicado exitosamente!');
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
    final labelColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Publicar Evento',
          style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700),
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

                // ── Título ───────────────────────────────
                LtTextField(
                  controller: _titleController,
                  label: 'Título del evento',
                  hint: 'Ej. Noche de Salsa en Brisbane',
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

                // ── Descripción ──────────────────────────
                LtTextField(
                  controller: _descriptionController,
                  label: 'Descripción',
                  hint: 'Describe el evento, artistas, programa...',
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

                // ── Categoría ────────────────────────────
                CategoryDropdown(
                  vertical: CategoryVertical.event,
                  label: 'Categoría',
                  hint: 'Tipo de evento',
                  value: _category,
                  enabled: !_isLoading,
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) =>
                      v == null ? 'Selecciona una categoría.' : null,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Fecha y hora ─────────────────────────
                Text(
                  'Fecha y hora del evento',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),
                InkWell(
                  onTap: _isLoading ? null : _selectEventDate,
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusMd),
                  child: Container(
                    height: AppDimensions.inputHeight,
                    padding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.md),
                    decoration: BoxDecoration(
                      color: fillColor,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.radiusMd),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            _eventDate != null
                                ? DateFormat(
                                        "EEEE d 'de' MMMM yyyy, HH:mm",
                                        'es')
                                    .format(_eventDate!)
                                : 'Selecciona fecha y hora',
                            style: TextStyle(
                              color: _eventDate != null
                                  ? (isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.textPrimary)
                                  : AppColors.textTertiary,
                              fontSize: 15,
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

                // ── Lugar ────────────────────────────────
                LtTextField(
                  controller: _locationController,
                  label: 'Lugar',
                  hint: 'Ej. The Arena, Brisbane CBD',
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v == null || v.trim().isEmpty) {
                      return 'El lugar es obligatorio.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Imagen (opcional) ────────────────────
                Text(
                  'Imagen del evento (opcional)',
                  style: GoogleFonts.hankenGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: labelColor,
                  ),
                ),
                const SizedBox(height: AppDimensions.sm),

                if (_imageFile != null) ...[
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                        child: Image.file(
                          _imageFile!,
                          height: 160,
                          width: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8,
                        right: 8,
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () => setState(() => _imageFile = null),
                          child: Container(
                            decoration: const BoxDecoration(
                              color: Colors.black54,
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(4),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppDimensions.sm),
                ],

                if (_imageFile == null && !_isLoading)
                  OutlinedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.add_photo_alternate_outlined,
                        color: AppColors.primary),
                    label: Text(
                      'Agregar imagen del evento',
                      style: GoogleFonts.hankenGrotesk(
                        fontWeight: FontWeight.w600,
                        color: AppColors.primary,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppColors.primary),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppDimensions.radiusMd),
                      ),
                      minimumSize: const Size.fromHeight(
                          AppDimensions.buttonHeight),
                    ),
                  ),

                const SizedBox(height: AppDimensions.md),

                // ── Link de tickets (opcional) ───────────
                LtTextField(
                  controller: _ticketLinkController,
                  label: 'Enlace de tickets (opcional)',
                  hint: 'https://tickets.com/evento',
                  keyboardType: TextInputType.url,
                  textInputAction: TextInputAction.next,
                  enabled: !_isLoading,
                ),
                const SizedBox(height: AppDimensions.md),

                // ── Precio (opcional) ────────────────────
                LtTextField(
                  controller: _ticketPriceController,
                  label: 'Precio de entrada AUD (opcional, vacío = gratis)',
                  hint: 'Ej. 25',
                  keyboardType: const TextInputType.numberWithOptions(
                      decimal: true),
                  textInputAction: TextInputAction.done,
                  enabled: !_isLoading,
                  validator: (v) {
                    if (v != null && v.trim().isNotEmpty) {
                      final val = double.tryParse(v.trim());
                      if (val == null || val < 0) {
                        return 'Ingresa un precio válido.';
                      }
                    }
                    return null;
                  },
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
                      'Acepto los términos de publicación de eventos',
                      style: GoogleFonts.hankenGrotesk(fontSize: 13),
                    ),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppDimensions.sm),
                  ),
                ),
                const SizedBox(height: AppDimensions.xl),

                // ── Botón enviar ─────────────────────────
                LtButton(
                  label: 'PUBLICAR EVENTO',
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

