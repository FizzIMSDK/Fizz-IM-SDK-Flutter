import 'dart:convert';

import '../enums/chat_typeu_enum.dart';
import 'Codes.dart';
import 'gen_message.dart';

//{bridge:false, type:2, dataContent:'萨达萨达撒旦', from:'1', to:'2', fp:'217e2ec7-3ac4-4df0-9373-a04c30f556bf', QoS:true, typeu:-1, retryCount:0, sm:-1}
//文本消息 req
class TextMsgReq extends GenMessage {
  late String fromId;
  late String toId;
  //文本内容
  late String dataContent;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['dataContent'] = dataContent;
    data['fromId'] = fromId;
    data['toId'] = toId;

    return data;
  }

  @override
  int getTypeu() {
    return ChatTypeuEnum.friendChat.type;
  }

  @override
  int getType() {
    return Codes.CODE_COMMON$DATA_RESP;
  }

  @override
  String getData() {
    return dataContent;
  }
}
