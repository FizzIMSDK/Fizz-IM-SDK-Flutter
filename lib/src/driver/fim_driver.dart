import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../fim_sdk.dart';
import '../models/gen_message.dart';
import '../models/listener_callback.dart';
import '../models/protocol.dart';
import 'manager/connection_manager.dart';
import 'manager/heartbeat_manager.dart';
import 'manager/message_manager.dart';
import 'state_store.dart';

///im核心 连接类 心跳类。消息接收类
class FIMDriver {
  //连接状态
  final StateStore _stateStore = StateStore();

  //连接管理
  late final ConnectionManager _connectionManager;

  //心跳管理
  late final HeartbeatManager _heartbeatManager;

  //长连接管理
  late final DriverMessageManager _messageManager;

  final FIMManager _fIMManager;

  FIMDriver(this._fIMManager, String? tcpIp, int? tcpPort, int? connectTimeoutMillis, int? requestTimeoutMillis,
      int? minRequestIntervalMillis, int? heartbeatIntervalMillis) {
    _connectionManager = ConnectionManager(stateStore, tcpIp, tcpPort, connectTimeoutMillis)
      ..addOnConnectedListener(_addOnConnectedListener) //连接成功回调
      ..addOnDisconnectedListener(_onConnectionDisconnected) //连接失败回调
      ..addMessageListener(_onMessage); //消息回调
    _heartbeatManager = HeartbeatManager(_stateStore, heartbeatIntervalMillis);
    _messageManager = DriverMessageManager(_stateStore, requestTimeoutMillis, minRequestIntervalMillis);
  }

  // Getters

  StateStore get stateStore => _stateStore;

  // Close

  Future<void> close() => Future.wait([_connectionManager.close(), _heartbeatManager.close(), _messageManager.close()]);

  // Heartbeat Service

  void startHeartbeat() => _heartbeatManager.start();

  void stopHeartbeat() => _heartbeatManager.stop();

  Future<void> sendHeartbeat() => _heartbeatManager.send();

  bool get isHeartbeatRunning => _heartbeatManager.isRunning;

  // Connection Service

  Future<void> connect(
      {String? host, int? port, int? connectTimeoutMillis, bool? useTls, SecurityContext? context}) async {
    _fIMManager.sdkCall(ListenerCallback(method: 'connectListener', type: "onConnecting"));
    await _connectionManager.connect(
        host: host, port: port, connectTimeoutMillis: connectTimeoutMillis, useTls: useTls, context: context);
  }

  bool get isConnected => _stateStore.isConnected;

  //连接成功
  void _addOnConnectedListener() {
    _fIMManager.sdkCall(ListenerCallback(method: 'connectListener', type: "onConnectSuccess"));
  }

  //连接关闭 重置
  void _onConnectionDisconnected({Object? error, StackTrace? stackTrace}) {
    _stateStore.reset();
    _heartbeatManager.onDisconnected(error: error, stackTrace: stackTrace);
    _messageManager.onDisconnected(error: error, stackTrace: stackTrace);
    _fIMManager.sdkCall(ListenerCallback(method: 'connectListener', type: "onConnectFailed"));
  }

  //监听消息
  void addNotificationListener(NotificationListener listener) => _messageManager.addNotificationListener(listener);

  //
  void removeNotificationListener(NotificationListener listener) =>
      _messageManager.removeNotificationListener(listener);

  //连接关闭
  void addOnDisconnectedListener(OnDisconnectedListener listener) {
    _connectionManager.addOnDisconnectedListener(listener);
  }

  // Message Service
  //1.传递自定义协议子类
  //2.生成Protocol 父类返回通知
  Future<Protocol> send(GenMessage genMessage) async {
    Protocol msg = Protocol.buildMsg(genMessage.getTo(), genMessage);
    final notification = await _messageManager.sendRequest(msg);
    //session是否创建 否则用本地token自动登录重连
    //if (request.hasCreateSessionRequest()) {
    _heartbeatManager.start();
    //}
    return notification;
  }

  // Future<Protocol> send1(to,String message) async {
  //   Protocol msg = Protocol.buildMsg("0", HeartbeatMsg()).encode());
  //   final notification = await _messageManager.sendRequest(msg);
  //   //session是否创建 否则用本地token自动登录重连
  //   //if (request.hasCreateSessionRequest()) {
  //   _heartbeatManager.start();
  //   //}
  //   return notification;
  // }

  // 发送Msg消息 暂时不做重发啥的
  // Future<void> sendMsg(Protocol msg) async {
  //   final notification = await _messageManager.sendRequest(msg);
  //
  //   _heartbeatManager.start();
  // }

  //处理二进制消息
  void _onMessage(Uint8List message) {
    Protocol protocol;
    try {
      protocol = Protocol.fromBuffer(message);
    } catch (e, s) {
      print('格式化协议失败: $e\n$s');
      return;
    }
    //心跳消息处理
    if (_heartbeatManager.rejectHeartbeatCompletersIfFail(protocol)) {
      return;
    }

    //处理session状态 获取服务器id
    // if (notification.data.hasUserSession()) {
    //   final session = notification.data.userSession;
    //   _stateStore
    //     ..sessionId = session.sessionId
    //     ..serverId = session.serverId;
    // } else if (notification.hasCloseStatus()) {
    //   _stateStore.isSessionOpen = false;
    // }
    _messageManager.didReceiveNotification(protocol);
  }
}
