part of 'font.dart';

/// assets资产包提供的预设字体
class FlutterFontPreset {
  FlutterFontPreset._();

  /// 系统字体
  static const systemFont = FlutterFontModel(fontFamily: '');

  /// 项目初始化的字体
  static get initialFont => FlutterFont._initialFont;

  /// 谷歌中文字体
  static const notoSansSC = FlutterFontModel(fontFamily: 'NotoSansSC');
}
