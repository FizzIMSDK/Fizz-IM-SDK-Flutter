import '../enums/device_type_enum.dart';
import '../models/Login.dart';
import '../models/protocol.dart';
import '../models/user_info.dart';
import 'fim_manager.dart';
import '../models/session_close_info.dart';
import '../models/session_close_status.dart';

class Location {
  final double longitude;
  final double latitude;

  Location(this.longitude, this.latitude);
}

// class User {
//   Int64 userId;
//   String? password;
//   DeviceType? deviceType;
//   Map<String, String>? deviceDetails;
//   UserStatus? onlineStatus;
//   Location? location;
//
//   User(this.userId, this.password, this.deviceType, this.deviceDetails,
//       this.onlineStatus, this.location);
// }
typedef OnOnlineListener = void Function();
typedef OnOfflineListener = void Function(SessionCloseInfo info);

class UserManager {
  final FIMManager _fIMManager;
  UserInfo? _userInfo;

  UserManager(this._fIMManager) {
    _fIMManager.driver
      //关闭连接监听器
      ..addOnDisconnectedListener(({error, stackTrace}) => _changeToOffline(SessionCloseInfo.from(
          closeStatus: SessionCloseStatus.connectionClosed, cause: error, stackTrace: stackTrace)));
    // ..addNotificationListener((notification) {
    //   //断开连接 失败原因
    //   //if (notification.hasCloseStatus() && isLoggedIn) {
    //     _changeToOffline(SessionCloseInfo.from(
    //         closeStatus: notification.closeStatus,
    //         businessStatus: notification.code,
    //         reason: notification.reason));
    //   //}
    // });
  }

  UserInfo? get userInfo => _userInfo;

  final List<OnOnlineListener> _onOnlineListeners = [];
  final List<OnOfflineListener> _onOfflineListeners = [];

  // bool get isLoggedIn =>
  //     _userInfo != null && _userInfo?.onlineStatus != UserStatus.OFFLINE;
  void addOnOnlineListener(OnOnlineListener listener) => _onOnlineListeners.add(listener);

  void addOnOfflineListener(OnOfflineListener listener) => _onOfflineListeners.add(listener);

  void removeOnOnlineListener(OnOnlineListener listener) => _onOnlineListeners.remove(listener);

  void removeOnOfflineListener(OnOfflineListener listener) => _onOfflineListeners.remove(listener);

  //将model编码成协议对象
  Future _sendModel(LoginReq loginReq) async {
    Protocol msg = Protocol.buildMsg("0", loginReq);
    await _fIMManager.driver.sendMsg(msg);
  }

  //修改在线状态
  void _changeToOnline() {
    _fIMManager.driver.stateStore.isSessionOpen = true;
    // if (!isLoggedIn) {
    //   _fIMManager.driver.stateStore.isSessionOpen = true;
    for (final listener in _onOnlineListeners) {
      listener.call();
    }
    //}
  }

  void _changeToOffline(SessionCloseInfo sessionCloseInfo) {
    _fIMManager.isLogined = false;
    // if (isLoggedIn) {
    //   _userInfo?.onlineStatus = UserStatus.OFFLINE;
    _fIMManager.driver.stateStore.isSessionOpen = false;
    //不管原因发起自动重连。
    _fIMManager.autoLogin();
    for (final listener in _onOfflineListeners) {
      listener.call(sessionCloseInfo);
    }
    //}
  }
}
