import 'package:meta/meta.dart';
import 'package:state_notifier/state_notifier.dart';

/// Use this mixin on any [StateNotifier] to add a history functionality to it.
///
/// All states that get set using the [state] setter will automatically be
/// remembered for up to [maxHistoryLength] entries. If you want to update
/// the state without adding it to the history, use the [temporaryState] setter
/// instead.
/// > Note: The initial state will not be remembered by default since it is
/// > created using the super() constructor. If you want it to be remembered,
/// > just call the [state] setter in your constructor once.
mixin HistoryStateNotifierMixin<T> on StateNotifier<T> {
  int? _maxHistoryLength;

  /// How many states this state notifier will keep track of.
  ///
  /// If null, all states will be stored.
  int? get maxHistoryLength => _maxHistoryLength;

  /// How many states this state notifier will keep track of.
  ///
  /// If null, all states will be stored.
  set maxHistoryLength(int? value) {
    assert(
        value == null || value >= 0, "The maxHistoryLength can't be negative!");
    _maxHistoryLength = value;
    if (value == null) return;
    if (_undoHistory.length > value) {
      _undoHistory = _undoHistory.sublist(0, value);
      _undoIndex = _undoIndex >= value ? value - 1 : _undoIndex;
    }
  }

  List<T> _undoHistory = [];
  int _undoIndex = 0;

  /// The current "state" of this [HistoryStateNotifier] and adds the new state
  /// to the undo history.
  ///
  /// Updating this variable will synchronously call all the listeners.
  /// Notifying the listeners is O(N) with N the number of listeners.
  ///
  /// Updating the state will throw if at least one listener throws.
  @override
  set state(T value) {
    _internalClearRedoQueue();
    if (_undoHistory.isEmpty || value != _undoHistory[0]) {
      _undoHistory.insert(0, value);
      if (_maxHistoryLength != null &&
          _undoHistory.length > _maxHistoryLength!) {
        _undoHistory = _undoHistory.sublist(0, _maxHistoryLength!);
      }
    }

    super.state = value;
  }

  /// Sets the current "state" of this [HistoryStateNotifier] **without** adding
  /// the new state to the undo history.
  ///
  /// This is helpful for loading states or in general any other state that the
  /// user should not be able to undo to.
  ///
  /// Updating this variable will synchronously call all the listeners.
  /// Notifying the listeners is O(N) with N the number of listeners.
  ///
  /// Updating the state will throw if at least one listener throws.
  @protected
  set temporaryState(T value) {
    super.state = value;
  }

  /// Whether currently an undo operation is possible.
  bool get canUndo => (_undoIndex + 1 < _undoHistory.length);

  /// Whether a redo operation is currently possible.
  bool get canRedo => (_undoIndex > 0);

  /// You can override this to prevent undo/redo operations in certain cases
  /// (e.g. when in a loading state)
  @protected
  bool get allowOperations => true;

  /// You can override this function if you want to transform states from the
  /// history before they get applied.
  ///
  /// This can be useful if your state contains values that aren't supposed
  /// to be changed upon undoing for example.
  @protected
  T transformHistoryState(T newState, T currentState) {
    return newState;
  }

  /// Returns to the previous state in the history.
  void undo() {
    if (canUndo && allowOperations) {
      temporaryState = transformHistoryState(_undoHistory[++_undoIndex], state);
    }
  }

  /// Proceeds to the next state in the history.
  void redo() {
    if (canRedo && allowOperations) {
      temporaryState = transformHistoryState(_undoHistory[--_undoIndex], state);
    }
  }

  /// Removes all history items from the queue.
  void clearQueue() {
    _undoHistory = [];
    _undoIndex = 0;
    temporaryState = state;
  }

  /// Removes all history items that happened after the current undo position.
  ///
  /// Internally this is used whenever a change occurs, but you might want to
  /// use it for something else.
  void clearRedoQueue() {
    _internalClearRedoQueue();
    temporaryState = state;
  }

  void _internalClearRedoQueue() {
    if (canRedo) {
      _undoHistory = _undoHistory.sublist(_undoIndex, _undoHistory.length);
      _undoIndex = 0;
    }
  }
}
