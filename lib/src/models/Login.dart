import 'dart:convert';

import 'Codes.dart';
import 'gen_message.dart';

//登录im 协议
class LoginReq extends GenMessage {
  late String loginUserId;
  late String loginToken;
  late int clientType;
  late String deviceId;
  String? extra;

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['loginUserId'] = loginUserId;
    data['loginToken'] = loginToken;
    data['extra'] = extra;
    data['clientType'] = clientType;
    data['deviceId'] = deviceId;
    return data;
  }

  @override
  int getType() {
    return Codes.CODE_LOGIN_REQ;
  }

  @override
  String getData() {
    return jsonEncode(toJson());
  }
}

// //登录结果报文 会带上登录者的个人信息
// class LoginResp extends Codec {
//   static const int RESULT_CODE_SUCCESS = 1;
//   static const int RESULT_CODE_ERROR = -1;
//
//   int resultCode;
//   String token;
//   String account;
//   int uid;
//   String avator;
//   String name;
//   int sex;
//   String desc;
//   int age;
//
//   @override
//   int decode(Uint8List rawData) {
//     resetReadIndex();
//
//     resultCode = readInt32(rawData);
//     token = readString(rawData);
//     account = readString(rawData);
//     uid = readInt64(rawData);
//     avator = readString(rawData);
//     name = readString(rawData);
//
//     sex = readInt32(rawData);
//     desc = readString(rawData);
//     age = readInt32(rawData);
//
//     return getReadIndex();
//   }
//
//   @override
//   Uint8List encode() {
//     List<Uint8List> result = [];
//
//     result.add(writeInt32(resultCode));
//     result.add(writeString(token));
//     result.add(writeString(account));
//     result.add(writeInt64(uid));
//     result.add(writeString(avator));
//     result.add(writeString(name));
//
//     result.add(writeInt32(sex));
//     result.add(writeString(desc));
//     result.add(writeInt32(age));
//
//     return Uint8List.fromList(result.expand((x) => x).toList());
//   }
//
//   @override
//   int getCode() {
//     return Codes.CODE_LOGIN_RESP;
//   }
// }
//
// //退出登录
// class LoginOutReq extends AuthBaseBean {
//   int uid;
//
//   LoginOutReq(this.uid) : super(Account.getToken());
//
//   @override
//   int decodeModel(Uint8List rawData) {
//     uid = readInt64(rawData);
//     return getReadIndex();
//   }
//
//   @override
//   Uint8List encodeModel(List<Uint8List> result) {
//     result.add(writeInt64(uid));
//     return null;
//   }
//
//   @override
//   int getCode() {
//     return Codes.CODE_LOGIN_OUT_REQ;
//   }
// }
//
// /**
//  * 注销登录消息 响应
//  */
// class LoginOutResp extends Codec {
//   int resultCode;
//
//   @override
//   int decode(Uint8List rawData) {
//     resetReadIndex();
//     resultCode = readInt32(rawData);
//
//     return getReadIndex();
//   }
//
//   @override
//   Uint8List encode() {
//     List<Uint8List> result = [];
//     result.add(writeInt32(resultCode));
//     return Uint8List.fromList(result.expand((x) => x).toList());
//   }
//
//   @override
//   int getCode() {
//     return Codes.CODE_LOGIN_OUT_RESP;
//   }
// }
//
// //自动登录 请求
// class AutoLoginReq extends AuthBaseBean {
//   int synType = 1;
//
//   AutoLoginReq() : super(Account.getToken());
//
//   @override
//   int decodeModel(Uint8List rawData) {
//     synType = readInt32(rawData);
//
//     return getReadIndex();
//   }
//
//   @override
//   Uint8List encodeModel(List<Uint8List> result) {
//     result.add(writeInt32(synType));
//     return null;
//   }
//
//   @override
//   int getCode() {
//     return Codes.CODE_AUTO_LOGIN_REQ;
//   }
// }
//
// class AutoLoginResp extends Codec {
//   int resultCode;
//
//   @override
//   int decode(Uint8List rawData) {
//     resetReadIndex();
//     resultCode = readInt32(rawData);
//
//     return getReadIndex();
//   }
//
//   @override
//   Uint8List encode() {
//     List<Uint8List> result = [];
//     result.add(writeInt32(resultCode));
//     return Uint8List.fromList(result.expand((x) => x).toList());
//   }
//
//   @override
//   int getCode() {
//     return Codes.CODE_AUTO_LOGIN_REQ;
//   }
// }
