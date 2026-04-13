import 'package:flutter/widgets.dart';

import '../repositories/driver_rating_repository.dart';

/// InheritedWidget providing DriverRatingRepository to the rating screen tree.
class DriverRatingRepositoryProvider extends InheritedWidget {
  const DriverRatingRepositoryProvider({
    super.key,
    required this.repository,
    required super.child,
  });

  final DriverRatingRepository repository;

  static DriverRatingRepository of(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<DriverRatingRepositoryProvider>();
    assert(widget != null, 'No DriverRatingRepositoryProvider found in context');
    return widget!.repository;
  }

  @override
  bool updateShouldNotify(DriverRatingRepositoryProvider oldWidget) {
    return repository != oldWidget.repository;
  }
}
