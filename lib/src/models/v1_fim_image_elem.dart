import 'v1_fim_elem.dart';
import 'v1_fim_image.dart';

/// V2TimImageElem
///
/// {@category Models}
///

class V1FimImageElem extends V1FIMElem {
  /// 图片本地路径，仅在发送消息时有效，用做发消息提前上屏预览
  late String? path;

  /// 图片资源列表
  List<V1FimImage?>? imageList = List.empty(growable: true);

  V1FimImageElem({
    this.path,
    this.imageList,
  });

  V1FimImageElem.fromJson(Map<String, dynamic> json) {
    path = json['path'];
    if (json['imageList'] != null) {
      imageList = List.empty(growable: true);
      json['imageList'].forEach((v) {
        imageList!.add(V1FimImage.fromJson(v));
      });
    }
    if (json['nextElem'] != null) {
      nextElem = Map<String, dynamic>.from(json['nextElem']);
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['path'] = path;
    if (imageList != null) {
      data['imageList'] = imageList!.map((v) => v!.toJson()).toList();
    }
    if (nextElem != null) {
      data['nextElem'] = nextElem;
    }
    return data;
  }
}
// {
//   "path":"",
//   "imageList":[{}]
// }
