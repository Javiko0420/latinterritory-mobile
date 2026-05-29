import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latinterritory/features/businesses/data/models/business_models.dart';
import 'package:latinterritory/features/businesses/providers/business_providers.dart';
import 'package:latinterritory/features/events/data/models/event_models.dart';
import 'package:latinterritory/features/events/providers/event_providers.dart';
import 'package:latinterritory/features/jobs/data/models/job_models.dart';
import 'package:latinterritory/features/jobs/providers/job_providers.dart';

final myBusinessesProvider =
    FutureProvider.autoDispose<List<Business>>((ref) async {
  final repo = ref.read(businessRepositoryProvider);
  return repo.getMyBusinesses();
});

final myEventsProvider =
    FutureProvider.autoDispose<List<Event>>((ref) async {
  final repo = ref.read(eventRepositoryProvider);
  return repo.getMyEvents();
});

final myJobsProvider =
    FutureProvider.autoDispose<List<Job>>((ref) async {
  final repo = ref.read(jobRepositoryProvider);
  return repo.getMyJobs();
});
