part of flutter_bloc_library;

/// Class that all Blocs will extend
abstract class Bloc {
  Function() _baseDispose;

  /// [controllers] are Controllers that will be closed when this object is disposed.
  Bloc(List<BehaviorSubject> controllers) {
    if (controllers == null) {
      _baseDispose = () {};
      return;
    }

    assert(!controllers.any((val) => val == null),
        "Do not set null controllers to be closed!");

    _baseDispose = () async {
      for (final controller in controllers) {
        await controller.drain().then((_) {}, onError: (_) {});
        await controller.close();
      }
    };
  }

  @mustCallSuper
  void dispose() {
    _baseDispose();
  }
}

class LoadableData<T> extends Equatable {
  final LoadingStatus status;
  final T data;

  LoadableData({this.status: LoadingStatus.notLoaded, this.data})
      : super([status, data]);
}

enum LoadingStatus { loading, loaded, notLoaded }