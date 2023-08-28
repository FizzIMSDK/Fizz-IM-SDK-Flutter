import '../transport/tcp_client.dart';

//sdk 长连接状态管理
class StateStore {
  TcpClient? tcp;
  //是否连接
  bool isConnected = false;

  // 用户Session
  bool isSessionOpen = false;

  // Request
  int lastRequestDate = 0;

  void reset() {
    tcp = null;
    isConnected = false;
    isSessionOpen = false;
    lastRequestDate = 0;
  }
}
