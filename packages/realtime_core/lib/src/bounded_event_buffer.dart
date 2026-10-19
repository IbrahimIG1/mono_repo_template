import 'dart:collection';

import 'models.dart';

enum BufferAddResult { accepted, droppedNewest, disconnectRequired }

final class BoundedEventBuffer<T> {
  BoundedEventBuffer({required this.maximumSize, required this.overflowPolicy})
    : assert(maximumSize > 0);

  final int maximumSize;
  final RealtimeOverflowPolicy overflowPolicy;
  final Queue<T> _queue = Queue<T>();

  int get length => _queue.length;

  BufferAddResult add(T value) {
    if (_queue.length < maximumSize) {
      _queue.addLast(value);
      return BufferAddResult.accepted;
    }
    return switch (overflowPolicy) {
      RealtimeOverflowPolicy.dropOldest => _replaceOldest(value),
      RealtimeOverflowPolicy.dropNewest => BufferAddResult.droppedNewest,
      RealtimeOverflowPolicy.disconnect => BufferAddResult.disconnectRequired,
    };
  }

  BufferAddResult _replaceOldest(T value) {
    _queue
      ..removeFirst()
      ..addLast(value);
    return BufferAddResult.accepted;
  }

  T removeFirst() => _queue.removeFirst();

  List<T> snapshot() => List.unmodifiable(_queue);

  void clear() => _queue.clear();
}
