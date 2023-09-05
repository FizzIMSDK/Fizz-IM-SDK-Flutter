import 'package:fim_sdk/src/models/fim_image_elem.dart';

import 'fim_text_elem.dart';

///消息协议体
class FimMessage {
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

  late String? content;

  /// 图片消息
  FimImageElem? imageElem;

  FimMessage(
      {this.msgId,
      this.timestamp,
      this.progress,
      this.fromId,
      this.faceUrl,
      this.nickName,
      this.friendRemark,
      this.nameCard,
      this.toId,
      this.status,
      required this.elemType,
      this.content,
      this.imageElem});

  FimMessage.fromJson(Map<String, dynamic> json) {
    elemType = json['elemType'];
    content = json['content'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['toId'] = this.toId;
    data['content'] = this.content;
    data['elemType'] = this.elemType;
    return data;
  }
}

/// 离线推送信息
class OfflinePushInfo {
  /// 通知标题
  String? title;

  /// 通知描述
  String? desc;

  /// 扩展内容
  String? ex;

  /// 仅ios有效
  String? iOSPushSound;

  /// 仅ios有效
  bool? iOSBadgeCount;

  OfflinePushInfo({this.title, this.desc, this.ex, this.iOSPushSound, this.iOSBadgeCount});

  OfflinePushInfo.fromJson(Map<String, dynamic> json) {
    title = json['title'];
    desc = json['desc'];
    ex = json['ex'];
    iOSPushSound = json['iOSPushSound'];
    iOSBadgeCount = json['iOSBadgeCount'];
  }

  Map<String, dynamic> toJson() {
    final data = Map<String, dynamic>();
    data['title'] = this.title;
    data['desc'] = this.desc;
    data['ex'] = this.ex;
    data['iOSPushSound'] = this.iOSPushSound;
    data['iOSBadgeCount'] = this.iOSBadgeCount;
    return data;
  }
}
