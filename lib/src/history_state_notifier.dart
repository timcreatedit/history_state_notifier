import 'package:meta/meta.dart';

import 'package:history_state_notifier/src/history_state_notifier_mixin.dart';
import 'package:state_notifier/state_notifier.dart';

/// Works like a [StateNotifier] with the added benefit of maintaining an
/// internal undo history that can be navigated through.
///
/// All states that get set using the [state] setter will automatically be
/// remembered for up to [maxHistoryLength] entries. If you want to update
/// the state without adding it to the history, use the [temporaryState] setter
/// instead.
/// > Note: The initial state will not be remembered by default since it is
/// > created using the super() constructor. If you want it to be remembered,
/// > just call the [state] setter in your constructor once.
abstract class HistoryStateNotifier<T> extends StateNotifier<T>
    with HistoryStateNotifierMixin<T> {
  @mustCallSuper
  HistoryStateNotifier(T initialState) : super(initialState);
}
