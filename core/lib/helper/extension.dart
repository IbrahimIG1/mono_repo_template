import 'package:flutter/material.dart';

extension Navigation on BuildContext {
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.of(this).pushNamed(routeName, arguments: arguments);
  }

  //* this navigate when dialog open because dialog context is Different from screen context
  Future<dynamic> pushReplacementNamedFromDialog(
      {required BuildContext dialogContext,
      required String routeName,
      Object? arguments}) {
    return Navigator.of(dialogContext, rootNavigator: true)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<void> openFullScreenBottomSheet({
    required BuildContext context,
    required Widget Function(BuildContext, ScrollController) builder,
  }) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return DraggableScrollableSheet(
          expand: true,
          initialChildSize: 1, // full screen
          minChildSize: 0.6,
          maxChildSize: 1,
          builder: (context, scrollController) {
            return Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: builder(context, scrollController),
            );
          },
        );
      },
    );
  }

  //* this navigate when dialog open because dialog context is Different from screen context
  Future<dynamic> pushNamedAndRemoveUntilFromDialog(
      {required BuildContext dialogContext,
      required String routeName,
      required RoutePredicate predicate,
      Object? arguments}) {
    return Navigator.of(dialogContext, rootNavigator: true)
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  Future<dynamic> pushReplacementNamed(String routeName,
      {Object? arguments, Widget? screen}) {
    return Navigator.of(this)
        .pushReplacementNamed(routeName, arguments: arguments);
  }

  Future<dynamic> pushNamedAndRemoveUntil(String routeName,
      {Object? arguments, required RoutePredicate predicate}) {
    return Navigator.of(this)
        .pushNamedAndRemoveUntil(routeName, predicate, arguments: arguments);
  }

  void pop() => Navigator.of(this).pop();
}

extension StringExtension on String? {
  bool isNullOrEmpty() => this == null || this == "";
}

extension ListExtension<T> on List<T>? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}

extension MapExtension<T> on Map? {
  bool isNullOrEmpty() => this == null || this!.isEmpty;
}