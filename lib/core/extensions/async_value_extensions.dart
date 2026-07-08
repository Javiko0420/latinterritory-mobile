import 'package:flutter_riverpod/flutter_riverpod.dart';

extension AsyncValueX<T> on AsyncValue<T> {
  /// Returns the value if available, otherwise null.
  /// This handles the case where the async operation is still loading or errored.
  T? get valueOrNull {
    return when(
      data: (value) => value,
      loading: () => null,
      error: (_, __) => null,
    );
  }
}
