import 'dart:convert';
import 'dart:typed_data';

import 'package:fixnum/fixnum.dart';

///请求体
class FimRequest {
  late Int64 requestId;

  FimRequest({required int requestId});


  ///将当前json协议体转成二进制流
  Uint8List writeToBuffer() {
    List<Uint8List> result = [];
    //写入协议json 到字节流
    result.add(writeString(jsonEncode(toJson())));
    return Uint8List.fromList(result.expand((x) => x).toList());
  }

  Map<String, dynamic> toJson() {
    return {
      'type': "type",
      'from': "from",
      'to': "to",
      'typeu': "typeu",
      'fp': "fp",
      'QoS': "QoS",
      'dataContent': "dataContent",
    };
  }

  //
  Uint8List writeString(String str) {
    if (str.isEmpty) {
      return writeInt32(0);
    }

    List<Uint8List> result = [];
    Uint8List strUint8List = utf8.encode(str) as Uint8List;
    result.add(writeInt32(strUint8List.length));
    result.add(strUint8List);

    return Uint8List.fromList(result.expand((x) => x).toList());
  }

  //向字节流中写入4字节的消息长度 由于C中使用大端模式 所以要进行大小端的转换
  Uint8List writeInt32(int value) {
    //发送的时候小端转大端
    return Uint8List(4)..buffer.asByteData().setInt32(0, value, Endian.big);
  }
}
