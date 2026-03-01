import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

class JobListScreen extends StatelessWidget {
  const JobListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Jobs')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.work_outline, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppDimensions.md),
            Text('Job Listings', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'API endpoint needed: GET /api/jobs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.textSecondary,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
