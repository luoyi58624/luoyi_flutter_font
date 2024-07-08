import 'package:luoyi_dart_base/luoyi_dart_base.dart';

import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';

import 'font_web.dart' if (dart.library.io) 'font_io.dart';

part 'model.dart';

late FontModel initialFontModel;

/// 当前加载的全局字体模型
FontModel currentFontModel = FontModel.systemFont;

/// [fontFamily]本地存储键
const String _localKey = 'font_family';

/// [_initialElFontModel]本地存储键，如果用户在[init]中更改了[ElFontModel]，则重新加载新的字体
const String _initialLocalKey = 'initial_font_family';

final HashSet<String> _loadFonts = HashSet();

/// 已加载的字体
HashSet<String> get loadFonts => _loadFonts;

/// Flutter字体工具类
class FlutterFont {
  FlutterFont._();

  /// 当前选择的全局字体，null 表示系统字体，当调用[loadFont]函数加载新字体成功时，此变量将会指向新字体的fontFamily
  static String? get fontFamily =>
      currentFontModel.fontFamily == '' ? null : currentFontModel.fontFamily;

  /// 基础字重字体
  static FontWeight get normal =>
      fontFamily == null ? (_normal ?? FontWeight.normal) : FontWeight.normal;

  /// 中等字重字体
  static FontWeight get medium =>
      fontFamily == null ? (_medium ?? FontWeight.w500) : FontWeight.w500;

  /// 粗体字重字体
  static FontWeight get bold =>
      fontFamily == null ? (_bold ?? FontWeight.bold) : FontWeight.bold;

  /// 初始化字体，但会根据不同平台加载字体，如果你需要将某个字体直接应用所有平台，请使用[initFont]
  /// * web canvaskit - fontModel
  ///
  /// * android - 系统字体
  /// * android web html - 系统字体
  ///
  /// * ios - 系统字体
  /// * ios web html - 系统字体
  ///
  /// * windows - fontModel
  /// * windows web html - fontModel
  ///
  /// * macos - 系统字体
  /// * macos web html - 系统字体
  ///
  /// * linux - fontModel
  /// * linux web html - fontModel
  static Future<void> init({
    FontModel? fontModel,
    bool canvaskit = true,
    bool android = false,
    bool androidWeb = false,
    bool ios = false,
    bool iosWeb = false,
    bool macos = false,
    bool macosWeb = false,
    bool windows = true,
    bool windowsWeb = true,
    bool linux = true,
    bool linuxWeb = true,
  }) async {
    bool allowLoadCustomFont = getAllowLoadCustomFont(
      canvaskit: canvaskit,
      android: android,
      androidWeb: androidWeb,
      ios: ios,
      iosWeb: iosWeb,
      macos: macos,
      macosWeb: macosWeb,
      windows: windows,
      windowsWeb: windowsWeb,
      linux: linux,
      linuxWeb: linuxWeb,
    );
    if (allowLoadCustomFont) {
      i(fontModel?.fontWeights);
      fontModel != null && fontModel.fontFamily != ''
          ? await initFont(fontModel)
          : await initFont(FontModel.notoSansSc([FontWeight.w500]));
    } else {
      await initFont(FontModel.systemFont);
    }
  }

  /// 初始化全局默认字体
  static Future<void> initFont(FontModel fontModel) async {
    await initLocalStorage();
    var localStr = localStorage.getItem(_localKey);

    // 第一次加载
    if (localStr == null) return await _initFont(fontModel);

    // 获取本地初始化的字体，如果本地初始化的字体和传递的fontModel不一致，说明用户更改了fontModel，
    // 那么我们需要重新加载用户传递的fontModel
    var initialLocalStr = localStorage.getItem(_initialLocalKey);

    if (initialLocalStr == null) {
      initialFontModel = fontModel;
      localStorage.setItem(
          _initialLocalKey, jsonEncode(initialFontModel.toJson()));
    } else {
      initialFontModel = FontModel.fromJson(
          (jsonDecode(initialLocalStr) as Map).cast<String, dynamic>());
      if (initialFontModel.fontFamily != fontModel.fontFamily) {
        initialFontModel = fontModel;
        localStorage.setItem(
            _initialLocalKey, jsonEncode(initialFontModel.toJson()));
        return await _initFont(fontModel);
      }
    }

    try {
      FontModel localFontModel = FontModel.fromJson(
          (jsonDecode(localStr) as Map).cast<String, dynamic>());
      await loadFont(localFontModel);
    } catch (error) {
      e(error, '本地缓存字体加载异常');
      await _initFont(fontModel);
    }
  }

  static Future<void> _initFont(FontModel fontModel) async {
    bool success = await loadFont(fontModel);
    if (success) {
      localStorage.setItem(_initialLocalKey, jsonEncode(fontModel.toJson()));
    }
  }

  /// 字体族列表，当我们的[fontFamily]为空时，flutter会根据此列表依次匹配字体
  static List<String>? get fontFamilyFallback {
    // 在 mac 上若不指定苹方字体，那么中文字重将失效
    if (PlatformUtil.isMacOS || PlatformUtil.isIOS) {
      return ['.AppleSystemUIFont', 'PingFang SC'];
    } else if (PlatformUtil.isWindows) {
      return ['Microsoft YaHei', '微软雅黑'];
    } else {
      return null;
    }
  }

