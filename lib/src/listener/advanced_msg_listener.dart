import '../models/protocol.dart';

/// 消息监听
class OnAdvancedMsgListener {
  Function(Protocol msg)? onRecvNewMessage;

  /// Uniquely identifies
  String id;

  OnAdvancedMsgListener({this.onRecvNewMessage})
      : id = "id_${DateTime.now().microsecondsSinceEpoch}";

  /// 收到了一条新消息
  void recvNewMessage(Protocol msg) {
    onRecvNewMessage?.call(msg);
  }
}
