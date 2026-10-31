import 'dart:async';

import 'subscription_events.dart';

/// HTTP snapshot, then incremental events, then one refetch when [resync] fires.
///
/// Live events can be missed across a disconnect. [resync] is that signal.
/// This helper does not poll.
Stream<List<T>> apitoWatchList<T>({
  required Future<List<T>> Function() snapshot,
  required Stream<ModelChangeEvent> changes,
  required Stream<void> resync,
  required String Function(T item) idOf,
  required T? Function(ModelChangeEvent event) parse,
}) {
  final out = StreamController<List<T>>();
  final items = <T>[];
  StreamSubscription<ModelChangeEvent>? changeSub;
  StreamSubscription<void>? resyncSub;
  var epoch = 0;

  Future<void> load() async {
    final token = ++epoch;
    try {
      final next = await snapshot();
      if (token != epoch || out.isClosed) return;
      items
        ..clear()
        ..addAll(next);
      out.add(List<T>.unmodifiable(items));
    } catch (err, stack) {
      if (token == epoch && !out.isClosed) out.addError(err, stack);
    }
  }

  void apply(ModelChangeEvent event) {
    final id = event.id;
    if (event.event == ModelChangeKind.deleted || event.node == null) {
      if (id == null) return;
      items.removeWhere((item) => idOf(item) == id);
      out.add(List<T>.unmodifiable(items));
      return;
    }
    final parsed = parse(event);
    if (parsed == null) return;
    final index = items.indexWhere((item) => idOf(item) == idOf(parsed));
    if (index >= 0) {
      items[index] = parsed;
    } else {
      items.add(parsed);
    }
    out.add(List<T>.unmodifiable(items));
  }

  out.onListen = () {
    load();
    changeSub = changes.listen(apply, onError: out.addError);
    resyncSub = resync.listen((_) {
      load();
    }, onError: out.addError);
  };
  out.onCancel = () async {
    await changeSub?.cancel();
    await resyncSub?.cancel();
  };
  return out.stream;
}

/// One authoritative reload on subscribe and again after each trigger.
/// [debounce] collapses bursts. There is no interval timer.
Stream<T> apitoRefetchOnChange<T>({
  required Future<T> Function() load,
  required Stream<void> triggers,
  Duration debounce = const Duration(milliseconds: 300),
}) {
  final out = StreamController<T>();
  StreamSubscription<void>? sub;
  Timer? timer;
  var epoch = 0;

  Future<void> run() async {
    final token = ++epoch;
    try {
      final value = await load();
      if (token != epoch || out.isClosed) return;
      out.add(value);
    } catch (err, stack) {
      if (token == epoch && !out.isClosed) out.addError(err, stack);
    }
  }

  out.onListen = () {
    run();
    sub = triggers.listen((_) {
      timer?.cancel();
      timer = Timer(debounce, () {
        run();
      });
    }, onError: out.addError);
  };
  out.onCancel = () async {
    timer?.cancel();
    await sub?.cancel();
  };
  return out.stream;
}
