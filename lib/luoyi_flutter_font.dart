library luoyi_flutter_font;

import 'dart:collection';
import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:localstorage/localstorage.dart';
import 'package:luoyi_dart_base/luoyi_dart_base.dart';
import 'package:mini_getx/mini_getx.dart';

import 'src/font_web.dart' if (dart.library.io) 'src/font_io.dart';

part 'src/device.dart';

part 'src/model.dart';

/// Flutter字体工具类
class FlutterFont {
  FlutterFont._();

  static bool _isInit = false;

  /// 系统字体
  static const FlutterFontModel systemFont = FlutterFontModel(fontFamily: '');

  static late FlutterFontModel _initialFontModel;

  /// [_initialFontModel]本地存储键，如果用户在[init]中更改了[FlutterFontModel]，则重新加载新的字体
  static const String _initialLocalKey = 'initial_font_family';

  /// [fontFamily]本地存储键
  static const String localKey = 'font_family';

  /// 当前加载的全局字体模型
  static FlutterFontModel _currentFontModel = systemFont;

  static final HashSet<String> _loadFonts = HashSet();

  /// 已加载的字体
  static HashSet<String> get loadFonts => _loadFonts;

  /// 当前选择的全局字体，当调用[loadFont]函数加载新字体成功时，此变量将会指向新字体的fontFamily
  ///
  /// 提示：null 表示系统字体
  static String? get fontFamily => _currentFontModel.fontFamily == '' ? null : _currentFontModel.fontFamily;

  static const FontWeight _normal = FontWeight.normal;

  /// 如果是系统字体，使用的 normal 字重
  static FontWeight? __normal;

  /// 基础字重字体，它对应[FontWeight.normal]
  ///
  /// 注意：如果执行[initSystemFontWeight]，该值会在部分设备上使用[FontWeight.w500]字重
  static FontWeight get normal => fontFamily == null ? (__normal ?? _normal) : _normal;

  static const FontWeight _medium = FontWeight.w500;

  /// 如果是系统字体，使用的 medium 字重
  static FontWeight? __medium;

  /// 中等字重字体，它对应[FontWeight.w500]
  ///
  /// 注意：如果执行[initSystemFontWeight]，该值会在部分设备上使用[FontWeight.w400]字重
  static FontWeight get medium => fontFamily == null ? (__medium ?? _medium) : _medium;

  static const FontWeight _bold = FontWeight.bold;

  /// 如果是系统字体，使用的 bold 字重
  static FontWeight? __bold;

  /// 粗体字重字体，它对应[FontWeight.bold]
  ///
  /// 注意：如果执行[initSystemFontWeight]，该值会在部分设备上使用[FontWeight.w600]字重
  static FontWeight get bold => fontFamily == null ? (__bold ?? _bold) : _bold;

  /// 初始化字体，默认情况下会根据不同平台加载字体，例如：Android、IOS，它们的系统字体本身就很优秀，所以它们将直接使用系统字体，
  /// 但是像 Windows、Web Canvaskit，它们的字体渲染就非常差劲，所以会使用自定义字体渲染
  ///
  /// * return fontFamilyFallback - 根据平台返回合适的字族集合
  ///
  /// 以下是所平台加载的字体：
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
  static Future<List<String>?> init({
    FlutterFontModel? fontModel,
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
      if (fontModel != null && fontModel.fontFamily != '') {
        return await initFont(fontModel);
      } else {
        // 如果不传递自定义字体，则加载谷歌在线字体，这仅限于上面指定 fontModel 的平台
        return await initFont(const FlutterFontModel(fontFamily: 'NotoSansSC', fontWeights: {
          500: 'https://fonts.gstatic.com/s/a/5383032c8e54fc5fa09773ce16483f64d9cdb7d1f8e87073a556051eb60f8529.ttf',
          700: 'https://fonts.gstatic.com/s/a/a7a29b6d611205bb39b9a1a5c2be5a48416fbcbcfd7e6de98976e73ecb48720b.ttf',
        }));
      }
    } else {
      return await initFont();
    }
  }

