part of 'font.dart';

class FontModel {
  /// 字体族名
  /// * 如果为空字符串，则表示加载系统默认字体
  /// * 如果你需要加载静态捆绑的字体，只需设置[fontFamily]即可
  final String fontFamily;

  /// 单个字体文件地址
  final String? fontUrl;

  /// 不同字重集合，key-[FontWidget.value]，value-字体文件地址
  ///
  /// 如果fontUrl、fontWidgets同时存在，则优先取fontWidgets
  final Map<int, String>? fontWeights;

  /// 从网络加载的字体模型
  const FontModel({
    required this.fontFamily,
    this.fontUrl,
    this.fontWeights,
  });

  factory FontModel.fromJson(Map<String, dynamic> json) {
    Map<int, String>? fontWeights;
    if (json["fontWeights"] != null) {
      fontWeights = json["fontWeights"]
          .map((key, value) => MapEntry(int.parse(key), value))
          .cast<int, String>();
    }
    return FontModel(
      fontFamily: json["fontFamily"],
      fontUrl: json["fontUrl"],
      fontWeights: fontWeights,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fontFamily": fontFamily,
      "fontUrl": fontUrl,
      "fontWeights":
          fontWeights?.map((key, value) => MapEntry(key.toString(), value)),
    };
  }

  /// 系统字体
  static const FontModel systemFont = FontModel(fontFamily: '');

  /// 项目硬编码初始化的字体
  static FontModel get initialFont => initialFontModel;

  /// 加载谷歌中文字体，包含100-900字重
  static FontModel notoSansSc([List<FontWeight>? fontWeights]) {
    return FontModel(
      fontFamily: 'NotoSansSC',
      fontWeights: _GoogleFonts.notoSansSc
          .filterFromKeys((fontWeights ?? []).map((e) => e.value).toList()),
    );
  }

  /// 谷歌斜体中文字体
  static FontModel longCang() => FontModel(
        fontFamily: 'LongCang',
        fontUrl: _GoogleFonts.baseUrl(
            'f626a05f45d156332017025fc68902a92f57f51ac57bb4a79097ee7bb1a97352'),
      );
}

class _GoogleFonts {
  _GoogleFonts._();

  static String baseUrl(String fileHash) =>
      'https://fonts.gstatic.com/s/a/$fileHash.ttf';

  static final Map<int, String> notoSansSc = {
    FontWeight.w100.value: baseUrl(
        'f1b8c2a287d23095abd470376c60519c9ff650ae8744b82bf76434ac5438982a'),
    FontWeight.w200.value: baseUrl(
        'cba9bb657b61103aeb3cd0f360e8d3958c66febf59fbf58a4762f61e52015d36'),
    FontWeight.w300.value: baseUrl(
        '4cdbb86a1d6eca92c7bcaa0c759593bc2600a153600532584a8016c24eaca56c'),
    FontWeight.w400.value: baseUrl(
        'eacedb2999b6cd30457f3820f277842f0dfbb28152a246fca8161779a8945425'),
    FontWeight.w500.value: baseUrl(
        '5383032c8e54fc5fa09773ce16483f64d9cdb7d1f8e87073a556051eb60f8529'),
    FontWeight.w600.value: baseUrl(
        '85c00dac0627c2c0184c24669735fad5adbb4f150bcb320c05620d46ed086381'),
    FontWeight.w700.value: baseUrl(
        'a7a29b6d611205bb39b9a1a5c2be5a48416fbcbcfd7e6de98976e73ecb48720b'),
    FontWeight.w800.value: baseUrl(
        '038de57b1dc5f6428317a8b0fc11984789c25f49a9c24d47d33d2c03e3491d28'),
    FontWeight.w900.value: baseUrl(
        '501582a5e956ab1f4d9f9b2d683cf1646463eea291b21f928419da5e0c5a26eb'),
  };
}
