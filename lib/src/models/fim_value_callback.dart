import 'dart:convert';

dynamic decode = json.decode;
dynamic encode = json.encode;

/// V1FimValueCallback
/// im api网关 请求返回结构体
/// {@category Models}
///
class FimValueCallback<T> {
  late int code;
  late String msg;
  T? data;

  FimValueCallback({
    required this.code,
    required this.msg,
    this.data,
  });

  _getT<T>() => T;

  FimValueCallback.fromJson(Map<String, dynamic> json) {
    late dynamic fromJsonData;
    if (json['data'] == null) {
      fromJsonData = data;
    }
    // else if (T == V2TimConversationResult) {
    //   fromJsonData = V2TimConversationResult.fromJson(json['data']) as T;
    // } else if (T == V2TimConversation) {
    //   fromJsonData = V2TimConversation.fromJson(json['data']) as T;
    // }

    else {
      fromJsonData = json['data'] as T;
    }
    code = json['code'];
    msg = json['msg'] ?? '';
    data = fromJsonData;
  }
}
