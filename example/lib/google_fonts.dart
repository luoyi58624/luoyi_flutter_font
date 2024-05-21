import 'package:flutter/material.dart';
import 'package:luoyi_flutter_font/luoyi_flutter_font.dart';

/// 谷歌在线字体
class GoogleFontModels {
  GoogleFontModels._();

  /// 谷歌在线字体通用字体
  static String _url(String fileHash) => 'https://fonts.gstatic.com/s/a/$fileHash.ttf';

  /// 谷歌中文字体
  static FlutterFontModel notoSansSc(List<FontWeight> fontWeights) {
    return FlutterFontModel(
      fontFamily: 'NotoSansSC',
      fontWeights: _GoogleFonts._notoSansSc.filterFromKeys((fontWeights).map((e) => e.value).toList()),
    );
  }

  static FlutterFontModel longCang() => FlutterFontModel(
        fontFamily: 'LongCang',
        fontUrl: _url('f626a05f45d156332017025fc68902a92f57f51ac57bb4a79097ee7bb1a97352'),
      );
}

class _GoogleFonts {
  _GoogleFonts._();

  static String _url(String fileHash) => GoogleFontModels._url(fileHash);

  static final Map<int, String> _notoSansSc = {
    FontWeight.w100.value: _url('f1b8c2a287d23095abd470376c60519c9ff650ae8744b82bf76434ac5438982a'),
    FontWeight.w200.value: _url('cba9bb657b61103aeb3cd0f360e8d3958c66febf59fbf58a4762f61e52015d36'),
    FontWeight.w300.value: _url('4cdbb86a1d6eca92c7bcaa0c759593bc2600a153600532584a8016c24eaca56c'),
    FontWeight.w400.value: _url('eacedb2999b6cd30457f3820f277842f0dfbb28152a246fca8161779a8945425'),
    FontWeight.w500.value: _url('5383032c8e54fc5fa09773ce16483f64d9cdb7d1f8e87073a556051eb60f8529'),
    FontWeight.w600.value: _url('85c00dac0627c2c0184c24669735fad5adbb4f150bcb320c05620d46ed086381'),
    FontWeight.w700.value: _url('a7a29b6d611205bb39b9a1a5c2be5a48416fbcbcfd7e6de98976e73ecb48720b'),
    FontWeight.w800.value: _url('038de57b1dc5f6428317a8b0fc11984789c25f49a9c24d47d33d2c03e3491d28'),
    FontWeight.w900.value: _url('501582a5e956ab1f4d9f9b2d683cf1646463eea291b21f928419da5e0c5a26eb'),
  };
}

extension DartMapExtension<K, V> on Map<K, V> {
  /// 根据keys集合，返回一个新的Map
  Map<K, V> filterFromKeys(List<K> keys) {
    Map<K, V> newMap = {};
    for (K key in keys) {
      newMap[key] = this[key] as V;
    }
    return newMap;
  }
}
