import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:fim_sdk/src/models/session_close_info.dart';
import 'package:fim_sdk/src/models/user_info.dart';

import '../../fim_sdk.dart';
import '../models/Login.dart';
import '../models/listener_callback.dart';
import '../models/session_close_status.dart';

///im sdk
class FIMManager {
  //长连接管理
  late final FIMDriver _driver;

  //用户服务管理类
  late final UserManager _userManager;

  //消息服务管理类
  late final MessageManager _messageManager;

  //对象存储管理类
  late final StorageManager _storageManager;

  //连接管理类
  late OnConnectListener _connectListener;

  late String userId;

  //登陆状态
  bool isLogined = false;

  //本次认证的token
  late String token;

  ///初始化网络
  ConnectivityResult _connectionStatus = ConnectivityResult.none;
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<ConnectivityResult> _connectivitySubscription;

  FIMDriver get driver => _driver;

  UserManager get userManager => _userManager;

  MessageManager get messageManager => _messageManager;

  StorageManager get storageManager => _storageManager;

  ///初始化SDK
  initSDK({
    required String apiAddr,
    required String tcpIp,
    required int tcpPort,
    required OnConnectListener listener,
    int? connectTimeoutMillis,
    int? requestTimeoutMillis,
    int? minRequestIntervalMillis,
    int? heartbeatIntervalMillis,
  }) {
    this._connectListener = listener;
    _driver = FIMDriver(this, tcpIp, tcpPort, connectTimeoutMillis, requestTimeoutMillis, minRequestIntervalMillis,
        heartbeatIntervalMillis)
      ..addOnDisconnectedListener(({error, stackTrace}) => _userManager.changeToOffline(SessionCloseInfo.from(
          closeStatus: SessionCloseStatus.connectionClosed, cause: error, stackTrace: stackTrace)));
    _userManager = UserManager(this);
    _messageManager = MessageManager(this);
    _storageManager = StorageManager(this, apiAddr);
    print("初始化sdk...");
  }

  //退出登录需要卸载sdk
  unInitSDK() {
    _driver.close();
  }

  //im登录
  Future<UserInfo> login({required String userId, required String token, int? clientType, String? deviceId}) async {
    //判断tcp连接状态
    if (!_driver.isConnected) {
      await _driver.connect();
    }
    // //组装协议
    LoginReq loginReq = new LoginReq();
    loginReq.loginUserId = userId;
    loginReq.loginToken = token;
    loginReq.clientType = 3;
    loginReq.deviceId = "deviceId";
    _driver.send(loginReq);

    // //登录完成修改在线状态
    // _changeToOnline();
    //登陆成功存储token和过期时间到内存。用于会话等http接口使用。
    this.isLogined = true;
    this.userId = userId;
    this.token = token;
    //登录成功
    _registerNetworkCallback();
    //修改sdk为在线状态
    userManager.changeToOnline();
    return UserInfo(userID: "1");
  }

  /// 登出
  Future<dynamic> logout() async {
    //断开socket
    _driver.close();
    this.isLogined = false;
    this.token = "";
    return true;
  }

  ///登录调用
  void _registerNetworkCallback() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
  }

  ///网络变更事件 目前实现网络检测自动重连。需要先判断用户在线状态再决定
  Future<void> _updateConnectionStatus(ConnectivityResult result) async {
    _connectionStatus = result;
    //无网络不做处理
    if (result == ConnectivityResult.none) {
      return;
    }
    autoLogin();
  }

  /// 自动重连
  Future<dynamic> autoLogin() async {
    if (isLogined == false && userId.isNotEmpty && token.isNotEmpty) {
      print("自动重连中...");
      login(userId: userId, token: token);
    }
  }

  void sdkCall(ListenerCallback callback) async {
    if (callback.method == "connectListener") {
      switch (callback.type) {
        case 'onConnecting':
          print("连接中");
          _connectListener.connecting();
          break;
        case 'onConnectSuccess':
          print("连接成功");
          _connectListener.connectSuccess();
          break;
        case 'onConnectFailed':
          print("连接失败");
          _connectListener.connectFailed(callback.errCode, callback.errMsg);
          break;
      }
    }
  }
}
