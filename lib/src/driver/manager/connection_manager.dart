import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import '../../exception/response_exception.dart';
import '../../models/response_status_code.dart';
import '../../utils/bytebuf.dart';
import '../../models/protocol.dart';
import '../../transport/tcp_client.dart';
import '../state_store.dart';
import 'base_service.dart';

typedef OnConnectedListener = void Function();
typedef OnDisconnectedListener = void Function({Object? error, StackTrace? stackTrace});
typedef MessageListener = void Function(Uint8List message);

//解析二进制消息
class _MessageDecoder {
  static const int _maxReadBufferCapacity = 8 * 1024 * 1024;

  int _readIndex = 0;
  int _tempPayloadLength = 0;
  int? _payloadLength;
  final List<int> _readBuffer = [];

  //解析接收到的原始数据
  List<Protocol> parseRawData(Uint8List rawData) {
    List<int> dataList = ByteBufUtil.convertUint8ListToMutable(rawData);

    if (_readBuffer.isNotEmpty) {
      //拼接上一次的数据
      dataList.insertAll(0, _readBuffer);
      _readBuffer.clear();
    }

    List<Protocol> resultMsgList = [];

    while (dataList.isNotEmpty) {
      if (dataList.length < 4) {
        // 首字节不足4位
        _readBuffer.addAll(dataList);
        dataList.removeRange(0, dataList.length);
        break;
      }

      int len = ByteBufUtil.readInt321(dataList);
      if (len > dataList.length) {
        //数据不完整
        _readBuffer.addAll(dataList);
        dataList.removeRange(0, dataList.length);
        break;
      } else {
        // len <= data.length
        Protocol msg = new Protocol();
        print("msg len = $len  , dataLen = ${dataList.length}");

        //msg.decode(Uint8List.fromList(dataList.sublist(0, len)));

        resultMsgList.add(msg);

        dataList.removeRange(0, len);
      }
    } //end while
    return resultMsgList;
  }

  String readString(Uint8List bytes) {
    //print("readString $bytes");
    int len = bytes.sublist(_readIndex).buffer.asInt32List()[0];
    //print("$_readIndex len = $len");
    String readString = utf8.decode(bytes.sublist(_readIndex + 4, _readIndex + 4 + len));
    _readIndex += (4 + len); //string 长度 + 数据长度

    return readString;
  }

  List<Uint8List> decodeMessages(List<int> bytes) {
    if ((_readBuffer.length + bytes.length) > _maxReadBufferCapacity) {
      throw Exception('The read buffer has exceeded the maximum size $_maxReadBufferCapacity');
    }
    _readBuffer.addAll(bytes);
    final messages = <Uint8List>[];
    while (true) {
      final message = _tryReadMessage();
      if (message == null) {
        break;
      }
      messages.add(message);
    }
    return messages;
  }

  void clear() {
    _readIndex = 0;
    _tempPayloadLength = 0;
    _payloadLength = null;
    _readBuffer.clear();
  }

  //读取完整缓冲区数据
  Uint8List? _tryReadMessage() {
    _payloadLength ??= _tryReadVarInt();
    if (_payloadLength == null) {
      return null;
    }
    final end = _readIndex + _payloadLength!;
    if (_readBuffer.length < end) {
      return null;
    }
    //去掉4字节
    final message = _readBuffer.sublist(_readIndex, end);
    _readBuffer.removeRange(0, end);
    _readIndex = 0;
    _payloadLength = null;
    return Uint8List.fromList(message);
  }

  //大端转小端
  int byteToNum(List<int> list) {
    Uint8List resultList = Uint8List.fromList(list);

    ByteData byteData = ByteData.view(resultList.buffer);

    return byteData.getInt32(0);
  }

  int? _tryReadVarInt() {
    final length = _readBuffer.length;

    while (_readIndex < 5) {
      if (_readIndex >= length) {
        return null;
      }

      final byte = _readBuffer[_readIndex];
      _tempPayloadLength |= (byte & 0x7F) << (7 * _readIndex);
      _readIndex++;
      if (byte & 0x80 == 0) {
        final length = _tempPayloadLength;
        _tempPayloadLength = 0;

        _readIndex = 4;
        //读取消息体长度
        int msgLength = byteToNum(_readBuffer.sublist(0, 4));

        return msgLength;
      }
    }
    throw Exception('VarInt input too big');
  }
}

