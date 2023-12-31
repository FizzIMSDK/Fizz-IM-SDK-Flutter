import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:fim_sdk/src/utils/int_extensions.dart';
import 'package:http/http.dart';

import '../../exception/response_exception.dart';
import '../../models/Request.dart';
import '../../models/protocol.dart';
import '../../models/response_status_code.dart';
import '../state_store.dart';
import 'base_service.dart';

//
// //通知返回类
typedef NotificationListener = void Function(Protocol notification);

///上行消息发送成功回调通知类
class RequestContext {
  //回调通知
  final Completer<Protocol> completer;

  //消息超时定时任务
  final Timer? timeoutTimer;

  RequestContext(this.completer, this.timeoutTimer);
}

///tcp消息服务类
class DriverMessageManager extends BaseService {
  static const int randomMax = 1 << 32;

  final Random _random = Random();

  //消息发送超时时间。默认1分钟
  late final int _requestTimeoutMillis;

  //最小请求间隔毫秒 默认0
  late final int _minRequestIntervalMillis;
  final List<NotificationListener> _notificationListeners = [];

  //消息上行缓冲区 (缓冲1分钟。收到服务器回执才算消息发送成功。)
  final Map<String, RequestContext> _idToRequest = {};

  DriverMessageManager(StateStore stateStore, int? requestTimeoutMillis, int? minRequestIntervalMillis)
      : super(stateStore) {
    _requestTimeoutMillis =
        requestTimeoutMillis == null || requestTimeoutMillis <= 0 ? 60 * 1000 : requestTimeoutMillis;
    _minRequestIntervalMillis = minRequestIntervalMillis ?? 0;
  }

  // Listeners
  void addNotificationListener(NotificationListener listener) => _notificationListeners.add(listener);

  void removeNotificationListener(NotificationListener listener) => _notificationListeners.remove(listener);

  void _notifyNotificationListeners(Protocol notification) {
    for (final listener in _notificationListeners) {
      try {
        listener.call(notification);
      } catch (e, s) {
        print('$e\n$s');
      }
    }
  }

  Future<Protocol> sendRequest(Protocol request) async {
    // if (!stateStore.isConnected || !stateStore.isSessionOpen) {
    //   throw ResponseException(
    //       code: ResponseStatusCode.clientSessionHasBeenClosed);
    // }
    final now = DateTime.now().millisecondsSinceEpoch;
    final difference = now - stateStore.lastRequestDate;
    final isFrequent = _minRequestIntervalMillis > 0 && difference <= _minRequestIntervalMillis;
    if (isFrequent) {
      throw ResponseException(code: ResponseStatusCode.clientRequestsTooFrequent);
    }

    final requestId = _generateRandomId().toString();
    request.fp = requestId.toString();
    var payload = request.encode();
    stateStore.tcp!.writeVarIntLengthAndBytes(payload);
    final timeoutTimer = _requestTimeoutMillis > 0
        ? Timer(Duration(milliseconds: _requestTimeoutMillis), () {
            final context = _idToRequest.remove(requestId);
            context?.completer.completeError(ResponseException(code: ResponseStatusCode.requestTimeout));
          })
        : null;
    final completer = Completer<Protocol>();
    final requestContext = RequestContext(completer, timeoutTimer);
    _idToRequest[requestId] = requestContext;
    stateStore.lastRequestDate = now;
    return completer.future;
  }

  /// 接受协议消息
  /// 处理上行缓存区消息并回调结果
  void didReceiveNotification(Protocol notification) {
    final isResponse = notification.fp != null && notification.fp != '';
    if (isResponse) {
      final requestId = notification.fp;
      final context = _idToRequest.remove(requestId);
      if (context != null) {
        context.timeoutTimer?.cancel();
        //回调新的
        context.completer.complete(notification);
        // if (notification.hasCode()) {
        //   if (ResponseStatusCode.isSuccessCode(notification.code)) {
        //     context.completer.complete(notification);
        //   } else {
        //     context.completer.completeError(
        //         ResponseException.fromNotification(notification));
        //   }
        // } else {
        //   context.completer.completeError(ResponseException(
        //       requestId:
        //       notification.hasRequestId() ? notification.requestId : null,
        //       code: ResponseStatusCode.invalidNotification,
        //       reason: 'The code is missing'));
        // }
      }
    }

    _notifyNotificationListeners(notification);
  }

//   //读取通知
//   void didReceiveNotification(Notification notification) {
//     final isResponse =
//         !notification.hasRelayedRequest() && notification.hasRequestId();
//     if (isResponse) {
//       final requestId = notification.requestId.toInt();
//       final context = _idToRequest.remove(requestId);
//       if (context != null) {
//         context.timeoutTimer?.cancel();
//         if (notification.hasCode()) {
//           if (ResponseStatusCode.isSuccessCode(notification.code)) {
//             context.completer.complete(notification);
//           } else {
//             context.completer.completeError(
//                 ResponseException.fromNotification(notification));
//           }
//         } else {
//           context.completer.completeError(ResponseException(
//               requestId:
//                   notification.hasRequestId() ? notification.requestId : null,
//               code: ResponseStatusCode.invalidNotification,
//               reason: 'The code is missing'));
//         }
//       }
//     }
//     _notifyNotificationListeners(notification);
//   }
//
  ///获取随机数
  int _generateRandomId() {
    int id;
    do {
      id = _random.nextInt(randomMax);
    } while (_idToRequest.containsKey(id));
    return id;
  }

//
  void _rejectRequestCompleter(ResponseException exception) {
    // _idToRequest.removeWhere((key, context) {
    //   context.completer.completeError(exception);
    //   return true;
    // });
  }

  @override
  Future<void> close() async {
    onDisconnected();
    return;
  }

  @override
  void onDisconnected({Object? error, StackTrace? stackTrace}) {
    final exception =
        ResponseException(code: ResponseStatusCode.clientSessionHasBeenClosed, cause: error, stackTrace: stackTrace);
    _rejectRequestCompleter(exception);
  }

  //发送消息
  // Future sendMsg(Protocol msg) async {
  //   var payload = msg.encode();
  //   stateStore.tcp!.writeVarIntLengthAndBytes(payload);
  // }
}
