import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:latinterritory/core/constants/app_colors.dart';
import 'package:latinterritory/core/i18n/tr.dart';
import 'package:latinterritory/features/profile/providers/profile_providers.dart';

class DeleteAccountDialog extends ConsumerStatefulWidget {
  const DeleteAccountDialog({super.key});

  @override
  ConsumerState<DeleteAccountDialog> createState() =>
      _DeleteAccountDialogState();
}

class _DeleteAccountDialogState extends ConsumerState<DeleteAccountDialog> {
  bool _confirmed = false;

  @override
  Widget build(BuildContext context) {
    final deleteState = ref.watch(deleteAccountNotifierProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AlertDialog(
      title: Row(
        children: [
          const Icon(Icons.warning_amber_rounded,
              color: AppColors.error, size: 22),
          const SizedBox(width: 8),
          Text(
            tr(ref, 'profile.delete_account_title'),
            style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700),
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr(ref, 'profile.delete_account_warning'),
            style: GoogleFonts.hankenGrotesk(
              fontSize: 14,
              color:
                  isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          if (deleteState.error != null) ...[
            const SizedBox(height: 12),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.10),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.error_outline,
                      color: AppColors.error, size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      deleteState.error!,
                      style: GoogleFonts.hankenGrotesk(
                          fontSize: 13, color: AppColors.error),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 12),
          CheckboxListTile(
            value: _confirmed,
            onChanged: deleteState.isLoading
                ? null
                : (v) => setState(() => _confirmed = v ?? false),
            title: Text(
              tr(ref, 'profile.delete_account_confirm_check'),
              style: GoogleFonts.hankenGrotesk(fontSize: 13),
            ),
            controlAffinity: ListTileControlAffinity.leading,
            contentPadding: EdgeInsets.zero,
            activeColor: AppColors.error,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed:
              deleteState.isLoading ? null : () => Navigator.of(context).pop(),
          child: Text(tr(ref, 'profile.cancel')),
        ),
        TextButton(
          onPressed: _confirmed && !deleteState.isLoading ? _submit : null,
          style: TextButton.styleFrom(foregroundColor: AppColors.error),
          child: deleteState.isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: AppColors.error),
                )
              : Text(
                  tr(ref, 'profile.delete_account_confirm_btn'),
                  style: GoogleFonts.hankenGrotesk(fontWeight: FontWeight.w700),
                ),
        ),
      ],
    );
  }

  Future<void> _submit() async {
    ref.read(deleteAccountNotifierProvider.notifier).clearError();
    await ref.read(deleteAccountNotifierProvider.notifier).deleteAccount();
    // GoRouter redirect handles navigation after logout — no manual pop needed.
  }
}
