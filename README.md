# History State Notifier

This package offers an extension on [state_notifier](https://pub.dev/packages/state_notifier) to add a full history
support with undo/redo functionality.

## Features

* ↩️ Add ``undo()`` and ``redo()`` to StateNotifier
* 🕐 Limit the size of your history
* 💕 Offers both a mixin that can be added to your existing StateNotifiers and an abstract class that you can extend
* 🪶 No dependencies on flutter or any other packages and super lightweight.
* 🔎 Choose which states get stored to the history
* 🔄 Transform states before applying them from the history

## Getting started

This package is designed to work with/like StateNotifier. If you're not using StateNotifier and don't plan to use it you
won't get much value out of this.

## Usage

### Upgrade an existing StateNotifier

```dart
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
```

### Create a HistoryStateNotifier

If you prefer to create a HistoryStateNotifier directly, you can do this instead:

```dart
class CounterNotifier extends HistoryStateNotifier<int> {
  // ... Same as above
}
```

### Use It!

You can now use the full functionality of the HistoryStateNotifier!

```dart
// Obtain a reference however you wish
final CounterNotifier notifier = watch(counterProvider.notifier);

notifier.increment(); // 1
notifier.undo(); // 0
notifier.redo(); // 1

notifier.decrement(); // 0
notifier.undo(); // 1
notifier.canRedo // true
notifier.increment // 2
notifier.canRedo // false

// ...
```