///登录平台
enum DeviceTypeEnum {
  WEB(type: 1, info: "WEB"),
  IOS(type: 2, info: "IOS"),
  ANDROID(type: 3, info: "ANDROID"),
  WINDOWS(type: 4, info: "WINDOWS"),
  MAC(type: 5, info: "MAC"),
  UNKNOWN(type: 6, info: "UNKNOWN"),
  ;

  const DeviceTypeEnum({required this.type, required this.info});

  final int type;
  final String info;
}
