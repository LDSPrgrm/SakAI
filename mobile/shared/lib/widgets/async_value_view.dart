import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'sakai_empty_state.dart';
import 'sakai_error_state.dart';
import 'sakai_loading_skeleton.dart';

/// Renders an [AsyncValue] as one of four states:
/// - loading: `loadingBuilder` (defaults to a card-skeleton list)
/// - error:   [SakaiErrorState] with retry CTA
/// - empty:   [SakaiEmptyState] when `data` is empty by [isEmpty]
/// - data:    `dataBuilder(value)`
///
/// Composes the existing shared widgets — no new design language.
class AsyncValueView<T> extends StatelessWidget {
  const AsyncValueView({
    super.key,
    required this.value,
    required this.dataBuilder,
    this.onRetry,
    this.loadingBuilder,
    this.errorBuilder,
    this.emptyBuilder,
    this.isEmpty,
    this.emptyIcon = Icons.inbox_outlined,
    this.emptyTitle = 'Nothing here yet',
    this.emptyMessage,
  });

  final AsyncValue<T> value;
  final Widget Function(T data) dataBuilder;
  final VoidCallback? onRetry;
  final WidgetBuilder? loadingBuilder;
  final Widget Function(Object error, StackTrace stack)? errorBuilder;
  final WidgetBuilder? emptyBuilder;

  /// Returns true if `data` should be rendered as the empty state.
  /// When null, only the data branch is taken on success.
  final bool Function(T data)? isEmpty;

  final IconData emptyIcon;
  final String emptyTitle;
  final String? emptyMessage;

  @override
  Widget build(BuildContext context) {
    return value.when(
      loading: () =>
          loadingBuilder?.call(context) ?? SakaiSkeleton.list(),
      error: (error, stack) =>
          errorBuilder?.call(error, stack) ??
          SakaiErrorState(
            message: error.toString(),
            onRetry: onRetry,
          ),
      data: (data) {
        if (isEmpty != null && isEmpty!(data)) {
          return emptyBuilder?.call(context) ??
              SakaiEmptyState(
                icon: emptyIcon,
                title: emptyTitle,
                message: emptyMessage,
              );
        }
        return dataBuilder(data);
      },
    );
  }
}
