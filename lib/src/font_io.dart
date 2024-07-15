import 'dart:io';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:luoyi_dart_base/luoyi_dart_base.dart';
import 'package:path_provider/path_provider.dart';

import 'font.dart';

/// 加载字体 - 客户端环境
Future<ByteData?> generalLoadNetworkFont(
  String fontUrl, {
  FontModel? fontModel,
  String? localKey,
}) async {
  assert(fontUrl.startsWith('http'), '字体文件地址必须是网络地址');
  // 本地缓存的字体路径，以字族名为文件夹
  late final String localPath;
  try {
    localPath =
        '${(await getApplicationSupportDirectory()).path}/$localKey.ttf';
  } catch (error) {
    e(error, '获取字体缓存路径错误');
    return null;
  }

  ByteData? byteData = _loadLocalFont(localPath);
  if (byteData != null) return byteData;

  http.Response? res;
  try {
    res = await http.get(Uri.parse(fontUrl));
  } catch (error) {
    e(error, '请求字体失败，请检查网络连接或检查是否添加网络权限');
    return null;
  }

  bool result = _saveLocalFont(localPath, res.bodyBytes);
  if (!result) return null;

  return ByteData.view(res.bodyBytes.buffer);
}

/// 加载本地字体
ByteData? _loadLocalFont(String localPath) {
  try {
    final file = File(localPath);
    if (file.existsSync()) {
      List<int> contents = file.readAsBytesSync();
      if (contents.isNotEmpty) {
        return ByteData.view(Uint8List.fromList(contents).buffer);
      }
    }
  } catch (error) {
    e(error, '加载本地缓存字体错误');
    return null;
  }
  return null;
}

/// 保存字体到本地
bool _saveLocalFont(String localPath, List<int> byteData) {
  try {
    File file = File(localPath);
    if (!file.existsSync()) file.createSync(recursive: true);
    file.writeAsBytesSync(byteData);
    return true;
  } catch (error) {
    e(error, '保存本地缓存字体错误');
    return false;
  }
}
