import 'package:flutter/material.dart';
import 'package:latinterritory/core/constants/app_dimensions.dart';
import 'package:latinterritory/core/constants/app_colors.dart';

class EventListScreen extends StatelessWidget {
  const EventListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.event_outlined, size: 64, color: AppColors.textTertiary),
            const SizedBox(height: AppDimensions.md),
            Text('Upcoming Events', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppDimensions.sm),
            Text(
              'API endpoint needed: GET /api/events',
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
