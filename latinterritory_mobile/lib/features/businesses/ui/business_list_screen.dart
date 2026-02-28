import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

class BusinessListScreen extends StatelessWidget {
  const BusinessListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Directory'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search.
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.store_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppDimensions.md),
            Text(
              'Business Directory',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'API endpoint needed: GET /api/businesses',
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
