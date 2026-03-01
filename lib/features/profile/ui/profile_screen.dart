import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/shared/widgets/lt_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final user = authState.value?.user;

    if (user == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: Text('Please log in to view your profile.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: Padding(
        padding: const EdgeInsets.all(AppDimensions.screenPaddingH),
        child: Column(
          children: [
            const SizedBox(height: AppDimensions.lg),

            // ── Avatar ──────────────────────────────────
            CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.primary.withValues(alpha: 0.12),
              backgroundImage:
                  user.image != null ? NetworkImage(user.image!) : null,
              child: user.image == null
                  ? Text(
                      (user.name ?? user.email)[0].toUpperCase(),
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    )
                  : null,
            ),
            const SizedBox(height: AppDimensions.md),

            // ── Name & Email ────────────────────────────
            if (user.name != null)
              Text(
                user.name!,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            const SizedBox(height: AppDimensions.xs),
            Text(
              user.email,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),

            const SizedBox(height: AppDimensions.xl),

            // ── Menu Items ──────────────────────────────
            _ProfileMenuItem(
              icon: Icons.edit_outlined,
              label: 'Edit Profile',
              onTap: () {
                // TODO: Navigate to edit profile.
              },
            ),
            _ProfileMenuItem(
              icon: Icons.lock_outline,
              label: 'Change Password',
              onTap: () {
                // TODO: Navigate to change password.
              },
            ),

            const Spacer(),

            // ── Logout ──────────────────────────────────
            LtButton(
              label: 'Log Out',
              variant: LtButtonVariant.outlined,
              onPressed: () {
                ref.read(authStateProvider.notifier).logout();
              },
            ),
            const SizedBox(height: AppDimensions.lg),
          ],
        ),
      ),
    );
  }
}

class _ProfileMenuItem extends StatelessWidget {
  const _ProfileMenuItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
      ),
    );
  }
}
