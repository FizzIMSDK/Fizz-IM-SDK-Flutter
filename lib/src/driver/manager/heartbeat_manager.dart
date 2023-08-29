import 'dart:async';
import 'dart:math';

import '../../exception/response_exception.dart';
import '../../models/gen_message.dart';
import '../../models/protocol.dart';
import '../../models/response_status_code.dart';
import '../state_store.dart';
import 'base_service.dart';

class HeartbeatManager extends BaseService {
  //默认心跳间隔
  static const _defaultHeartbeatIntervalMillis = 15 * 1000;

  final int _heartbeatIntervalMillis;
  final Duration _heartbeatTimerInterval;
  int _lastHeartbeatRequestDate = 0;
  Timer? _heartbeatTimer;
  final List<Completer<void>> _heartbeatCompleters = [];

  HeartbeatManager(StateStore stateStore, int? heartbeatIntervalMillis)
      : _heartbeatIntervalMillis = heartbeatIntervalMillis ?? _defaultHeartbeatIntervalMillis,
        _heartbeatTimerInterval =
            Duration(milliseconds: max(1, (heartbeatIntervalMillis ?? _defaultHeartbeatIntervalMillis) ~/ 10)),
        super(stateStore);

  bool get isRunning => _heartbeatTimer?.isActive == true;

  void start() {
    if (isRunning) {
      return;
    }
    _heartbeatTimer = Timer.periodic(
      _heartbeatTimerInterval,
      (_) {
        final now = DateTime.now().millisecondsSinceEpoch;
        final difference = min(now - stateStore.lastRequestDate, now - _lastHeartbeatRequestDate);
        if (difference > _heartbeatIntervalMillis) {
          send();
          _lastHeartbeatRequestDate = now;
        }
      },
    );
  }

  void stop() => _heartbeatTimer?.cancel();

  Future<void> send() async {
    //检查连接
    // if (!stateStore.isConnected || !stateStore.isSessionOpen) {
    //   throw ResponseException(code: ResponseStatusCode.clientSessionHasBeenClosed);
    // }
    print("发送心跳到服务器");
    stateStore.tcp!.write(Protocol.buildMsg("0", HeartbeatMsg()).encode());
    final completer = Completer<void>();
    _heartbeatCompleters.add(completer);
    return completer.future;
  }

  void resolveHeartbeatCompleters() {
    _heartbeatCompleters.removeWhere((completer) {
      completer.complete();
      return true;
    });
  }

  //
  //接收心跳失败的协议消息 抛出异常停止心跳任务
  bool rejectHeartbeatCompletersIfFail(Protocol notification) {
    //服务器回复的心跳应答包。不处理
    if (notification.type == 51) {
      //心跳响应 不回调
      this.resolveHeartbeatCompleters();
      return true;
    }
    // //心跳异常 抛错
    // if (_heartbeatFailureRequestId == notification.requestId.toInt()) {
    //   _rejectHeartbeatCompleters(ResponseException.fromNotification(notification));
    //   return true;
    // }
    return false;
  }

  void _rejectHeartbeatCompleters(ResponseException exception) {
    _heartbeatCompleters.removeWhere((completer) {
      completer.completeError(exception);
      return true;
    });
  }

  @override
  Future<void> close() {
    onDisconnected();
    return Future.value();
  }

  @override
  void onDisconnected({Object? error, StackTrace? stackTrace}) {
    stop();
    final exception =
        ResponseException(code: ResponseStatusCode.clientSessionHasBeenClosed, cause: error, stackTrace: stackTrace);
    _rejectHeartbeatCompleters(exception);
  }
}