  /// 初始化全局默认字体
  static Future<List<String>?> initFont([FlutterFontModel? fontModel]) async {
    await initLocalStorage();
    var localStr = localStorage.getItem(localKey);
    // 加载本地字体数据是否成功，如果已经加载了本地数据，则不会执行初始化
    bool loadLocalDataSuccess = false;
    if (localStr != null) {
      // 是否允许加载本地字体数据，如果传递的fontModel和本地的不一致，那么说明用户更改了fontModel，则禁止加载本地数据
      bool allowLoadLocalFont = true;
      var initialLocalStr = localStorage.getItem(_initialLocalKey);
      if (initialLocalStr != null) {
        _initialFontModel = FlutterFontModel.fromJson((jsonDecode(initialLocalStr) as Map).cast<String, dynamic>());
        if (_initialFontModel.fontFamily != fontModel?.fontFamily) {
          if (!(_initialFontModel.fontFamily == '' && (fontModel == null || fontModel.fontFamily == ''))) {
            allowLoadLocalFont = false;
          }
        }
      } else {
        _initialFontModel = fontModel ?? systemFont;
        localStorage.setItem(_initialLocalKey, jsonEncode(_initialFontModel.toJson()));
      }
      if (allowLoadLocalFont) {
        late FlutterFontModel localFontModel;
        try {
          localFontModel = FlutterFontModel.fromJson((jsonDecode(localStr) as Map).cast<String, dynamic>());
          await loadFont(localFontModel);
          loadLocalDataSuccess = true;
        } catch (error) {
          w(error, '字体缓存数据解析错误');
        }
      }
    }
    if (!loadLocalDataSuccess) {
      _initialFontModel = fontModel ?? systemFont;
      localStorage.setItem(_initialLocalKey, jsonEncode(_initialFontModel.toJson()));
      await loadFont(_initialFontModel);
    }
    _isInit = true;
    return fontFamily == null ? _fontFamilyFallback : null;
  }

  /// 优先加载的字体族列表，只有当[fontFamily]为系统字体时才生效
  static List<String>? get _fontFamilyFallback {
    // 暂时只需要处理 mac 平台，在 mac 上若不指定苹方字体，那么中文字重将失效
    if (GetPlatform.isMacOS || GetPlatform.isIOS) {
      return ['.AppleSystemUIFont', 'PingFang SC'];
    } else if (GetPlatform.isWindows) {
      return ['Microsoft YaHei', '微软雅黑'];
    } else {
      return null;
    }
  }

  /// 动态加载全局字体，如果加载成功则返回true
  ///
  /// 注意：此函数不会更新你的页面，你应当使用状态管理保存当前选中的字体，
  /// 每次加载完字体后通过[FontUtil.fontFamily]变量更新你的状态
  static Future<bool> loadFont([FlutterFontModel? fontModel]) async {
    fontModel ??= systemFont;
    // 如果加载的fontUrl、fontWeights都为空，则那么跳过网络解析
    if (fontModel.fontUrl == null && (fontModel.fontWeights == null || fontModel.fontWeights!.isEmpty)) {
      _currentFontModel = fontModel;
      localStorage.setItem(localKey, jsonEncode(fontModel.toJson()));
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
        for (int key in fontModel.fontWeights!.keys) {
          // 包含字重已加载的fontFamily键
          String loadKey = '${fontModel.fontFamily}_$key';
          if (!loadFonts.contains(loadKey)) {
            var result = await generalLoadNetworkFont(
              fontModel.fontWeights![key]!,
              fontModel: fontModel,
              localKey: loadKey,
            );
            if (result == null) return false;
            fontFamilyList.add(loadKey);
            fontByteDataList.add(result);
          }
        }
      }
      // 注入字体失败，返回false结束运行
      if (!(await _loadFont(fontModel.fontFamily, fontByteDataList))) return false;
      _currentFontModel = fontModel;
      localStorage.setItem(localKey, jsonEncode(fontModel.toJson()));
      _loadFonts.addAll(fontFamilyList);
      return true;
    }
  }

  /// 当使用系统字体时，优化某些设备的[FontWeight]
  /// * 小米 - normal: w500
  /// * 华为 - bold: w600
  ///
  /// 提示：此函数是可选的，它只作用于[FontUtil.normal]、[FontUtil.medium]、[FontUtil.bold]等变量，它默认在[initApp]函数中初始化，
  /// 如果需要自定义，可以再次执行此函数覆盖上一次配置
  static Future<void> initSystemFontWeight({
    FontWeight? normal,
    FontWeight? medium,
    FontWeight? bold,
  }) async {
    if (kIsWeb) return; // web不考虑
    assert(_isInit, '执行 initSystemFontWeight 前请先初始化字体');
    if (fontFamily == null) {
      await _DeviceUtil.init();
      ___normal = normal;
      ___medium = medium;
      ___bold = bold;
      if (GetPlatform.isAndroid) {
        // 小米手机400字重太细了，将normal设置为500
        if (_DeviceUtil.isXiaomi) {
          _setFontWeight(FontWeight.w500, FontWeight.w500, FontWeight.bold);
        }
        // 华为手机700字重太重了，将bold设置为600
        else if (_DeviceUtil.isHUAWEI) {
          _setFontWeight(FontWeight.w400, FontWeight.w500, FontWeight.w600);
        }
      }
      // Windows平台不包含w500字重，中等字重调整为400
      else if (GetPlatform.isWindows) {
        _setFontWeight(FontWeight.normal, FontWeight.normal, FontWeight.bold);
      }
    }
  }

  static FontWeight? ___normal;
  static FontWeight? ___medium;
  static FontWeight? ___bold;

  static void _setFontWeight(FontWeight normalFont, FontWeight mediumFont, FontWeight boldFont) {
    __normal = ___normal ?? normalFont;
    __medium = ___medium ?? mediumFont;
    __bold = ___bold ?? boldFont;
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
