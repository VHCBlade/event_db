part of flutter_bloc_library;

/// Functions for helping create the BLoC Pattern
class StreamHelper {
  /// Maps the [stream] with the [mapper] while initializing the value with the mapper
  static ValueObservable<T> mapWithSeed<A, T>(
      ValueObservable<A> stream, T Function(A) mapper,
      {bool distinct: true, bool Function(T, T) equals}) {
    assert(stream != null);
    assert(mapper != null);

    final initialStream = stream.map(mapper);

    return makeDistinct(initialStream, distinct, equals)
        .shareValueSeeded(mapper(stream.value));
  }

  /// Equivalent to ObservableValue.combineLatest2 with a seeded value
  static ValueObservable<T> combineLatest2WithSeed<A, B, T>(
      ValueObservable<A> streamA,
      ValueObservable<B> streamB,
      T Function(A, B) combiner,
      {bool distinct: true,
      bool Function(T, T) equals}) {
    assert(streamA != null);
    assert(streamB != null);
    assert(combiner != null);

    final stream = Observable.combineLatest2(streamA, streamB, combiner);

    return makeDistinct(stream, distinct, equals)
        .shareValueSeeded(combiner(streamA.value, streamB.value));
  }

  /// Equivalent to ObservableValue.combineLatest3 with a seeded value
  static ValueObservable<T> combineLatest3WithSeed<A, B, C, T>(
      ValueObservable<A> streamA,
      ValueObservable<B> streamB,
      ValueObservable<C> streamC,
      T Function(A, B, C) combiner,
      {bool distinct: true,
      bool Function(T, T) equals}) {
    assert(streamA != null);
    assert(streamB != null);
    assert(streamC != null);
    assert(combiner != null);

    final stream =
        Observable.combineLatest3(streamA, streamB, streamC, combiner);

    return makeDistinct(stream, distinct, equals).shareValueSeeded(
        combiner(streamA.value, streamB.value, streamC.value));
  }

  /// Equivalent to ObservableValue.combineLatest4 with a seeded value
  ///
  /// if [distinct] is true,
  ///
  /// if [equals] is not specified, will default to the == operator
  static ValueObservable<T> combineLatest4WithSeed<A, B, C, D, T>(
      ValueObservable<A> streamA,
      ValueObservable<B> streamB,
      ValueObservable<C> streamC,
      ValueObservable<D> streamD,
      T Function(A, B, C, D) combiner,
      {bool distinct: true,
      bool Function(T, T) equals}) {
    assert(streamA != null);
    assert(streamB != null);
    assert(streamC != null);
    assert(streamD != null);
    assert(combiner != null);

    final stream =
        Observable.combineLatest4(streamA, streamB, streamC, streamD, combiner);

    return makeDistinct(stream, distinct, equals).shareValueSeeded(
        combiner(streamA.value, streamB.value, streamC.value, streamD.value));
  }

  /// Converts the Observable into a distinct version if [distinct] is true.
  static Observable<T> makeDistinct<T>(
      Observable<T> stream, bool distinct, bool Function(T, T) equals) {
    if (distinct) {
      return stream.distinct(equals ?? (a, b) => a == b);
    }

    return stream;
  }
}