///连接服务
class ConnectionManager extends BaseService {
  final String _initialHost;
  final int _initialPort;
  final int _initialConnectTimeoutMillis;

  //连接成功回调
  final List<OnConnectedListener> _onConnectedListeners = [];

  //连接关闭回调
  final List<OnDisconnectedListener> _onDisconnectedListeners = [];

  //消息监听回调
  final List<MessageListener> _messageListeners = [];

  final _MessageDecoder _decoder = _MessageDecoder();

  ConnectionManager(StateStore stateStore, String? host, int? port, int? connectTimeoutMillis)
      : _initialHost = host ?? '127.0.0.1',
        _initialPort = port ?? 10010,
        _initialConnectTimeoutMillis = connectTimeoutMillis ?? 30 * 1000,
        super(stateStore);

  //重连标识
  static bool retryConnect = false;

  ///连接监听器
  void addOnConnectedListener(OnConnectedListener listener) => _onConnectedListeners.add(listener);

  ///连接关闭监听器
  void addOnDisconnectedListener(OnDisconnectedListener listener) => _onDisconnectedListeners.add(listener);

  ///消息监听器
  void addMessageListener(MessageListener listener) => _messageListeners.add(listener);

  ///消息监听器
  void removeOnConnectedListener(OnConnectedListener listener) => _onConnectedListeners.remove(listener);

  void removeOnDisconnectedListener(OnDisconnectedListener listener) => _onDisconnectedListeners.remove(listener);

  void removeMessageListener(MessageListener listener) => _messageListeners.remove(listener);

  void _notifyOnConnectedListeners() {
    for (final listener in _onConnectedListeners) {
      listener.call();
    }
  }

  void _notifyOnDisconnectedListeners(Object? error, StackTrace? stackTrace) {
    for (final listener in _onDisconnectedListeners) {
      listener.call(error: error, stackTrace: stackTrace);
    }
  }

  void _notifyMessageListeners(Uint8List message) {
    for (final listener in _messageListeners) {
      listener.call(message);
    }
  }

  // Connection

  Future<void> connect(
      {String? host, int? port, int? connectTimeoutMillis, bool? useTls = false, SecurityContext? context}) async {
    if (stateStore.isConnected) {
      if (host == stateStore.tcp?.host && port == stateStore.tcp?.port) {
        return;
      } else {
        throw ResponseException(code: ResponseStatusCode.clientSessionAlreadyEstablished);
      }
    }
    //监听socket
    final tcp = TcpClient(_onSocketClosed, (bytes) {
      final messages = _decoder.decodeMessages(bytes);
      for (final message in messages) {
        _notifyMessageListeners(message);
      }
    });
    connectTimeoutMillis ??= _initialConnectTimeoutMillis;
    final timeout = connectTimeoutMillis > 0 ? Duration(milliseconds: connectTimeoutMillis) : null;
    await tcp.connect(host ?? _initialHost, port ?? _initialPort, useTls ?? false, context, timeout);
    stateStore.tcp = tcp;
    _onSocketOpened();
  }

  Future<void> disconnect() async {
    if (stateStore.isConnected) {
      stateStore.isConnected = false;
      await stateStore.tcp?.close();
    }
    _decoder.clear();
  }

  // Lifecycle hooks

  void _onSocketOpened() {
    print("socket:已连接");
    stateStore.isConnected = true;
    _notifyOnConnectedListeners();
  }

  //连接断开。尝试自动重连。间隔2s
  void _onSocketClosed({Object? error, StackTrace? stackTrace}) {
    print("socket:连接断开");
    _decoder.clear();
    stateStore.isConnected = false;
    _notifyOnDisconnectedListeners(error, stackTrace);
  }

  @override
  Future<void> close() => disconnect();

  @override
  void onDisconnected({Object? error, StackTrace? stackTrace}) {
    print("告诉上层长连接断开了");
  }

// static _retryConnectSocketIo() {
//   if (retryConnect) {
//     print("socket:开启重新连接");
//     Future.delayed(Duration(seconds: 10), () {
//       connect();
//     });
//   }
// }
}