  /// 动态加载全局字体，如果加载成功则返回true
  ///
  /// 注意：此函数不会更新你的页面，你应当使用状态管理保存当前选中的字体，
  /// 每次加载完字体后通过[FontUtil.fontFamily]变量更新你的状态
  static Future<bool> loadFont([FontModel? fontModel]) async {
    fontModel ??= FontModel.systemFont;
    // 如果加载的fontUrl、fontWeights都为空，则那么跳过网络解析
    if (fontModel.fontUrl == null &&
        (fontModel.fontWeights == null || fontModel.fontWeights!.isEmpty)) {
      currentFontModel = fontModel;
      localStorage.setItem(_localKey, jsonEncode(fontModel.toJson()));
      _loadFonts.add(fontModel.fontFamily);
      return true;
    } else {
      List<String> fontFamilyList = [];
      List<ByteData> fontByteDataList = [];
      if (fontModel.fontUrl != null) {
        // 如果当前字体已加载，那么跳过网络解析
        if (!loadFonts.contains(fontModel.fontFamily)) {
          var result = await generalLoadNetworkFont(fontModel.fontUrl!);
          // 加载网络字体失败，返回false结束运行
          if (result == null) return false;
          fontFamilyList.add(fontModel.fontFamily);
          fontByteDataList.add(result);
        }
      } else {
        List<int> needLoadFonts = [];
        for (int key in fontModel.fontWeights!.keys) {
          if (!loadFonts.contains('${fontModel.fontFamily}_$key')) {
            needLoadFonts.add(key);
          }
        }
        var result =
            await Future.wait(needLoadFonts.map((key) => generalLoadNetworkFont(
                  fontModel!.fontWeights![key]!,
                  fontModel: fontModel,
                  localKey: '${fontModel.fontFamily}_$key',
                )));
        if (result.contains(null)) return false;
        fontFamilyList.addAll(
            needLoadFonts.map((key) => '${fontModel!.fontFamily}_$key'));
        fontByteDataList.addAll(result.cast<ByteData>());
      }
      // 注入字体失败，返回false结束运行
      if (!(await _loadFont(fontModel.fontFamily, fontByteDataList))) {
        return false;
      }
      currentFontModel = fontModel;
      localStorage.setItem(_localKey, jsonEncode(fontModel.toJson()));
      _loadFonts.addAll(fontFamilyList);
      return true;
    }
  }

  /// 当使用系统字体时，优化某些设备的[FontWeight]，例如：
  /// * 小米 - normal: w500
  /// * 华为 - bold: w600
  ///
  /// 提示：此函数是可选的，它只作用于[FontUtil.normal]、[FontUtil.medium]、[FontUtil.bold]等变量
  static Future<void> initSystemFontWeight({
    FontWeight? normal,
    FontWeight? medium,
    FontWeight? bold,
  }) async {
    // if (kIsWeb) return;
    // await DeviceUtil.init();
    // __normal = normal;
    // __medium = medium;
    // __bold = bold;
    // if (PlatformUtil.isAndroid) {
    //   // 小米手机400字重太细了，将normal设置为500
    //   if (DeviceUtil.isXiaomi) {
    //     _setFontWeight(FontWeight.w500, FontWeight.w500, FontWeight.bold);
    //   }
    //   // 华为手机700字重太重了，将bold设置为600
    //   else if (DeviceUtil.isHUAWEI) {
    //     _setFontWeight(FontWeight.w400, FontWeight.w500, FontWeight.w600);
    //   }
    // }
    // // Windows平台不包含w500字重，中等字重调整为400
    // else if (PlatformUtil.isWindows) {
    //   _setFontWeight(FontWeight.normal, FontWeight.normal, FontWeight.bold);
    // }
  }

  /// 如果是系统字体，使用的 normal 字重，如果执行了[initSystemFontWeight]，该值会在部分设备上使用[FontWeight.w500]字重
  static FontWeight? _normal;

  /// 如果是系统字体，使用的 w500 字重，如果执行了[initSystemFontWeight]，该值会在部分设备上使用[FontWeight.w400]字重
  static FontWeight? _medium;

  /// 如果是系统字体，使用的 bold 字重，如果执行了[initSystemFontWeight]，会在部分设备上使用[FontWeight.w600]字重
  static FontWeight? _bold;

  static FontWeight? __normal;
  static FontWeight? __medium;
  static FontWeight? __bold;

  static void _setFontWeight(
      FontWeight normalFont, FontWeight mediumFont, FontWeight boldFont) {
    _normal = __normal ?? normalFont;
    _medium = __medium ?? mediumFont;
    _bold = __bold ?? boldFont;
  }
}

/// 加载字体
Future<bool> _loadFont(String fontFamily, List<ByteData> byteDataList) async {
  if (byteDataList.isEmpty) return true;
  try {
    final fontLoader = FontLoader(fontFamily);
    for (var byteData in byteDataList) {
      fontLoader.addFont(Future.value(byteData));
    }
    await fontLoader.load();
    return true;
  } catch (error) {
    e(error, 'FontLoader加载字体失败');
    return false;
  }
}
