import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/routing/route_names.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/features/profile/data/models/profile_models.dart';
import 'package:latinterritory/features/profile/providers/profile_providers.dart';
import 'package:latinterritory/shared/extensions/context_extensions.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(profileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_outlined),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(profileProvider),
          ),
        ],
      ),
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
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenPaddingH,
        vertical: AppDimensions.screenPaddingV,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: AppDimensions.md),

          // ── Avatar ──────────────────────────────────────
          _ProfileAvatar(profile: profile),
          const SizedBox(height: AppDimensions.md),

          // ── Name ────────────────────────────────────────
          if (profile.name != null)
            Text(
              profile.name!,
              style: context.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),

          // ── Nickname ─────────────────────────────────────
          if (profile.nickname != null) ...[
            const SizedBox(height: AppDimensions.xs),
            Text(
              '@${profile.nickname}',
              style: context.textTheme.bodyLarge?.copyWith(
                color: AppColors.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],

          // ── Email ────────────────────────────────────────
          const SizedBox(height: AppDimensions.xs),
          Text(
            profile.email,
            style: context.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondary,
            ),
          ),

          // ── Badges ───────────────────────────────────────
          const SizedBox(height: AppDimensions.md),
          Wrap(
            spacing: AppDimensions.sm,
            runSpacing: AppDimensions.xs,
            alignment: WrapAlignment.center,
            children: [
              _RoleBadge(role: profile.role),
              if (profile.isGoogleUser) const _GoogleBadge(),
            ],
          ),

          const SizedBox(height: AppDimensions.xl),

          // ── Info Cards ───────────────────────────────────
          _ProfileInfoSection(profile: profile),

          const SizedBox(height: AppDimensions.xl),

          // ── Action Buttons ───────────────────────────────
          LtButton(
            label: 'Edit Profile',
            icon: Icons.edit_outlined,
            onPressed: () => context.pushNamed(RouteNames.editProfile),
          ),
          const SizedBox(height: AppDimensions.md),

          if (profile.hasPassword) ...[
            LtButton(
              label: 'Change Password',
              icon: Icons.lock_outline,
              variant: LtButtonVariant.outlined,
              onPressed: () =>
                  context.pushNamed(RouteNames.changePassword),
            ),
            const SizedBox(height: AppDimensions.md),
          ],

          // ── Logout ───────────────────────────────────────
          LtButton(
            label: 'Log Out',
            icon: Icons.logout,
            variant: LtButtonVariant.text,
            onPressed: () => _confirmLogout(context, ref),
          ),

          const SizedBox(height: AppDimensions.xl),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log Out'),
        content: const Text('Are you sure you want to log out?'),
        actions: [
          TextButton(
            onPressed: () => ctx.pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => ctx.pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.error),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(authStateProvider.notifier).logout();
    }
  }
}

// ── Avatar ────────────────────────────────────────────────

class _ProfileAvatar extends StatelessWidget {
  const _ProfileAvatar({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    const double radius = 56;

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
            placeholder: (_, _) => const CircularProgressIndicator(
              strokeWidth: 2,
            ),
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
      backgroundColor: AppColors.primary.withValues(alpha: 0.12),
      child: Text(
        name[0].toUpperCase(),
        style: TextStyle(
          fontSize: radius * 0.65,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
    );
  }
}

// ── Badges ────────────────────────────────────────────────

class _RoleBadge extends StatelessWidget {
  const _RoleBadge({required this.role});

  final String role;

  Color get _color => switch (role.toUpperCase()) {
        'ADMIN' => AppColors.error,
        'MODERATOR' => AppColors.warning,
        _ => AppColors.secondary,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: _color.withValues(alpha: 0.3)),
      ),
      child: Text(
        role,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: _color,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _GoogleBadge extends StatelessWidget {
  const _GoogleBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.sm,
        vertical: AppDimensions.xs,
      ),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppDimensions.radiusFull),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.g_mobiledata, size: 14, color: AppColors.info),
          SizedBox(width: 3),
          Text(
            'Google Account',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.info,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Info Section ──────────────────────────────────────────

class _ProfileInfoSection extends StatelessWidget {
  const _ProfileInfoSection({required this.profile});

  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final items = <(IconData, String, String)>[
      if (profile.phoneNumber != null)
        (Icons.phone_outlined, 'Phone', profile.phoneNumber!),
      if (profile.dateOfBirth != null)
        (
          Icons.cake_outlined,
          'Date of Birth',
          _formatDate(profile.dateOfBirth!)
        ),
    ];

    if (items.isEmpty) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (int i = 0; i < items.length; i++) ...[
            _InfoTile(
              icon: items[i].$1,
              label: items[i].$2,
              value: items[i].$3,
            ),
            if (i < items.length - 1)
              const Divider(
                height: 1,
                indent: AppDimensions.md,
                endIndent: AppDimensions.md,
                color: AppColors.divider,
              ),
          ],
        ],
      ),
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      return '${dt.day.toString().padLeft(2, '0')}/'
          '${dt.month.toString().padLeft(2, '0')}/'
          '${dt.year}';
    } catch (_) {
      return isoDate;
    }
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppDimensions.md,
        vertical: AppDimensions.sm + AppDimensions.xs,
      ),
      child: Row(
        children: [
          Icon(icon, size: AppDimensions.iconMd, color: AppColors.primary),
          const SizedBox(width: AppDimensions.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
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
              'Could not load profile',
              style: context.textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: AppDimensions.sm),
            const Text(
              'Check your connection and try again.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textTertiary),
            ),
            const SizedBox(height: AppDimensions.xl),
            LtButton(
              label: 'Retry',
              icon: Icons.refresh,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}
