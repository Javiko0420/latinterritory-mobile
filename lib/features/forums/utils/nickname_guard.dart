import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/auth/providers/auth_provider.dart';
import 'package:latinterritory/shared/widgets/nickname_dialog.dart';

/// Ensures the user has a nickname before proceeding.
///
/// Returns `true` if the user has (or just set) a nickname,
/// `false` if the user cancelled the dialog.
Future<bool> ensureNickname(BuildContext context, WidgetRef ref) async {
  final user = ref.read(authStateProvider).value?.user;
  if (user == null) return false;

  if (user.nickname != null && user.nickname!.isNotEmpty) return true;

  final nickname = await NicknameDialog.show(context);
  if (nickname == null) return false;

  await ref.read(authStateProvider.notifier).setNickname(nickname);
  return true;
}
