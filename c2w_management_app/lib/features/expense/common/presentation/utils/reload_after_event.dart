import 'package:flutter/foundation.dart';

Future<void> reloadAfterEvent<S>({
  required Stream<S> states,
  required VoidCallback dispatch,
  required bool Function(S state) isComplete,
}) async {
  final completed = states.firstWhere(isComplete);
  dispatch();
  await completed;
}
