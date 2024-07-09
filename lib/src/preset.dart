part of 'font.dart';

/// assets资产包提供的预设字体
class FontPreset {
  FontPreset._();

  /// 系统字体
  static const systemFont = FontModel(fontFamily: '');

  /// 项目初始化的字体
  static get initialFont => FlutterFont._initialFont;

  /// 谷歌中文字体
  static const notoSansSC = FontModel(fontFamily: 'NotoSansSC');
}
