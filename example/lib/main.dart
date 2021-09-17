import 'package:state_notifier/state_notifier.dart';
import 'package:history_state_notifier/history_state_notifier.dart';

void main() {
  final notifier = CounterNotifier();
  notifier.increment();
  print(notifier.state);
  notifier.undo();
  print(notifier.state);
  print(notifier.canRedo);
  notifier.increment();
  print(notifier.state);
  print(notifier.canRedo);
}

class CounterNotifier extends StateNotifier<int>
    with HistoryStateNotifierMixin<int> {
  CounterNotifier() : super(0) {
    // If you want the initial state to be added to the history, do it like this
    state = 0;
    // This is how you limit the size of your history.
    // Set it to null to keep all state (default)
    maxHistoryLength = 30;
  }

  void increment() => ++state;

  void decrement() => --state;

  // By using temporaryState setter, the change won't be stored in history
  void reset() => temporaryState = 0;

  // You can override this function to apply a transformation to a state
  // from the history before it gets applied.
  @override
  int transformHistoryState(int newState, int currentState) {
    return newState;
  }
}