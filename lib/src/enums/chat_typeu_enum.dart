
//自定义协议
enum ChatTypeuEnum {
  //单聊
  friendChat(type: 10),

  //群聊
  groupChat(type: 100);

  const ChatTypeuEnum({required this.type});

  final int type;
}
