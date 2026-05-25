import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/profile/data/models/profile_models.dart';
import 'package:latinterritory/features/profile/providers/profile_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_andean_pattern.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: profileAsync.when(
        loading: () => const _ProfileSkeleton(),
        error: (error, _) => _ProfileError(
          onRetry: () => ref.invalidate(profileProvider),
        ),
        data: (profile) => _ProfileBody(profile: profile),
      ),
    );
  }
}

// ── Profile Body ──────────────────────────────────────────

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _HeroHeader(profile: profile),
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppDimensions.screenPaddingH,
            AppDimensions.lg,
            AppDimensions.screenPaddingH,
            AppDimensions.xl,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PublishSection(),
              const SizedBox(height: AppDimensions.xl),
              _ProfileMenu(profile: profile),
              const SizedBox(height: AppDimensions.md),
              const _LanguageTile(),
              const SizedBox(height: AppDimensions.xl),
              _LogoutButton(
                onPressed: () => _confirmLogout(context, ref),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

// ── Hero Header ───────────────────────────────────────────

class _HeroHeader extends StatelessWidget {
  const _HeroHeader({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.secondaryDark,
            AppColors.secondary,
            AppColors.primary,
          ],
        ),
      ),
      child: Stack(
        children: [
          const Positioned.fill(
            child: IgnorePointer(
              child: CustomPaint(
                painter: AndeanPatternPainter(
                  color: Colors.white,
                  opacity: 0.10,
                ),
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
              child: Column(
                children: [
                  Row(
                    children: [
                      Text(
                        'Perfil',
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(
                          Icons.settings_outlined,
                          color: Colors.white,
                        ),
                        onPressed: () =>
                            context.pushNamed(RouteNames.editProfile),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _AvatarStack(profile: profile),
                  const SizedBox(height: 14),
                  Text(
                    profile.name ?? profile.email,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (profile.nickname != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '@${profile.nickname}',
                        style: GoogleFonts.dmSans(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Expanded(
                        child: _StatTile(
                          label: 'Publicaciones',
                          value: '0',
                        ),
                      ),
                      _Divider(),
                      const Expanded(
                        child: _StatTile(
                          label: 'Seguidos',
                          value: '0',
                        ),
                      ),
                      _Divider(),
                      Expanded(
                        child: _StatTile(
                          label: 'Miembro desde',
                          value: _memberSince(),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Approximation: until backend exposes [UserProfile.createdAt],
  /// show the current month/year as a non-blocking placeholder.
  static String _memberSince() {
    return DateFormat('MMM yy', 'es').format(DateTime.now());
  }
}

class _Divider extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 1,
      height: 32,
      color: Colors.white.withValues(alpha: 0.25),
    );
  }
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: GoogleFonts.dmSans(
            fontSize: 11,
            color: Colors.white.withValues(alpha: 0.85),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

// ── Avatar ────────────────────────────────────────────────

class _AvatarStack extends StatelessWidget {
  const _AvatarStack({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const double radius = 48;
    return SizedBox(
      width: radius * 2 + 8,
      height: radius * 2 + 8,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 14,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: _AvatarImage(profile: profile, radius: radius),
            ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: const Text('🇨🇴', style: TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
    );
  }
}

class _AvatarImage extends StatelessWidget {
  const _AvatarImage({required this.profile, required this.radius});

  final UserProfile profile;
  final double radius;

  @override
  Widget build(BuildContext context) {
    if (profile.image != null) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.primary.withValues(alpha: 0.12),
        child: ClipOval(
          child: CachedNetworkImage(
            imageUrl: profile.image!,
            width: radius * 2,
            height: radius * 2,
            fit: BoxFit.cover,
            placeholder: (_, _) =>
                const CircularProgressIndicator(strokeWidth: 2),
            errorWidget: (_, _, _) => _AvatarInitial(
              name: profile.name ?? profile.email,
              radius: radius,
            ),
          ),
        ),
      );
    }
    return _AvatarInitial(
      name: profile.name ?? profile.email,
      radius: radius,
    );
  }
}

class _AvatarInitial extends StatelessWidget {
  const _AvatarInitial({required this.name, required this.radius});

  final String name;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: AppColors.primary.withValues(alpha: 0.18),
      child: Text(
        name.isEmpty ? '?' : name[0].toUpperCase(),
        style: GoogleFonts.spaceGrotesk(
          fontSize: radius * 0.7,
          fontWeight: FontWeight.w700,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Publish Section ───────────────────────────────────────

class _PublishSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Publicar en la comunidad',
          style: GoogleFonts.spaceGrotesk(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.sm),
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.border,
            ),
          ),
          child: Column(
            children: [
              _PublishTile(
                icon: Icons.store_outlined,
                title: 'Publicar Negocio',
                subtitle: 'Agrega tu negocio a la comunidad',
                onTap: () => context.pushNamed(RouteNames.createBusiness),
                isFirst: true,
              ),
              Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: isDark ? AppColors.darkBorder : AppColors.divider,
              ),
              _PublishTile(
                icon: Icons.event_outlined,
                title: 'Publicar Evento',
                subtitle: 'Comparte tus eventos con la comunidad',
                onTap: () => context.pushNamed(RouteNames.createEvent),
              ),
              Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: isDark ? AppColors.darkBorder : AppColors.divider,
              ),
              _PublishTile(
                icon: Icons.work_outline,
                title: 'Publicar Empleo',
                subtitle: 'Busca talento latino en tu ciudad',
                onTap: () => context.pushNamed(RouteNames.createJob),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PublishTile extends StatelessWidget {
  const _PublishTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isFirst = false,
    this.isLast = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isFirst;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    BorderRadius? borderRadius;
    if (isFirst) {
      borderRadius = const BorderRadius.vertical(
          top: Radius.circular(AppDimensions.radiusLg));
    } else if (isLast) {
      borderRadius = const BorderRadius.vertical(
          bottom: Radius.circular(AppDimensions.radiusLg));
    }

    return InkWell(
      onTap: onTap,
      borderRadius: borderRadius,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 18, color: AppColors.primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: isDark
                  ? AppColors.darkTextTertiary
                  : AppColors.textTertiary,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Profile Menu ──────────────────────────────────────────

class _ProfileMenu extends StatelessWidget {
  const _ProfileMenu({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final items = <_MenuEntry>[
      _MenuEntry(
        icon: Icons.edit_outlined,
        title: 'Editar perfil',
        subtitle: 'Nombre, foto y datos personales',
        onTap: () => context.pushNamed(RouteNames.editProfile),
      ),
      if (profile.hasPassword)
        _MenuEntry(
          icon: Icons.lock_outline,
          title: 'Cambiar contraseña',
          subtitle: 'Actualiza tu seguridad',
          onTap: () => context.pushNamed(RouteNames.changePassword),
        ),
      _MenuEntry(
        icon: Icons.person_outline,
        title: 'Rol',
        subtitle: profile.role,
        onTap: null,
      ),
      if (profile.email.isNotEmpty)
        _MenuEntry(
          icon: Icons.mail_outline,
          title: 'Email',
          subtitle: profile.email,
          onTap: null,
        ),
      if (profile.phoneNumber != null)
        _MenuEntry(
          icon: Icons.phone_outlined,
          title: 'Teléfono',
          subtitle: profile.phoneNumber!,
          onTap: null,
        ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            _MenuItem(entry: items[i]),
            if (i < items.length - 1)
              Divider(
                height: 1,
                indent: 60,
                endIndent: 16,
                color: isDark ? AppColors.darkBorder : AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }
}

class _MenuEntry {
  const _MenuEntry({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
}

class _MenuItem extends StatelessWidget {
  const _MenuItem({required this.entry});

  final _MenuEntry entry;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor =
        isDark ? AppColors.darkTextPrimary : AppColors.textPrimary;
    final subtitleColor =
        isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;

    return InkWell(
      onTap: entry.onTap,
      borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                entry.icon,
                size: 18,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.title,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    entry.subtitle,
                    style: GoogleFonts.dmSans(
                      fontSize: 12,
                      color: subtitleColor,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (entry.onTap != null)
              Icon(
                Icons.chevron_right,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.textTertiary,
              ),
          ],
        ),
      ),
    );
  }
}

// ── Language Tile ─────────────────────────────────────────

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final isEs = locale.languageCode == 'es';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.border,
        ),
      ),
      child: InkWell(
        onTap: () => ref.read(localeProvider.notifier).toggle(),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.language,
                  size: 18,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tr(ref, 'profile.language'),
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      isEs
                          ? tr(ref, 'profile.language_sub_es')
                          : tr(ref, 'profile.language_sub_en'),
                      style: GoogleFonts.dmSans(
                        fontSize: 12,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                isEs ? '🇪🇸' : '🇬🇧',
                style: const TextStyle(fontSize: 22),
              ),
              const SizedBox(width: 4),
              Icon(
                Icons.chevron_right,
                color:
                    isDark ? AppColors.darkTextTertiary : AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Logout Button ─────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: onPressed,
      icon: const Icon(Icons.logout, color: AppColors.latinRed),
      label: Text(
        'Cerrar sesión',
        style: GoogleFonts.spaceGrotesk(
          fontWeight: FontWeight.w700,
          color: AppColors.latinRed,
        ),
      ),
      style: TextButton.styleFrom(
        backgroundColor: AppColors.latinRed.withValues(alpha: 0.10),
        side: BorderSide(
          color: AppColors.latinRed.withValues(alpha: 0.27),
        ),
        minimumSize: const Size.fromHeight(AppDimensions.buttonHeight),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        ),
      ),
    );
  }
}

// ── Loading Skeleton ──────────────────────────────────────

class _ProfileSkeleton extends StatelessWidget {
  const _ProfileSkeleton();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

// ── Error State ───────────────────────────────────────────

class _ProfileError extends StatelessWidget {
  const _ProfileError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppDimensions.xl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.person_off_outlined,
              size: 64,
              color: AppColors.textTertiary,
            ),
            const SizedBox(height: AppDimensions.md),
            Text(
              'No se pudo cargar el perfil',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Revisa tu conexión e intenta de nuevo.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppDimensions.xl),
            LtButton(
              label: 'Reintentar',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
