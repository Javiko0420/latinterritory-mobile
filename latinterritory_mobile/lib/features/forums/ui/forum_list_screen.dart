import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

class ForumListScreen extends StatelessWidget {
  const ForumListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Forums')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.forum_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppDimensions.md),
            Text('Community Forums', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'APIs ready: GET /api/forums',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.secondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
