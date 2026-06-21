import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/i18n/locale_provider.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/core/theme/lt_colors.dart';
import 'package:latinterritory/core/theme/lt_tokens.dart';
import 'package:latinterritory/core/theme/lt_typography.dart';
import 'package:latinterritory/core/theme/theme_mode_provider.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/profile/data/models/profile_models.dart';
import 'package:latinterritory/features/profile/providers/profile_providers.dart';
import 'package:latinterritory/shared/widgets/lt_avatar.dart';
import 'package:latinterritory/shared/widgets/lt_pressable.dart';
import 'package:latinterritory/shared/widgets/lt_screen_in.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final async = ref.watch(profileProvider);

    return Scaffold(
      backgroundColor: c.bg,
      body: async.when(
        loading: () => Center(child: CircularProgressIndicator(strokeWidth: 2, color: c.gold)),
        error: (_, __) => _ErrorState(onRetry: () => ref.invalidate(profileProvider)),
        data: (profile) => _Body(profile: profile),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return LtScreenIn(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          _Header(profile: profile),
          Padding(
            padding: const EdgeInsets.fromLTRB(LTSpace.screenH, LTSpace.x5, LTSpace.screenH, 36),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Publicar ──────────────────────────────
                _SectionTitle(tr(ref, 'profile.publish_section')),
                const SizedBox(height: 10),
                _GroupCard(children: [
                  _Tile(icon: Icons.storefront_outlined, accent: c.gold, soft: c.goldBg, title: tr(ref, 'profile.publish_business'), subtitle: tr(ref, 'profile.publish_business_sub'), onTap: () => context.pushNamed(RouteNames.createBusiness)),
                  _Tile(icon: Icons.event_outlined, accent: c.coral, soft: c.coralSoft, title: tr(ref, 'profile.publish_event'), subtitle: tr(ref, 'profile.publish_event_sub'), onTap: () => context.pushNamed(RouteNames.createEvent)),
                  _Tile(icon: Icons.work_outline, accent: c.blue, soft: c.blueSoft, title: tr(ref, 'profile.publish_job'), subtitle: tr(ref, 'profile.publish_job_sub'), onTap: () => context.pushNamed(RouteNames.createJob)),
                  _Tile(icon: Icons.inventory_2_outlined, accent: c.green, soft: c.greenSoft, title: 'Mis Publicaciones', subtitle: 'Edita o elimina tus negocios, eventos y empleos', onTap: () => context.pushNamed(RouteNames.myPublications)),
                ]),
                const SizedBox(height: 22),

                // ── Cuenta ────────────────────────────────
                _SectionTitle('Cuenta'),
                const SizedBox(height: 10),
                _GroupCard(children: [
                  _Tile(icon: Icons.edit_outlined, accent: c.gold, soft: c.goldBg, title: tr(ref, 'profile.edit'), subtitle: tr(ref, 'profile.edit_sub'), onTap: () => context.pushNamed(RouteNames.editProfile)),
                  if (profile.hasPassword)
                    _Tile(icon: Icons.lock_outline, accent: c.gold, soft: c.goldBg, title: tr(ref, 'profile.change_password'), subtitle: tr(ref, 'profile.change_password_sub'), onTap: () => context.pushNamed(RouteNames.changePassword)),
                  if (profile.email.isNotEmpty)
                    _Tile(icon: Icons.mail_outline, accent: c.blue, soft: c.blueSoft, title: tr(ref, 'profile.email'), subtitle: profile.email),
                  if (profile.phoneNumber != null)
                    _Tile(icon: Icons.phone_outlined, accent: c.blue, soft: c.blueSoft, title: tr(ref, 'profile.phone'), subtitle: profile.phoneNumber!),
                ]),
                const SizedBox(height: 22),

                // ── Preferencias ──────────────────────────
                _SectionTitle(tr(ref, 'profile.preferences')),
                const SizedBox(height: 10),
                _GroupCard(children: [
                  const _LanguageTile(),
                  const _ThemeTile(),
                ]),
                const SizedBox(height: 24),

                // ── Logout ────────────────────────────────
                _LogoutButton(onTap: () => _confirmLogout(context, ref)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(trRead(ref, 'profile.logout_title')),
        content: Text(trRead(ref, 'profile.logout_confirm')),
        actions: [
          TextButton(onPressed: () => ctx.pop(false), child: Text(trRead(ref, 'profile.cancel'))),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: ctx.lt.coral),
            child: Text(trRead(ref, 'profile.logout')),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

// ── Header ────────────────────────────────────────────────

class _Header extends ConsumerWidget {
  const _Header({required this.profile});

  final UserProfile profile;

  static const _ink = Color(0xFFF1EDE3);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = profile.name ?? profile.email;
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [LTBrand.night, Color(0xFF16273F)],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
          child: Column(
            children: [
              Row(
                children: [
                  Text(tr(ref, 'profile.title'), style: GoogleFonts.hankenGrotesk(fontSize: 18, fontWeight: FontWeight.w800, color: _ink)),
                  const Spacer(),
                  LtPressable(
                    onTap: () => context.pushNamed(RouteNames.editProfile),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(LTRadius.md)),
                      child: const Icon(Icons.settings_outlined, color: _ink, size: 20),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _Avatar(profile: profile),
              const SizedBox(height: 14),
              Text(name, textAlign: TextAlign.center, style: GoogleFonts.hankenGrotesk(fontSize: 22, fontWeight: FontWeight.w800, letterSpacing: -0.4, color: _ink)),
              if (profile.nickname != null) ...[
                const SizedBox(height: 2),
                Text('@${profile.nickname}', style: GoogleFonts.hankenGrotesk(fontSize: 13, fontWeight: FontWeight.w500, color: _ink.withValues(alpha: 0.8))),
              ],
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(LTRadius.pill)),
                child: Text(profile.role, style: GoogleFonts.hankenGrotesk(fontSize: 11.5, fontWeight: FontWeight.w700, letterSpacing: 0.3, color: _ink)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const double size = 84;
    final ring = Container(
      padding: const EdgeInsets.all(3),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: profile.image != null
          ? ClipOval(
              child: CachedNetworkImage(
                imageUrl: profile.image!,
                width: size,
                height: size,
                fit: BoxFit.cover,
                placeholder: (_, __) => LtAvatar(name: profile.name ?? profile.email, size: size),
                errorWidget: (_, __, ___) => LtAvatar(name: profile.name ?? profile.email, size: size),
              ),
            )
          : LtAvatar(name: profile.name ?? profile.email, size: size),
    );
    return ring;
  }
}

// ── Tiles ─────────────────────────────────────────────────

class _GroupCard extends StatelessWidget {
  const _GroupCard({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Container(
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(LTRadius.lg),
        border: Border.all(color: c.line),
        boxShadow: c.softShadow,
      ),
      child: Column(
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: c.line, indent: 60, endIndent: 14),
            children[i],
          ],
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({
    required this.icon,
    required this.accent,
    required this.soft,
    required this.title,
    required this.subtitle,
    this.onTap,
    this.trailing,
  });

  final IconData icon;
  final Color accent;
  final Color soft;
  final String title;
  final String subtitle;
  final VoidCallback? onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(color: soft, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon, size: 19, color: accent),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: LTType.body(c.ink, size: 14, weight: FontWeight.w700)),
                const SizedBox(height: 2),
                Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis, style: LTType.caption(c.ink2, size: 12.5)),
              ],
            ),
          ),
          if (trailing != null) trailing!
          else if (onTap != null) Icon(Icons.chevron_right, color: c.ink3, size: 20),
        ],
      ),
    );
    return onTap != null ? LtPressable(onTap: onTap, child: row) : row;
  }
}

