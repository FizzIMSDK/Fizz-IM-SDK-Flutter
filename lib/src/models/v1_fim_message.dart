import 'package:fim_sdk/src/models/v1_fim_image_elem.dart';

import 'v2_tim_text_elem.dart';

///消息协议体
class Message {
  /// 消息ID
  late String? msgId;

  /// 消息时间戳
  late int? timestamp;

  /// 消息发送进度，只有多媒体消息才会有，其余消息为100
  late int? progress;

  /// 消息发送者
  late String? fromId;

  /// 发送者头像
  late String? faceUrl;

  /// 消息发送者昵称
  late String? nickName;

  /// 消息发送者好友备注，只有当与消息发送者有好友关系，且给好友设置过备注，才会有值
  late String? friendRemark;

  /// 发送者备注
  late String? nameCard;

  /// 消息接受者用户ID 群就是群id
  late String? toId;

  /// 消息状态 发送中 成功 失败等
  late int? status;

  /// 消息类型 文本消息 图片消息等
  late int elemType;

  /// 文本消息
  V1FimTextElem? textElem;

  /// 图片消息
  V1FimImageElem? imageElem;
}
