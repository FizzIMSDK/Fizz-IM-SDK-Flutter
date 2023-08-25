
///个人头像 群头像
enum StorageResourceTypeEnum {
  //单聊
  USER_PROFILE_PICTURE(type: 0),

  //群头像
  GROUP_PROFILE_PICTURE(type: 1),
  //消息附件 图片视频文件等
  MESSAGE_ATTACHMENT(type: 2);

  const StorageResourceTypeEnum({required this.type});

  final int type;
}