// ── Language tile ─────────────────────────────────────────

class _LanguageTile extends ConsumerWidget {
  const _LanguageTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final isEs = ref.watch(localeProvider).languageCode == 'es';
    return _Tile(
      icon: Icons.language,
      accent: c.blue,
      soft: c.blueSoft,
      title: tr(ref, 'profile.language'),
      subtitle: isEs ? tr(ref, 'profile.language_sub_es') : tr(ref, 'profile.language_sub_en'),
      onTap: () => ref.read(localeProvider.notifier).toggle(),
    );
  }
}

// ── Theme tile (switch claro/oscuro) ──────────────────────

class _ThemeTile extends ConsumerWidget {
  const _ThemeTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    final mode = ref.watch(themeModeProvider);
    final isDark = mode == ThemeMode.dark ||
        (mode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);
    return _Tile(
      icon: isDark ? Icons.dark_mode_outlined : Icons.light_mode_outlined,
      accent: c.gold,
      soft: c.goldBg,
      title: tr(ref, 'profile.theme'),
      subtitle: isDark ? tr(ref, 'profile.theme_dark') : tr(ref, 'profile.theme_light'),
      trailing: Switch.adaptive(
        value: isDark,
        activeTrackColor: c.gold,
        onChanged: (v) => ref.read(themeModeProvider.notifier).set(v ? ThemeMode.dark : ThemeMode.light),
      ),
    );
  }
}

// ── Logout ────────────────────────────────────────────────

class _LogoutButton extends ConsumerWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.lt;
    return LtPressable(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: c.coralSoft,
          borderRadius: BorderRadius.circular(LTRadius.md),
          border: Border.all(color: c.coral.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.logout, size: 18, color: c.coral),
            const SizedBox(width: 8),
            Text(tr(ref, 'profile.logout'), style: GoogleFonts.hankenGrotesk(fontSize: 15, fontWeight: FontWeight.w800, color: c.coral)),
          ],
        ),
      ),
    );
  }
}

// ── Helpers ───────────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Text(text, style: GoogleFonts.hankenGrotesk(fontSize: 16, fontWeight: FontWeight.w800, letterSpacing: -0.32, color: c.ink));
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final c = context.lt;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.person_off_outlined, size: 44, color: c.ink3),
          const SizedBox(height: 12),
          Text('No se pudo cargar el perfil.', style: LTType.body(c.ink2)),
          const SizedBox(height: 10),
          LtPressable(onTap: onRetry, child: Text('Reintentar', style: LTType.caption(c.gold, size: 14, weight: FontWeight.w700))),
        ],
      ),
    );
  }
}
