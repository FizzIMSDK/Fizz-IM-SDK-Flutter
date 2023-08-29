import 'package:fixnum/fixnum.dart';

import 'dart:typed_data';


import '../utils/GenUtil.dart';
import 'dart:convert' show jsonDecode, jsonEncode, utf8;

import 'codec.dart';
import 'gen_message.dart';

//通信协议
class Protocol extends Codec {
  //协议类型
  int? type;

  bool? QoS;
  //发送者
  String? from;

  //接收者
  String? to;

  //全局唯一id
  String? fp;

  //用户协议 dataContent的
  int? typeu;
  String? dataContent;

  Protocol();

  static Protocol buildMsg(String to, GenMessage genMessage) {
    final Protocol msg = Protocol();
    msg.from = genMessage.getFrom();
    msg.to = to;
    msg.type = genMessage.getType();
    msg.typeu = genMessage.getTypeu();
    msg.QoS = true;
    if (genMessage.getData() != null) {
      msg.dataContent = genMessage.getData();
    }
    return msg;
  }

  @override
  int decode(Uint8List rawData) {
    String bodyStr = utf8.decode(rawData);
    Map<String, dynamic> json = jsonDecode(bodyStr);
    resetReadIndex();
    return getReadIndex();
  }

  @override
  Uint8List encode() {
    List<Uint8List> result = [];
    //写入协议json 到字节流
    result.add(writeString(jsonEncode(toJson())));
    return Uint8List.fromList(result.expand((x) => x).toList());
  }

  //反序列化
  static Protocol fromBuffer(Uint8List rawData) {
    String bodyStr = utf8.decode(rawData);
    return Protocol.fromJson(jsonDecode(bodyStr));
  }

  Protocol.fromJson(Map<String, dynamic> map)
      : type = map["type"] ?? '',
        from = map["from"] ?? '',
        to = map['to'] ?? '',
        typeu = map['typeu'] ?? '',
        fp = map['fp'] ?? '',
        QoS = map['QoS'] ?? false,
        dataContent = map['dataContent'] ?? '';

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'from': from,
      'to': to,
      'typeu': typeu,
      'fp': fp,
      'QoS': QoS,
      'dataContent': dataContent,
    };
  }

  // Map<String, dynamic> toJson() {
  //   final data = <String, dynamic>{};
  //   data['type'] = type;
  //     data['from'] = from;
  //     data['to'] = to;
  //     data['typeu'] = typeu;
  //   data['fp'] = fp;
  //   data['dataContent'] = dataContent;
  //   return data;
  // }
} //end class
