import 'dart:typed_data';

import 'package:fixnum/fixnum.dart' show Int64;

import '../../fim_sdk.dart';
import '../listener/advanced_msg_listener.dart';
import '../models/protocol.dart';
import '../models/fim_message.dart';
import 'fim_manager.dart';

typedef MessageListener = void Function(Protocol message);

//消息管理
class MessageManager {
  final FIMManager _fIMManager;
  final List<MessageListener> _messageListeners = [];

  //监听类
  late OnAdvancedMsgListener msgListener;

  MessageManager(this._fIMManager) {
    _fIMManager.driver.addNotificationListener((notification) {
      // if (_messageListeners.isNotEmpty &&
      //     notification.hasRelayedRequest() &&
      //     notification.relayedRequest.hasCreateMessageRequest()) {
      // final message = _createMessageRequest2Message(notification);
      // final addition = _parseMessageAddition(message);
      for (final listener in _messageListeners) {
        listener.call(notification);
        //}
      }
      // //判断消息类型
      // if (notification.type == 2) {
      //   msgListener.onRecvNewMessage(notification);
      // }
      //}
    });
  }

  /// 消息监听
  // Future setAdvancedMsgListener(OnAdvancedMsgListener listener) {
  //   this.msgListener = listener;
  //   return msgListener.onRecvNewMessage(listener);
  //   // advancedMsgListeners.add(listener);
  // }

  void addMessageListener(MessageListener listener) =>
      _messageListeners.add(listener);

  void removeMessageListener(MessageListener listener) =>
      _messageListeners.remove(listener);

  // Future<Response<Int64>> sendMessage(bool isGroupMessage, Int64 targetId,
  //     {DateTime? deliveryDate,
  //     String? text,
  //     List<Uint8List>? records,
  //     int? burnAfter,
  //     Int64? preMessageId}) async {
  //   if (text == null && (records?.isEmpty ?? true)) {
  //     throw ResponseException(
  //         code: ResponseStatusCode.illegalArgument,
  //         reason: '"text" and "records" must not all be null');
  //   }
  //   final n = await _fIMManager.driver.send(CreateMessageRequest(
  //       groupId: isGroupMessage ? targetId : null,
  //       recipientId: !isGroupMessage ? targetId : null,
  //       deliveryDate: deliveryDate?.toInt64(),
  //       text: text,
  //       records: records,
  //       burnAfter: burnAfter,
  //       preMessageId: preMessageId));
  //   return n.toResponse((data) => data.getLongOrThrow());
  // }

  Protocol _createMessageRequest2Message(protocol) => Protocol();

//创建文本消息
  FimMessage createTextMessage({
    required String text,
  }) {
    return FimMessage();
  }
  // 发送json message.toJson()
  Future<FimMessage> sendMessage({required  FimMessage message}) =>
      _fIMManager.driver.send(new TextMsgReq()).then((value) => new FimMessage());

//创建图片消息
}
