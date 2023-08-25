import 'package:meta/meta.dart';

import '../state_store.dart';

///im连接状态维护类抽象类
abstract class BaseService {
  @protected
  final StateStore stateStore;

  BaseService(this.stateStore);

  Future<void> close();

  void onDisconnected({Object? error, StackTrace? stackTrace});
}
