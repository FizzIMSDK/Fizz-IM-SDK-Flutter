import 'dart:typed_data';
import 'dart:convert' show utf8;

import '../models/protocol.dart';


// ByteBuf 协议工具类
class ByteBufUtil {
  static Protocol? readMsg(Uint8List rawData) {
    if (rawData == null) return null;

    Protocol msg = new Protocol();
    msg.decode(rawData);

    print("接收到的消息======================================");
    print(msg);
    print("======================================");
    return msg;
  }

  static String readString(Uint8List data) {
    return utf8.decode(data);
    //return String.fromCharCodes(data);
  }

  //
  static List<int> convertUint8ListToMutable(Uint8List data) {
    List<int> result = <int>[];
    if (data == null) return result;

    for (int i = 0; i < data.length; i++) {
      result.add(data[i]);
    }
    return result;
  }

  //大端转小端
  static int readInt321(List<int> list) {
    Uint8List resultList = Uint8List.fromList(list);
    ByteData byteData = ByteData.view(resultList.buffer);
    return byteData.getInt32(0);
  }

  static int readInt32(List<int> list) {
    Uint8List bytes = Uint8List.fromList(list);
    int result = bytes.sublist(0).buffer.asInt32List()[0];
    return result;
  }
}
