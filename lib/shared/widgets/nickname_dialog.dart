import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/shared/utils/validators.dart';
import 'package:latinterritory/shared/widgets/lt_text_field.dart';

/// Dialog to set or edit the user's forum nickname.
class NicknameDialog extends StatefulWidget {
  const NicknameDialog({super.key, this.currentNickname});

  final String? currentNickname;

  /// Shows the dialog and returns the chosen nickname, or null if cancelled.
  static Future<String?> show(
    BuildContext context, {
    String? currentNickname,
  }) {
    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (_) => NicknameDialog(currentNickname: currentNickname),
    );
  }

  @override
  State<NicknameDialog> createState() => _NicknameDialogState();
}

class _NicknameDialogState extends State<NicknameDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.currentNickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop(_controller.text.trim());
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose your nickname'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'This is how you\'ll appear in forums.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: AppDimensions.md),
            LtTextField(
              controller: _controller,
              hint: 'e.g. cool_user_123',
              validator: Validators.nickname,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleSave(),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _handleSave,
          child: const Text('Save'),
        ),
      ],
    );
  }
}
