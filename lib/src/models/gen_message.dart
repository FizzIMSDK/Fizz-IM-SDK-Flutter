import 'Codes.dart';

abstract class GenMessage {
  GenMessage();

  String getFrom(){
    return "";
  }
  //0 =服务器
  String getTo() {
    return "0";
  }

  //im协议
  int getType() {
    return 1;
  }

  //聊天协议 单聊群聊
  int getTypeu() {
    return 0;
  }

  String? getData() {
    return null;
  }
}

//心跳协议
class HeartbeatMsg extends GenMessage {
  @override
  int getType() {
    //心跳
    return 1;
  }
}
