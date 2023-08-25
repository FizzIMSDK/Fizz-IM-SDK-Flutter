import 'dart:convert';
import 'v1_fim_elem.dart';


///文本消息
class V1FimTextElem extends V1FIMElem {
  late String? text;

  V1FimTextElem({
    this.text,
  });

  V1FimTextElem.fromJson(Map<String, dynamic> json) {
    text = json['text'];
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['text'] = text;
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }

  formatJson(jsonSrc) {
    return json.decode(json.encode(jsonSrc));
  }
}

// {
//   "text":""
// }
