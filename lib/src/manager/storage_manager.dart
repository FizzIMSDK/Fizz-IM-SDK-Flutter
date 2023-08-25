import 'dart:typed_data';

import '../enums/storage_resource_type_enum.dart';
import 'fim_manager.dart';
import 'package:http/http.dart' as http;
import 'package:fixnum/fixnum.dart';
import 'package:http_parser/http_parser.dart';

///存储服务 目前使用支持s3协议的 云存储 或者自建的minio
///从后端获取临时上传地址 7天内有效
class StorageManager {
  final FIMManager _fIMManager;

  static const String _resourceIdKeyName = 'id';
  static const String _defaultUrlKeyName = 'url';
  static final Map<StorageResourceTypeEnum, String> _resourceTypeToBucketName =
      {
    for (final type in StorageResourceTypeEnum.values)
      type: type.name.toLowerCase().replaceAll('_', '-')
  };

  final String serverUrl;

  // http
  final http.Client _httpClient = http.Client();

  StorageManager(this._fIMManager, String? storageServerUrl)
      : serverUrl = storageServerUrl == null
            ? 'http://localhost:9000'
            : Uri.parse(storageServerUrl).origin;

// Base

// Future<Response<StorageUploadResult>> _upload(String url, Map<String, String> formData, Uint8List data, String id,
//     {String? name, MediaType? mediaType}) async {
//   if (data.isEmpty) {
//     throw ResponseException(
//         code: ResponseStatusCode.illegalArgument, reason: 'The data of resource must not be empty');
//   }
//   final Uri uri;
//   try {
//     uri = Uri.parse(url);
//   } on Exception catch (e) {
//     throw ResponseException(code: ResponseStatusCode.illegalArgument, reason: 'The URL is illegal: $url', cause: e);
//   }
//   final request = http.MultipartRequest('POST', uri)
//     ..fields.addAll(formData)
//     ..fields['key'] = id
//     ..files.add(http.MultipartFile.fromBytes('file', data, filename: name ?? id, contentType: mediaType));
//   if (mediaType != null) {
//     request.fields['Content-Type'] = mediaType.toString();
//   }
//   final http.StreamedResponse response;
//   try {
//     response = await _httpClient.send(request);
//   } on Exception catch (e) {
//     throw ResponseException(
//         code: ResponseStatusCode.httpError,
//         reason: 'Caught an error while sending an HTTP POST request to update the resource',
//         cause: e);
//   }
//   if (response.isNotSuccessful) {
//     throw ResponseException(
//         code: ResponseStatusCode.httpNotSuccessfulResponse,
//         reason: 'Failed to upload the resource because the HTTP response status code is: ${response.statusCode}');
//   }
//   final String responseData;
//   try {
//     responseData = await response.stream.bytesToString();
//   } on Exception catch (e) {
//     throw ResponseException(
//         code: ResponseStatusCode.invalidResponse, reason: 'Failed to get the response body as a string', cause: e);
//   }
//   Int64? idNum;
//   try {
//     idNum = Int64.parseInt(id);
//   } on FormatException catch (_) {}
//   final idStr = idNum == null ? id : null;
//   return Response.value(StorageUploadResult(uri, response.headers, responseData, idNum, idStr));
// }
}
